import 'package:aquasense/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Mint-teal circular back button used across all auth screens.
/// Matches the design: mint fill (#B2F5EA), teal arrow icon.
class TealBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const TealBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
   onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          // Check if we can actually go back
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            // Fallback: If stack is empty, go to Onboarding
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          }
        }
   },
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFB2F5EA), // mint teal — matches design
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: AppColors.teal,
          size: 20,
        ),
      ),
    );
  }
}