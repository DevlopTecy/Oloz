import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:oloz/data/db/app_database.dart';

class TrackingPermissionsStatus {
  const TrackingPermissionsStatus({
    required this.usageStats,
    required this.accessibility,
    required this.overlay,
    required this.notifications,
  });

  factory TrackingPermissionsStatus.fromMap(Map<dynamic, dynamic> map) {
    return TrackingPermissionsStatus(
      usageStats: map['usageStats'] as bool? ?? false,
      accessibility: map['accessibility'] as bool? ?? false,
      overlay: map['overlay'] as bool? ?? false,
      notifications: map['notifications'] as bool? ?? false,
    );
  }

  final bool usageStats;
  final bool accessibility;
  final bool overlay;
  final bool notifications;

  bool get hasRequired => usageStats;
}

class TrackingService {
  TrackingService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
    this.isAndroid,
  })  : _methodChannel =
            methodChannel ?? const MethodChannel('com.oloz.app/tracking'),
        _eventChannel =
            eventChannel ?? const EventChannel('com.oloz.app/tracking_events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  final bool? isAndroid;

  bool get _isAndroidPlatform => isAndroid ?? Platform.isAndroid;

  /// Check all permission states.
  Future<TrackingPermissionsStatus> checkPermissions() async {
    if (!_isAndroidPlatform) {
      return const TrackingPermissionsStatus(
        usageStats: true,
        accessibility: true,
        overlay: true,
        notifications: true,
      );
    }

    try {
      final res =
          await _methodChannel.invokeMapMethod<String, dynamic>('checkPermissions');
      return TrackingPermissionsStatus.fromMap(res ?? {});
    } on PlatformException {
      return const TrackingPermissionsStatus(
        usageStats: false,
        accessibility: false,
        overlay: false,
        notifications: false,
      );
    }
  }

  /// Deep link to Android Usage Access Settings.
  Future<void> requestUsageAccess() async {
    if (!_isAndroidPlatform) return;
    try {
      await _methodChannel.invokeMethod<void>('requestUsageAccess');
    } on PlatformException {
      // ignored
    }
  }

  /// Deep link to Android Accessibility Settings.
  Future<void> requestAccessibility() async {
    if (!_isAndroidPlatform) return;
    try {
      await _methodChannel.invokeMethod<void>('requestAccessibility');
    } on PlatformException {
      // ignored
    }
  }

  /// Deep link to Android Manage Overlay Permission.
  Future<void> requestOverlayPermission() async {
    if (!_isAndroidPlatform) return;
    try {
      await _methodChannel.invokeMethod<void>('requestOverlayPermission');
    } on PlatformException {
      // ignored
    }
  }

  /// Sends the user to the device home screen (used by "Take a break").
  Future<void> sendToDeviceHome() async {
    if (!_isAndroidPlatform) return;
    try {
      await _methodChannel.invokeMethod<void>('sendToDeviceHome');
    } on PlatformException {
      // ignored
    }
  }

  /// Show the floating live reel counter pill overlay.
  Future<bool> showOverlayCounter({int count = 37, int minutes = 12}) async {
    if (!_isAndroidPlatform) return true;
    try {
      final shown = await _methodChannel.invokeMethod<bool>(
        'showOverlayCounter',
        {'count': count, 'minutes': minutes},
      );
      return shown ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Hide the floating live reel counter pill overlay.
  Future<bool> hideOverlayCounter() async {
    if (!_isAndroidPlatform) return true;
    try {
      final hidden =
          await _methodChannel.invokeMethod<bool>('hideOverlayCounter');
      return hidden ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Update count displayed on the floating pill.
  Future<void> updateOverlayCount({int count = 37, int minutes = 12}) async {
    if (!_isAndroidPlatform) return;
    try {
      await _methodChannel.invokeMethod<void>(
        'updateOverlayCount',
        {'count': count, 'minutes': minutes},
      );
    } on PlatformException {
      // ignored
    }
  }

  /// Check if the overlay is currently showing.
  Future<bool> isOverlayShowing() async {
    if (!_isAndroidPlatform) return false;
    try {
      final res =
          await _methodChannel.invokeMethod<bool>('isOverlayShowing');
      return res ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Start background TrackingForegroundService and WorkManager.
  Future<bool> startTrackingService() async {
    if (!_isAndroidPlatform) return true;
    try {
      final started =
          await _methodChannel.invokeMethod<bool>('startTrackingService');
      return started ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Stop background TrackingForegroundService and WorkManager.
  Future<bool> stopTrackingService() async {
    if (!_isAndroidPlatform) return true;
    try {
      final stopped =
          await _methodChannel.invokeMethod<bool>('stopTrackingService');
      return stopped ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Query native UsageCollector for sessions and apps summary.
  Future<Map<String, dynamic>> queryUsageForRange({
    int? startMs,
    int? endMs,
  }) async {
    if (!_isAndroidPlatform) {
      return {'sessions': <dynamic>[], 'apps': <dynamic>[]};
    }
    try {
      final res = await _methodChannel.invokeMapMethod<String, dynamic>(
        'queryUsageForRange',
        {
          'startMs': ?startMs,
          'endMs': ?endMs,
        },
      );
      return res ?? {'sessions': <dynamic>[], 'apps': <dynamic>[]};
    } on PlatformException {
      return {'sessions': <dynamic>[], 'apps': <dynamic>[]};
    }
  }

  /// Stream of native tracking and foreground transitions.
  Stream<Map<dynamic, dynamic>> get trackingEventStream {
    if (!_isAndroidPlatform) {
      return const Stream.empty();
    }
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as Map<dynamic, dynamic>);
  }

  /// Get recent accessibility events for debug verification screen.
  Future<List<Map<dynamic, dynamic>>> getDebugEvents() async {
    if (!_isAndroidPlatform) return [];
    try {
      final res = await _methodChannel.invokeListMethod<dynamic>('getDebugEvents');
      return (res ?? []).whereType<Map<dynamic, dynamic>>().toList();
    } on PlatformException {
      return [];
    }
  }

  /// Clear debug event circular buffer.
  Future<void> clearDebugEvents() async {
    if (!_isAndroidPlatform) return;
    try {
      await _methodChannel.invokeMethod<void>('clearDebugEvents');
    } on PlatformException {
      // ignored
    }
  }

  /// Record a live reel event into the database.
  Future<void> recordNativeReelEvent(
    AppDatabase db, {
    required String package,
    required int dwellMs,
    required int timestampMs,
    required String day,
    String deviceId = 'phone',
  }) async {
    await db.reelDao.recordReelEvent(
      package: package,
      deviceId: deviceId,
      atMs: timestampMs,
      dwellMs: dwellMs,
      day: day,
    );
  }

  /// Ingests native Android sessions into Drift database and updates daily rollups.
  Future<int> syncNativeUsageToDb(
    AppDatabase db, {
    String deviceId = 'phone',
    int? startMs,
    int? endMs,
  }) async {
    final usageData = await queryUsageForRange(
      startMs: startMs,
      endMs: endMs,
    );

    final rawSessions = usageData['sessions'] as List<dynamic>? ?? [];
    final rawApps = usageData['apps'] as List<dynamic>? ?? [];

    // Ensure apps exist in apps table
    for (final rawApp in rawApps) {
      if (rawApp is! Map) continue;
      final package = rawApp['package'] as String? ?? '';
      final label = rawApp['label'] as String? ?? package;
      final category = rawApp['category'] as String? ?? 'other';
      final isShort = rawApp['isShortVideo'] as bool? ?? false;

      await db.usageDao.upsertApp(
        AppsCompanion.insert(
          package: package,
          label: label,
          platform: 'android',
          category: category,
          isShortVideo: Value(isShort),
        ),
      );
    }

    var insertedSessions = 0;
    for (final rawSession in rawSessions) {
      if (rawSession is! Map) continue;
      final package = rawSession['package'] as String? ?? '';
      final start = (rawSession['startMs'] as num?)?.toInt() ?? 0;
      final end = (rawSession['endMs'] as num?)?.toInt() ?? 0;
      final day = rawSession['day'] as String? ?? '';

      if (package.isEmpty || end <= start) continue;

      await db.usageDao.recordSession(
        package: package,
        deviceId: deviceId,
        startMs: start,
        endMs: end,
        day: day,
      );
      insertedSessions++;
    }

    return insertedSessions;
  }
}
