import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// Bottom sheet scaffold container matching the Oloz design specifications:
/// 28px top radius, centered grabber handle, clean top title bar.
class BottomSheetScaffold extends StatelessWidget {
  const BottomSheetScaffold({
    required this.child,
    this.title,
    this.headerTrailing,
    super.key,
  });

  final Widget child;
  final String? title;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: OlozSpacing.s20, vertical: OlozSpacing.s12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grabber handle
              Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: OlozSpacing.s16),
              if (title != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    ?headerTrailing,
                  ],
                ),
                const SizedBox(height: OlozSpacing.s20),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

