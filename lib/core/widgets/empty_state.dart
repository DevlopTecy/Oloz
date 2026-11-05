import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// Clean first-day empty state matching §4D:
/// Centered soft indigo ring icon, "Nothing tracked yet", action button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OlozSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 32,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: OlozSpacing.s20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: OlozSpacing.s24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

