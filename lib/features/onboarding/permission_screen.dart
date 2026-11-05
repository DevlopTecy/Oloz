import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/data/providers/app_providers.dart';

class OnboardingPermissionScreen extends ConsumerWidget {
  const OnboardingPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

              // Shield icon with soft container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.chartSoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: colors.primary,
                  ),
                ),
              ),

              const SizedBox(height: OlozSpacing.s32),

              // Title: "Allow usage access"
              Text(
                'Allow usage access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colors.text,
                ),
              ),

              const SizedBox(height: OlozSpacing.s8),

              // Subtext: "Stays on your device."
              Text(
                'Stays on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),

              const SizedBox(height: OlozSpacing.s32),

              // Compact row of two icon+label pairs: lock "Private" and swipe "Counts reels"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OlozSpacing.s12,
                  vertical: OlozSpacing.s16,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: _FeaturePair(
                          icon: Icons.lock_outline,
                          label: 'Private',
                          colors: colors,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: colors.border,
                    ),
                    Expanded(
                      child: Center(
                        child: _FeaturePair(
                          icon: Icons.swipe_outlined,
                          label: 'Counts reels',
                          colors: colors,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Page dots (second dot active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PageDot(isActive: false, color: colors.border),
                  const SizedBox(width: 8),
                  _PageDot(isActive: true, color: colors.primary),
                  const SizedBox(width: 8),
                  _PageDot(isActive: false, color: colors.border),
                ],
              ),

              const SizedBox(height: OlozSpacing.s32),

              // Button "Allow" in #5870C2 without check icon
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    await ref.read(trackingServiceProvider).requestUsageAccess();
                    if (context.mounted) {
                      context.go('/onboarding/goal');
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Allow',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: OlozSpacing.s12),

              // "Not now" text button below
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => context.go('/onboarding/goal'),
                  child: Text(
                    'Not now',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: OlozSpacing.s8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePair extends StatelessWidget {
  const _FeaturePair({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final OlozColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: OlozSpacing.s8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
      ],
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
