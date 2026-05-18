import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';

/// Coloured pill badge displaying the sensor's [RiskLevel].
///
/// Colour pairs (foreground + background) come from [AppColors] semantic
/// tokens — no raw hex literals live in this file.
class RiskBadge extends StatelessWidget {
  final RiskLevel level;

  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color:        _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level.label,
        style: 
          Theme.of(context).textTheme.labelSmall?.copyWith(color: _fgColor),
      
      ),
    );
  }

  /// Background fill — sourced from [AppColors] semantic risk tokens.
  Color get _bgColor {
    switch (level) {
      case RiskLevel.high:   return AppColors.riskHighBg;
      case RiskLevel.medium: return AppColors.riskMediumBg;
      case RiskLevel.low:    return AppColors.riskLowBg;
    }
  }

  /// Text colour — sourced from [AppColors] semantic risk tokens.
  Color get _fgColor {
    switch (level) {
      case RiskLevel.high:   return AppColors.riskHighFg;
      case RiskLevel.medium: return AppColors.riskMediumFg;
      case RiskLevel.low:    return AppColors.riskLowFg;
    }
  }
}