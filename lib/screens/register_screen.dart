import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../widgets/dazie_action_button.dart';
import '../widgets/dazie_page.dart';
import '../widgets/dazie_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_saving || _formKey.currentState?.validate() != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final profile = await widget.services.profiles.createProfile(
        username: _username.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (_) => false,
        arguments: {'displayName': profile.username, 'profileId': profile.id},
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error is StateError
            ? error.message.toString()
            : 'Could not register. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => DaziePage(
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Register',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Make an account on this phone',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          DazieTextField(
            controller: _username,
            hint: 'Your name',
            label: 'Your name',
            textInputAction: TextInputAction.done,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your name.'
                : null,
            onSubmitted: (_) => _register(),
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          if (_saving) ...[
            const LinearProgressIndicator(semanticsLabel: 'Creating account'),
            const SizedBox(height: 12),
          ],
          DazieActionButton(
            label: _saving ? 'Creating…' : 'Create account',
            onPressed: _saving ? null : _register,
          ),
          TextButton(
            onPressed: _saving ? null : () => Navigator.maybePop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    ),
  );
}
