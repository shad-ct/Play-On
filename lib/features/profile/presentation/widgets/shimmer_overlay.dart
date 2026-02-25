import 'package:flutter/material.dart';

/// Diagonal shimmer sweep overlay — rendered on top of card content.
/// Uses a smooth, wide gradient band that sweeps diagonally across the card.
class ShimmerOverlay extends StatelessWidget {
  final Animation<double> animation;
  final double intensity;

  const ShimmerOverlay({
    super.key,
    required this.animation,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    if (intensity <= 0) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, child2) {
        final t = animation.value;
        // Wider sweep range (-1.5 to 1.5) with smoother gradient
        final center = -1.5 + t * 3.0;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(center - 0.6, -0.5),
              end: Alignment(center + 0.6, 0.5),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.05 * intensity),
                Colors.white.withValues(alpha: 0.15 * intensity),
                Colors.white.withValues(alpha: 0.25 * intensity),
                Colors.white.withValues(alpha: 0.15 * intensity),
                Colors.white.withValues(alpha: 0.05 * intensity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
            ),
          ),
        );
      },
    );
  }
}
