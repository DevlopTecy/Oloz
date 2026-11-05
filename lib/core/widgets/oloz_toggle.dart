import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// Custom toggle switch matching the design specifications:
/// 50px x 28px pill chassis, pure white circular thumb sliding 22px.
class OlozToggle extends StatelessWidget {
  const OlozToggle({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Semantics(
      toggled: value,
      label: semanticLabel ?? 'Toggle switch',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: OlozDurations.fast,
          curve: Curves.easeOut,
          width: 50,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? colors.primary : colors.surfaceMuted,
            borderRadius: BorderRadius.circular(OlozSpacing.radiusPill),
          ),
          child: AnimatedAlign(
            duration: OlozDurations.fast,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.shadowColor,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

