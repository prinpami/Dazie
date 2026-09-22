import 'package:flutter/material.dart';

// This wrapper gives the forms one shared field style and validation hook.
class DazieTextField extends StatelessWidget {
  const DazieTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.validator,
    this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final String? Function(String?) validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
