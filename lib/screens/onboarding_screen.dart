import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/dazie_action_button.dart';
import '../widgets/dazie_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DaziePage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              'assets/images/Dazie_Logo.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              semanticLabel: 'Dazie mascot',
            ),
          ),
          const SizedBox(height: 34),
          Center(
            child: Image.asset(
              'assets/images/DAZIE.png',
              width: 151,
              height: 38,
              fit: BoxFit.contain,
              semanticLabel: 'Dazie',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Stay connected, even offline.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: DazieColors.violetText, fontSize: 18),
          ),
          const SizedBox(height: 124),
          DazieActionButton(
            label: 'GET STARTED',
            onPressed: () => Navigator.pushNamed(context, '/register'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DazieColors.tangerineOrange,
                backgroundColor: DazieColors.white,
                side: const BorderSide(color: DazieColors.tangerineOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('I already have an account'),
            ),
          ),
        ],
      ),
    );
  }
}
