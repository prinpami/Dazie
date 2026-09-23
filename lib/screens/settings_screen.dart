import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/settings_components.dart';
import '../widgets/settings_profile_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.displayName});

  final String displayName;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isActive = true;
  String _appearance = 'System';

  String get _username {
    final identity = widget.displayName.split('@').first;
    final handle = identity.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    return '@${handle.isEmpty ? 'taylor' : handle}';
  }

  void _showPreviewMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _chooseAppearance() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DazieColors.searchPurple,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in ['System', 'Light', 'Dark'])
              ListTile(
                title: Text(option),
                trailing: option == _appearance
                    ? const Icon(
                        Icons.check,
                        color: DazieColors.tangerineOrange,
                      )
                    : null,
                onTap: () {
                  setState(() => _appearance = option);
                  Navigator.pop(context);
                  if (option != 'Dark') {
                    _showPreviewMessage(
                      'Appearance selection is a visual preview for now.',
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DazieColors.darkIndigo,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SettingsTitleBar(onBack: () => Navigator.maybePop(context)),
            const SizedBox(height: 12),
            SettingsProfileHeader(username: _username),
            const SizedBox(height: 39),
            const SettingsSectionHeading(),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: SettingsCard(
                height: 60,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showPreviewMessage(
                    'Account details will be available in a later checkpoint.',
                  ),
                  child: const SettingRow(
                    iconAsset: 'assets/images/Vector-2.png',
                    title: 'Accounts Centre',
                    subtitle: 'Email, Password, Security',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: SettingsCard(
                height: 73,
                child: Column(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        onTap: () => setState(() => _isActive = !_isActive),
                        child: SettingRow(
                          iconAsset: 'assets/images/Vector.png',
                          title: 'Active Status',
                          value: _isActive ? 'On' : 'Off',
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 47, right: 12),
                      color: const Color(0x668F8BB7),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                        onTap: _chooseAppearance,
                        child: SettingRow(
                          iconAsset: 'assets/images/Vector-1.png',
                          title: 'Dark mode',
                          value: _appearance,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(43, 0, 43, 50),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (_) => false,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: DazieColors.electricViolet,
                    foregroundColor: DazieColors.white,
                    elevation: 3,
                    shadowColor: const Color(0xFF623FBE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('LOG OUT'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
