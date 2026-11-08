import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

enum WeekBarsTheme { indigo, peach }

class DailyBarItem {
  const DailyBarItem({
    required this.dayLabel,
    required this.value,
    this.semanticLabel,
    this.formattedValue,
    this.fullDayName,
  });

  /// Single letter weekday e.g. 'M', 'T', 'W', 'T', 'F', 'S', 'S'
  final String dayLabel;

  /// Numeric height value (e.g. minutes or reels count)
  final double value;

  /// Accessibility semantic description (e.g. "Friday 5 hours 7 minutes")
  final String? semanticLabel;

  /// Formatted duration/count (e.g. "1h 48m" or "142 reels")
  final String? formattedValue;

  /// Full day name (e.g. "Sunday, Nov 8")
  final String? fullDayName;
}

/// 7-bar chart with touch interactivity and tooltips:
/// - Previous 6 days in soft tint (primarySoft or reelSoft)
/// - Today is the 7th (last) bar in vibrant color (chart or reel)
/// - Tapping any bar reveals its exact numbers and details
/// - Single-letter labels below, today's letter in bold
class WeekBars extends StatefulWidget {
  const WeekBars({
    required this.items,
    this.barTheme = WeekBarsTheme.indigo,
    this.accentIndex = 6,
    this.accentColor,
    this.defaultColor,
    this.height = 140,
    this.onBarSelected,
    super.key,
  });

  final List<DailyBarItem> items;
  final WeekBarsTheme barTheme;
  final int accentIndex;
  final Color? accentColor;
  final Color? defaultColor;
  final double height;
  final ValueChanged<int>? onBarSelected;

  @override
  State<WeekBars> createState() => _WeekBarsState();
}

class _WeekBarsState extends State<WeekBars> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.accentIndex;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.items.length == 7,
      'WeekBars must contain exactly 7 days ending with today',
    );
    final colors = context.olozColors;

    final activeColor = widget.accentColor ??
        (widget.barTheme == WeekBarsTheme.indigo ? colors.chart : colors.reel);
    final softColor = widget.defaultColor ??
        (widget.barTheme == WeekBarsTheme.indigo
            ? colors.primarySoft
            : colors.reelSoft);

    final maxValue =
        widget.items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxValue <= 0 ? 1.0 : maxValue;

    final activeIndex = _selectedIndex ?? widget.accentIndex;
    final selectedItem =
        activeIndex >= 0 && activeIndex < widget.items.length
            ? widget.items[activeIndex]
            : null;

    final tooltipText = selectedItem?.semanticLabel ??
        (selectedItem != null
            ? '${selectedItem.fullDayName ?? selectedItem.dayLabel}: ${selectedItem.formattedValue ?? selectedItem.value.toStringAsFixed(1)}'
            : '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Interactive info pill when a bar is selected
        if (tooltipText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: OlozSpacing.s8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.barTheme == WeekBarsTheme.indigo
                          ? colors.chartSoft
                          : colors.reelSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tooltipText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.barTheme == WeekBarsTheme.indigo
                            ? colors.primary
                            : colors.reel,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: OlozSpacing.s8),
                Text(
                  'Tap bar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: colors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: widget.height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final item = widget.items[index];
              final isToday = index == widget.accentIndex;
              final isSelected = index == activeIndex;

              // Normalize height fraction (with min height of 6%)
              final fraction = (item.value / effectiveMax).clamp(0.06, 1.0);
              final barHeight = (widget.height - 30) * fraction;

              final barColor = isToday
                  ? activeColor
                  : (isSelected
                      ? (widget.barTheme == WeekBarsTheme.indigo
                          ? colors.chart.withValues(alpha: 0.6)
                          : colors.reel.withValues(alpha: 0.6))
                      : softColor);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    widget.onBarSelected?.call(index);
                  },
                  child: Semantics(
                    button: true,
                    excludeSemantics: true,
                    label: item.semanticLabel ??
                        '${item.dayLabel}: ${item.value.toInt()}',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: isSelected ? 24 : 20,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
                            border: isSelected && !isToday
                                ? Border.all(
                                    color: activeColor.withValues(alpha: 0.8),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: OlozSpacing.s8),
                        Text(
                          item.dayLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isToday
                                ? colors.text
                                : (isSelected
                                    ? colors.primary
                                    : colors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
