import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Decorative logo: stacked discs above a mini board silhouette.
class Connect4Logo extends StatelessWidget {
  const Connect4Logo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.9,
      child: CustomPaint(
        painter: _Connect4LogoPainter(),
      ),
    );
  }
}

class _Connect4LogoPainter extends CustomPainter {
  void _drawDisc(Canvas canvas, Offset center, double radius, Color color, Color highlight) {
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 2), radius, shadow);

    final disc = Paint()..color = color;
    canvas.drawCircle(center, radius, disc);

    final gloss = Paint()
      ..shader = RadialGradient(
        colors: [highlight, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: center - Offset(radius * 0.2, radius * 0.25),
          radius: radius,
        ),
      );
    canvas.drawCircle(center, radius * 0.85, gloss);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final boardPaint = Paint()
      ..color = AppColors.boardFrame
      ..style = PaintingStyle.fill;
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.35,
        size.width * 0.84,
        size.height * 0.58,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(boardRect, boardPaint);

    final holePaint = Paint()..color = AppColors.slotEmpty;
    const cols = 4;
    const rows = 3;
    final cellW = size.width * 0.84 / cols;
    final cellH = size.height * 0.58 / rows;
    final ox = size.width * 0.08;
    final oy = size.height * 0.35;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cx = ox + cellW * (c + 0.5);
        final cy = oy + cellH * (r + 0.5);
        canvas.drawCircle(Offset(cx, cy), cellW * 0.32, holePaint);
      }
    }

    _drawDisc(
      canvas,
      Offset(size.width * 0.32, size.height * 0.52),
      size.width * 0.11,
      AppColors.playerX,
      AppColors.playerXLight,
    );
    _drawDisc(
      canvas,
      Offset(size.width * 0.58, size.height * 0.68),
      size.width * 0.11,
      AppColors.playerO,
      AppColors.playerOLight,
    );
    _drawDisc(
      canvas,
      Offset(size.width * 0.72, size.height * 0.48),
      size.width * 0.1,
      AppColors.playerX,
      AppColors.playerXLight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
