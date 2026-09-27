import 'dart:async';

import 'package:flutter/material.dart';

import '../models/conversation.dart';
import '../models/local_profile.dart';
import '../services/app_services.dart';
import '../services/nearby_event.dart';
import '../theme/app_theme.dart';
import '../widgets/discovery_radar.dart';
import '../widgets/peer_connect_sheet.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
    required this.displayName,
    required this.services,
  });

  final String displayName;
  final AppServices services;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final _groupNameController = TextEditingController();
  final Map<String, String> _foundPeers = {};
  final Set<String> _shownRequests = {};
  StreamSubscription<NearbyEvent>? _nearbySubscription;
  LocalProfile? _profile;
  Conversation? _hostedConversation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _groupNameController.text = "${widget.displayName}'s group";
    _hostedConversation = widget.services.chatSync.hostedConversation;
    _nearbySubscription = widget.services.nearby.events.listen(
      _handleNearbyEvent,
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _profile = await widget.services.profiles.getCurrentProfile();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _nearbySubscription?.cancel();
    widget.services.nearby.stopFinding();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<LocalProfile?> _getProfile() async {
    final profile =
        _profile ?? await widget.services.profiles.getCurrentProfile();
    if (profile == null && mounted) {
      _showMessage('Create a local profile before using nearby chat.');
    }
    return profile;
  }

  Future<void> _hostGroup() async {
    if (!widget.services.nearby.isAvailable) {
      _showMessage('Nearby group chat needs Android devices.');
      return;
    }
    final profile = await _getProfile();
    if (profile == null || !mounted) return;
    if (widget.services.chatSync.isHosting &&
        widget.services.chatSync.hostedConversation != null) {
      setState(() {
        _hostedConversation = widget.services.chatSync.hostedConversation;
      });
      _showMessage('You are already hosting a group.');
      return;
    }
    try {
      final conversation = await widget.services.chatSync.startGroup(
        _groupNameController.text.trim().isEmpty
            ? "${profile.username}'s group"
            : _groupNameController.text.trim(),
        profile,
      );
      if (mounted) {
        setState(() => _hostedConversation = conversation);
        _showMessage('Group is ready. Ask others to find and join it.');
      }
    } catch (error) {
      if (mounted) _showMessage('Could not start the group: $error');
    }
  }

  Future<void> _findGroups() async {
    if (!widget.services.nearby.isAvailable) {
      _showMessage('Nearby group chat needs Android devices.');
      return;
    }
    final profile = await _getProfile();
    if (profile == null) return;
    try {
      await widget.services.chatSync.findGroups(profile);
      if (mounted) setState(() => _isSearching = true);
    } catch (error) {
      if (mounted) _showMessage('Could not search nearby: $error');
    }
  }

  Future<void> _connect(String endpointId) async {
    final profile = await _getProfile();
    if (profile == null) return;
    try {
      await widget.services.chatSync.connect(endpointId, profile);
      if (mounted) setState(() => _isSearching = false);
    } catch (error) {
      if (mounted) _showMessage('Could not connect: $error');
    }
  }

  void _handleNearbyEvent(NearbyEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case NearbyEventType.peerFound:
        setState(() => _foundPeers[event.endpointId] = event.name);
        break;
      case NearbyEventType.peerLost:
        setState(() => _foundPeers.remove(event.endpointId));
        break;
      case NearbyEventType.connectionRequest:
        unawaited(_showConnectionRequest(event));
        break;
      case NearbyEventType.connected:
        setState(() => _isSearching = false);
        _showMessage('Connected. Group details are syncing.');
        break;
      case NearbyEventType.disconnected:
        _showMessage(
          'A group member disconnected. Saved messages are still here.',
        );
        break;
      case NearbyEventType.packet:
        break;
    }
  }

  Future<void> _showConnectionRequest(NearbyEvent event) async {
    if (!_shownRequests.add(event.endpointId)) return;
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: DazieColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => PeerConnectSheet(
        peerName: event.name,
        verificationCode: event.authenticationToken,
        onConnect: () => Navigator.pop(context, true),
        onDecline: () => Navigator.pop(context, false),
      ),
    );
    _shownRequests.remove(event.endpointId);
    if (!mounted) return;
    try {
      if (accepted == true) {
        await widget.services.chatSync.acceptConnection(event.endpointId);
      } else {
        await widget.services.chatSync.rejectConnection(event.endpointId);
      }
    } catch (error) {
      if (mounted) _showMessage('Could not finish the connection: $error');
    }
  }

  void _openChat(Conversation conversation) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'id': conversation.id, 'title': conversation.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final peers = _foundPeers.entries.toList();
    return Scaffold(
      backgroundColor: DazieColors.darkIndigo,
      appBar: AppBar(
        backgroundColor: DazieColors.darkIndigo,
        title: const Text('Nearby group chat'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Connect without mobile data',
            style: TextStyle(
              color: DazieColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.services.nearby.isAvailable
                ? 'Keep Dazie open on both phones. Turn on Bluetooth, Wi-Fi, and Location.'
                : 'Two-device messaging is available on Android phones. This screen stays as a browser preview.',
            style: const TextStyle(color: DazieColors.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Center(
            child: DiscoveryRadar(
              peerCount: peers.length,
              onPeerTap: (index) {
                if (index < peers.length) _connect(peers[index].key);
              },
            ),
          ),
          const SizedBox(height: 4),
          if (widget.services.nearby.isAvailable) ...[
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group name',
                filled: true,
                fillColor: DazieColors.surface,
              ),
              style: const TextStyle(color: DazieColors.white),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _hostGroup,
                icon: const Icon(Icons.wifi_tethering_rounded),
                label: Text(
                  _hostedConversation == null
                      ? 'HOST A GROUP'
                      : 'GROUP IS HOSTED',
                ),
              ),
            ),
            if (_hostedConversation != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _openChat(_hostedConversation!),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: Text('OPEN ${_hostedConversation!.name}'),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isSearching ? null : _findGroups,
                icon: const Icon(Icons.radar_rounded),
                label: Text(
                  _isSearching ? 'SEARCHING NEARBY…' : 'FIND A GROUP',
                ),
              ),
            ),
            if (_isSearching)
              TextButton(
                onPressed: () async {
                  await widget.services.nearby.stopFinding();
                  if (mounted) setState(() => _isSearching = false);
                },
                child: const Text('Stop searching'),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            widget.services.nearby.isAvailable
                ? 'NEARBY DEVICES (${peers.length})'
                : 'NEARBY DEVICES',
            style: const TextStyle(
              color: DazieColors.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          if (peers.isEmpty)
            const Text(
              'Start searching to see groups hosted by nearby phones.',
              style: TextStyle(color: DazieColors.mutedText, fontSize: 12),
            ),
          for (final peer in peers)
            _PeerTile(name: peer.value, onTap: () => _connect(peer.key)),
        ],
      ),
    );
  }
}

class _PeerTile extends StatelessWidget {
  const _PeerTile({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: DazieColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          leading: const CircleAvatar(
            backgroundColor: DazieColors.tangerineOrange,
            child: Icon(Icons.person_rounded, color: DazieColors.darkIndigo),
          ),
          title: Text(name, style: const TextStyle(color: DazieColors.white)),
          subtitle: const Text(
            'Tap to request a connection',
            style: TextStyle(color: DazieColors.mutedText, fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}
