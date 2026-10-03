import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_components.dart';
import '../widgets/settings_profile_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.displayName,
    required this.services,
  });

  final String displayName;
  final AppServices services;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isActive = true;
  bool _isLoggingOut = false;
  String _appearance = 'System';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.services.settings.getSettings();
    if (!mounted) return;
    setState(() {
      _isActive = settings.activeStatus;
      _appearance = settings.appearance;
    });
  }

  Future<void> _saveSettings() async {
    await widget.services.settings.saveSettings(
      AppSettings(activeStatus: _isActive, appearance: _appearance),
    );
  }

  void _toggleActive() {
    setState(() => _isActive = !_isActive);
    unawaited(_saveSettings());
  }

  Future<void> _logOut() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    await widget.services.chatSync.stopNearby();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

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
                  unawaited(_saveSettings());
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
            SizedBox(height: 25),
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
                    'This local profile is saved on this device. Passwords are not stored.',
                  ),
                  child: const SettingRow(
                    iconAsset: 'assets/images/Vector-2.png',
                    title: 'Local Profile',
                    subtitle: 'Saved on this device',
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
                        onTap: _toggleActive,
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
                  onPressed: _logOut,
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
