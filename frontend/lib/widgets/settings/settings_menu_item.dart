import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/settings_item.dart';

/// A single tappable row in the Settings menu.
///
/// Shows: [icon] · [label] · chevron right
/// Sourced from [SettingsItem] so the screen only builds a list
/// of data objects — no layout logic in the screen itself.
class SettingsMenuItem extends StatelessWidget {
  final SettingsItem item;

  const SettingsMenuItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap:        item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderColor)),
        ),
        child: Row(
          children: [
            // Leading person icon (all items use the same silhouette per design)
            Icon(item.icon, size: 20, color: AppColors.textDark),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(item.label, style: tt.bodyLarge),
            ),
            // Trailing chevron
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}
