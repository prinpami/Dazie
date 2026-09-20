import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

// I use this layout on welcome and profile screens to keep them centered on web.
class DaziePage extends StatelessWidget {
  const DaziePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
