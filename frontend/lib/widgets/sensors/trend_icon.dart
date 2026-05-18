import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';

/// Arrow icon indicating the direction of the latest sensor reading trend.
///
/// Colours are sourced from [AppColors] semantic trend tokens —
/// no raw hex literals in this file.
class TrendIcon extends StatelessWidget {
  final TrendDirection trend;
  final double size;

  const TrendIcon({super.key, required this.trend, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Icon(_icon, size: size, color: _color);
  }

  IconData get _icon {
    switch (trend) {
      case TrendDirection.up:     return Icons.trending_up;
      case TrendDirection.down:   return Icons.trending_down;
      case TrendDirection.stable: return Icons.trending_flat;
    }
  }

  Color get _color {
    switch (trend) {
      case TrendDirection.up:     return AppColors.trendUp;
      case TrendDirection.down:   return AppColors.trendDown;
      case TrendDirection.stable: return AppColors.trendStable;
    }
  }
}