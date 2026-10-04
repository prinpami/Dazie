import 'package:flutter/material.dart';

import '../models/local_profile.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/dazie_action_button.dart';
import '../widgets/dazie_page.dart';

/// Entry screen for local accounts. An active account goes straight to chats.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.services});

  final AppServices? services;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late Future<LocalProfile?> _activeProfile;
  late Future<List<LocalProfile>> _savedProfiles;
  bool _openingHome = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _activeProfile =
        widget.services?.profiles.getCurrentProfile() ??
        Future<LocalProfile?>.value();
    _savedProfiles =
        widget.services?.profiles.getProfiles() ??
        Future<List<LocalProfile>>.value(const []);
  }

  void _openHome(LocalProfile profile) {
    if (_openingHome || !mounted) return;
    _openingHome = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (_) => false,
        arguments: {'displayName': profile.username, 'profileId': profile.id},
      );
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LocalProfile?>(
    future: _activeProfile,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasData) {
        _openHome(snapshot.data!);
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return DaziePage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 44),
              const SizedBox(height: 12),
              const Text('Could not open your account.'),
              TextButton(
                onPressed: () => setState(() {
                  _openingHome = false;
                  _load();
                }),
                child: const Text('Try again'),
              ),
            ],
          ),
        );
      }

      return FutureBuilder<List<LocalProfile>>(
        future: _savedProfiles,
        builder: (context, profilesSnapshot) {
          final hasSavedAccounts = (profilesSnapshot.data?.isNotEmpty ?? false);
          return DaziePage(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/Dazie_Logo.png',
                    width: 144,
                    height: 144,
                    fit: BoxFit.contain,
                    semanticLabel: 'Dazie mascot',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'DAZIE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: DazieColors.tangerineOrange,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your chats, even offline.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 48),
                if (hasSavedAccounts) ...[
                  DazieActionButton(
                    label: 'Login',
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Register'),
                  ),
                ] else ...[
                  DazieActionButton(
                    label: 'Register',
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}
