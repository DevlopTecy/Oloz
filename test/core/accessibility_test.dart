import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/core/widgets/app_row.dart';
import 'package:oloz/core/widgets/delta_chip.dart';
import 'package:oloz/core/widgets/duration_stepper.dart';
import 'package:oloz/core/widgets/oloz_nav_bar.dart';
import 'package:oloz/core/widgets/oloz_toggle.dart';
import 'package:oloz/core/widgets/preset_pills.dart';
import 'package:oloz/core/widgets/ring.dart';
import 'package:oloz/core/widgets/segmented_pill.dart';
import 'package:oloz/core/widgets/stat_card.dart';
import 'package:oloz/core/widgets/thirty_day_bars.dart';
import 'package:oloz/core/widgets/week_bars.dart';

void main() {
  group('Accessibility & TalkBack Semantics', () {
    testWidgets('Ring exposes semantic progress percentage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: const Scaffold(
            body: Ring(
              progress: 0.82,
              semanticLabel: 'Reels goal progress 82%',
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(Ring)),
        matchesSemantics(
          label: 'Reels goal progress 82%',
          value: '82%',
        ),
      );
      handle.dispose();
    });

    testWidgets('DeltaChip exposes descriptive decrease/increase label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: const Scaffold(
            body: DeltaChip(delta: -14),
          ),
        ),
      );

      expect(find.bySemanticsLabel('14% decrease'), findsOneWidget);
    });

    testWidgets('AppRow has combined semantic description', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: Scaffold(
            body: AppRow(
              name: 'Instagram',
              timeFormatted: '1h 48m',
              reelsCount: 142,
              progress: 0.8,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Instagram, 1h 48m, 142 reels')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('DurationStepper buttons have semantic labels and button traits', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: Scaffold(
            body: DurationStepper(
              durationMinutes: 90,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Decrease duration'), findsOneWidget);
      expect(find.bySemanticsLabel('Increase duration'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('PresetPills and SegmentedPill expose selected semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: Scaffold(
            body: Column(
              children: [
                PresetPills(
                  presets: const [
                    DurationPreset(label: '30m', minutes: 30),
                    DurationPreset(label: '1h', minutes: 60),
                  ],
                  selectedMinutes: 30,
                  onSelected: (_) {},
                ),
                SegmentedPill(
                  options: const ['Day', 'Week', 'Month'],
                  selectedIndex: 0,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('30m'), findsWidgets);
      expect(find.bySemanticsLabel('Day'), findsWidgets);
      handle.dispose();
    });

    testWidgets('OlozToggle exposes toggle semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: Scaffold(
            body: OlozToggle(
              value: true,
              semanticLabel: 'Notifications',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(OlozToggle)),
        matchesSemantics(
          label: 'Notifications',
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('WeekBars and ThirtyDayBars announce chart summaries', (tester) async {
      final handle = tester.ensureSemantics();
      final weekItems = List.generate(
        7,
        (i) => DailyBarItem(
          dayLabel: ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
          value: 100 + i * 20.0,
          semanticLabel: 'Day ${i + 1}: ${100 + i * 20}',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: Scaffold(
            body: Column(
              children: [
                WeekBars(items: weekItems),
                ThirtyDayBars(values: List.generate(30, (i) => i * 10.0)),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Day 1: 100'), findsOneWidget);
      expect(find.bySemanticsLabel('30-day activity trend chart'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Font Scaling 1.3x and 320dp Width', () {
    testWidgets('Key widgets scale to 1.3x at 320dp width without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(1.3),
          ),
          child: MaterialApp(
            theme: OlozTheme.lightTheme(),
            home: Scaffold(
              body: ListView(
                children: [
                  const StatCard(
                    value: '5h 07m',
                    label: 'Screen time today',
                    delta: -14,
                  ),
                  const SizedBox(height: 16),
                  const AppRow(
                    name: 'Instagram',
                    timeFormatted: '1h 48m',
                    reelsCount: 142,
                    progress: 0.8,
                  ),
                  const SizedBox(height: 16),
                  PresetPills(
                    presets: const [
                      DurationPreset(label: '30m', minutes: 30),
                      DurationPreset(label: '1h', minutes: 60),
                      DurationPreset(label: '1h 30m', minutes: 90),
                    ],
                    selectedMinutes: 30,
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 16),
                  OlozNavBar(
                    currentTab: OlozTab.home,
                    onTabSelected: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
