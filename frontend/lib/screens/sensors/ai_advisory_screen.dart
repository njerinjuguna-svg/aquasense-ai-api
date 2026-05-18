 import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import '../../widgets/sensors/ai_advisory_card.dart';

/// Full-page AI Advisory view for a sensor.
///
/// Design details:
///   - Dark background (scaffold uses [AppColors.background])
///   - Purple [_AiFabCircle] circle at top-centre (matching the AI FAB colour)
///   - Pink chevron back button top-left///   - [AiAdvisoryCard] displays structured advisory data
///
/// Receives a [SensorModel] via route arguments.
class AiAdvisoryScreen extends StatelessWidget {
  const AiAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if( args is! SensorModel){
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Invalid sensor data'))  ,
      );
    }
    final sensor = args;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: back button + purple AI circle ──────────────────
            _AiScreenHeader(),
            const SizedBox(height: 24),

            // ── Advisory card ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AiAdvisoryCard(advisory: sensor.advisory),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Top area with a pink back button (left) and the purple AI FAB circle (centre).
class _AiScreenHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pink back button — top-left
          Align(
            alignment: Alignment.centerLeft,
            child: _PinkBackButton(
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          // Purple AI sparkle circle — centred, matches FAB colour
          const _AiFabCircle(),
        ],
      ),
    );
  }
}

/// Pink-tinted circular back button (same style as SensorDetailScreen).
class _PinkBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PinkBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(
          color: AppColors.pinkLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.chevron_left, color: AppColors.teal, size: 22),
      ),
    );
  }
}

/// Purple circle with a sparkle icon — matches the AI FAB from [MainShell].
/// Colour is [AppColors.aiFab] so no raw hex appears here.
class _AiFabCircle extends StatelessWidget {
  const _AiFabCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, height: 56,
      decoration: const BoxDecoration(
        color: AppColors.aiFab,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 26),
    );
  }
}
