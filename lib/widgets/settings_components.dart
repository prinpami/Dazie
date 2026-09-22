import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsTitleBar extends StatelessWidget {
  const SettingsTitleBar({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            InkWell(
              onTap: onBack,
              child: Image.asset(
                'assets/images/BackButton.png',
                width: 18,
                height: 18,
                semanticLabel: 'Back',
              ),
            ),
            const Expanded(
              child: Text(
                'Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DazieColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}

class SettingsSectionHeading extends StatelessWidget {
  const SettingsSectionHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 61),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Your account',
              style: TextStyle(
                color: DazieColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Image.asset(
            'assets/images/DAZIE.png',
            width: 40,
            height: 12,
            fit: BoxFit.contain,
            semanticLabel: 'Dazie',
          ),
        ],
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.height, required this.child, super.key});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: DazieColors.searchPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.iconAsset,
    required this.title,
    this.subtitle,
    this.value,
    super.key,
  });

  final String iconAsset;
  final String title;
  final String? subtitle;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 16, height: 16, fit: BoxFit.contain),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DazieColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: DazieColors.mutedText,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                color: DazieColors.mutedText,
                fontSize: 10,
              ),
            ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/Vector-3.png',
            width: 7,
            height: 12,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
