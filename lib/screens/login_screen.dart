import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/dazie_action_button.dart';
import '../widgets/dazie_page.dart';
import '../widgets/dazie_provider_buttons.dart';
import '../widgets/dazie_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continueToHome() {
    if (_formKey.currentState?.validate() != true) return;

    // This is only a local preview. It does not check an online account.
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
              'Welcome back',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sign in to pick up where your group left off.',
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
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your display name.'
                  : null,
              onSubmitted: (_) => _continueToHome(),
            ),
            const SizedBox(height: AppSpacing.md),
            DazieActionButton(label: 'CONTINUE', onPressed: _continueToHome),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This preview uses a display name for this session. It does not connect to an online account.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(height: 1.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            const DazieProviderButtons(),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/register'),
              child: const Text('Create a local profile'),
            ),
          ],
        ),
      ),
    );
  }
}
