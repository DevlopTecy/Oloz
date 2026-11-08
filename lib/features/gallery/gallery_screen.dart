import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/app_row.dart';
import 'package:oloz/core/widgets/duration_stepper.dart';
import 'package:oloz/core/widgets/empty_state.dart';
import 'package:oloz/core/widgets/oloz_toggle.dart';
import 'package:oloz/core/widgets/platform_bar.dart';
import 'package:oloz/core/widgets/preset_pills.dart';
import 'package:oloz/core/widgets/ring.dart';
import 'package:oloz/core/widgets/segmented_pill.dart';
import 'package:oloz/core/widgets/stat_card.dart';
import 'package:oloz/core/widgets/thirty_day_bars.dart';
import 'package:oloz/core/widgets/week_bars.dart';

/// Phase 1 Component Gallery for inspecting and verifying all reusable Oloz widgets.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _segmentedIndex = 0;
  bool _toggleState = true;
  int _stepperMinutes = 90;
  int _presetMinutes = 90;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    final weekBarsSample = [
      const DailyBarItem(dayLabel: 'S', value: 3.2, semanticLabel: 'Saturday 3h 12m'),
      const DailyBarItem(dayLabel: 'M', value: 4.5, semanticLabel: 'Monday 4h 30m'),
      const DailyBarItem(dayLabel: 'T', value: 2.8, semanticLabel: 'Tuesday 2h 48m'),
      const DailyBarItem(dayLabel: 'W', value: 5.1, semanticLabel: 'Wednesday 5h 06m'),
      const DailyBarItem(dayLabel: 'T', value: 4, semanticLabel: 'Thursday 4h 00m'),
      const DailyBarItem(dayLabel: 'F', value: 3.9, semanticLabel: 'Friday 3h 54m'),
      const DailyBarItem(dayLabel: 'S', value: 5.1, semanticLabel: 'Today 5h 07m'),
    ];

    final platformItems = [
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

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Oloz Component Gallery'),
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(OlozSpacing.s20),
        children: [
          Text(
            'Screens Showcase',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('Onboarding 1: Welcome'),
                onPressed: () => context.push('/onboarding/welcome'),
              ),
              ActionChip(
                label: const Text('Onboarding 2: Permission'),
                onPressed: () => context.push('/onboarding/permission'),
              ),
              ActionChip(
                label: const Text('Onboarding 3: Goal'),
                onPressed: () => context.push('/onboarding/goal'),
              ),
              ActionChip(
                label: const Text('App Detail (Instagram)'),
                onPressed: () => context.push('/apps/com.instagram.android'),
              ),
              ActionChip(
                label: const Text('Over-limit Alert'),
                onPressed: () => context.push('/alert/com.instagram.android'),
              ),
              ActionChip(
                label: const Text('Live Counter Pill'),
                onPressed: () => context.push('/counter-preview'),
              ),
              ActionChip(
                label: const Text('Empty State First Day'),
                onPressed: () => context.push('/empty-preview'),
              ),
            ],
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'Stat Cards & Delta Chips',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '5h 07m',
                  label: 'Screen time',
                  deltaPercentage: -14,
                ),
              ),
              SizedBox(width: OlozSpacing.s12),
              Expanded(
                child: StatCard(
                  value: '286',
                  label: 'Reels',
                  deltaPercentage: -8,
                ),
              ),
            ],
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'Segmented Pill Control',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          Center(
            child: SegmentedPill(
              options: const ['Day', 'Week', 'Month'],
              selectedIndex: _segmentedIndex,
              onChanged: (val) => setState(() => _segmentedIndex = val),
            ),
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'Circular Progress Rings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Ring(
                  size: 148,
                  progress: 0.82,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '286',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      Text(
                        '64 left',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: OlozSpacing.s16),
                Ring(
                  size: 148,
                  progress: 0.85,
                  colorType: RingColor.indigo,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '5h 07m',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      Text(
                        '6h limit',
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
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'Weekly Charts (Indigo & Peach)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OlozSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Screen time (last 7 days)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: OlozSpacing.s12),
                  WeekBars(
                    items: weekBarsSample,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OlozSpacing.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OlozSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reels (last 7 days)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: OlozSpacing.s12),
                  WeekBars(
                    items: weekBarsSample,
                    barTheme: WeekBarsTheme.peach,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'Platform Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OlozSpacing.s16),
              child: PlatformBar(items: platformItems),
            ),
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'App Rows',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(OlozSpacing.s12),
              child: Column(
                children: [
                  AppRow(
                    name: 'Instagram',
                    timeFormatted: '1h 48m',
                    progress: 0.35,
                    reelsCount: 142,
                    deviceTag: 'Phone',
                  ),
                  AppRow(
                    name: 'TikTok',
                    timeFormatted: '1h 12m',
                    progress: 0.23,
                    reelsCount: 84,
                    deviceTag: 'Phone',
                  ),
                  AppRow(
                    name: 'YouTube',
                    timeFormatted: '45m',
                    progress: 0.15,
                    reelsCount: 48,
                    deviceTag: 'Phone',
                  ),
                  AppRow(
                    name: 'Chrome',
                    timeFormatted: '22m',
                    progress: 0.08,
                    deviceTag: 'PC',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'Controls: Toggle, Stepper, Presets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OlozSpacing.s16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remind me',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colors.text,
                        ),
                      ),
                      OlozToggle(
                        value: _toggleState,
                        onChanged: (val) => setState(() => _toggleState = val),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  DurationStepper(
                    durationMinutes: _stepperMinutes,
                    onChanged: (val) => setState(() => _stepperMinutes = val),
                  ),
                  const SizedBox(height: OlozSpacing.s16),
                  PresetPills(
                    presets: const [
                      PresetOption(label: '45m', minutes: 45),
                      PresetOption(label: '1h', minutes: 60),
                      PresetOption(label: '1h 30m', minutes: 90),
                      PresetOption(label: '2h', minutes: 120),
                    ],
                    selectedMinutes: _presetMinutes,
                    onSelected: (val) {
                      setState(() {
                        _presetMinutes = val;
                        _stepperMinutes = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            '30-Day Trend Bars',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OlozSpacing.s16),
              child: ThirtyDayBars(
                values: List.generate(30, (i) => 10.0 + (i * 3) % 40),
                barThemeColor: colors.reel,
                barSoftColor: colors.reelSoft,
              ),
            ),
          ),
          const SizedBox(height: OlozSpacing.s24),

          Text(
            'First-Day Empty State',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OlozSpacing.s12),
          Card(
            child: EmptyState(
              message: 'Nothing tracked yet',
              actionLabel: 'Allow usage access',
              onAction: () {},
            ),
          ),
          const SizedBox(height: OlozSpacing.s48),
        ],
      ),
    );
  }
}

