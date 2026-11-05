import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

class FirstDayEmptyStateView extends StatelessWidget {
  const FirstDayEmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: OlozSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.chartSoft, width: 6),
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.reelSoft,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: OlozSpacing.s24),
            Text(
              'Nothing tracked yet',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: OlozSpacing.s8),
            Text(
              'Usage will appear here as you use your device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: OlozSpacing.s24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => context.push('/onboarding/permission'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Allow usage access',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

