import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../common/app_logo.dart';
import 'teal_back_button.dart';

/// Shared header used at the top of every auth screen.
///
/// Renders (top → bottom):
///   1. Teal back button (top-left aligned)
///   2. AquaSense logo  (centred)
///   3. Title           (centred, [TextTheme.titleLarge])
///   4. Subtitle        (centred, [TextTheme.bodyMedium])
///
/// Text styles come from [Theme.of(context).textTheme] so they automatically
/// pick up font family, size, weight, and colour from [AppTheme].
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Teal back button ─────────────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: TealBackButton(onTap: onBack),
        ),
        const SizedBox(height: 24),

        // ── Brand logo ───────────────────────────────────────────────
        const Center(child: AppLogo(size: 100)),
        const SizedBox(height: 22),

        // ── Screen title ─────────────────────────────────────────────
        Text(title, textAlign: TextAlign.center, style: tt.titleLarge),
        const SizedBox(height: 6),

        // ── Subtitle / instruction ────────────────────────────────────
        Text(subtitle, textAlign: TextAlign.center, style: tt.bodyMedium),
      ],
    );
  }
}