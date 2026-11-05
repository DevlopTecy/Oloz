import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/utils/formatters.dart';

/// A calm, non-shaming delta chip showing percentage change vs previous period.
/// Down (reduction in screen time/reels) is shown in calm green.
/// Up is shown in neutral textSecondary. Red is NEVER used.
class DeltaChip extends StatelessWidget {
  const DeltaChip({
    this.percentage,
    int? delta,
    super.key,
  }) : delta = delta ?? percentage ?? 0;

  final int? percentage;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final isReduction = delta < 0;

    final bgColor = isReduction ? colors.success.withValues(alpha: 0.15) : colors.surfaceMuted;
    final textColor = isReduction ? colors.success : colors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(OlozSpacing.radiusPill),
      ),
      child: Text(
        OlozFormatters.formatDelta(delta),
        semanticsLabel: '${delta.abs()}% ${isReduction ? 'decrease' : 'increase'}',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

