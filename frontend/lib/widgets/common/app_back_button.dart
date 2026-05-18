import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.pinkLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.textDark,
          size: 22,
        ),
      ),
    )
    );
  }
}