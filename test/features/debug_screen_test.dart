import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/core/platform/tracking_service.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/data/providers/app_providers.dart';
import 'package:oloz/features/settings/debug_screen.dart';

class FakeDebugTrackingService extends TrackingService {
  FakeDebugTrackingService({required this.fakeEvents}) : super(isAndroid: true);

  final List<Map<dynamic, dynamic>> fakeEvents;
  bool cleared = false;

  @override
  Future<List<Map<dynamic, dynamic>>> getDebugEvents() async {
    if (cleared) return [];
    return fakeEvents;
  }

  @override
  Future<void> clearDebugEvents() async {
    cleared = true;
  }
}

void main() {
  testWidgets('DebugScreen renders empty state when no events logged', (tester) async {
    final fakeService = FakeDebugTrackingService(fakeEvents: []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackingServiceProvider.overrideWithValue(fakeService),
        ],
        child: MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: const DebugScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reel Event Logger'), findsOneWidget);
    expect(find.text('No accessibility events logged'), findsOneWidget);
    expect(find.text('Captured Events: 0'), findsOneWidget);
  });

  testWidgets('DebugScreen renders captured accessibility events and responds to clear', (tester) async {
    final fakeEvents = [
      {
        'packageName': 'com.instagram.android',
        'eventType': 4096, // TYPE_VIEW_SCROLLED
        'className': 'androidx.viewpager2.widget.ViewPager2',
        'viewId': 'clips_viewer',
        'timestampMs': 1762416000000,
        'isFullScreenScroll': true,
        'fromIndex': 1,
        'toIndex': 2,
      },
      {
        'packageName': 'com.google.android.youtube',
        'eventType': 2048, // TYPE_WINDOW_CONTENT_CHANGED
        'className': 'android.widget.FrameLayout',
        'viewId': 'reel_player_page_container',
        'timestampMs': 1762416001000,
        'isFullScreenScroll': false,
        'fromIndex': -1,
        'toIndex': -1,
      },
    ];

    final fakeService = FakeDebugTrackingService(fakeEvents: fakeEvents);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackingServiceProvider.overrideWithValue(fakeService),
        ],
        child: MaterialApp(
          theme: OlozTheme.lightTheme(),
          home: const DebugScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Captured Events: 2'), findsOneWidget);
    expect(find.text('TYPE_VIEW_SCROLLED'), findsOneWidget);
    expect(find.text('TYPE_WINDOW_CONTENT_CHANGED'), findsOneWidget);
    expect(find.text('com.instagram.android'), findsOneWidget);
    expect(find.text('com.google.android.youtube'), findsOneWidget);
    expect(find.text('Full Screen'), findsOneWidget);

    // Tap clear button
    await tester.tap(find.byTooltip('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('Captured Events: 0'), findsOneWidget);
    expect(find.text('No accessibility events logged'), findsOneWidget);
  });
}
