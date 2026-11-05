import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/fake_data_generator.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase & DAOs', () {
    test('Default limits and settings are seeded on creation', () async {
      // Trigger onCreate by querying a table
      final allLimits = await db.limitDao.watchAllLimits().first;
      expect(allLimits.length, equals(2));

      final totalLimit = allLimits.firstWhere((l) => l.scope == 'total');
      expect(totalLimit.dailyLimitMs, equals(6 * 60 * 60 * 1000)); // 6h

      final reelsLimit = allLimits.firstWhere((l) => l.scope == 'reels_total');
      expect(reelsLimit.dailyLimitReels, equals(350));

      final reminderInterval = await db.settingsDao.getSetting('reminder_interval_min');
      expect(reminderInterval, equals('15'));
    });

    test('UsageDao records sessions and aggregates correctly', () async {
      // Insert app
      await db.into(db.apps).insert(
        AppsCompanion.insert(
          package: 'com.instagram.android',
          label: 'Instagram',
          platform: 'android',
          category: 'social',
        ),
      );

      // Record morning session (45 minutes = 2,700,000 ms)
      await db.usageDao.recordSession(
        package: 'com.instagram.android',
        deviceId: 'device-1',
        startMs: 1000,
        endMs: 1000 + (45 * 60 * 1000),
        day: '2026-11-06',
      );

      // Record afternoon session (15 minutes = 900,000 ms)
      await db.usageDao.recordSession(
        package: 'com.instagram.android',
        deviceId: 'device-1',
        startMs: 5000000,
        endMs: 5000000 + (15 * 60 * 1000),
        day: '2026-11-06',
      );

      final totalMs = await db.usageDao.getTotalTimeForRange(
        startDay: '2026-11-06',
        endDay: '2026-11-06',
      );
      expect(totalMs, equals(60 * 60 * 1000)); // 1 hour total

      final appsSummary = await db.usageDao.watchAppsSummaryForRange(
        startDay: '2026-11-06',
        endDay: '2026-11-06',
      ).first;

      expect(appsSummary.length, equals(1));
      expect(appsSummary.first.package, equals('com.instagram.android'));
      expect(appsSummary.first.foregroundMs, equals(60 * 60 * 1000));
      expect(appsSummary.first.opens, equals(2));
    });

    test('ReelDao records events and computes platform split', () async {
      await db.into(db.apps).insert(
        AppsCompanion.insert(
          package: 'com.instagram.android',
          label: 'Instagram',
          platform: 'android',
          category: 'social',
          isShortVideo: const Value(true),
        ),
      );
      await db.into(db.apps).insert(
        AppsCompanion.insert(
          package: 'com.zhiliaoapp.musically',
          label: 'TikTok',
          platform: 'android',
          category: 'video',
          isShortVideo: const Value(true),
        ),
      );

      // Record 3 IG reels and 2 TikTok reels
      for (var i = 0; i < 3; i++) {
        await db.reelDao.recordReelEvent(
          package: 'com.instagram.android',
          deviceId: 'device-1',
          atMs: 10000 + i * 2000,
          dwellMs: 1500,
          day: '2026-11-06',
        );
      }

      for (var i = 0; i < 2; i++) {
        await db.reelDao.recordReelEvent(
          package: 'com.zhiliaoapp.musically',
          deviceId: 'device-1',
          atMs: 20000 + i * 2000,
          dwellMs: 1200,
          day: '2026-11-06',
        );
      }

      final totalReels = await db.reelDao.watchTotalReelsForRange(
        startDay: '2026-11-06',
        endDay: '2026-11-06',
      ).first;
      expect(totalReels, equals(5));

      final platformSplit = await db.reelDao.watchReelsByPlatformForRange(
        startDay: '2026-11-06',
        endDay: '2026-11-06',
      ).first;
      expect(platformSplit.length, equals(2));
      expect(platformSplit[0].name, equals('Instagram'));
      expect(platformSplit[0].count, equals(3));
      expect(platformSplit[1].name, equals('TikTok'));
      expect(platformSplit[1].count, equals(2));
    });

    test('LimitDao handles app limits and snoozing', () async {
      await db.limitDao.setLimit(
        scope: 'app',
        package: 'com.instagram.android',
        dailyLimitMs: 90 * 60 * 1000,
      );

      final limit = await db.limitDao.getLimit(
        scope: 'app',
        package: 'com.instagram.android',
      );
      expect(limit, isNotNull);
      expect(limit!.dailyLimitMs, equals(90 * 60 * 1000));
      expect(limit.snoozeUntilMs, isNull);

      final snoozeUntil = DateTime.now().millisecondsSinceEpoch + (5 * 60 * 1000);
      await db.limitDao.snoozeLimit(limit.id, snoozeUntil);

      final snoozed = await db.limitDao.getLimit(
        scope: 'app',
        package: 'com.instagram.android',
      );
      expect(snoozed!.snoozeUntilMs, equals(snoozeUntil));
    });

    test('FakeDataGenerator populates 35 days matching canonical dataset', () async {
      final generator = FakeDataGenerator(db);
      final refDate = DateTime(2026, 11, 6);
      await generator.populate(referenceDate: refDate);

      // 1. Verify Today's total screen time: 5h 07m = 307 minutes = 18,420,000 ms
      final todayTimeMs = await db.usageDao.getTotalTimeForRange(
        startDay: '2026-11-06',
        endDay: '2026-11-06',
      );
      expect(todayTimeMs, equals(307 * 60 * 1000));

      // 2. Verify Today's total reels: 286
      final todayReels = await db.reelDao.watchTotalReelsForRange(
        startDay: '2026-11-06',
        endDay: '2026-11-06',
      ).first;
      expect(todayReels, equals(286));

      // 3. Verify Reels by platform: Instagram 142, TikTok 84, YouTube 48, Facebook 12
      final platforms = await db.reelDao.watchReelsByPlatformForRange(
        startDay: '2026-11-06',
        endDay: '2026-11-06',
      ).first;
      expect(platforms.length, equals(4));
      expect(platforms.firstWhere((p) => p.name == 'Instagram').count, equals(142));
      expect(platforms.firstWhere((p) => p.name == 'TikTok').count, equals(84));
      expect(platforms.firstWhere((p) => p.name == 'YouTube').count, equals(48));
      expect(platforms.firstWhere((p) => p.name == 'Facebook').count, equals(12));

      // 4. Verify 7-day series ending today has 7 points
      final last7Days = List.generate(
        7,
        (i) => '2026-11-0${6 - 6 + i}',
      );
      final series = await db.usageDao.watchDailySeries(last7Days).first;
      expect(series.length, equals(7));
      expect(series.last.foregroundMs, equals(307 * 60 * 1000));
    });
  });
}
