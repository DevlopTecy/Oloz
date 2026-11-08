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

CustomTransitionPage<void> _buildTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRouter createAppRouter({String initialLocation = '/home'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
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
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: const DebugScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // App detail with smooth transition
      GoRoute(
        path: '/apps/:package',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final package =
              state.pathParameters['package'] ?? 'com.instagram.android';
          return _buildTransitionPage(
            key: state.pageKey,
            child: AppDetailScreen(package: package),
          );
        },
      ),
      // Over-limit alert
      GoRoute(
        path: '/alert/:package',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final package =
              state.pathParameters['package'] ?? 'com.instagram.android';
          final isInstagram = package.contains('instagram');
          return _buildTransitionPage(
            key: state.pageKey,
            child: OverLimitAlertScreen(
              appName: isInstagram ? 'Instagram' : 'Application',
              package: package,
            ),
          );
        },
      ),
      // Onboarding flow with smooth transitions
      GoRoute(
        path: '/onboarding/welcome',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const OnboardingWelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/permission',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const OnboardingPermissionScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/goal',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const OnboardingGoalScreen(),
        ),
      ),
      // Gallery component showcase
      GoRoute(
        path: '/gallery',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const GalleryScreen(),
        ),
      ),
      // Live floating reel counter pill preview
      GoRoute(
        path: '/counter-preview',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const FloatingCounterPreviewScreen(),
        ),
      ),
      // Empty state preview
      GoRoute(
        path: '/empty-preview',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const Scaffold(
            body: SafeArea(child: FirstDayEmptyStateView()),
          ),
        ),
      ),
    ],
  );
}

final goRouter = createAppRouter();
