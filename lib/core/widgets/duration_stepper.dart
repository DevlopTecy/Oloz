import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/utils/formatters.dart';

/// Duration stepper widget for adjusting limits:
/// Minus button, large tabular time string, plus button.
class DurationStepper extends StatelessWidget {
  const DurationStepper({
    int? durationMinutes,
    int? durationMs,
    this.onChanged,
    this.onIncrement,
    this.onDecrement,
    this.stepMinutes = 15,
    this.minMinutes = 15,
    this.maxMinutes = 1440,
    super.key,
  }) : durationMinutes = durationMinutes ?? (durationMs != null ? durationMs ~/ 60000 : 90);

  final int durationMinutes;
  final ValueChanged<int>? onChanged;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final int stepMinutes;
  final int minMinutes;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    final formatted = OlozFormatters.formatDurationMs(durationMinutes * 60 * 1000);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepperButton(
          icon: Icons.remove_rounded,
          enabled: durationMinutes > minMinutes,
          onTap: () {
            if (onDecrement != null) {
              onDecrement!();
            } else {
              final next = (durationMinutes - stepMinutes).clamp(minMinutes, maxMinutes);
              onChanged?.call(next);
            }
          },
        ),
        const SizedBox(width: OlozSpacing.s24),
        SizedBox(
          width: 140,
          child: Text(
            formatted,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: colors.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: OlozSpacing.s24),
        _StepperButton(
          icon: Icons.add_rounded,
          enabled: durationMinutes < maxMinutes,
          onTap: () {
            if (onIncrement != null) {
              onIncrement!();
            } else {
              final next = (durationMinutes + stepMinutes).clamp(minMinutes, maxMinutes);
              onChanged?.call(next);
            }
          },
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final label = icon == Icons.remove_rounded ? 'Decrease duration' : 'Increase duration';

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: colors.surfaceMuted,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
              color: enabled ? colors.text : colors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

