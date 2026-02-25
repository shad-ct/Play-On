import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:playon/features/profile/presentation/widgets/card_rarity_theme.dart';

/// Animated CustomPainter for Elite-tier card backgrounds.
/// Draws moving electric streaks, a breathing neon orb, and rising particles.
class EliteBgPainter extends CustomPainter {
  final double value; // 0.0–1.0 from AnimationController
  final PlayOnCardTheme theme;

  EliteBgPainter({required this.value, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    _drawStreaks(canvas, size);
    _drawGlowOrb(canvas, size);
    _drawParticles(canvas, size);
  }

  void _drawStreaks(Canvas canvas, Size size) {
    const streakCount = 7;
    for (int i = 0; i < streakCount; i++) {
      final rng = math.Random(i * 13 + 7);
      final progress = (value + i / streakCount) % 1.0;
      final opacity = math.sin(progress * math.pi).clamp(0.0, 1.0) * 0.55;
      if (opacity < 0.01) continue;

      final x0 = rng.nextDouble() * size.width;
      final y0 = rng.nextDouble() * size.height;
      final x1 = x0 + (rng.nextDouble() - 0.5) * size.width * 0.7;
      final y1 = rng.nextDouble() * size.height;

      final paint = Paint()
        ..color = theme.glowColor.withValues(alpha: opacity)
        ..strokeWidth = 0.8 + rng.nextDouble() * 1.2
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(x0, y0);
      const segs = 5;
      for (int j = 1; j <= segs; j++) {
        final t = j / segs;
        path.lineTo(
          x0 + (x1 - x0) * t + (rng.nextDouble() - 0.5) * 28,
          y0 + (y1 - y0) * t,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawGlowOrb(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.38;
    final r = 55.0 + math.sin(value * math.pi * 2) * 18;
    final alpha = 0.28 + math.sin(value * math.pi * 2) * 0.12;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            theme.glowColor.withValues(alpha: alpha),
            theme.glowColor.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
  }

  void _drawParticles(Canvas canvas, Size size) {
    const count = 14;
    for (int i = 0; i < count; i++) {
      final rng = math.Random(i * 31 + 17);
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      // Particles drift upward
      final y = (baseY - value * size.height * 0.35 + size.height) % size.height;
      final opacity =
          math.sin((value + i / count) * math.pi).clamp(0.0, 1.0) * 0.65;
      if (opacity < 0.01) continue;

      canvas.drawCircle(
        Offset(baseX, y),
        1.0 + rng.nextDouble() * 1.5,
        Paint()
          ..color = theme.borderColor.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(EliteBgPainter old) => old.value != value;
}
