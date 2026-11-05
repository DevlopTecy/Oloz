import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/utils/formatters.dart';
import 'package:oloz/data/providers/app_providers.dart';

class OnboardingGoalScreen extends ConsumerStatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  ConsumerState<OnboardingGoalScreen> createState() =>
      _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends ConsumerState<OnboardingGoalScreen> {
  int _screenTimeMs = 6 * 60 * 60 * 1000; // 6h 00m
  int _reelsGoal = 350;

  void _adjustTime(int deltaMs) {
    setState(() {
      _screenTimeMs = (_screenTimeMs + deltaMs).clamp(
        15 * 60 * 1000,
        16 * 60 * 60 * 1000,
      );
    });
  }

  void _adjustReels(int delta) {
    setState(() {
      _reelsGoal = (_reelsGoal + delta).clamp(25, 2000);
    });
  }

  Future<void> _saveAndFinish() async {
    final limitRepo = ref.read(limitRepositoryProvider);
    await limitRepo.setLimit(
      scope: 'total',
      dailyLimitMs: _screenTimeMs,
    );
    await limitRepo.setLimit(
      scope: 'reels_total',
      dailyLimitReels: _reelsGoal,
    );
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: OlozSpacing.screenPaddingMobile,
            vertical: OlozSpacing.s16,
          ),
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

            const SizedBox(height: OlozSpacing.s16),

            Text(
              'Daily goal',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: colors.text,
              ),
            ),

              const SizedBox(height: OlozSpacing.s24),

              // Card 1: Screen time
              Container(
                padding: const EdgeInsets.all(OlozSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screen time',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: OlozSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          OlozFormatters.formatDurationMs(_screenTimeMs),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: colors.text,
                          ),
                        ),
                        Row(
                          children: [
                            _StepperButton(
                              icon: Icons.remove,
                              onTap: () => _adjustTime(-15 * 60 * 1000),
                              colors: colors,
                            ),
                            const SizedBox(width: 8),
                            _StepperButton(
                              icon: Icons.add,
                              onTap: () => _adjustTime(15 * 60 * 1000),
                              colors: colors,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: OlozSpacing.s16),
                    // Indigo progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: 6,
                        color: colors.chartSoft,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (_screenTimeMs / (10 * 60 * 60 * 1000))
                              .clamp(0.05, 1.0),
                          child: Container(color: colors.chart),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OlozSpacing.s16),

              // Card 2: Reels
              Container(
                padding: const EdgeInsets.all(OlozSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reels',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: OlozSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_reelsGoal',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: colors.text,
                          ),
                        ),
                        Row(
                          children: [
                            _StepperButton(
                              icon: Icons.remove,
                              onTap: () => _adjustReels(-25),
                              colors: colors,
                            ),
                            const SizedBox(width: 8),
                            _StepperButton(
                              icon: Icons.add,
                              onTap: () => _adjustReels(25),
                              colors: colors,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: OlozSpacing.s16),
                    // Peach progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: 6,
                        color: colors.reelSoft,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (_reelsGoal / 600).clamp(0.05, 1.0),
                          child: Container(color: colors.reel),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OlozSpacing.s24),

              // Page dots (third dot active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PageDot(isActive: false, color: colors.border),
                  const SizedBox(width: 8),
                  _PageDot(isActive: false, color: colors.border),
                  const SizedBox(width: 8),
                  _PageDot(isActive: true, color: colors.primary),
                ],
              ),

              const SizedBox(height: OlozSpacing.s32),

              // Button "Done" in #5870C2
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saveAndFinish,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: OlozSpacing.s12),

              // "Skip" text button below
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Skip',
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
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final VoidCallback onTap;
  final OlozColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: colors.text),
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
