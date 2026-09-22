import 'package:flutter/material.dart';

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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() != true) return;

    // This early demo only carries the username to the sample home screen.
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: _usernameController.text.trim(),
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
              'Sign up',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 49),
            SizedBox(
              height: 47,
              child: DazieTextField(
                controller: _usernameController,
                hint: 'Username',
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a username.'
                    : null,
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 47,
              child: DazieTextField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a valid email.'
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
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.length < 6
                    ? 'Use at least six characters.'
                    : null,
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 47,
              child: DazieTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) => value != _passwordController.text
                    ? 'Passwords do not match.'
                    : null,
                onSubmitted: (_) => _register(),
              ),
            ),
            const SizedBox(height: 18),
            DazieActionButton(label: 'REGISTER', onPressed: _register),
            const SizedBox(height: 21),
            const DazieProviderButtons(),
            const SizedBox(height: 31),
            const _LegalNotice(),
          ],
        ),
      ),
    );
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        children: const [
          TextSpan(text: 'By signing up to Dazie, you agree to our '),
          TextSpan(
            text: 'Terms',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
