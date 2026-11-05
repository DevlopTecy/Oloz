import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

enum RingColor { indigo, peach }

/// Circular progress ring matching the Oloz design system:
/// 8px stroke, round caps, clockwise from top.
class Ring extends StatelessWidget {
  const Ring({
    required this.progress,
    this.colorType = RingColor.peach,
    this.color,
    this.trackColor,
    this.strokeWidth = 8,
    this.size = 180,
    this.center,
    this.child,
    this.semanticLabel,
    super.key,
  });

  /// Progress value between 0.0 and 1.0 (clamped).
  final double progress;
  final RingColor colorType;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;
  final double size;
  final Widget? center;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final strokeColor =
        color ?? (colorType == RingColor.peach ? colors.reel : colors.chart);
    final bgTrackColor = trackColor ?? colors.surfaceMuted;
    final contentWidget = child ?? center;

    return Semantics(
      label: semanticLabel ?? 'Progress ${(progress * 100).toInt()}%',
      value: '${(progress * 100).toInt()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: progress.clamp(0.0, 1.0),
                trackColor: bgTrackColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
              ),
            ),
            ?contentWidget,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Active arc (starts from top = -pi/2)
    final activePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

