import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({required this.username, super.key});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/PFP.svg',
          width: 78,
          height: 78,
          semanticsLabel: 'Profile picture',
        ),
        const SizedBox(height: 13),
        Text(
          username,
          style: const TextStyle(
            color: DazieColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
