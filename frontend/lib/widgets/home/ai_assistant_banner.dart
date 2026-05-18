import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Teal banner shown on the Home screen advertising AI insights.
/// Tapping "view details" navigates to the full AI advisory page.
class AiAssistantBanner extends StatelessWidget {
  final VoidCallback? onViewDetails;
  const AiAssistantBanner({super.key, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with sparkle icon
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AI Assistant help!',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Some sensors need urgent attention in some areas.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // "view details" link
          GestureDetector(
            onTap: onViewDetails,
            child: const Text(
              'view details',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.mint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
