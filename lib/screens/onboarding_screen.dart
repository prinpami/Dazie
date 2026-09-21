import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/dazie_action_button.dart';
import '../widgets/dazie_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DaziePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Image.asset(
              'assets/images/DAZIE.png',
              width: 92,
              height: 28,
              fit: BoxFit.contain,
              semanticLabel: 'Dazie',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: 224,
            decoration: BoxDecoration(
              color: DazieColors.midnightIndigo,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/Dazie_Logo.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                semanticLabel: 'Dazie mascot',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Stay connected,\neven offline.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontSize: 30, height: 1.15),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bring your group together and find friends nearby, even when the internet is out.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: DazieColors.mutedText, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          DazieActionButton(
            label: 'GET STARTED',
            onPressed: () => Navigator.pushNamed(context, '/register'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('I already have a local profile'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
