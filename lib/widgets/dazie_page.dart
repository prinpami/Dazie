import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// I use this layout on welcome and profile screens to keep them centered on web.
class DaziePage extends StatelessWidget {
  const DaziePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: DazieColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth < 344
                  ? constraints.maxWidth - 40
                  : 304.0;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: SizedBox(width: contentWidth, child: child),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
