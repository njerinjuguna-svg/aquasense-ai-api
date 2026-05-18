import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A centred row used at the bottom of auth screens:
///   "[prefixText]  [linkText]"
///
/// Examples:
///   "Already have an account?  Sign in"
///   "Don't have an account?  Create One"
///   "Remember your password?  Log in"
class AuthFooterLink extends StatelessWidget {
  final String prefixText;
  final String linkText;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefixText,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}