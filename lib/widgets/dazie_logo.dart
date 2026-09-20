import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// The orange wordmark is reused at the top of the starter screens.
class DazieLogo extends StatelessWidget {
  const DazieLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'DAZIE',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: DazieColors.tangerineOrange,
        fontSize: size,
        height: 1,
      ),
    );
  }
}
