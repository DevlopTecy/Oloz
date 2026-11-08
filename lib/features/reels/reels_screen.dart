import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/delta_chip.dart';
import 'package:oloz/core/widgets/ring.dart';
import 'package:oloz/core/widgets/thirty_day_bars.dart';
import 'package:oloz/core/widgets/week_bars.dart';
import 'package:oloz/data/db/daos/reel_dao.dart';
import 'package:oloz/data/providers/app_providers.dart';

class ReelsScreen extends ConsumerWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;

    final totalReelsAsync = ref.watch(totalReelsProvider);
    final platformSplitAsync = ref.watch(platformSplitProvider);
    final thirtyDayReelsAsync = ref.watch(thirtyDayReelsProvider);

    final totalReels = totalReelsAsync.value ?? 0;
    const dailyGoal = 350;
    final remaining = (dailyGoal - totalReels).clamp(0, dailyGoal);
    final progress = (totalReels / dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: isDesktop
            ? _DesktopReelsContent(
                totalReels: totalReels,
                remaining: remaining,
                progress: progress,
                platformSplitAsync: platformSplitAsync,
                thirtyDayReelsAsync: thirtyDayReelsAsync,
              )
            : _MobileReelsContent(
                totalReels: totalReels,
                remaining: remaining,
                progress: progress,
                platformSplitAsync: platformSplitAsync,
                thirtyDayReelsAsync: thirtyDayReelsAsync,
              ),
      ),
    );
  }
}

class _MobileReelsContent extends StatelessWidget {
  const _MobileReelsContent({
    required this.totalReels,
    required this.remaining,
    required this.progress,
    required this.platformSplitAsync,
    required this.thirtyDayReelsAsync,
  });

  final int totalReels;
  final int remaining;
  final double progress;
  final AsyncValue<List<PlatformReelSummary>> platformSplitAsync;
  final AsyncValue<List<DailyReelPoint>> thirtyDayReelsAsync;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    final dayFormatter = DateFormat('E');
    final now = DateTime.now();
    final points = thirtyDayReelsAsync.value;
    final last7Points = points != null && points.length >= 7
        ? points.sublist(points.length - 7)
        : null;

    final weekBars = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayInitial = dayFormatter.format(date).substring(0, 1);
      final count =
          last7Points != null ? last7Points[i].count.toDouble() : 0.0;
      final isToday = i == 6;
      return DailyBarItem(
        dayLabel: dayInitial,
        value: count,
        semanticLabel:
            '${dayFormatter.format(date)}${isToday ? ' (Today)' : ''}: ${count.toInt()} reels',
      );
    });

    final platformItems = _buildPlatformItems(platformSplitAsync.value, colors);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: OlozSpacing.screenPaddingMobile,
        vertical: OlozSpacing.s16,
      ),
      children: [
        // Title "Reels"
        Text(
          'Reels',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: colors.text,
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // Goal card: Peach ring showing 82%, center "286" & "Reels today", "64 left" below
        Container(
          padding: const EdgeInsets.all(OlozSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              const SizedBox(height: OlozSpacing.s12),
              Ring(
                progress: progress,
                size: 160,
                color: colors.reel,
                trackColor: colors.reelSoft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalReels',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Reels today',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OlozSpacing.s16),
              Text(
                '$remaining left',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: OlozSpacing.s8),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // "By platform" card (4 rows, sentence case, peach bars in decreasing tints)
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
                'By platform',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: OlozSpacing.s16),
              if (platformItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: OlozSpacing.s8),
                  child: Center(
                    child: Text(
                      'No reels detected yet today.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...platformItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: OlozSpacing.s12),
                      child: _PlatformReelRow(item: item, colors: colors),
                    )),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // "Last 7 days" card (all bars peach, today last solid peach, others peach-soft)
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
                'Last 7 days',
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
                accentColor: colors.reel,
                defaultColor: colors.reelSoft,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopReelsContent extends StatelessWidget {
  const _DesktopReelsContent({
    required this.totalReels,
    required this.remaining,
    required this.progress,
    required this.platformSplitAsync,
    required this.thirtyDayReelsAsync,
  });

  final int totalReels;
  final int remaining;
  final double progress;
  final AsyncValue<List<PlatformReelSummary>> platformSplitAsync;
  final AsyncValue<List<DailyReelPoint>> thirtyDayReelsAsync;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final platformItems = _buildPlatformItems(platformSplitAsync.value, colors);

    // 30 days values
    final thirtyPoints = thirtyDayReelsAsync.value;
    final thirtyValues = thirtyPoints != null && thirtyPoints.length >= 30
        ? thirtyPoints.map((p) => p.count.toDouble()).toList()
        : List.generate(30, (i) {
            if (i == 29) return 286.0;
            return 180.0 + ((i * 17) % 140);
          });

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: OlozSpacing.screenPaddingDesktop,
        vertical: OlozSpacing.s24,
      ),
      children: [
        // Title: "Reels"
        Text(
          'Reels',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: colors.text,
          ),
        ),

        const SizedBox(height: OlozSpacing.s24),

        // Row of 2 big cards: Big card with sparkline & Goal card with ring
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big card: 286 large, "reels today", delta chip, small peach sparkline
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalReels',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontFeatures: const [FontFeature.tabularFigures()],
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'reels today',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const DeltaChip(delta: -8),
                      ],
                    ),
                    const SizedBox(height: OlozSpacing.s24),
                    // Peach sparkline for last 24h
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _PeachSparklinePainter(color: colors.reel),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: OlozSpacing.s16),

            // Goal card: peach ring 82%, center "64 left"
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
                  children: [
                    Ring(
                      progress: progress,
                      size: 130,
                      color: colors.reel,
                      trackColor: colors.reelSoft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$remaining left',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontFeatures: const [FontFeature.tabularFigures()],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'of 350 goal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: OlozSpacing.s20),

        // By platform card (4 rows with counts)
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
                'By platform',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: OlozSpacing.s16),
              if (platformItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: OlozSpacing.s8),
                  child: Center(
                    child: Text(
                      'No reels detected yet today.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...platformItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: OlozSpacing.s12),
                      child: _PlatformReelRow(item: item, colors: colors),
                    )),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s20),

        // Last 30 days chart
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
                    'Last 30 days',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.reelSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Today: $totalReels',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onReelSoft,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OlozSpacing.s24),
              ThirtyDayBars(
                values: thirtyValues,
                color: colors.reelSoft,
                todayColor: colors.reel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlatformReelsItemData {
  const _PlatformReelsItemData({
    required this.name,
    required this.count,
    required this.fraction,
    required this.barColor,
    required this.icon,
  });

  final String name;
  final int count;
  final double fraction;
  final Color barColor;
  final IconData icon;
}

List<_PlatformReelsItemData> _buildPlatformItems(
  List<PlatformReelSummary>? platformList,
  OlozColors colors,
) {
  if (platformList == null || platformList.isEmpty) {
    return const <_PlatformReelsItemData>[];
  }

  final maxCount = platformList.fold<int>(
    1,
    (m, p) => p.count > m ? p.count : m,
  );

  return platformList.map((p) {
    final name = p.name;
    final count = p.count;
    final fraction = (count / maxCount).clamp(0.08, 1.0);
    return _PlatformReelsItemData(
      name: name,
      count: count,
      fraction: fraction,
      barColor: colors.reel.withValues(alpha: 0.5 + 0.5 * fraction),
      icon: _getPlatformIcon(name),
    );
  }).toList();
}

IconData _getPlatformIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('instagram')) return Icons.camera_alt_outlined;
  if (lower.contains('tiktok')) return Icons.music_note_outlined;
  if (lower.contains('youtube')) return Icons.play_arrow_outlined;
  if (lower.contains('facebook')) return Icons.thumb_up_alt_outlined;
  return Icons.play_circle_outline;
}

class _PlatformReelRow extends StatelessWidget {
  const _PlatformReelRow({
    required this.item,
    required this.colors,
  });

  final _PlatformReelsItemData item;
  final OlozColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 16, color: colors.textSecondary),
                ),
                const SizedBox(width: OlozSpacing.s12),
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
              ],
            ),
            Text(
              '${item.count}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontFeatures: const [FontFeature.tabularFigures()],
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 5,
            width: double.infinity,
            color: colors.reelSoft,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: item.fraction,
              child: Container(color: item.barColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _PeachSparklinePainter extends CustomPainter {
  const _PeachSparklinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      0.2, 0.35, 0.25, 0.6, 0.45, 0.7, 0.55, 0.8, 0.65, 0.9, 0.75, 0.82
    ];
    final path = Path();
    final dx = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PeachSparklinePainter oldDelegate) =>
      color != oldDelegate.color;
}
