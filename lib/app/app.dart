import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/app/router.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/data/providers/app_providers.dart';

class OlozApp extends ConsumerStatefulWidget {
  const OlozApp({this.initialLocation = '/home', super.key});

  final String initialLocation;

  @override
  ConsumerState<OlozApp> createState() => _OlozAppState();
}

class _OlozAppState extends ConsumerState<OlozApp> with WidgetsBindingObserver {
  StreamSubscription<Map<dynamic, dynamic>>? _eventSub;
  Timer? _periodicSyncTimer;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(initialLocation: widget.initialLocation);
    WidgetsBinding.instance.addObserver(this);
    _initializeTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_eventSub?.cancel());
    _periodicSyncTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncUsage();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _syncUsage();
      final ms = ref.read(totalTimeProvider).value ?? 0;
      final minutes = ms ~/ (60 * 1000);
      final reels = ref.read(totalReelsProvider).value ?? 0;
      final tracking = ref.read(trackingServiceProvider);
      unawaited(
        tracking.updateTrackingNotification(
          reels: reels,
          minutes: minutes,
        ),
      );
    }
  }

  void _initializeTracking() {
    final tracking = ref.read(trackingServiceProvider);

    // 1. Start foreground tracking service
    unawaited(tracking.startTrackingService());

    // 2. Perform initial sync
    _syncUsage();

    // 3. Listen to native events (reels, usage sync)
    _eventSub = tracking.trackingEventStream.listen((event) {
      final type = event['type'] as String? ?? '';
      if (type == 'REEL_DETECTED') {
        ref
          ..invalidate(totalReelsProvider)
          ..invalidate(thirtyDayReelsProvider)
          ..invalidate(platformSplitProvider);
      } else if (type == 'USAGE_SYNC') {
        _syncUsage();
      }
    });

    // 4. Periodic background sync every 30 seconds
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncUsage();
    });
  }

  void _syncUsage() {
    final tracking = ref.read(trackingServiceProvider);
    final db = ref.read(databaseProvider);
    unawaited(tracking.syncNativeUsageToDb(db));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Keep background notification and overlay stats in sync with real DB data
    ref.listen(totalTimeProvider, (_, next) {
      final ms = next.value ?? 0;
      final minutes = ms ~/ (60 * 1000);
      final reels = ref.read(totalReelsProvider).value ?? 0;
      unawaited(
        ref.read(trackingServiceProvider).updateTrackingNotification(
              reels: reels,
              minutes: minutes,
            ),
      );
    });

    ref.listen(totalReelsProvider, (_, next) {
      final reels = next.value ?? 0;
      final ms = ref.read(totalTimeProvider).value ?? 0;
      final minutes = ms ~/ (60 * 1000);
      unawaited(
        ref.read(trackingServiceProvider).updateTrackingNotification(
              reels: reels,
              minutes: minutes,
            ),
      );
    });

    return MaterialApp.router(
      title: 'Oloz',
      debugShowCheckedModeBanner: false,
      theme: OlozTheme.lightTheme(),
      darkTheme: OlozTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
