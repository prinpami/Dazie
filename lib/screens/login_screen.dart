import 'package:flutter/material.dart';

import '../models/local_profile.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/dazie_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Future<List<LocalProfile>> _profiles;
  String? _openingProfileId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _profiles = widget.services.profiles.getProfiles();
  }

  Future<void> _login(LocalProfile profile) async {
    if (_openingProfileId != null) return;
    setState(() {
      _openingProfileId = profile.id;
      _error = null;
    });
    try {
      await widget.services.profiles.activateProfile(profile.id);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (_) => false,
        arguments: {'displayName': profile.username, 'profileId': profile.id},
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _openingProfileId = null;
          _error = 'Could not log in. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => DaziePage(
    child: FutureBuilder<List<LocalProfile>>(
      future: _profiles,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load accounts.'),
              TextButton(
                onPressed: () => setState(() {
                  _profiles = widget.services.profiles.getProfiles();
                }),
                child: const Text('Retry'),
              ),
            ],
          );
        }

        final profiles = snapshot.data ?? const <LocalProfile>[];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profiles.isEmpty ? 'No accounts yet' : 'Choose an account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
            ],
            for (final profile in profiles) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: DazieColors.tangerineOrange,
                    foregroundColor: DazieColors.darkIndigo,
                    child: Text(
                      profile.username.characters.first.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  title: Text(profile.username),
                  subtitle: const Text('This phone'),
                  trailing: _openingProfileId == profile.id
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: _openingProfileId == null
                      ? () => _login(profile)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (profiles.isEmpty)
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Register'),
              )
            else
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Register another account'),
              ),
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text('Back'),
            ),
          ],
        );
      },
    ),
  );
}
