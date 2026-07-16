import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// Champ de texte réutilisable avec label et validation.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}

/// Validateurs simples réutilisables.
class Validators {
  Validators._();

  static String? email(String? value, BuildContext context) {
    final tr = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return tr.emailRequired;
    }
    if (!value.contains('@') || !value.contains('.')) {
      return tr.invalidEmail;
    }
    return null;
  }

  static String? password(String? value, BuildContext context) {
    final tr = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return tr.passwordRequired;
    }
    if (value.length < 6) {
      return tr.minChars;
    }
    return null;
  }

  static String? notEmpty(String? value, {required BuildContext context, String field = 'Ce champ'}) {
    final tr = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return tr.fieldRequired(field);
    }
    return null;
  }
}
