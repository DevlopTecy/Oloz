import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/app/shell/responsive_shell.dart';
import 'package:oloz/core/widgets/oloz_nav_bar.dart';
import 'package:oloz/features/alerts/alert_screen.dart';
import 'package:oloz/features/apps/app_detail_screen.dart';
import 'package:oloz/features/apps/apps_screen.dart';
import 'package:oloz/features/gallery/gallery_screen.dart';
import 'package:oloz/features/home/empty_state_screen.dart';
import 'package:oloz/features/home/home_screen.dart';
import 'package:oloz/features/onboarding/goal_screen.dart';
import 'package:oloz/features/onboarding/permission_screen.dart';
import 'package:oloz/features/onboarding/welcome_screen.dart';
import 'package:oloz/features/reels/floating_counter_pill.dart';
import 'package:oloz/features/reels/reels_screen.dart';
import 'package:oloz/features/settings/debug_screen.dart';
import 'package:oloz/features/settings/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
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
          onTabSelected: (tab) {
            navigationShell.goBranch(
              tab.index,
              initialLocation: tab.index == navigationShell.currentIndex,
            );
          },
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
              path: '/reels',
              builder: (context, state) => const ReelsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/apps',
              builder: (context, state) => const AppsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'debug',
                  builder: (context, state) => const DebugScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // App detail
    GoRoute(
      path: '/apps/:package',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final package =
            state.pathParameters['package'] ?? 'com.instagram.android';
        return AppDetailScreen(package: package);
      },
    ),
    // Over-limit alert
    GoRoute(
      path: '/alert/:package',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final package =
            state.pathParameters['package'] ?? 'com.instagram.android';
        final isInstagram = package.contains('instagram');
        return OverLimitAlertScreen(
          appName: isInstagram ? 'Instagram' : 'Application',
          package: package,
        );
      },
    ),
    // Onboarding flow
    GoRoute(
      path: '/onboarding/welcome',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingWelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding/permission',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingPermissionScreen(),
    ),
    GoRoute(
      path: '/onboarding/goal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingGoalScreen(),
    ),
    // Gallery component showcase
    GoRoute(
      path: '/gallery',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GalleryScreen(),
    ),
    // Live floating reel counter pill preview
    GoRoute(
      path: '/counter-preview',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FloatingCounterPreviewScreen(),
    ),
    // Empty state preview
    GoRoute(
      path: '/empty-preview',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const Scaffold(
        body: SafeArea(child: FirstDayEmptyStateView()),
      ),
    ),
  ],
);
