import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PeerConnectSheet extends StatelessWidget {
  const PeerConnectSheet({
    super.key,
    required this.peerName,
    required this.verificationCode,
    required this.onConnect,
    required this.onDecline,
  });

  final String peerName;
  final String verificationCode;
  final VoidCallback onConnect;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: DazieColors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 34,
              backgroundColor: DazieColors.tangerineOrange,
              child: Icon(
                Icons.person_rounded,
                size: 35,
                color: DazieColors.darkIndigo,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              peerName,
              style: const TextStyle(
                color: DazieColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check the code with the other phone. Both codes should match.',
              textAlign: TextAlign.center,
              style: TextStyle(color: DazieColors.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SelectableText(
              verificationCode,
              style: const TextStyle(
                color: DazieColors.tangerineOrange,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onConnect,
                child: const Text('ACCEPT CONNECTION'),
              ),
            ),
            TextButton(onPressed: onDecline, child: const Text('Not now')),
          ],
        ),
      ),
    );
  }
}
