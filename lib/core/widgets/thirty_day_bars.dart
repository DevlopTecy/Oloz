import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// 30-day bar chart for the Reels / App Detail view.
class ThirtyDayBars extends StatelessWidget {
  const ThirtyDayBars({
    required this.values,
    this.barThemeColor,
    this.barSoftColor,
    Color? color,
    Color? todayColor,
    this.height = 100,
    super.key,
  })  : color = color ?? barSoftColor,
        todayColor = todayColor ?? barThemeColor;

  final List<double> values;
  final Color? barThemeColor;
  final Color? barSoftColor;
  final Color? color;
  final Color? todayColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    assert(values.length == 30, 'ThirtyDayBars expects 30 data points');
    final colors = context.olozColors;
    final activeColor = todayColor ?? barThemeColor ?? colors.reel;
    final softColor = color ?? barSoftColor ?? colors.reelSoft;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxValue <= 0 ? 1.0 : maxValue;

    return Semantics(
      label: '30-day activity trend chart',
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(30, (index) {
            final val = values[index];
            final isToday = index == 29;
            final fraction = (val / effectiveMax).clamp(0.08, 1.0);
            final barHeight = height * fraction;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isToday ? activeColor : softColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
