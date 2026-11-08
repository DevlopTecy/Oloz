import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/utils/formatters.dart';
import 'package:oloz/core/widgets/app_icon_tile.dart';
import 'package:oloz/core/widgets/delta_chip.dart';
import 'package:oloz/core/widgets/week_bars.dart';
import 'package:oloz/data/db/daos/usage_dao.dart';
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

    final summaryAsync = ref.watch(appDetailSummaryProvider(package));
    final summary = summaryAsync.value;

    final seriesAsync = ref.watch(appDailySeriesProvider(package));
    final series = seriesAsync.value;

    final isInstagram = package.contains('instagram');
    final appName = summary?.label ?? (isInstagram ? 'Instagram' : _getAppName(package));
    final appIcon = _getAppIcon(package);

    final usageMs = summary?.foregroundMs ?? (isInstagram ? 108 * 60 * 1000 : 0);
    final reelsCount = summary?.reels ?? (isInstagram ? 142 : 0);
    final opensCount = summary?.opens ?? (isInstagram ? 23 : 0);
    final isOverLimit = limitMs > 0 && usageMs > limitMs;

    final refDate = ref.watch(referenceDateProvider);
    final weekBars = _buildAppWeekBars(series, refDate, usageMs);

    // Calculate delta compared to yesterday if available
    var deltaPct = -18;
    if (series != null && series.length >= 2) {
      final yestMs = series[series.length - 2].foregroundMs;
      if (yestMs > 0) {
        deltaPct = (((usageMs - yestMs) / yestMs) * 100).round();
      }
    }

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
                AppIconTile(packageNameOrName: package, icon: appIcon),
                const SizedBox(width: OlozSpacing.s12),
                Expanded(
                  child: Text(
                    appName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
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
                      DeltaChip(delta: deltaPct),
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
                  WeekBars(
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

List<DailyBarItem> _buildAppWeekBars(
  List<DailyUsagePoint>? series,
  DateTime refDate,
  int todayMs,
) {
  final dayFormatter = DateFormat('E');
  final fullFormatter = DateFormat('EEEE, MMM d');

  if (series == null || series.length < 7) {
    return List.generate(7, (i) {
      final date = refDate.subtract(Duration(days: 6 - i));
      final dayInitial = dayFormatter.format(date).substring(0, 1);
      final isToday = i == 6;
      final ms = isToday ? todayMs : 0;
      final durStr = OlozFormatters.formatDurationMs(ms);
      return DailyBarItem(
        dayLabel: dayInitial,
        value: ms / (60 * 60 * 1000),
        formattedValue: durStr,
        fullDayName: fullFormatter.format(date),
        semanticLabel:
            '${fullFormatter.format(date)}${isToday ? ' (Today)' : ''}: $durStr',
      );
    });
  }

  return List.generate(7, (i) {
    final pt = series[i];
    final date =
        DateTime.tryParse(pt.day) ?? refDate.subtract(Duration(days: 6 - i));
    final dayInitial = dayFormatter.format(date).substring(0, 1);
    final isToday = i == 6;
    final ms = isToday && pt.foregroundMs == 0 ? todayMs : pt.foregroundMs;
    final durStr = OlozFormatters.formatDurationMs(ms);
    return DailyBarItem(
      dayLabel: dayInitial,
      value: ms / (60 * 60 * 1000),
      formattedValue: durStr,
      fullDayName: fullFormatter.format(date),
      semanticLabel:
          '${fullFormatter.format(date)}${isToday ? ' (Today)' : ''}: $durStr',
    );
  });
}
