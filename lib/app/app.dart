import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oloz/app/router.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/data/providers/app_providers.dart';

class OlozApp extends ConsumerStatefulWidget {
  const OlozApp({super.key});

  @override
  ConsumerState<OlozApp> createState() => _OlozAppState();
}

class _OlozAppState extends ConsumerState<OlozApp> with WidgetsBindingObserver {
  StreamSubscription<Map<dynamic, dynamic>>? _eventSub;
  Timer? _periodicSyncTimer;

  @override
  void initState() {
    super.initState();
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
    }
  }

  void _initializeTracking() {
    final tracking = ref.read(trackingServiceProvider);
    final db = ref.read(databaseProvider);

    // 1. Start foreground tracking service
    unawaited(tracking.startTrackingService());

    // 2. Perform initial sync
    _syncUsage();

    // 3. Listen to native events (reels, usage sync)
    _eventSub = tracking.trackingEventStream.listen((event) {
      final type = event['type'] as String? ?? '';
      if (type == 'REEL_DETECTED') {
        final pkg = event['package'] as String? ?? '';
        final dwell = (event['dwellMs'] as num?)?.toInt() ?? 0;
        final ts = (event['timestampMs'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch;
        final day = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(ts));

        unawaited(
          tracking.recordNativeReelEvent(
            db,
            package: pkg,
            dwellMs: dwell,
            timestampMs: ts,
            day: day,
          ),
        );
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

    return MaterialApp.router(
      title: 'Oloz',
      debugShowCheckedModeBanner: false,
      theme: OlozTheme.lightTheme(),
      darkTheme: OlozTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
