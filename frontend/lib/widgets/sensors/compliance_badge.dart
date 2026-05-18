import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';

/// Inline WHO compliance indicator: "WHO Compliance level:  Pass" or "Fail".
///
/// The label is grey; the status value uses semantic risk colours from
/// [AppColors] so no raw hex values appear here.
class ComplianceBadge extends StatelessWidget {
  final ComplianceStatus status;
  const ComplianceBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Text('WHO Compliance level:', style: tt.bodySmall),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: tt.bodySmall?.copyWith(
            color:      _statusColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Color get _statusColor {
    switch (status) {
      case ComplianceStatus.pass: return AppColors.riskLowFg;
      case ComplianceStatus.fail: return AppColors.riskHighFg;
    }
  }
}
