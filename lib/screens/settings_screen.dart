import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/app_services.dart';
import '../services/nearby_failure.dart';

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
  bool _saving = false;
  bool _loggingOut = false;
  String? _error;
  bool get _working => _saving || _loggingOut;

  Future<void> _chooseAppearance() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in ['System', 'Light', 'Dark'])
                ListTile(
                  title: Text(option),
                  trailing:
                      option == widget.services.settings.current.appearance
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.services.settings.saveSettings(
        AppSettings(
          activeStatus: widget.services.settings.current.activeStatus,
          appearance: selected,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save appearance. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logOut() async {
    if (_working) return;
    setState(() {
      _loggingOut = true;
      _error = null;
    });
    try {
      await widget.services.chatSync.stopNearby();
      await widget.services.profiles.clearCurrentProfile();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is NearbyFailure
              ? error.message
              : 'Could not log out. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_working,
    child: Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onTertiaryContainer,
              child: Text(
                widget.displayName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.displayName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Appearance'),
                subtitle: Text(widget.services.settings.current.appearance),
                onTap: _working ? null : _chooseAppearance,
              ),
            ),
            if (_saving)
              const LinearProgressIndicator(
                semanticsLabel: 'Saving appearance',
              ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_loggingOut)
              const LinearProgressIndicator(semanticsLabel: 'Logging out'),
            OutlinedButton.icon(
              onPressed: _working ? null : _logOut,
              icon: const Icon(Icons.logout_rounded),
              label: Text(_loggingOut ? 'Logging out…' : 'Log out'),
            ),
          ],
        ),
      ),
    ),
  );
}
