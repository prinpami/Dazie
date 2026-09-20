import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/dazie_action_button.dart';
import '../widgets/dazie_logo.dart';
import '../widgets/dazie_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DaziePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          const Center(child: DazieLogo(size: 30)),
          const SizedBox(height: AppSpacing.xl),
          const _WelcomeIllustration(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Stay connected,\neven when offline.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontSize: 29, height: 1.15),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chat with your group and find your friends nearby, even when mobile data is weak.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: DazieColors.mutedText, height: 1.45),
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

// A small Flutter illustration stands in for a Figma image asset for now.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 208,
      child: Center(
        child: SizedBox.square(
          dimension: 196,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 188,
                height: 188,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DazieColors.midnightIndigo.withOpacity(0.12),
                  ),
                ),
              ),
              Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DazieColors.midnightIndigo.withOpacity(0.18),
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: DazieColors.tangerineOrange,
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: DazieColors.darkIndigo,
                  size: 38,
                ),
              ),
              const Positioned(
                top: 20,
                right: 20,
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: DazieColors.electricViolet,
                  child: Icon(Icons.person, color: DazieColors.white),
                ),
              ),
              const Positioned(
                bottom: 18,
                left: 16,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: DazieColors.midnightIndigo,
                  child: Icon(
                    Icons.near_me,
                    color: DazieColors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
