import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/discovery_radar.dart';
import '../widgets/peer_connect_sheet.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key, required this.displayName});

  final String displayName;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  static const _peers = <_DemoPeer>[
    _DemoPeer('Mia Santos', '8 m'),
    _DemoPeer('Jordan Lee', '14 m'),
    _DemoPeer('Avery Cruz', '21 m'),
  ];

  String? _connectedPeer;

  Future<void> _showPeer(int index) async {
    final peer = _peers[index];
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: DazieColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => PeerConnectSheet(
        peerName: peer.name,
        distance: peer.distance,
        onConnect: () => Navigator.pop(sheetContext, true),
        onDecline: () => Navigator.pop(sheetContext, false),
      ),
    );

    if (accepted == true && mounted) {
      setState(() => _connectedPeer = peer.name);
    }
  }

  void _openChat() {
    final peer = _connectedPeer;
    if (peer == null) return;
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'title': peer, 'displayName': widget.displayName},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DazieColors.darkIndigo,
      appBar: AppBar(
        backgroundColor: DazieColors.darkIndigo,
        title: const Text('Find nearby friends'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'See who is close by',
            style: TextStyle(
              color: DazieColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Sample peers are shown for this screen preview. Device discovery is not active.',
            style: TextStyle(color: DazieColors.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Center(child: DiscoveryRadar(onPeerTap: _showPeer)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'NEARBY DEMO PEERS',
                  style: TextStyle(
                    color: DazieColors.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Text(
                '3 shown',
                style: TextStyle(color: DazieColors.mutedText, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < _peers.length; index++)
            _PeerTile(
              peer: _peers[index],
              isConnected: _connectedPeer == _peers[index].name,
              onTap: () => _showPeer(index),
            ),
          if (_connectedPeer != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _openChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: Text('MESSAGE $_connectedPeer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoPeer {
  const _DemoPeer(this.name, this.distance);

  final String name;
  final String distance;
}

class _PeerTile extends StatelessWidget {
  const _PeerTile({
    required this.peer,
    required this.isConnected,
    required this.onTap,
  });

  final _DemoPeer peer;
  final bool isConnected;
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
          title: Text(
            peer.name,
            style: const TextStyle(color: DazieColors.white),
          ),
          subtitle: Text(
            isConnected ? 'Connected in this demo' : 'Available in this demo',
            style: const TextStyle(color: DazieColors.mutedText, fontSize: 12),
          ),
          trailing: Text(
            peer.distance,
            style: const TextStyle(color: DazieColors.mutedText, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
