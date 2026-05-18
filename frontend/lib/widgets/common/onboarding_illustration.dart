
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';


/// Asset paths — defined once here so renaming images is a single-line change.
class _Assets {
  static const circuitBoard  = 'assets/images/1.png';
  static const colorfulWires = 'assets/images/3.png';
  static const pipeline      = 'assets/images/2.png';
}

/// The decorative illustration shown on onboarding pages 1–3.
///
/// Matches the design exactly:
///   • Three teal/mint pill cards with circular photo thumbnails
///   • A standalone circular thumbnail (colourful wires) floating top-right
///   • Two blob shapes in the background corners
///   • Scatter dots in brand accent colours
///
/// All positions are proportional to [MediaQuery] width so the layout
/// holds on different screen sizes.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const h = 320.0;

    return SizedBox(
      width: double.infinity,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background Blobs
          Positioned(left: -30, bottom: 40, child: _Blob(size: 100, color: AppColors.mint)),
          Positioned(right: -20, bottom: 0, child: _Blob(size: 80, color: const Color(0xFFFCE7F3))),

          // Scatter Dots
          const Positioned(top: 20, left: 80, child: _Dot(size: 10, color: Color(0xFF7F1D1D))),
          const Positioned(top: 60, right: 120, child: _Dot(size: 8, color: Color(0xFFF9A8D4))),
          const Positioned(bottom: 100, left: 20, child: _Dot(size: 12, color: Color(0xFF10B981))),

          // --- Card 1 (Top Center) ---
          Positioned(
            top: 20,
            child: const _SensorCard(),
          ),

          // --- Card 2 (Middle Left + Circuit Photo) ---
          Positioned(
            top: 90,
            left: w * 0.05,
            child: Row(
              children: [
                const _CircularPhoto(assetPath: _Assets.circuitBoard, size: 60),
                Transform.translate(
                  offset: const Offset(-15, 0), // Slight overlap
                  child: const _SensorCard(),
                ),
              ],
            ),
          ),

          // --- Standalone Photo (Top Right) ---
          Positioned(
            top: 60,
            right: w * 0.1,
            child: const _CircularPhoto(assetPath: _Assets.colorfulWires, size: 70),
          ),

          // --- Card 3 (Bottom Center + Large Pipeline Photo) ---
          Positioned(
            bottom: 20,
            right: w * 0.08,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _CircularPhoto(assetPath: _Assets.pipeline, size: 100),
                Transform.translate(
                  offset: const Offset(-20, -10),
                  child: const _SensorCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Solid circle used as a background blob.
class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Tiny filled circle used as a scatter dot.
class _Dot extends StatelessWidget {
  final double size;
  final Color color;

  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// A circular clipped photo from a local asset path.
/// Shows a grey placeholder while loading.
class _CircularPhoto extends StatelessWidget {
  final String assetPath;
  final double size;

  const _CircularPhoto({required this.assetPath, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2.5),
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          // Grey placeholder shown before the asset is decoded
          errorBuilder: (_, _, _) => Container(
            color: const Color(0xFFD1D5DB),
            child: const Icon(Icons.image, color: Color(0xFF9CA3AF)),
          ),
        ),
      ),
    );
  }
}

/// A teal/mint pill-shaped sensor-reading card.
///
/// When [assetPath] is provided a [_CircularPhoto] is shown on the left.
/// Always includes a teal check-circle and two coloured placeholder bars.
class _SensorCard extends StatelessWidget {
  /// Optional asset image shown as the left thumbnail.
  /// Pass null (default) for a card with no image.
  final String? assetPath;

  /// Diameter of the thumbnail circle.
  final double thumbnailSize;

  const _SensorCard({
    super.key,
    this.assetPath,
    this.thumbnailSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        // Mint pill — matches the design
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Optional photo thumbnail ─────────────────────────────────
          if (assetPath != null) ...[
            _CircularPhoto(assetPath: assetPath!, size: thumbnailSize),
            const SizedBox(width: 8),
          ],

          // ── Teal check-circle ────────────────────────────────────────
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.white, size: 13),
          ),
          const SizedBox(width: 8),

          // ── Data-bar placeholders ────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary bar — teal
              Container(
                width: 68,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              // Secondary bar — maroon accent
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF7F1D1D),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}