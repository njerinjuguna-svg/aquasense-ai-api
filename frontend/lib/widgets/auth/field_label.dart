import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Bold field label rendered above each text input on auth screens.
class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:Theme.of(context).textTheme.labelLarge
    );
  }
}
