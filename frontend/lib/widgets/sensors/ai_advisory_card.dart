
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';

/// Structured card displaying the full [AiAdvisory] for a sensor.
///
/// Layout (matches the design):
///   ┌──────────────────────────────────────┐
///   │ ✦ [headline]                         │
///   ├──────────────────────────────────────│
///   │ Impact Explanation:  [text]          │
///   │ Recommended Actions: • action 1      │
///   │                      • action 2      │
///   │ Impact Notes:        [text]          │
///   └──────────────────────────────────────┘
class AiAdvisoryCard extends StatelessWidget {
  final AiAdvisory advisory;
  const AiAdvisoryCard({super.key, required this.advisory});

  @override
  Widget build(BuildContext context) {
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
          // ── Headline row ──────────────────────────────────────────────
          _HeadlineRow(headline: advisory.headline),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 16),

          // ── Structured rows ───────────────────────────────────────────
          _AdvisoryRow(
            label:   'Impact\nExplanation:',
            child:   _BodyText(advisory.impactExplanation),
          ),
          const SizedBox(height: 14),
          _AdvisoryRow(
            label: 'Recommended\nActions:',
            child: _BulletList(items: advisory.recommendedActions),
          ),

          // Only render Impact Notes if non-empty
          if (advisory.impactNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _AdvisoryRow(
              label: 'Impact Notes:',
              child: _BodyText(advisory.impactNotes),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

/// Sparkle icon + headline text matching the design's top row.
class _HeadlineRow extends StatelessWidget {
  final String headline;
  const _HeadlineRow({required this.headline});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.auto_awesome, size: 16, color: AppColors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            headline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Two-column row: bold left label, flexible right content widget.
class _AdvisoryRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _AdvisoryRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed-width label column — matches design's left-column alignment
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color:      AppColors.textDark,
         
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Plain body text for single-paragraph advisory content.
class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodySmall);
}

/// Bullet-point list for recommended actions.
class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: tt.bodySmall),
              Expanded(child: Text(item, style: tt.bodySmall)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
