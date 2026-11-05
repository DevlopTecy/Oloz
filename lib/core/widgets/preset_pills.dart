import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

class DurationPreset {
  const DurationPreset({
    required this.label,
    int? durationMs,
    int? minutes,
  }) : durationMs = durationMs ?? ((minutes ?? 0) * 60 * 1000);

  const DurationPreset.fromMinutes({
    required this.label,
    required int minutes,
  }) : durationMs = minutes * 60 * 1000;

  final String label;
  final int durationMs;

  int get minutes => durationMs ~/ (60 * 1000);
}

typedef PresetOption = DurationPreset;

/// Horizontal list of preset pills for quick selection.
/// Selected uses primarySoft with primary text.
class PresetPills extends StatelessWidget {
  const PresetPills({
    required this.presets,
    required this.onSelected, this.selectedMinutes,
    this.selectedIndex,
    super.key,
  });

  final List<DurationPreset> presets;
  final int? selectedMinutes;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(presets.length, (index) {
        final preset = presets[index];
        final isSelected = selectedIndex != null
            ? index == selectedIndex
            : preset.minutes == selectedMinutes;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: OlozSpacing.s4),
          child: Semantics(
            button: true,
            selected: isSelected,
            child: GestureDetector(
              onTap: () => onSelected(selectedIndex != null ? index : preset.minutes),
              child: AnimatedContainer(
                duration: OlozDurations.fast,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primarySoft : colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(OlozSpacing.radiusPill),
                ),
                child: Text(
                  preset.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
