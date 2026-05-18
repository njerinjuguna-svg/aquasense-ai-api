import 'package:flutter/material.dart';

/// A single row in the Settings menu list.
///
/// [onTap] is nullable — pass null for rows that are placeholders
/// (they still render but show no visual feedback on tap).
class SettingsItem {
  final IconData    icon;
  final String      label;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}
