import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/delta_chip.dart';

/// Styled stat value with tabular numbers and units at 55% size in textSecondary.
class StyledStatValue extends StatelessWidget {
  const StyledStatValue({
    required this.value,
    this.fontSize = 36,
    this.color,
    super.key,
  });

  final String value;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final primaryColor = color ?? colors.text;
    final unitColor = colors.textSecondary;
    final unitSize = fontSize * 0.55;

    final regex = RegExp(r'(\d+)|([a-zA-Z]+)|([^a-zA-Z\d\s]+)');
    final matches = regex.allMatches(value);

    final spans = <InlineSpan>[];
    for (final match in matches) {
      final part = match.group(0)!;
      final isDigits = RegExp(r'^\d+$').hasMatch(part);
      final isUnit = RegExp(r'^[a-zA-Z]+$').hasMatch(part);

      if (isDigits) {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
      } else if (isUnit) {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: unitSize,
              fontWeight: FontWeight.w500,
              color: unitColor,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      semanticsLabel: value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Primary metric card matching the Oloz design system:
/// 20px radius, 1px border, 20px padding, no decorative dots or clutter.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.value,
    required this.label,
    this.deltaPercentage,
    int? delta,
    this.onTap,
    super.key,
  }) : delta = delta ?? deltaPercentage;

  final String value;
  final String label;
  final int? deltaPercentage;
  final int? delta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(OlozSpacing.radiusCard),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(OlozSpacing.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OlozSpacing.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(OlozSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: StyledStatValue(
                          value: value,
                          fontSize: 34,
                        ),
                      ),
                    ),
                    if (delta != null) ...[
                      const SizedBox(width: OlozSpacing.s8),
                      DeltaChip(delta: delta),
                    ],
                  ],
                ),
                const SizedBox(height: OlozSpacing.s4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

