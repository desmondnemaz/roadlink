import 'package:flutter/material.dart';
import 'package:roadlink/app/theme/app_theme.dart';

/// The official Roadlink brand mark (white rounded squircle with navy car
/// silhouette) and optional "Roadlink" wordmark, matching the Figma exports.
class RoadlinkLogo extends StatelessWidget {
  final double iconBoxSize;
  final double borderRadius;
  final bool showWordmark;
  final Color wordmarkColor;
  final double wordmarkFontSize;

  const RoadlinkLogo({
    super.key,
    this.iconBoxSize = 34,
    this.borderRadius = 10,
    this.showWordmark = true,
    this.wordmarkColor = AppPalette.neutral0,
    this.wordmarkFontSize = 18,
  });

  /// Large 76Ã—76 splash screen mark (radius 20).
  const RoadlinkLogo.splash({
    super.key,
    this.iconBoxSize = 76,
    this.borderRadius = 20,
    this.showWordmark = false,
    this.wordmarkColor = AppPalette.neutral0,
    this.wordmarkFontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: iconBoxSize,
      height: iconBoxSize,
      decoration: BoxDecoration(
        color: AppPalette.neutral0,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(iconBoxSize * 0.5, iconBoxSize * 0.34),
        painter: const _RoadlinkCarMarkPainter(color: AppPalette.navy900),
      ),
    );

    if (!showWordmark) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: 10),
        Text(
          'Roadlink',
          style: AppTypography.h3.copyWith(
            color: wordmarkColor,
            fontSize: wordmarkFontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RoadlinkCarMarkPainter extends CustomPainter {
  final Color color;

  const _RoadlinkCarMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Normalised to the 40Ã—28 vector space from Roadlink Mobile Splash.pdf.
    final sx = size.width / 40.0;
    final sy = size.height / 28.0;
    final s = sx < sy ? sx : sy;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(6 * s, 20 * s)
      ..lineTo(2 * s, 20 * s)
      ..quadraticBezierTo(0, 20 * s, 0, 18 * s)
      ..lineTo(0, 10 * s)
      ..lineTo(3.2 * s, 3.8 * s)
      ..quadraticBezierTo(4.2 * s, 2 * s, 6 * s, 2 * s)
      ..lineTo(20 * s, 2 * s)
      ..quadraticBezierTo(22.2 * s, 2 * s, 23.6 * s, 3.4 * s)
      ..lineTo(28 * s, 8 * s)
      ..lineTo(37 * s, 10.2 * s)
      ..quadraticBezierTo(40 * s, 11 * s, 40 * s, 14 * s)
      ..lineTo(40 * s, 18 * s)
      ..quadraticBezierTo(40 * s, 20 * s, 38 * s, 20 * s)
      ..lineTo(34 * s, 20 * s)
      ..moveTo(14 * s, 20 * s)
      ..lineTo(26 * s, 20 * s);

    canvas.drawPath(body, paint);
    canvas.drawCircle(Offset(10 * s, 20 * s), 4 * s, paint);
    canvas.drawCircle(Offset(30 * s, 20 * s), 4 * s, paint);
  }

  @override
  bool shouldRepaint(covariant _RoadlinkCarMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
