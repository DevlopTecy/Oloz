import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// Recessed segmented pill control for switching time ranges (Day / Week / Month).
class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.horizontalPadding = 12,
    this.verticalPadding = 6,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Container(
      padding: const EdgeInsets.all(OlozSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(OlozSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return Semantics(
            button: true,
            selected: isSelected,
            child: GestureDetector(
              onTap: () => onChanged(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: OlozDurations.fast,
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(OlozSpacing.radiusPill),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.shadowColor,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colors.text : colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

