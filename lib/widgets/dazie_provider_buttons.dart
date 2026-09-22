import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

// These brand buttons are visual placeholders until provider sign-in exists.
class DazieProviderButtons extends StatelessWidget {
  const DazieProviderButtons({super.key});

  void _showNotConnected(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-in is not connected in this demo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: Color(0xFFD8D8D8), thickness: 2),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text('OR', style: Theme.of(context).textTheme.bodySmall),
            ),
            const Expanded(
              child: Divider(color: Color(0xFFD8D8D8), thickness: 2),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showNotConnected(context, 'Google'),
                icon: Image.asset('assets/images/Google.png', width: 20),
                label: const Text('Google'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showNotConnected(context, 'Facebook'),
                icon: Image.asset('assets/images/Facebook.png', width: 20),
                label: const Text('Facebook'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
