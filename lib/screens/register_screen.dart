import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../widgets/dazie_action_button.dart';
import '../widgets/dazie_page.dart';
import '../widgets/dazie_provider_buttons.dart';
import '../widgets/dazie_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createLocalProfile() {
    if (_formKey.currentState?.validate() != true) return;

    // I pass the name to the home page for this session; no profile is saved yet.
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DaziePage(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.maybePop(context),
                  icon: Image.asset('assets/images/BackButton.png', width: 22),
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/DAZIE.png',
                  width: 82,
                  height: 26,
                  fit: BoxFit.contain,
                  semanticLabel: 'Dazie',
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Create your profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Choose the name your friends will see in Dazie.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: DazieColors.mutedText),
            ),
            const SizedBox(height: AppSpacing.xl),
            DazieTextField(
              controller: _nameController,
              label: 'Display name',
              hint: 'Your name',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Use at least two characters.';
                }
                return null;
              },
              onSubmitted: (_) => _createLocalProfile(),
            ),
            const SizedBox(height: AppSpacing.md),
            DazieActionButton(
              label: 'CREATE LOCAL PROFILE',
              onPressed: _createLocalProfile,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This preview keeps your name for the current session. Your profile is not saved yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(height: 1.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            const DazieProviderButtons(),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('I already have a local profile'),
            ),
          ],
        ),
      ),
    );
  }
}
