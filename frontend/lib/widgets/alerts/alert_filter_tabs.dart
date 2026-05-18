import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/alert_model.dart';

/// Horizontal row of pill-shaped filter tabs: All · Alerts · Recommendation.
///
/// The active tab fills solid teal; inactive tabs show a teal border on white.
/// Tapping a tab calls [onFilterChanged] with the chosen [AlertFilter].
class AlertFilterTabs extends StatelessWidget {
  final AlertFilter         active;
  final ValueChanged<AlertFilter> onFilterChanged;

  const AlertFilterTabs({
    super.key,
    required this.active,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AlertFilter.values.map((f) {
        final isActive = f == active;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onFilterChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:        isActive ? AppColors.teal : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.teal,
                  width: 1.5,
                ),
              ),
              child: Text(
                f.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:      isActive ? AppColors.white : AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
