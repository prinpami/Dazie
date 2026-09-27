import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/compass_dial.dart';

class CompassScreen extends StatelessWidget {
  const CompassScreen({super.key, required this.friendName});

  final String friendName;

  void _showDemoNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live location and compass sensors are not connected.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DazieColors.darkIndigo,
      appBar: AppBar(
        backgroundColor: DazieColors.darkIndigo,
        title: const Text('Friend direction'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: DazieColors.tangerineOrange,
              child: Icon(
                Icons.person_rounded,
                color: DazieColors.darkIndigo,
                size: 32,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              friendName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DazieColors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Center(child: _LastKnownBadge()),
            const SizedBox(height: 8),
            const Text(
              'LAST SHARED DIRECTION',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DazieColors.mutedText,
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const CompassDial(bearingDegrees: 42),
            const SizedBox(height: 2),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NE',
                  style: TextStyle(
                    color: DazieColors.tangerineOrange,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '450 m',
                  style: TextStyle(
                    color: DazieColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DazieColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: DazieColors.tangerineOrange,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last known location',
                          style: TextStyle(
                            color: DazieColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Shared 4 minutes ago · demo data',
                          style: TextStyle(
                            color: DazieColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showDemoNotice(context),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('UPDATE DIRECTION'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DazieColors.tangerineOrange,
                  side: const BorderSide(color: DazieColors.tangerineOrange),
                ),
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'This preview uses a sample bearing. Device location and compass data are not active.',
              textAlign: TextAlign.center,
              style: TextStyle(color: DazieColors.mutedText, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastKnownBadge extends StatelessWidget {
  const _LastKnownBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DazieColors.electricViolet,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          'LAST KNOWN · 4 MIN AGO',
          style: TextStyle(
            color: DazieColors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
