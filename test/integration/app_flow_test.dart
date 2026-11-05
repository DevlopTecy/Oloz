import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/app/shell/responsive_shell.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/core/widgets/oloz_nav_bar.dart';
import 'package:oloz/core/widgets/stat_card.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/fake_data_generator.dart';
import 'package:oloz/data/providers/app_providers.dart';
import 'package:oloz/features/alerts/alert_screen.dart';
import 'package:oloz/features/apps/app_detail_screen.dart';
import 'package:oloz/features/apps/apps_screen.dart';
import 'package:oloz/features/home/home_screen.dart';
import 'package:oloz/features/onboarding/goal_screen.dart';
import 'package:oloz/features/onboarding/permission_screen.dart';
import 'package:oloz/features/onboarding/welcome_screen.dart';

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

  GoRouter createTestRouter({String initialLocation = '/onboarding/welcome'}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/onboarding/welcome',
          builder: (context, state) => const OnboardingWelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding/permission',
          builder: (context, state) => const OnboardingPermissionScreen(),
        ),
        GoRoute(
          path: '/onboarding/goal',
          builder: (context, state) => const OnboardingGoalScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            final currentTab = switch (navigationShell.currentIndex) {
              0 => OlozTab.home,
              1 => OlozTab.reels,
              2 => OlozTab.apps,
              _ => OlozTab.settings,
            };
            return ResponsiveShell(
              currentTab: currentTab,
              onTabSelected: (tab) => navigationShell.goBranch(tab.index),
              child: navigationShell,
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/apps',
                  builder: (context, state) => const AppsScreen(),
                  routes: [
                    GoRoute(
                      path: ':package',
                      builder: (context, state) => AppDetailScreen(
                        package: state.pathParameters['package'] ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/alert/:package',
          builder: (context, state) => OverLimitAlertScreen(
            package: state.pathParameters['package'] ?? '',
          ),
        ),
      ],
    );
  }

  testWidgets(
      'Full End-to-End Flow: Onboarding -> Permission -> Goal -> Home -> App Detail -> Alert',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = createTestRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          referenceDateProvider.overrideWithValue(DateTime(2026, 11, 6)),
        ],
        child: MaterialApp.router(
          theme: OlozTheme.lightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Onboarding Welcome Screen
    expect(find.text('Know your scroll.'), findsOneWidget);
    expect(find.text('Screen time and reels, simply.'), findsOneWidget);
    final getStartedButton = find.text('Get started');
    expect(getStartedButton, findsOneWidget);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    // 2. Onboarding Permission Screen
    expect(find.text('Allow usage access'), findsOneWidget);
    final allowButton = find.text('Not now');
    expect(allowButton, findsOneWidget);
    await tester.tap(allowButton);
    await tester.pumpAndSettle();

    // 3. Onboarding Goal Screen
    expect(find.text('Daily goal'), findsOneWidget);
    final doneButton = find.text('Done');
    expect(doneButton, findsOneWidget);
    await tester.tap(doneButton);
    await tester.pumpAndSettle();

    // 4. Home Screen is reached and shows canonical data
    expect(
      find.byWidgetPredicate((w) => w is StatCard && w.value == '5h 07m'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => w is StatCard && w.value == '286'),
      findsOneWidget,
    );

    // 5. Navigate to Instagram detail
    router.go('/apps/com.instagram.android');
    await tester.pumpAndSettle();

    expect(find.text('Instagram'), findsWidgets);
    expect(find.text('1h 48m'), findsOneWidget);
    expect(find.text('142'), findsOneWidget);

    // 6. Navigate to Limit Alert Screen for Instagram
    router.go('/alert/com.instagram.android');
    await tester.pumpAndSettle();

    expect(find.text('Limit reached'), findsOneWidget);
    expect(find.text('Instagram · 1h 30m'), findsOneWidget);
    expect(find.text('Take a break'), findsOneWidget);
    expect(find.text('5 more min'), findsOneWidget);

    // Drain timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
