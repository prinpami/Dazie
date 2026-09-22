import 'package:flutter/material.dart';

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
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() {
    if (_formKey.currentState?.validate() != true) return;

    // The mockup flow uses the entered identity as a temporary display name.
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: _identityController.text.trim(),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password recovery is not connected yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DaziePage(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log in',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 47,
              child: DazieTextField(
                controller: _identityController,
                hint: 'Email or Username',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your email or username.'
                    : null,
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 47,
              child: DazieTextField(
                controller: _passwordController,
                hint: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password.'
                    : null,
                onSubmitted: (_) => _logIn(),
                suffixIcon: TextButton(
                  onPressed: _forgotPassword,
                  style: TextButton.styleFrom(
                    foregroundColor: DazieColors.fieldText,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('FORGOT?'),
                ),
              ),
            ),
            const SizedBox(height: 29),
            DazieActionButton(label: 'LOG IN', onPressed: _logIn),
            const SizedBox(height: 21),
            const DazieProviderButtons(),
            const SizedBox(height: 31),
            const _LegalNotice(verb: 'signing in'),
            const SizedBox(height: 28),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: DazieColors.violetText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  children: const [
                    TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: 'SIGN UP',
                      style: TextStyle(color: DazieColors.tangerineOrange),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice({required this.verb});

  final String verb;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        children: [
          TextSpan(text: 'By $verb to Dazie, you agree to our '),
          const TextSpan(
            text: 'Terms',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const TextSpan(text: ' and '),
          const TextSpan(
            text: 'Privacy Policy.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
