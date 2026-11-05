import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/utils/formatters.dart';
import 'package:oloz/core/widgets/app_icon_tile.dart';
import 'package:oloz/core/widgets/delta_chip.dart';
import 'package:oloz/core/widgets/week_bars.dart';
import 'package:oloz/data/providers/app_providers.dart';
import 'package:oloz/features/apps/set_limit_sheet.dart';

class AppDetailScreen extends ConsumerWidget {
  const AppDetailScreen({
    required this.package,
    super.key,
  });

  final String package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;

    final appLimitAsync = ref.watch(appLimitProvider(package));
    final limitMs = appLimitAsync.value?.dailyLimitMs ?? (90 * 60 * 1000); // 1h 30m default

    final isInstagram = package.contains('instagram');
    final appName = isInstagram ? 'Instagram' : _getAppName(package);
    final appIcon = _getAppIcon(package);

    // Canonical values for Instagram: 1h 48m, 142 reels, 23 opens, -18% delta
    const usageMs = 108 * 60 * 1000; // 1h 48m
    const reelsCount = 142;
    const opensCount = 23;
    final isOverLimit = usageMs > limitMs;

    const weekBars = [
      DailyBarItem(dayLabel: 'S', value: 1.6, semanticLabel: 'Saturday 1h 36m'),
      DailyBarItem(dayLabel: 'S', value: 2.1, semanticLabel: 'Sunday 2h 06m'),
      DailyBarItem(dayLabel: 'M', value: 1.8, semanticLabel: 'Monday 1h 48m'),
      DailyBarItem(dayLabel: 'T', value: 1.2, semanticLabel: 'Tuesday 1h 12m'),
      DailyBarItem(dayLabel: 'W', value: 2.4, semanticLabel: 'Wednesday 2h 24m'),
      DailyBarItem(dayLabel: 'T', value: 1.9, semanticLabel: 'Thursday 1h 54m'),
      DailyBarItem(dayLabel: 'F', value: 1.8, semanticLabel: 'Friday (Today) 1h 48m'),
    ];

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: OlozSpacing.screenPaddingMobile,
            vertical: OlozSpacing.s16,
          ),
          children: [
            // Top Bar: Back arrow and app title block
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: colors.text,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                AppIconTile(icon: appIcon),
                const SizedBox(width: OlozSpacing.s12),
                Text(
                  appName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
              ],
            ),

            const SizedBox(height: OlozSpacing.s20),

            // Card 1: "1h 48m" large, label "Today", progress bar of limit, delta chip "−18%"
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const DeltaChip(delta: -18),
                    ],
                  ),
                  const SizedBox(height: OlozSpacing.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          OlozFormatters.formatDurationMs(usageMs),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: colors.text,
                          ),
                        ),
                      ),
                      Text(
                        '${OlozFormatters.formatDurationMs(limitMs)} limit',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isOverLimit ? colors.error : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: OlozSpacing.s16),
                  // Progress bar: danger-soft color if over limit, else indigo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 6,
                      color: isOverLimit ? colors.error.withValues(alpha: 0.2) : colors.chartSoft,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (usageMs / limitMs).clamp(0.05, 1.0),
                        child: Container(
                          color: isOverLimit ? colors.error : colors.chart,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: OlozSpacing.s16),

            // Card 2: 7-day bar chart, today last and bold
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
                    'This week',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: OlozSpacing.s20),
                  const WeekBars(
                    items: weekBars,
                  ),
                ],
              ),
            ),

            const SizedBox(height: OlozSpacing.s16),

            // Two small cards: "142 reels" (peach icon) and "23 opens"
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(OlozSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.swipe_outlined, size: 18, color: colors.reel),
                            const SizedBox(width: 6),
                            Text(
                              'Reels',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OlozSpacing.s12),
                        Text(
                          '$reelsCount',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: OlozSpacing.s12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(OlozSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.launch_outlined, size: 18, color: colors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Opens',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OlozSpacing.s12),
                        Text(
                          '$opensCount',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: OlozSpacing.s24),

            // Primary button "Set limit" in #5870C2, 48px, no icon
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  unawaited(
                    SetLimitSheet.show(
                      context,
                      package: package,
                      appName: appName,
                      initialLimitMs: limitMs,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Set limit',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: OlozSpacing.s12),
          ],
        ),
      ),
    );
  }
}

String _getAppName(String package) {
  if (package.contains('instagram')) return 'Instagram';
  if (package.contains('musically') || package.contains('tiktok')) return 'TikTok';
  if (package.contains('youtube')) return 'YouTube';
  if (package.contains('facebook')) return 'Facebook';
  if (package.contains('twitter')) return 'X';
  if (package.contains('chrome')) return 'Chrome';
  if (package.contains('whatsapp')) return 'WhatsApp';
  if (package.contains('reddit')) return 'Reddit';
  return package;
}

IconData _getAppIcon(String package) {
  if (package.contains('instagram')) return Icons.camera_alt_outlined;
  if (package.contains('musically') || package.contains('tiktok')) {
    return Icons.music_note_outlined;
  }
  if (package.contains('youtube')) return Icons.play_arrow_outlined;
  if (package.contains('facebook')) return Icons.thumb_up_alt_outlined;
  if (package.contains('twitter')) return Icons.close_outlined;
  if (package.contains('chrome')) return Icons.circle_outlined;
  if (package.contains('whatsapp')) return Icons.chat_bubble_outline;
  if (package.contains('reddit')) return Icons.reddit_outlined;
  return Icons.apps_outlined;
}
