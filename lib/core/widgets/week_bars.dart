import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

enum WeekBarsTheme { indigo, peach }

class DailyBarItem {
  const DailyBarItem({
    required this.dayLabel,
    required this.value,
    this.semanticLabel,
  });

  /// Single letter weekday e.g. 'M', 'T', 'W', 'T', 'F', 'S', 'S'
  final String dayLabel;

  /// Numeric height value (e.g. minutes or reels count)
  final double value;

  /// Accessibility semantic description (e.g. "Friday 5 hours 7 minutes")
  final String? semanticLabel;
}

/// 7-bar chart ending today, matching the Oloz design specifications:
/// - Previous 6 days in soft tint (primarySoft or reelSoft)
/// - Today is the 7th (last) bar in full vibrant color (chart or reel)
/// - Single-letter labels below, today's letter in bold
/// - Minimum visible height so no bar is completely invisible
class WeekBars extends StatelessWidget {
  const WeekBars({
    required this.items,
    this.barTheme = WeekBarsTheme.indigo,
    this.accentIndex = 6,
    this.accentColor,
    this.defaultColor,
    this.height = 140,
    super.key,
  });

  final List<DailyBarItem> items;
  final WeekBarsTheme barTheme;
  final int accentIndex;
  final Color? accentColor;
  final Color? defaultColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    assert(
      items.length == 7,
      'WeekBars must contain exactly 7 days ending with today',
    );
    final colors = context.olozColors;

    final activeColor = accentColor ??
        (barTheme == WeekBarsTheme.indigo ? colors.chart : colors.reel);
    final softColor = defaultColor ??
        (barTheme == WeekBarsTheme.indigo ? colors.primarySoft : colors.reelSoft);

    final maxValue = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxValue <= 0 ? 1.0 : maxValue;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final item = items[index];
          final isToday = index == accentIndex;

          // Normalize height fraction (with min height of 6%)
          final fraction = (item.value / effectiveMax).clamp(0.06, 1.0);
          final barHeight = (height - 30) * fraction;

          final barColor = isToday ? activeColor : softColor;

          return Expanded(
            child: Semantics(
              excludeSemantics: true,
              label: item.semanticLabel ??
                  '${item.dayLabel}: ${item.value.toInt()}',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 22,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: OlozSpacing.s8),
                  Text(
                    item.dayLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday ? colors.text : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
