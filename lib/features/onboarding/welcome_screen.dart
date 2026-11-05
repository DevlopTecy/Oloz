import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OlozSpacing.screenPaddingMobile,
            vertical: OlozSpacing.s16,
          ),
          child: Column(
            children: [
              // Top Bar: Skip button top right
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Logo mark: 120px ring with peach center dot and soft glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.chart, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: colors.chart.withValues(alpha: 0.18),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.reel,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.reel.withValues(alpha: 0.25),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: OlozSpacing.s40),

              // Title: "Know your scroll."
              Text(
                'Know your scroll.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colors.text,
                ),
              ),

              const SizedBox(height: OlozSpacing.s12),

              // Subtitle: "Screen time and reels, simply."
              Text(
                'Screen time and reels, simply.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),

              const Spacer(),

              // Page dots (3 dots, first active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PageDot(isActive: true, color: colors.primary),
                  const SizedBox(width: 8),
                  _PageDot(isActive: false, color: colors.border),
                  const SizedBox(width: 8),
                  _PageDot(isActive: false, color: colors.border),
                ],
              ),

              const SizedBox(height: OlozSpacing.s32),

              // Primary button: "Get started" in #5870C2 without arrow icon
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.go('/onboarding/permission'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: OlozSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive, required this.color});

  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: OlozDurations.fast,
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

