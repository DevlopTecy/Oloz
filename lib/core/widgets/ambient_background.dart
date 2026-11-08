import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// Ambient atmospheric background container.
/// Adds subtle, calm radial gradient glow (soft Indigo top-right, soft Peach bottom-left)
/// to prevent plain solid flat backgrounds while maintaining the calm Oloz aesthetic.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Stack(
      children: [
        // Top right soft indigo aura
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bg,
              gradient: RadialGradient(
                center: const Alignment(0.85, -0.85),
                radius: 1.1,
                colors: [
                  colors.chart.withValues(alpha: 0.07),
                  colors.bg.withValues(alpha: 0),
                ],
                stops: const [0, 0.65],
              ),
            ),
          ),
        ),
        // Bottom left soft peach aura
        Positioned(
          left: -80,
          bottom: 60,
          width: 280,
          height: 280,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.reel.withValues(alpha: 0.06),
                    colors.bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

