import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/core/widgets/stat_card.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/fake_data_generator.dart';
import 'package:oloz/data/providers/app_providers.dart';
import 'package:oloz/features/alerts/alert_screen.dart';
import 'package:oloz/features/apps/app_detail_screen.dart';
import 'package:oloz/features/apps/apps_screen.dart';
import 'package:oloz/features/apps/set_limit_sheet.dart';
import 'package:oloz/features/home/empty_state_screen.dart';
import 'package:oloz/features/home/home_screen.dart';
import 'package:oloz/features/onboarding/goal_screen.dart';
import 'package:oloz/features/onboarding/permission_screen.dart';
import 'package:oloz/features/onboarding/welcome_screen.dart';
import 'package:oloz/features/reels/floating_counter_pill.dart';
import 'package:oloz/features/reels/reels_screen.dart';
import 'package:oloz/features/settings/settings_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final generator = FakeDataGenerator(db);
    await generator.populate(referenceDate: DateTime(2026, 11, 6));
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget child, {
    ThemeMode themeMode = ThemeMode.light,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          referenceDateProvider.overrideWithValue(DateTime(2026, 11, 6)),
        ],
        child: MaterialApp(
          theme: OlozTheme.lightTheme(),
          darkTheme: OlozTheme.darkTheme(),
          themeMode: themeMode,
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> cleanUp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('Onboarding Screens', () {
    testWidgets('OnboardingWelcomeScreen renders branding and button',
        (tester) async {
      await pumpScreen(tester, const OnboardingWelcomeScreen());

      expect(find.text('Know your scroll.'), findsOneWidget);
      expect(find.text('Screen time and reels, simply.'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('OnboardingPermissionScreen renders disclosures and allow',
        (tester) async {
      await pumpScreen(tester, const OnboardingPermissionScreen());

      expect(find.text('Allow usage access'), findsOneWidget);
      expect(find.text('Stays on your device.'), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
      expect(find.text('Counts reels'), findsOneWidget);
      expect(find.text('Allow'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('OnboardingGoalScreen steppers increment and decrement',
        (tester) async {
      await pumpScreen(tester, const OnboardingGoalScreen());

      expect(find.text('Daily goal'), findsOneWidget);
      expect(find.text('Screen time'), findsOneWidget);
      expect(find.text('6h 00m'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Increment reels
      final plusButtons = find.byIcon(Icons.add);
      await tester.tap(plusButtons.last);
      await tester.pumpAndSettle();
      expect(find.text('375'), findsOneWidget);
      await cleanUp(tester);
    });
  });

  group('Home Screen', () {
    testWidgets(
        'HomeScreen mobile renders 5h 07m, 286 reels, week chart and apps',
        (tester) async {
      await pumpScreen(tester, const HomeScreen());

      expect(find.text('Oloz'), findsOneWidget);
      expect(find.text('Screen time'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is StatCard && w.value == '5h 07m'),
          findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is StatCard && w.value == '286'),
          findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Top apps'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('1h 48m'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('HomeScreen desktop renders 1440 layout with Today header',
        (tester) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        size: const Size(1440, 1000),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Fri, Nov 6'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is StatCard && w.value == '5h 07m'),
          findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is StatCard && w.value == '286'),
          findsOneWidget);
      expect(find.text('By platform'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('EmptyStateView renders nothing tracked message',
        (tester) async {
      await pumpScreen(tester, const FirstDayEmptyStateView());

      expect(find.text('Nothing tracked yet'), findsOneWidget);
      expect(find.text('Allow usage access'), findsOneWidget);
      await cleanUp(tester);
    });
  });

  group('Reels Screen', () {
    testWidgets('ReelsScreen mobile renders 286 count, 64 left, and platforms',
        (tester) async {
      await pumpScreen(tester, const ReelsScreen());

      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('286'), findsOneWidget);
      expect(find.text('Reels today'), findsOneWidget);
      expect(find.text('64 left'), findsOneWidget);
      expect(find.text('By platform'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets(
        'ReelsScreen desktop renders sparkline, goal card, and 30-day chart',
        (tester) async {
      await pumpScreen(
        tester,
        const ReelsScreen(),
        size: const Size(1440, 1200),
      );

      expect(find.text('reels today'), findsOneWidget);
      expect(find.text('64 left'), findsOneWidget);
      expect(find.text('of 350 goal'), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
      expect(find.text('Today: 286'), findsOneWidget);
      await cleanUp(tester);
    });
  });

  group('Apps Screen and Detail', () {
    testWidgets('AppsScreen mobile renders summary row and search',
        (tester) async {
      await pumpScreen(tester, const AppsScreen());

      expect(find.text('Apps'), findsOneWidget);
      expect(find.text('5h 07m'), findsOneWidget);
      expect(find.text('6h limit'), findsOneWidget);
      expect(find.text('Search apps'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Social'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('AppsScreen desktop split view renders table and detail panel',
        (tester) async {
      await pumpScreen(
        tester,
        const AppsScreen(),
        size: const Size(1440, 1000),
      );

      expect(find.text('Export'), findsOneWidget);
      expect(find.text('App'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Break reminder'), findsOneWidget);
      expect(find.text('Set limit'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('AppDetailScreen renders Instagram metrics and set limit button',
        (tester) async {
      await pumpScreen(
        tester,
        const AppDetailScreen(package: 'com.instagram.android'),
      );

      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('1h 48m'), findsOneWidget);
      expect(find.text('1h 30m limit'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.text('Set limit'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('SetLimitSheet stepper and presets update limit',
        (tester) async {
      await pumpScreen(
        tester,
        const SetLimitSheet(
          package: 'com.instagram.android',
        ),
      );

      expect(find.text('Daily limit'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('1h 30m'), findsWidgets);
      expect(find.text('Remind me'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Tap 2h preset
      await tester.tap(find.text('2h'));
      await tester.pumpAndSettle();
      expect(find.text('2h 00m'), findsOneWidget);
      await cleanUp(tester);
    });
  });

  group('Alert and Floating Counter Pill', () {
    testWidgets('OverLimitAlertScreen renders limit reached and break button',
        (tester) async {
      await pumpScreen(
        tester,
        const OverLimitAlertScreen(
          
        ),
      );

      expect(find.text('Limit reached'), findsOneWidget);
      expect(find.text('Instagram · 1h 30m'), findsOneWidget);
      expect(find.text('Take a break'), findsOneWidget);
      expect(find.text('5 more min'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('FloatingCounterPill toggles between collapsed and expanded',
        (tester) async {
      await pumpScreen(
        tester,
        const FloatingCounterPill(
          
        ),
      );

      expect(find.text('37'), findsOneWidget);
      expect(find.text('reels'), findsOneWidget);
      expect(find.text('12m'), findsNothing);

      // Tap to expand
      await tester.tap(find.byType(FloatingCounterPill));
      await tester.pumpAndSettle();

      expect(find.text('12m'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
      await cleanUp(tester);
    });
  });

  group('Settings Screen', () {
    testWidgets('SettingsScreen mobile renders preferences, devices, and theme',
        (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('100% On-Device & Private'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Goals and limits'), findsOneWidget);
      expect(find.text('6h · 350 reels'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Every 15m'), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);
      expect(find.text('This phone'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Local database'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('SettingsScreen desktop renders Startup options',
        (tester) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        size: const Size(1440, 1000),
      );

      expect(find.text('Startup'), findsOneWidget);
      expect(find.text('Launch with Windows'), findsOneWidget);
      expect(find.text('Show in tray'), findsOneWidget);
      await cleanUp(tester);
    });
  });
}
