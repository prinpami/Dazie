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
      throw const NearbyFailure('Log in to start a nearby chat.');
    }
    await _sync.startGroup(_name.text, profile);
    _peers.clear();
  });

  Future<void> _find() => _perform(() async {
    final profile = await widget.services.profiles.getCurrentProfile();
    if (profile == null) {
      throw const NearbyFailure('Log in to find a nearby chat.');
    }
    _peers.clear();
    await _sync.findGroups(profile);
  });

  Future<void> _connect(String id) => _perform(() async {
    final profile = await widget.services.profiles.getCurrentProfile();
    if (profile == null) {
      throw const NearbyFailure('Log in to join a nearby chat.');
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
      appBar: AppBar(title: const Text('Nearby chat')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _NearbyHero(searching: searching, connected: connected > 0),
          const SizedBox(height: 18),
          if (!available)
            const _InfoCard(
              icon: Icons.info_outline_rounded,
              text: 'Nearby chat needs Google Play services.',
            ),
          if (error != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded),
                        const SizedBox(width: 8),
                        Text(
                          'Connection issue',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(error.message),
                    if (error.openSettings)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: openAppSettings,
                          icon: const Icon(Icons.settings_outlined),
                          label: const Text('Settings'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (group != null) ...[
            _ActiveGroupCard(
              group: group,
              hosting: widget.services.chatSync.isHosting,
              connected: connected,
              busy: busy,
              onOpen: () => _open(group),
              onLeave: () =>
                  _perform(() => widget.services.chatSync.stopNearby()),
            ),
          ] else if (available) ...[
            if (connecting) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
              const SizedBox(height: 14),
              const _InfoCard(
                icon: Icons.verified_user_outlined,
                text: 'Compare the code on both phones.',
              ),
              TextButton.icon(
                onPressed: _working
                    ? null
                    : () =>
                          _perform(() => widget.services.chatSync.stopNearby()),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancel'),
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
                  searching ? Icons.stop_circle_outlined : Icons.radar_rounded,
                ),
                label: Text(searching ? 'Stop searching' : 'Find a group'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 58)),
              ),
              if (searching) ...[
                const SizedBox(height: 14),
                if (_peers.isEmpty)
                  const _InfoCard(
                    icon: Icons.search_rounded,
                    text: 'Searching for groups nearby…',
                  )
                else ...[
                  Text(
                    'Groups nearby',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  for (final peer in _peers.entries)
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: DazieColors.tangerineOrange,
                          child: Icon(Icons.groups_rounded),
                        ),
                        title: Text(peer.value),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: busy ? null : () => _connect(peer.key),
                      ),
                    ),
                ],
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR HOST',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                enabled: !busy && !searching,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  prefixIcon: Icon(Icons.groups_rounded),
                ),
              ),
              OutlinedButton.icon(
                onPressed: busy || searching ? null : _host,
                icon: const Icon(Icons.wifi_tethering_rounded),
                label: Text(busy ? 'Please wait…' : 'Host a group'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _NearbyHero extends StatelessWidget {
  const _NearbyHero({required this.searching, required this.connected});

  final bool searching;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? DazieColors.white
        : DazieColors.darkIndigo;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD69B), Color(0xFFFFF0D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: DazieColors.tangerineOrange.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              connected
                  ? Icons.check_rounded
                  : searching
                  ? Icons.radar_rounded
                  : Icons.wifi_tethering_rounded,
              size: 38,
              color: DazieColors.darkIndigo,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connected
                      ? 'You’re connected!'
                      : searching
                      ? 'Looking nearby…'
                      : 'Chat, no data needed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RadioPill(
                      icon: Icons.bluetooth_rounded,
                      label: 'Bluetooth',
                    ),
                    _RadioPill(icon: Icons.wifi_rounded, label: 'Wi-Fi'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioPill extends StatelessWidget {
  const _RadioPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: DazieColors.darkIndigo),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: DazieColors.darkIndigo,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: DazieColors.electricViolet),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}

class _ActiveGroupCard extends StatelessWidget {
  const _ActiveGroupCard({
    required this.group,
    required this.hosting,
    required this.connected,
    required this.busy,
    required this.onOpen,
    required this.onLeave,
  });

  final Conversation group;
  final bool hosting;
  final int connected;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final status = hosting
        ? (connected == 0 ? 'Waiting for friends' : '$connected connected')
        : (connected == 0 ? 'Saved on this phone' : 'Connected');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: DazieColors.tangerineOrange,
                  child: Icon(Icons.groups_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  connected > 0 ? Icons.circle : Icons.cloud_off_outlined,
                  size: 14,
                  color: connected > 0
                      ? Colors.green
                      : Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.chat_bubble_rounded),
              label: const Text('Open chat'),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: busy ? null : onLeave,
              icon: const Icon(Icons.logout_rounded),
              label: Text(hosting ? 'Stop hosting' : 'Leave chat'),
            ),
          ],
        ),
      ),
    );
  }
}
