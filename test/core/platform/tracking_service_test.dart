import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/core/platform/tracking_service.dart';
import 'package:oloz/data/db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrackingPermissionsStatus', () {
    test('parses permission map correctly', () {
      final status = TrackingPermissionsStatus.fromMap({
        'usageStats': true,
        'accessibility': false,
        'overlay': true,
        'notifications': true,
      });

      expect(status.usageStats, isTrue);
      expect(status.accessibility, isFalse);
      expect(status.overlay, isTrue);
      expect(status.notifications, isTrue);
      expect(status.hasRequired, isTrue);
    });
  });

  group('TrackingService with Mock MethodChannel', () {
    late AppDatabase db;
    late TrackingService trackingService;
    final log = <MethodCall>[];

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      log.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.oloz.app/tracking'),
        (call) async {
          log.add(call);
          switch (call.method) {
            case 'checkPermissions':
              return {
                'usageStats': true,
                'accessibility': true,
                'overlay': true,
                'notifications': true,
              };
            case 'requestUsageAccess':
            case 'requestAccessibility':
            case 'requestOverlayPermission':
              return true;
            case 'startTrackingService':
              return true;
            case 'stopTrackingService':
              return true;
            case 'showOverlayCounter':
            case 'hideOverlayCounter':
            case 'updateOverlayCount':
            case 'sendToDeviceHome':
              return true;
            case 'isOverlayShowing':
              return true;
            case 'queryUsageForRange':
              return {
                'sessions': [
                  {
                    'package': 'com.instagram.android',
                    'label': 'Instagram',
                    'startMs': 1762416000000,
                    'endMs': 1762422480000, // 1h 48m = 6480000 ms
                    'day': '2026-11-06',
                  },
                  {
                    'package': 'com.zhiliaoapp.musically',
                    'label': 'TikTok',
                    'startMs': 1762423000000,
                    'endMs': 1762427320000, // 1h 12m = 4320000 ms
                    'day': '2026-11-06',
                  },
                ],
                'apps': [
                  {
                    'package': 'com.instagram.android',
                    'label': 'Instagram',
                    'category': 'social',
                    'foregroundMs': 6480000,
                    'opens': 23,
                    'isShortVideo': true,
                  },
                  {
                    'package': 'com.zhiliaoapp.musically',
                    'label': 'TikTok',
                    'category': 'social',
                    'foregroundMs': 4320000,
                    'opens': 14,
                    'isShortVideo': true,
                  },
                ],
              };
            default:
              return null;
          }
        },
      );

      trackingService = TrackingService(isAndroid: true);
    });

    tearDown(() async {
      await db.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.oloz.app/tracking'),
        null,
      );
    });

    test('syncNativeUsageToDb ingests sessions and creates app records', () async {
      final inserted = await trackingService.syncNativeUsageToDb(
        db,
        startMs: 1762416000000,
        endMs: 1762428000000,
      );

      expect(inserted, equals(2));

      // Verify apps table contains synced apps
      final apps = await db.select(db.apps).get();
      expect(apps.length, equals(2));
      expect(apps.any((a) => a.package == 'com.instagram.android'), isTrue);
      expect(apps.any((a) => a.package == 'com.zhiliaoapp.musically'), isTrue);

      // Verify sessions table contains the 2 recorded sessions
      final sessions = await db.select(db.sessions).get();
      expect(sessions.length, equals(2));
      expect(sessions.first.package, equals('com.instagram.android'));
      expect(sessions.first.day, equals('2026-11-06'));

      // Verify daily totals rolled up
      final totals = await db.select(db.dailyTotals).get();
      expect(totals.length, equals(2));
      final igTotal = totals.firstWhere((t) => t.package == 'com.instagram.android');
      expect(igTotal.foregroundMs, equals(6480000));
      expect(igTotal.opens, equals(1));
    });

    test('overlay methods invoke platform channel correctly', () async {
      final shown = await trackingService.showOverlayCounter();
      expect(shown, isTrue);
      expect(log.any((c) => c.method == 'showOverlayCounter'), isTrue);

      await trackingService.updateOverlayCount(count: 38, minutes: 13);
      expect(log.any((c) => c.method == 'updateOverlayCount'), isTrue);

      final isShowing = await trackingService.isOverlayShowing();
      expect(isShowing, isTrue);

      final hidden = await trackingService.hideOverlayCounter();
      expect(hidden, isTrue);
      expect(log.any((c) => c.method == 'hideOverlayCounter'), isTrue);

      await trackingService.sendToDeviceHome();
      expect(log.any((c) => c.method == 'sendToDeviceHome'), isTrue);
    });
  });
}
