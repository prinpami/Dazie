import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/conversation_repository.dart';
import '../data/message_repository.dart';
import '../data/peer_repository.dart';
import '../data/profile_repository.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/local_profile.dart';
import '../models/peer_profile.dart';
import 'nearby_event.dart';
import 'nearby_packet.dart';
import 'nearby_failure.dart';
import 'nearby_service.dart';

class ChatSyncService extends ChangeNotifier {
  ChatSyncService({
    required this.nearby,
    required this.profiles,
    required this.peers,
    required this.conversations,
    required this.messages,
  }) {
    _subscription = nearby.events.listen(_queueEvent);
  }

  final NearbyService nearby;
  final ProfileRepository profiles;
  final PeerRepository peers;
  final ConversationRepository conversations;
  final MessageRepository messages;
  StreamSubscription<NearbyEvent>? _subscription;
  Future<void>? _eventQueue;
  Completer<void>? _activeEventHandler;
  Future<Conversation>? _hostOperation;
  final Map<String, String> _endpointGroups = {};
  final Map<String, String> _endpointPeers = {};
  final Map<String, NearbyEvent> _requests = {};
  final Map<String, Timer> _timeouts = {};
  LocalProfile? _profile;
  Conversation? _active;
  bool _hosting = false;
  bool _searching = false;
  bool _busy = false;
  bool _closed = false;
  bool _stopping = false;
  int _generation = 0;
  String? _connecting;
  NearbyFailure? _error;

  Conversation? get activeConversation => _active;
  Conversation? get hostedConversation => _hosting ? _active : null;
  bool get isHosting => _hosting;
  bool get isSearching => _searching;
  bool get isBusy => _busy || _connecting != null;
  String? get connectingEndpoint => _connecting;
  NearbyFailure? get error => _error;
  List<NearbyEvent> get requests => _requests.values.toList();
  int connectionCount(String groupId) => _endpointGroups.entries
      .where(
        (entry) =>
            entry.value == groupId &&
            nearby.connectedEndpointIds.contains(entry.key),
      )
      .length;
  bool get hasSession => _active != null || _hosting;

  void _queueEvent(NearbyEvent event) {
    if (_stopping || _closed) return;
    final generation = _generation;
    final previous = _eventQueue;
    final next = previous == null
        ? Future<void>.sync(() => _dispatchEvent(event, generation))
        : previous.then((_) => _dispatchEvent(event, generation));
    _eventQueue = next.catchError((Object error) {
      _report(error);
    });
  }

  Future<void> _dispatchEvent(NearbyEvent event, int generation) async {
    if (_closed || _stopping || generation != _generation) return;
    final handler = Completer<void>();
    _activeEventHandler = handler;
    try {
      await _handleEvent(event);
    } finally {
      if (identical(_activeEventHandler, handler)) {
        _activeEventHandler = null;
      }
      if (!handler.isCompleted) handler.complete();
    }
  }

  void _changed() {
    if (!_closed) notifyListeners();
  }

  void clearError() {
    _error = null;
    _changed();
  }

  void _report(Object error) {
    _error = NearbyFailure.from(error);
    _changed();
  }

  void _requireIdle() {
    if (isBusy) {
      throw const NearbyFailure(
        'Please wait for the current connection attempt.',
      );
    }
    if (hasSession) {
      throw const NearbyFailure(
        'Leave the current nearby session before joining or hosting another group.',
      );
    }
  }

  Future<Conversation> startGroup(String name, LocalProfile profile) async {
    if (_hostOperation != null) return _hostOperation!;
    if (_hosting && _active != null) return _active!;
    _requireIdle();
    _hostOperation = _startGroup(name, profile);
    try {
      return await _hostOperation!;
    } finally {
      _hostOperation = null;
    }
  }

  Future<Conversation> _startGroup(String name, LocalProfile profile) async {
    _busy = true;
    _error = null;
    _profile = profile;
    _changed();
    try {
      final cleanName = name.trim();
      if (cleanName.isEmpty) throw const NearbyFailure('Enter a group name.');
      await nearby.stopFinding();
      _searching = false;
      // Do not persist a new group until permission checks and advertising succeed.
      await nearby.startHosting(cleanName);
      _active =
          await conversations.findOwnedGroup(cleanName, profile.id) ??
          await conversations.createGroup(name: cleanName, ownerId: profile.id);
      _hosting = true;
      return _active!;
    } catch (error) {
      try {
        await nearby.stop();
      } catch (_) {}
      _hosting = false;
      _active = null;
      _report(error);
      rethrow;
    } finally {
      _busy = false;
      _changed();
    }
  }

  Future<void> findGroups(LocalProfile profile) async {
    if (_searching) return;
    _requireIdle();
    _busy = true;
    _error = null;
    _profile = profile;
    _changed();
    try {
      await nearby.startFinding(profile.username);
      _searching = true;
    } catch (error) {
      _report(error);
      rethrow;
    } finally {
      _busy = false;
      _changed();
    }
  }

  Future<void> stopFinding() async {
    if (_busy) return;
    _busy = true;
    _changed();
    try {
      await nearby.stopFinding();
      _searching = false;
    } catch (error) {
      _report(error);
      rethrow;
    } finally {
      _busy = false;
      _changed();
    }
  }

  Future<void> connect(String endpointId, LocalProfile profile) async {
    _requireIdle();
    _connecting = endpointId;
    _error = null;
    _profile = profile;
    _changed();
    try {
      await nearby.connect(endpointId, profile.username);
      _searching = false;
      // The timeout includes verification and group sync, not just the radio link.
      if (_connecting == endpointId) _startTimeout(endpointId);
    } catch (error) {
      _connecting = null;
      _searching = false;
      _report(error);
      rethrow;
    } finally {
      _changed();
    }
  }

  void _startTimeout(String endpointId) {
    _timeouts.remove(endpointId)?.cancel();
    _timeouts[endpointId] = Timer(const Duration(seconds: 45), () async {
      _forgetEndpoint(endpointId);
      _report(
        const NearbyFailure(
          'Connection timed out. Accept the matching code on both phones, then try again.',
        ),
      );
      try {
        await nearby.disconnect(endpointId);
      } catch (_) {}
    });
  }

  Future<void> acceptConnection(String endpointId) async {
    if (!_requests.containsKey(endpointId)) return;
    _requests.remove(endpointId);
    _changed();
    try {
      await nearby.accept(endpointId);
    } catch (error) {
      _forgetEndpoint(endpointId);
      _report(error);
      rethrow;
    }
  }

  Future<void> rejectConnection(String endpointId) async {
    _forgetEndpoint(endpointId);
    try {
      await nearby.reject(endpointId);
    } catch (error) {
      _report(error);
      rethrow;
    }
  }

  void _forgetEndpoint(String id) {
    _timeouts.remove(id)?.cancel();
    _requests.remove(id);
    _endpointGroups.remove(id);
    _endpointPeers.remove(id);
    if (_connecting == id) _connecting = null;
    _changed();
  }

  Future<void> stopNearby() async {
    if (_busy) {
      throw const NearbyFailure('Wait for the current operation to finish.');
    }
    _busy = true;
    _stopping = true;
    _generation++;
    _error = null;
    _changed();
    try {
      // Let the in-flight handler finish before shutting down the transport.
      // Events queued before this stop are discarded by the generation check.
      await _activeEventHandler?.future;
      await nearby.stop();
      for (final timer in _timeouts.values) {
        timer.cancel();
      }
      _timeouts.clear();
      _requests.clear();
      _connecting = null;
      _endpointGroups.clear();
      _endpointPeers.clear();
      _active = null;
      _hosting = false;
      _searching = false;
    } catch (error) {
      // Keep session state so the user can retry a partially failed shutdown.
      _report(error);
      rethrow;
    } finally {
      _stopping = false;
      _busy = false;
      _changed();
    }
  }

  Future<void> deleteConversation(String groupId) async {
    if (_active?.id == groupId) await stopNearby();
    // Tombstones make queued and late packets harmless after local deletion.
    await conversations.deleteConversation(groupId);
  }

  Future<ChatMessage> sendMessage({
    required String groupId,
    required String text,
    required LocalProfile profile,
  }) async {
    _profile = profile;
    final message = await messages.createMessage(
      groupId: groupId,
      senderId: profile.id,
      sender: profile.username,
      text: text,
      isMine: true,
    );
    await _sendMessage(message);
    return message;
  }

  Future<void> _handleEvent(NearbyEvent event) async {
    switch (event.type) {
      case NearbyEventType.connectionRequest:
        if (!_hosting && _connecting != event.endpointId) {
          await nearby.reject(event.endpointId);
          return;
        }
        _requests[event.endpointId] = event;
        _startTimeout(event.endpointId);
        _changed();
        return;
      case NearbyEventType.connected:
        if (!_hosting && _connecting != event.endpointId) {
          await nearby.disconnect(event.endpointId);
          return;
        }
        _requests.remove(event.endpointId);
        _changed();
        await _sendHello(event.endpointId);
        return;
      case NearbyEventType.disconnected:
        _forgetEndpoint(event.endpointId);
        return;
      case NearbyEventType.connectionFailed:
        _forgetEndpoint(event.endpointId);
        _report(NearbyFailure(event.message));
        return;
      case NearbyEventType.packet:
        if (!nearby.connectedEndpointIds.contains(event.endpointId)) return;
        break;
      case NearbyEventType.peerFound:
      case NearbyEventType.peerLost:
        return;
    }
    final packet = NearbyPacket.validate(event.packet);
    final profile = _profile ?? await profiles.getCurrentProfile();
    if (packet == null || profile == null) return;
    _profile = profile;
    switch (packet['type']) {
      case 'hello':
        await _handleHello(event.endpointId, packet, profile);
      case 'group':
        await _handleGroup(event.endpointId, packet, profile);
      case 'message':
        await _handleMessage(event.endpointId, packet, profile);
      case 'ack':
        final id = packet['messageId'];
        if (id is! String) return;
        final message = await messages.getMessage(id);
        if (message != null &&
            message.senderId == profile.id &&
            _endpointGroups[event.endpointId] == message.groupId) {
          await messages.updateDeliveryStatus(id, 'delivered');
        }
    }
  }

  Future<void> _sendPacket(String endpointId, Map<String, Object?> packet) =>
      nearby.sendPacket(endpointId, {
        'version': NearbyPacket.version,
        ...packet,
      });

  Future<void> _sendHello(String endpointId) async {
    final profile = _profile ?? await profiles.getCurrentProfile();
    if (profile == null) return;
    await _sendPacket(endpointId, {
      'type': 'hello',
      'peerId': profile.id,
      'displayName': profile.username,
    });
  }

  Future<void> _handleHello(
    String endpointId,
    Map<String, Object?> packet,
    LocalProfile profile,
  ) async {
    final peerId = packet['peerId'];
    final name = packet['displayName'];
    if (peerId is! String || name is! String || peerId == profile.id) return;
    if (_endpointPeers[endpointId] != null &&
        _endpointPeers[endpointId] != peerId) {
      return;
    }
    _endpointPeers[endpointId] = peerId;
    await peers.savePeer(
      PeerProfile(
        id: peerId,
        displayName: name,
        lastSeenAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    final group = hostedConversation;
    if (group == null) return;
    await conversations.addMember(group.id, peerId);
    _active = await conversations.getConversation(group.id);
    _endpointGroups[endpointId] = group.id;
    _timeouts.remove(endpointId)?.cancel();
    _changed();
    // Send membership to everyone before relaying messages from the new member.
    for (final id in _groupEndpoints(group.id)) {
      await _sendGroup(id, _active!);
    }
    for (final message in await messages.getLatestMessages(group.id)) {
      await _sendPacket(endpointId, {
        'type': 'message',
        'message': message.toMap(),
      });
    }
    await _sendPending(group.id);
  }

  Future<void> _handleGroup(
    String endpointId,
    Map<String, Object?> packet,
    LocalProfile profile,
  ) async {
    if (_hosting ||
        (_connecting != endpointId &&
            !_endpointGroups.containsKey(endpointId))) {
      return;
    }
    final id = packet['groupId'];
    final name = packet['name'];
    final rawMembers = packet['memberIds'];
    if (id is! String || name is! String || rawMembers is! List) return;
    final members = rawMembers.whereType<String>().toSet().toList();
    final peerId = _endpointPeers[endpointId];
    if (!members.contains(profile.id) ||
        peerId == null ||
        !members.contains(peerId)) {
      return;
    }
    final ownerId = packet['ownerId'] as String? ?? members.firstOrNull;
    if (ownerId != peerId) return;
    if (_active != null && _active!.id != id) return;
    if (await conversations.isDeleted(id)) {
      if (_connecting != endpointId) return;
      await conversations.allowRejoin(id);
    }
    final old = await conversations.getConversation(id);
    final now = DateTime.now().toUtc().toIso8601String();
    _active = Conversation(
      id: id,
      name: name,
      ownerId: ownerId!,
      memberIds: members,
      createdAt: old?.createdAt ?? now,
      updatedAt: old?.updatedAt ?? now,
      lastMessage: old?.lastMessage ?? '',
    );
    await conversations.saveConversation(_active!);
    _endpointGroups[endpointId] = id;
    _connecting = null;
    _timeouts.remove(endpointId)?.cancel();
    _changed();
    await _sendPending(id);
  }

  Iterable<String> _groupEndpoints(String groupId) => _endpointGroups.entries
      .where(
        (entry) =>
            entry.value == groupId &&
            nearby.connectedEndpointIds.contains(entry.key),
      )
      .map((entry) => entry.key)
      .toList();

  Future<void> _handleMessage(
    String endpointId,
    Map<String, Object?> packet,
    LocalProfile profile,
  ) async {
    final raw = packet['message'];
    if (raw is! Map) return;
    ChatMessage source;
    try {
      source = ChatMessage.fromMap(Map<String, Object?>.from(raw));
    } catch (_) {
      return;
    }
    if (_endpointGroups[endpointId] != source.groupId) return;
    final group = await conversations.getConversation(source.groupId);
    if (group == null || !group.memberIds.contains(source.senderId)) return;
    if (_hosting && source.senderId != _endpointPeers[endpointId]) return;
    final message = ChatMessage(
      id: source.id,
      groupId: source.groupId,
      senderId: source.senderId,
      sender: source.sender,
      text: source.text,
      createdAt: source.createdAt,
      isMine: source.senderId == profile.id,
      deliveryStatus: source.senderId == profile.id ? 'delivered' : 'received',
    );
    final isNew = await messages.saveMessage(message);
    await _sendPacket(endpointId, {'type': 'ack', 'messageId': message.id});
    if (isNew && _hosting) {
      for (final id in _groupEndpoints(message.groupId)) {
        if (id == endpointId) continue;
        try {
          await _sendPacket(id, {
            'type': 'message',
            'message': message.toMap(),
          });
        } catch (_) {
          /* History sync retries after reconnect. */
        }
      }
    }
  }

  Future<void> _sendMessage(ChatMessage message) async {
    var sent = false;
    for (final id in _groupEndpoints(message.groupId)) {
      try {
        await _sendPacket(id, {'type': 'message', 'message': message.toMap()});
        sent = true;
      } catch (_) {
        /* Keep pending for reconnection. */
      }
    }
    if (sent) await messages.updateDeliveryStatus(message.id, 'sent');
  }

  Future<void> _sendGroup(String endpointId, Conversation group) =>
      _sendPacket(endpointId, {
        'type': 'group',
        'groupId': group.id,
        'name': group.name,
        'ownerId': group.ownerId,
        'memberIds': group.memberIds,
      });

  Future<void> _sendPending(String groupId) async {
    for (final message in await messages.getPendingMessages(groupId)) {
      if (message.senderId == _profile?.id) await _sendMessage(message);
    }
  }

  Future<void> close() async {
    _closed = true;
    for (final timer in _timeouts.values) {
      timer.cancel();
    }
    await _subscription?.cancel();
    final activeHandler = _activeEventHandler;
    if (activeHandler != null) await activeHandler.future;
    super.dispose();
  }
}
