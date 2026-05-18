import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Animated three-dot typing indicator shown while the AI is composing a reply.
///
/// Uses a single [AnimationController] driving an offset-staggered
/// opacity animation on three dots.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin:  const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        AppColors.mintLight,
          borderRadius: const BorderRadius.only(
            topLeft:    Radius.circular(16),
            topRight:   Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _Dot(controller: _controller, delay: i * 0.2)),
        ),
      ),
    );
  }
}

/// A single dot with a staggered bounce animation.
class _Dot extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const _Dot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        // Each dot peaks at a different phase of the loop
        final t      = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
        final offset = t < 0.5 ? t * 2 : (1 - t) * 2; // triangle wave 0→1→0
        return Container(
          margin:  const EdgeInsets.symmetric(horizontal: 2),
          width:   7,
          height:  7,
          transform: Matrix4.translationValues(0, -offset * 4, 0),
          decoration: BoxDecoration(
            color: AppColors.teal,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
