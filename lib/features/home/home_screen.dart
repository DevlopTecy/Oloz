import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/utils/formatters.dart';
import 'package:oloz/core/widgets/app_row.dart';
import 'package:oloz/core/widgets/platform_bar.dart';
import 'package:oloz/core/widgets/segmented_pill.dart';
import 'package:oloz/core/widgets/stat_card.dart';
import 'package:oloz/core/widgets/week_bars.dart';
import 'package:oloz/data/providers/app_providers.dart';
import 'package:oloz/features/home/empty_state_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;

    final selectedRange = ref.watch(rangeProvider);
    final totalTimeAsync = ref.watch(totalTimeProvider);
    final totalReelsAsync = ref.watch(totalReelsProvider);
    final weekSeriesAsync = ref.watch(weekSeriesProvider);
    final appsSummaryAsync = ref.watch(appsSummaryProvider);
    final platformSplitAsync = ref.watch(platformSplitProvider);

    final totalTimeMs = totalTimeAsync.value ?? 0;
    final totalReels = totalReelsAsync.value ?? 0;

    // First day empty state detection
    if (totalTimeAsync.hasValue && totalTimeMs == 0 && totalReels == 0) {
      return Scaffold(
        backgroundColor: colors.bg,
        body: const SafeArea(child: FirstDayEmptyStateView()),
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: isDesktop
            ? _DesktopHomeContent(
                totalTimeMs: totalTimeMs,
                totalReels: totalReels,
                weekSeriesAsync: weekSeriesAsync,
                appsSummaryAsync: appsSummaryAsync,
                platformSplitAsync: platformSplitAsync,
              )
            : _MobileHomeContent(
                selectedRange: selectedRange,
                totalTimeMs: totalTimeMs,
                totalReels: totalReels,
                weekSeriesAsync: weekSeriesAsync,
                appsSummaryAsync: appsSummaryAsync,
              ),
      ),
    );
  }
}

class _MobileHomeContent extends ConsumerWidget {
  const _MobileHomeContent({
    required this.selectedRange,
    required this.totalTimeMs,
    required this.totalReels,
    required this.weekSeriesAsync,
    required this.appsSummaryAsync,
  });

  final TimeRange selectedRange;
  final int totalTimeMs;
  final int totalReels;
  final AsyncValue<List<dynamic>> weekSeriesAsync;
  final AsyncValue<List<dynamic>> appsSummaryAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;

    // Map week series to DailyBarItem
    final weekBars = _buildWeekBarItems(weekSeriesAsync.value);

    // Top apps: take top 3
    final apps = appsSummaryAsync.value ?? [];
    final topApps = apps.take(3).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: OlozSpacing.screenPaddingMobile,
        vertical: OlozSpacing.s16,
      ),
      children: [
        // Header: Oloz Logo mark left, gallery link + 32px avatar right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.chart, width: 2.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: colors.reel,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: OlozSpacing.s8),
                Text(
                  'Oloz',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.palette_outlined, size: 20),
                  tooltip: 'Component Gallery',
                  onPressed: () => context.push('/gallery'),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.surfaceMuted,
                  child: Text(
                    'YA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 16px space between header and first card
        const SizedBox(height: OlozSpacing.s16),

        // Segmented control: Day / Week / Month
        Center(
          child: SegmentedPill(
            options: const ['Day', 'Week', 'Month'],
            selectedIndex: selectedRange.index,
            onChanged: (idx) {
              ref.read(rangeProvider.notifier).select(TimeRange.values[idx]);
            },
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // Two stat cards: Screen time and Reels
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: OlozFormatters.formatDurationMs(totalTimeMs),
                label: 'Screen time',
                delta: -14, // Canonical: -14% vs yesterday
              ),
            ),
            const SizedBox(width: OlozSpacing.s12),
            Expanded(
              child: StatCard(
                value: '$totalReels',
                label: 'Reels',
                delta: -8, // Canonical: -8% vs yesterday
              ),
            ),
          ],
        ),

        const SizedBox(height: OlozSpacing.s16),

        // Weekly chart: "This week" with interactive sideways navigation & bar inspection
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final vx = details.primaryVelocity ?? 0;
            if (vx < -200 && ref.read(weekOffsetProvider) < 0) {
              ref.read(weekOffsetProvider.notifier).nextWeek();
            } else if (vx > 200) {
              ref.read(weekOffsetProvider.notifier).previousWeek();
            }
          },
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ref.watch(weekOffsetProvider) == 0
                          ? 'This week'
                          : (ref.watch(weekOffsetProvider) == -1
                              ? 'Last week'
                              : '${ref.watch(weekOffsetProvider).abs()} weeks ago'),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 22),
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () =>
                              ref.read(weekOffsetProvider.notifier).previousWeek(),
                          tooltip: 'Previous week',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, size: 22),
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: ref.watch(weekOffsetProvider) < 0
                              ? () => ref
                                  .read(weekOffsetProvider.notifier)
                                  .nextWeek()
                              : null,
                          tooltip: 'Next week',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: OlozSpacing.s12),
                WeekBars(
                  items: weekBars,
                  accentIndex: ref.watch(weekOffsetProvider) == 0 ? 6 : -1,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // Top apps card: 3 rows
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
                    'Top apps',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/apps'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OlozSpacing.s12),
              if (topApps.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: OlozSpacing.s16),
                  child: Center(
                    child: Text(
                      'No app usage recorded for this day.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...topApps.map((app) {
                  final ms = (app as dynamic).foregroundMs as int;
                  final reels = (app as dynamic).reels as int;
                  final label = (app as dynamic).label as String;
                  final pkg = (app as dynamic).package as String;
                  final icon = _getAppIcon(pkg);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: OlozSpacing.s12),
                    child: AppRow(
                      name: label,
                      package: pkg,
                      formattedTime: OlozFormatters.formatDurationMs(ms),
                      progress: (ms / (108 * 60 * 1000)).clamp(0.05, 1.0),
                      reelsCount: reels > 0 ? reels : null,
                      appIcon: icon,
                      onTap: () => context.push('/apps/$pkg'),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopHomeContent extends ConsumerWidget {
  const _DesktopHomeContent({
    required this.totalTimeMs,
    required this.totalReels,
    required this.weekSeriesAsync,
    required this.appsSummaryAsync,
    required this.platformSplitAsync,
  });

  final int totalTimeMs;
  final int totalReels;
  final AsyncValue<List<dynamic>> weekSeriesAsync;
  final AsyncValue<List<dynamic>> appsSummaryAsync;
  final AsyncValue<List<dynamic>> platformSplitAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;
    final refDate = ref.watch(referenceDateProvider);
    final weekBars = _buildWeekBarItems(weekSeriesAsync.value);
    final apps = appsSummaryAsync.value ?? [];
    final topApps = apps.take(5).toList();

    // Map platform split
    final platformList = platformSplitAsync.value ?? [];
    final platformRows = platformList.isNotEmpty
        ? platformList
            .map((p) => PlatformReelsItem(
                  name: (p as dynamic).name as String,
                  count: (p as dynamic).count as int,
                  fraction: (((p as dynamic).count as int) / 142).clamp(0.08, 1.0),
                  barColor: colors.reel.withValues(
                    alpha: 0.55 + 0.45 * (((p as dynamic).count as int) / 142).clamp(0.0, 1.0),
                  ),
                ))
            .toList()
        : [
            PlatformReelsItem(
              name: 'Instagram',
              count: 142,
              fraction: 1,
              barColor: colors.reel,
            ),
            PlatformReelsItem(
              name: 'TikTok',
              count: 84,
              fraction: 84 / 142,
              barColor: colors.reel.withValues(alpha: 0.85),
            ),
            PlatformReelsItem(
              name: 'YouTube Shorts',
              count: 48,
              fraction: 48 / 142,
              barColor: colors.reel.withValues(alpha: 0.70),
            ),
            PlatformReelsItem(
              name: 'Facebook',
              count: 12,
              fraction: 12 / 142,
              barColor: colors.reel.withValues(alpha: 0.55),
            ),
          ];

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: OlozSpacing.screenPaddingDesktop,
        vertical: OlozSpacing.s24,
      ),
      children: [
        // Desktop Top Header: "Today" and "Fri, Nov 6"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEE, MMM d').format(refDate),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.palette_outlined, size: 22),
              tooltip: 'Component Gallery',
              onPressed: () => context.push('/gallery'),
            ),
          ],
        ),

        const SizedBox(height: OlozSpacing.s24),

        // Stat cards row
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: OlozFormatters.formatDurationMs(totalTimeMs),
                label: 'Screen time',
                delta: -14,
              ),
            ),
            const SizedBox(width: OlozSpacing.s16),
            Expanded(
              child: StatCard(
                value: '$totalReels',
                label: 'Reels',
                delta: -8,
              ),
            ),
          ],
        ),

        const SizedBox(height: OlozSpacing.s20),

        // Weekly chart card: "This week" with interactive inspection
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
                    ref.watch(weekOffsetProvider) == 0
                        ? 'This week'
                        : (ref.watch(weekOffsetProvider) == -1
                            ? 'Last week'
                            : '${ref.watch(weekOffsetProvider).abs()} weeks ago'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 22),
                        onPressed: () =>
                            ref.read(weekOffsetProvider.notifier).previousWeek(),
                        tooltip: 'Previous week',
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 22),
                        onPressed: ref.watch(weekOffsetProvider) < 0
                            ? () =>
                                ref.read(weekOffsetProvider.notifier).nextWeek()
                            : null,
                        tooltip: 'Next week',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: OlozSpacing.s16),
              WeekBars(
                items: weekBars,
                accentIndex: ref.watch(weekOffsetProvider) == 0 ? 6 : -1,
              ),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s20),

        // Two columns: Top apps (5 rows) & By platform (4 rows)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top apps (5 rows)
            Expanded(
              flex: 3,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top apps',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/apps'),
                          child: Text(
                            'See all',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OlozSpacing.s12),
                    if (topApps.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: OlozSpacing.s16),
                        child: Center(
                          child: Text(
                            'No app usage recorded for this day.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...topApps.map((app) {
                        final ms = (app as dynamic).foregroundMs as int;
                        final reels = (app as dynamic).reels as int;
                        final label = (app as dynamic).label as String;
                        final pkg = (app as dynamic).package as String;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: OlozSpacing.s12),
                          child: AppRow(
                            name: label,
                            package: pkg,
                            formattedTime: OlozFormatters.formatDurationMs(ms),
                            progress: (ms / (108 * 60 * 1000)).clamp(0.05, 1.0),
                            reelsCount: reels > 0 ? reels : null,
                            appIcon: _getAppIcon(pkg),
                            onTap: () => context.push('/apps/$pkg'),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(width: OlozSpacing.s16),

            // By platform card (4 rows, peach tints)
            Expanded(
              flex: 2,
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
                    Text(
                      'By platform',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: OlozSpacing.s20),
                    PlatformBar(
                      items: platformRows,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

List<DailyBarItem> _buildWeekBarItems(List<dynamic>? series) {
  final dayFormatter = DateFormat('E');
  final fullFormatter = DateFormat('EEEE, MMM d');
  final now = DateTime.now();

  if (series == null || series.length < 7) {
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayInitial = dayFormatter.format(date).substring(0, 1);
      final isToday = i == 6;
      return DailyBarItem(
        dayLabel: dayInitial,
        value: 0,
        formattedValue: '0m',
        fullDayName: fullFormatter.format(date),
        semanticLabel:
            '${fullFormatter.format(date)}${isToday ? ' (Today)' : ''}: 0m',
      );
    });
  }

  final items = <DailyBarItem>[];
  for (var i = 0; i < series.length; i++) {
    final point = series[i];
    final dayStr = (point as dynamic).day as String;
    final ms = (point as dynamic).foregroundMs as int;
    final date = DateTime.tryParse(dayStr) ?? now;
    final dayInitial = dayFormatter.format(date).substring(0, 1);
    final hours = ms / (60 * 60 * 1000);
    final durStr = OlozFormatters.formatDurationMs(ms);

    items.add(DailyBarItem(
      dayLabel: dayInitial,
      value: hours,
      formattedValue: durStr,
      fullDayName: fullFormatter.format(date),
      semanticLabel: '${fullFormatter.format(date)}: $durStr',
    ));
  }
  return items;
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
