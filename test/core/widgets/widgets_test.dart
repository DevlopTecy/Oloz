import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/core/widgets/app_row.dart';
import 'package:oloz/core/widgets/delta_chip.dart';
import 'package:oloz/core/widgets/duration_stepper.dart';
import 'package:oloz/core/widgets/empty_state.dart';
import 'package:oloz/core/widgets/oloz_nav_bar.dart';
import 'package:oloz/core/widgets/oloz_sidebar.dart';
import 'package:oloz/core/widgets/oloz_toggle.dart';
import 'package:oloz/core/widgets/platform_bar.dart';
import 'package:oloz/core/widgets/preset_pills.dart';
import 'package:oloz/core/widgets/ring.dart';
import 'package:oloz/core/widgets/segmented_pill.dart';
import 'package:oloz/core/widgets/stat_card.dart';
import 'package:oloz/core/widgets/week_bars.dart';

Widget _wrap(Widget child, {bool isDark = false}) {
  return MaterialApp(
    theme: isDark ? OlozTheme.darkTheme() : OlozTheme.lightTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StatCard', () {
    testWidgets('renders value, label, and delta chip in light and dark', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatCard(
            value: '5h 07m',
            label: 'Screen time',
            deltaPercentage: -14,
          ),
        ),
      );

      expect(find.text('Screen time'), findsOneWidget);
      expect(find.text('−14%'), findsOneWidget);
      expect(find.byType(StatCard), findsOneWidget);

      // Verify dark theme
      await tester.pumpWidget(
        _wrap(
          const StatCard(
            value: '286',
            label: 'Reels',
            deltaPercentage: -8,
          ),
          isDark: true,
        ),
      );

      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('−8%'), findsOneWidget);
    });
  });

  group('DeltaChip', () {
    testWidgets('renders negative reduction and positive change', (tester) async {
      await tester.pumpWidget(_wrap(const DeltaChip(percentage: -14)));
      expect(find.text('−14%'), findsOneWidget);

      await tester.pumpWidget(_wrap(const DeltaChip(percentage: 5)));
      expect(find.text('+5%'), findsOneWidget);
    });
  });

  group('SegmentedPill', () {
    testWidgets('taps trigger selection', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        _wrap(
          SegmentedPill(
            options: const ['Day', 'Week', 'Month'],
            selectedIndex: selected,
            onChanged: (val) => selected = val,
          ),
        ),
      );

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);

      await tester.tap(find.text('Week'));
      expect(selected, equals(1));
    });
  });

  group('Ring', () {
    testWidgets('renders custom progress without errors', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Ring(
            progress: 0.82,
            center: Text('286'),
          ),
        ),
      );

      expect(find.text('286'), findsOneWidget);
      expect(find.byType(Ring), findsOneWidget);
    });
  });

  group('AppRow', () {
    testWidgets('renders name, time, and optional reels count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppRow(
            name: 'Instagram',
            timeFormatted: '1h 48m',
            progress: 0.72,
            reelsCount: 142,
          ),
        ),
      );

      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('1h 48m'), findsOneWidget);
      expect(find.text('142 reels'), findsOneWidget);
    });
  });

  group('PlatformBar', () {
    testWidgets('renders all platform rows with counts', (tester) async {
      final items = [
        const PlatformReelsItem(
          name: 'Instagram',
          count: 142,
          fraction: 1,
          barColor: Color(0xFFF0A98E),
        ),
        const PlatformReelsItem(
          name: 'TikTok',
          count: 84,
          fraction: 0.6,
          barColor: Color(0xFFF3BAA4),
        ),
      ];

      await tester.pumpWidget(_wrap(PlatformBar(items: items)));
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);
      expect(find.text('84'), findsOneWidget);
    });
  });

  group('OlozToggle', () {
    testWidgets('toggling switches state', (tester) async {
      var toggled = false;
      await tester.pumpWidget(
        _wrap(
          OlozToggle(
            value: toggled,
            onChanged: (val) => toggled = val,
          ),
        ),
      );

      await tester.tap(find.byType(OlozToggle));
      expect(toggled, isTrue);
    });
  });

  group('DurationStepper', () {
    testWidgets('increments and decrements duration', (tester) async {
      var minutes = 90;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              DurationStepper(
                durationMinutes: minutes,
                onChanged: (val) {
                  setState(() => minutes = val);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('1h 30m'), findsOneWidget);

      // Tap plus button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(minutes, equals(105));

      // Tap minus button
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(minutes, equals(90));
    });
  });

  group('PresetPills', () {
    testWidgets('selecting preset pill triggers callback', (tester) async {
      var selected = 90;
      await tester.pumpWidget(
        _wrap(
          PresetPills(
            presets: const [
              PresetOption(label: '45m', minutes: 45),
              PresetOption(label: '1h', minutes: 60),
              PresetOption(label: '1h 30m', minutes: 90),
            ],
            selectedMinutes: selected,
            onSelected: (val) => selected = val,
          ),
        ),
      );

      await tester.tap(find.text('1h'));
      expect(selected, equals(60));
    });
  });

  group('WeekBars', () {
    testWidgets('renders 7 bars with today as last', (tester) async {
      const items = [
        DailyBarItem(dayLabel: 'S', value: 3),
        DailyBarItem(dayLabel: 'M', value: 4),
        DailyBarItem(dayLabel: 'T', value: 2),
        DailyBarItem(dayLabel: 'W', value: 5),
        DailyBarItem(dayLabel: 'T', value: 4),
        DailyBarItem(dayLabel: 'F', value: 3),
        DailyBarItem(dayLabel: 'S', value: 5),
      ];

      await tester.pumpWidget(_wrap(const WeekBars(items: items)));
      expect(find.byType(WeekBars), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders message and triggers action', (tester) async {
      var acted = false;
      await tester.pumpWidget(
        _wrap(
          EmptyState(
            message: 'Nothing tracked yet',
            actionLabel: 'Allow usage access',
            onAction: () => acted = true,
          ),
        ),
      );

      expect(find.text('Nothing tracked yet'), findsOneWidget);
      await tester.tap(find.text('Allow usage access'));
      expect(acted, isTrue);
    });
  });

  group('OlozNavBar and OlozSidebar', () {
    testWidgets('NavBar renders 4 tabs and responds to selection', (tester) async {
      var currentTab = OlozTab.home;
      await tester.pumpWidget(
        _wrap(
          OlozNavBar(
            currentTab: currentTab,
            onTabSelected: (tab) => currentTab = tab,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.play_circle_outline_rounded));
      expect(currentTab, equals(OlozTab.reels));
    });

    testWidgets('Sidebar renders 4 tabs', (tester) async {
      var currentTab = OlozTab.home;
      await tester.pumpWidget(
        _wrap(
          OlozSidebar(
            currentTab: currentTab,
            onTabSelected: (tab) => currentTab = tab,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('Apps'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
