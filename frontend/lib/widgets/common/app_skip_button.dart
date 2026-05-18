import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const SkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textGrey,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('Skip'),
        ),
      ),
    );
  }
}