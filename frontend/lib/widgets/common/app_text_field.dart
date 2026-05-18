import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Standard text input used on all auth screens.
///
/// Decoration (borders, fill colour, padding, hint style) comes entirely
/// from [AppTheme.inputDecorationTheme] — this widget only configures
/// behaviour (password toggle, keyboard type) and passes a hint string.
/// No raw [Color] or border literals live here.
class AppTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.hint,
    this.isPassword    = false,
    this.controller,
    this.keyboardType  = TextInputType.text,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller:   widget.controller,
      keyboardType: widget.keyboardType,
      obscureText:  widget.isPassword && _obscure,
      onChanged:    widget.onChanged,
      // Use the theme body style — size + colour maintained in one place
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        // Suffix icon only needed for password fields; everything else
        // (borders, fill, padding) is inherited from inputDecorationTheme
        suffixIcon: widget.isPassword ? _VisibilityToggle(
          obscure:  _obscure,
          onToggle: () => setState(() => _obscure = !_obscure),
        ) : null,
      ),
    );
  }
}

/// Eye icon button that toggles password visibility.
/// Extracted to keep [_AppTextFieldState.build] readable.
class _VisibilityToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;

  const _VisibilityToggle({required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textGrey,
        size:  20,
      ),
      onPressed: onToggle,
    );
  }
}