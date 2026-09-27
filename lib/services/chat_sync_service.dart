import 'dart:async';

import '../data/conversation_repository.dart';
import '../data/message_repository.dart';
import '../data/peer_repository.dart';
import '../data/profile_repository.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/local_profile.dart';
import '../models/peer_profile.dart';
import 'nearby_event.dart';
import 'nearby_service.dart';

class ChatSyncService {
  ChatSyncService({
    required this.nearby,
    required this.profiles,
    required this.peers,
    required this.conversations,
    required this.messages,
  }) {
    _nearbySubscription = nearby.events.listen(_handleNearbyEvent);
  }

  final NearbyService nearby;
  final ProfileRepository profiles;
  final PeerRepository peers;
  final ConversationRepository conversations;
  final MessageRepository messages;

  StreamSubscription<NearbyEvent>? _nearbySubscription;
  LocalProfile? _localProfile;
  Conversation? _hostedConversation;
  bool _isHosting = false;

  Conversation? get hostedConversation => _hostedConversation;
  bool get isHosting => _isHosting;

  Future<Conversation> startGroup(String name, LocalProfile profile) async {
    final conversation = await conversations.createGroup(
      name: name,
      ownerId: profile.id,
    );
    _localProfile = profile;
    _hostedConversation = conversation;
    _isHosting = true;
    try {
      await nearby.startHosting(profile.username);
      return conversation;
    } catch (_) {
      _isHosting = false;
      _hostedConversation = null;
      rethrow;
    }
  }

  Future<void> findGroups(LocalProfile profile) async {
    _localProfile = profile;
    await nearby.startFinding(profile.username);
  }

  Future<void> connect(String endpointId, LocalProfile profile) async {
    _localProfile = profile;
    await nearby.connect(endpointId, profile.username);
  }

  Future<void> acceptConnection(String endpointId) => nearby.accept(endpointId);

  Future<void> rejectConnection(String endpointId) => nearby.reject(endpointId);

  Future<void> stopNearby() async {
    await nearby.stop();
    _isHosting = false;
    _hostedConversation = null;
    _localProfile = null;
  }

  Future<ChatMessage> sendMessage({
    required String groupId,
    required String text,
    required LocalProfile profile,
  }) async {
    final message = await messages.createMessage(
      groupId: groupId,
      senderId: profile.id,
      sender: profile.username,
      text: text,
      isMine: true,
    );
    _localProfile = profile;
    await _sendMessageToNearby(message);
    return message;
  }

  Future<void> _handleNearbyEvent(NearbyEvent event) async {
    if (event.type == NearbyEventType.connected) {
      await _sendHello(event.endpointId);
      return;
    }
    if (event.type != NearbyEventType.packet) return;
    final packet = event.packet;
    final profile = _localProfile ?? await profiles.getCurrentProfile();
    if (packet == null || profile == null) return;
    _localProfile = profile;

    switch (packet['type']) {
      case 'hello':
        await _handleHello(event.endpointId, packet, profile);
        break;
      case 'group':
        await _handleGroup(packet, profile);
        break;
      case 'message':
        await _handleMessage(event.endpointId, packet, profile);
        break;
      case 'ack':
        final messageId = packet['messageId'];
        if (messageId is String) {
          await messages.updateDeliveryStatus(messageId, 'delivered');
        }
        break;
    }
  }

  Future<void> _sendHello(String endpointId) async {
    final profile = _localProfile ?? await profiles.getCurrentProfile();
    if (profile == null) return;
    _localProfile = profile;
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
    final displayName = packet['displayName'];
    if (peerId is! String || displayName is! String || peerId == profile.id) {
      return;
    }

    await peers.savePeer(
      PeerProfile(
        id: peerId,
        displayName: displayName,
        lastSeenAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );

    if (_isHosting && _hostedConversation != null) {
      await conversations.addMember(_hostedConversation!.id, peerId);
      _hostedConversation = await conversations.getConversation(
        _hostedConversation!.id,
      );
      await _sendGroup(endpointId, _hostedConversation!);
      await _sendRecentMessages(endpointId, _hostedConversation!.id);
      await _sendPendingMessages(_hostedConversation!.id);
      await _sendGroupToOtherPeers(endpointId);
    }
  }

  Future<void> _handleGroup(
    Map<String, Object?> packet,
    LocalProfile profile,
  ) async {
    final groupId = packet['groupId'];
    final name = packet['name'];
    final rawMembers = packet['memberIds'];
    if (groupId is! String || name is! String || rawMembers is! List) return;
    final memberIds = rawMembers.whereType<String>().toSet().toList();
    if (!memberIds.contains(profile.id)) memberIds.add(profile.id);
    final now = DateTime.now().toUtc().toIso8601String();
    final oldGroup = await conversations.getConversation(groupId);
    await conversations.saveConversation(
      Conversation(
        id: groupId,
        name: name,
        memberIds: memberIds,
        createdAt: oldGroup?.createdAt ?? now,
        updatedAt: now,
        lastMessage: oldGroup?.lastMessage ?? '',
      ),
    );
    await _sendPendingMessages(groupId);
  }

  Future<void> _handleMessage(
    String endpointId,
    Map<String, Object?> packet,
    LocalProfile profile,
  ) async {
    final rawMessage = packet['message'];
    if (rawMessage is! Map) return;
    final fields = Map<String, Object?>.from(rawMessage);
    ChatMessage received;
    try {
      final source = ChatMessage.fromMap(fields);
      received = ChatMessage(
        id: source.id,
        groupId: source.groupId,
        senderId: source.senderId,
        sender: source.sender,
        text: source.text,
        createdAt: source.createdAt,
        isMine: source.senderId == profile.id,
        deliveryStatus: 'received',
      );
    } catch (_) {
      return;
    }
    final conversation = await conversations.getConversation(received.groupId);
    if (conversation == null ||
        !conversation.memberIds.contains(received.senderId)) {
      return;
    }

    final wasNew = await messages.saveMessage(received);
    await _sendPacket(endpointId, {'type': 'ack', 'messageId': received.id});

    if (wasNew && _isHosting) {
      for (final otherEndpoint in nearby.connectedEndpointIds) {
        if (otherEndpoint == endpointId) continue;
        await _sendPacket(otherEndpoint, {
          'type': 'message',
          'message': received.toMap(),
        });
      }
    }
  }

  Future<void> _sendMessageToNearby(ChatMessage message) async {
    var sent = false;
    for (final endpointId in nearby.connectedEndpointIds) {
      try {
        await _sendPacket(endpointId, {
          'type': 'message',
          'message': message.toMap(),
        });
        sent = true;
      } catch (_) {
        // The message stays in the outbox so it can be sent after reconnecting.
      }
    }
    if (sent) await messages.updateDeliveryStatus(message.id, 'sent');
  }

  Future<void> _sendGroup(String endpointId, Conversation conversation) async {
    await _sendPacket(endpointId, {
      'type': 'group',
      'groupId': conversation.id,
      'name': conversation.name,
      'memberIds': conversation.memberIds,
    });
  }

  Future<void> _sendGroupToOtherPeers(String joiningEndpoint) async {
    final conversation = _hostedConversation;
    if (conversation == null) return;
    for (final endpointId in nearby.connectedEndpointIds) {
      if (endpointId != joiningEndpoint) {
        await _sendGroup(endpointId, conversation);
      }
    }
  }

  Future<void> _sendRecentMessages(String endpointId, String groupId) async {
    final recentMessages = await messages.getLatestMessages(groupId);
    for (final message in recentMessages) {
      await _sendPacket(endpointId, {
        'type': 'message',
        'message': message.toMap(),
      });
    }
  }

  Future<void> _sendPendingMessages(String groupId) async {
    final profile = _localProfile ?? await profiles.getCurrentProfile();
    if (profile == null) return;
    final savedMessages = await messages.getLatestMessages(groupId);
    for (final message in savedMessages) {
      if (message.senderId == profile.id &&
          message.deliveryStatus == 'queued') {
        await _sendMessageToNearby(message);
      }
    }
  }

  Future<void> _sendPacket(
    String endpointId,
    Map<String, Object?> packet,
  ) async {
    await nearby.sendPacket(endpointId, packet);
  }

  Future<void> dispose() async {
    await _nearbySubscription?.cancel();
  }
}
