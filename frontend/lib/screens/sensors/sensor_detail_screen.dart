import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/home/search_bar_widget.dart';
import '../../widgets/sensors/compliance_badge.dart';
import '../../widgets/sensors/risk_badge.dart';
import '../../widgets/sensors/trend_icon.dart';

/// Displays expanded information for a single sensor.
///
/// Receives a [SensorModel] via [Navigator.pushNamed] arguments.
/// Tapping "View AI Advisory" pushes [AiAdvisoryScreen].
class SensorDetailScreen extends StatelessWidget {
  const SensorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! SensorModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Invalid sensor data')),
      );
    }  
     final sensor = args;

    return Scaffold(      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar row ────────────────────────────────────────────
            _DetailAppBar(title: 'Sensor Detail'),
            const SizedBox(height: 12),

            // ── Search bar (matches Sensors screen chrome) ──────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(
                onChanged: (_) {
                  // search for sensors 
                  

                }, // No-op since this is a detail view
              ),
            ),
            const SizedBox(height: 16),

            // ── Detail card ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SensorDetailCard(sensor: sensor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Top navigation row with pink back button and centred title.
class _DetailAppBar extends StatelessWidget {
  final String title;
  const _DetailAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button — left
          Align(
            alignment: Alignment.centerLeft,
            child: _PinkBackButton(
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          // Title — centred
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Pink-tinted circular back button matching the auth screen style.
class _PinkBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PinkBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: 'Go back',
        child: Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
            color: AppColors.pinkLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_left, color: AppColors.teal, size: 22),
        ),
      ),
    );  }
}

/// Expanded sensor card with compliance row and AI Advisory CTA.
class _SensorDetailCard extends StatelessWidget {
  final SensorModel sensor;
  const _SensorDetailCard({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: sensor ID · risk badge · edit icon ─────────────────
          Row(
            children: [
              Text(sensor.id, style: tt.titleSmall),
              const Spacer(),
              RiskBadge(level: sensor.riskLevel),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, size: 18, color: AppColors.textGrey),
            ],
          ),
          const SizedBox(height: 8),

          // ── Reading value + trend ────────────────────────────────────
          Row(
            children: [
              Text(sensor.latestReading.displayValue, style: tt.headlineSmall),
              const SizedBox(width: 6),
              TrendIcon(trend: sensor.latestReading.trend),
            ],
          ),
          const SizedBox(height: 6),

          // ── Location ─────────────────────────────────────────────────
          Text(sensor.location, style: tt.bodyMedium),
          const SizedBox(height: 4),

          // ── WHO Compliance status ────────────────────────────────────
          ComplianceBadge(status: sensor.complianceStatus),
          const SizedBox(height: 4),

          // ── Last update ──────────────────────────────────────────────
          Text(
            _formatTimestamp(sensor.latestReading.timestamp),
            style: tt.bodySmall,
          ),
          const SizedBox(height: 10),

          // ── AI headline snippet ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sensor.advisory.headline,
                  style: tt.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── View AI Advisory CTA ─────────────────────────────────────
          AppButton(
            label: 'View AI Advisory',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.aiAdvisory,
              arguments: sensor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.isNegative) return 'Updated just now';
    if (diff.inSeconds < 60) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours   < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }
}
