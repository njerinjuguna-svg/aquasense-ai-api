import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// The AquaSense brand logo — a teal circle containing two water drop outlines.
/// Used on the final onboarding landing page and (optionally) the splash screen.
///
/// [size]        — diameter of the outer circle (default 120)
/// [circleColor] — background fill of the circle (default [AppColors.teal])
class AppLogo extends StatelessWidget {
  final double size;
  final Color circleColor;

  const AppLogo({
    super.key,
    this.size = 120,
    this.circleColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        // Stack two drop icons offset from each other to match the brand mark
        child: SizedBox(
          width: size * 0.55,
          height: size * 0.55,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Small drop (top-left) ──────────────────────────────────
              Positioned(
                left: 0,
                top: size * 0.06,
                child: Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.white,
                  size: size * 0.24,
                ),
              ),
              // ── Large drop (bottom-right) ──────────────────────────────
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.white,
                  size: size * 0.38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
