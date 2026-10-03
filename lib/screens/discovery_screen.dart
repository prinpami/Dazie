import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/conversation.dart';
import '../services/app_services.dart';
import '../services/chat_sync_service.dart';
import '../services/nearby_event.dart';
import '../services/nearby_failure.dart';
import '../theme/app_theme.dart';

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
  final _name = TextEditingController();
  final Map<String, String> _peers = {};
  StreamSubscription<NearbyEvent>? _subscription;
  NearbyFailure? _localError;
  bool _working = false;
  ChatSyncService get _sync => widget.services.chatSync;

  @override
  void initState() {
    super.initState();
    _name.text = "${widget.displayName}'s group";
    _sync.addListener(_refresh);
    _subscription = widget.services.nearby.events.listen((event) {
      if (!mounted) return;
      if (event.type == NearbyEventType.peerFound) {
        setState(() => _peers[event.endpointId] = event.name);
      }
      if (event.type == NearbyEventType.peerLost) {
        setState(() => _peers.remove(event.endpointId));
      }
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sync.removeListener(_refresh);
    _subscription?.cancel();
    _name.dispose();
    super.dispose();
  }

  Future<void> _perform(Future<void> Function() action) async {
    if (_working) return;
    setState(() {
      _working = true;
      _localError = null;
    });
    _sync.clearError();
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _localError = NearbyFailure.from(error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _host() => _perform(() async {
    final profile = await widget.services.profiles.getCurrentProfile();
    if (profile == null) {
      throw const NearbyFailure('Create a local profile first.');
    }
    await _sync.startGroup(_name.text, profile);
    _peers.clear();
  });
  Future<void> _find() => _perform(() async {
    final profile = await widget.services.profiles.getCurrentProfile();
    if (profile == null) {
      throw const NearbyFailure('Create a local profile first.');
    }
    _peers.clear();
    await _sync.findGroups(profile);
  });
  Future<void> _connect(String id) => _perform(() async {
    final profile = await widget.services.profiles.getCurrentProfile();
    if (profile == null) {
      throw const NearbyFailure('Create a local profile first.');
    }
    await _sync.connect(id, profile);
  });
  void _open(Conversation group) => Navigator.pushNamed(
    context,
    '/chat',
    arguments: {'id': group.id, 'title': group.name},
  );

  @override
  Widget build(BuildContext context) {
    final group = widget.services.chatSync.activeConversation;
    final busy = _working || widget.services.chatSync.isBusy;
    final searching = widget.services.chatSync.isSearching;
    final connecting = widget.services.chatSync.connectingEndpoint != null;
    final error = _localError ?? widget.services.chatSync.error;
    final available = widget.services.nearby.isAvailable;
    final connected = group == null
        ? 0
        : widget.services.chatSync.connectionCount(group.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby group chat')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Connect without mobile data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep both apps open with Bluetooth and Wi-Fi on. Older Android versions also need Location.',
            style: TextStyle(color: DazieColors.mutedText),
          ),
          const SizedBox(height: 20),
          if (!available)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Nearby connections are available on Android phones with Google Play services. Your saved chats remain available on this device.',
                ),
              ),
            ),
          if (error != null)
            Card(
              color: const Color(0xFF602E39),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection needs attention',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(error.message),
                    if (error.openSettings)
                      TextButton(
                        onPressed: openAppSettings,
                        child: const Text('Open app settings'),
                      ),
                  ],
                ),
              ),
            ),
          if (group != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      connected > 0
                          ? Icons.check_circle_outline
                          : Icons.wifi_tethering,
                      color: DazieColors.tangerineOrange,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.services.chatSync.isHosting
                          ? (connected == 0
                                ? 'Hosting · waiting for members'
                                : 'Hosting · $connected connected')
                          : (connected == 0
                                ? 'Disconnected · messages are saved'
                                : 'Connected · ready to chat'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _open(group),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Open chat'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => _perform(
                              () => widget.services.chatSync.stopNearby(),
                            ),
                      child: Text(
                        widget.services.chatSync.isHosting
                            ? 'Stop hosting'
                            : 'Leave connection',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Leaving keeps your saved chat and messages.',
                      style: TextStyle(
                        color: DazieColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (available) ...[
            if (connecting) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              const Text(
                'Connecting · compare and accept the code on both phones',
              ),
              TextButton(
                onPressed: _working
                    ? null
                    : () =>
                          _perform(() => widget.services.chatSync.stopNearby()),
                child: const Text('Cancel connection'),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : (searching
                          ? () => _perform(
                              () => widget.services.chatSync.stopFinding(),
                            )
                          : _find),
                icon: Icon(
                  searching ? Icons.stop_circle_outlined : Icons.radar,
                ),
                label: Text(searching ? 'Stop searching' : 'Find a group'),
              ),
              const SizedBox(height: 12),
              if (searching) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  _peers.isEmpty
                      ? 'Searching… Ask the other phone to host a group.'
                      : 'Choose a group below to join.',
                ),
                const SizedBox(height: 12),
              ],
              if (searching)
                for (final peer in _peers.entries)
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.groups_outlined,
                        color: DazieColors.tangerineOrange,
                      ),
                      title: Text(peer.value),
                      subtitle: const Text('Tap to join and verify the code'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: busy ? null : () => _connect(peer.key),
                    ),
                  ),
              const SizedBox(height: 24),
              Text(
                'Or host a group',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                enabled: !busy && !searching,
                maxLength: 40,
                decoration: const InputDecoration(labelText: 'Group name'),
              ),
              OutlinedButton.icon(
                onPressed: busy || searching ? null : _host,
                icon: const Icon(Icons.wifi_tethering),
                label: Text(busy ? 'Please wait…' : 'Host a group'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Using the same name resumes your saved group. Stop searching before hosting.',
                style: TextStyle(color: DazieColors.mutedText, fontSize: 12),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
