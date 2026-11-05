import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:oloz/data/db/app_database.dart';

class FakeDataGenerator {
  const FakeDataGenerator(this.db);

  final AppDatabase db;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Populates 35 days of plausible sessions and reels ending on [referenceDate].
  /// Defaults to Friday, Nov 6, 2026 to match the canonical test dataset.
  Future<void> populate({DateTime? referenceDate}) async {
    final today = referenceDate ?? DateTime(2026, 11, 6);

    await db.transaction(() async {
      // 1. Seed Apps
      final trackedApps = [
        const AppsCompanion(
          package: Value('com.instagram.android'),
          label: Value('Instagram'),
          platform: Value('android'),
          category: Value('social'),
          isShortVideo: Value(true),
        ),
        const AppsCompanion(
          package: Value('com.zhiliaoapp.musically'),
          label: Value('TikTok'),
          platform: Value('android'),
          category: Value('video'),
          isShortVideo: Value(true),
        ),
        const AppsCompanion(
          package: Value('com.google.android.youtube'),
          label: Value('YouTube'),
          platform: Value('android'),
          category: Value('video'),
          isShortVideo: Value(true),
        ),
        const AppsCompanion(
          package: Value('com.facebook.katana'),
          label: Value('Facebook'),
          platform: Value('android'),
          category: Value('social'),
          isShortVideo: Value(true),
        ),
        const AppsCompanion(
          package: Value('com.twitter.android'),
          label: Value('X'),
          platform: Value('android'),
          category: Value('social'),
          isShortVideo: Value(false),
        ),
        const AppsCompanion(
          package: Value('chrome.exe'),
          label: Value('Chrome'),
          platform: Value('windows'),
          category: Value('browsing'),
          isShortVideo: Value(false),
        ),
        const AppsCompanion(
          package: Value('com.whatsapp'),
          label: Value('WhatsApp'),
          platform: Value('android'),
          category: Value('messaging'),
          isShortVideo: Value(false),
        ),
        const AppsCompanion(
          package: Value('com.reddit.frontpage'),
          label: Value('Reddit'),
          platform: Value('android'),
          category: Value('social'),
          isShortVideo: Value(false),
        ),
      ];

      for (final app in trackedApps) {
        await db.into(db.apps).insertOnConflictUpdate(app);
      }

      // 2. Set limits
      await db.limitDao.setLimit(
        scope: 'total',
        dailyLimitMs: 6 * 60 * 60 * 1000, // 6h 00m
      );
      await db.limitDao.setLimit(
        scope: 'reels_total',
        dailyLimitReels: 350,
      );
      await db.limitDao.setLimit(
        scope: 'app',
        package: 'com.instagram.android',
        dailyLimitMs: 90 * 60 * 1000, // 1h 30m
      );

      // 3. Generate 35 days of history ending with today
      const phoneId = 'phone-device-id';
      const pcId = 'pc-device-id';

      for (var i = 34; i >= 0; i--) {
        final currentDay = today.subtract(Duration(days: i));
        final dayStr = _dateFormat.format(currentDay);

        if (i == 0) {
          // Today's exact canonical values:
          // Instagram: 1h 48m, 23 opens, 142 reels
          // TikTok: 1h 12m, 18 opens, 84 reels
          // YouTube: 45m, 12 opens, 48 reels
          // Facebook: 8m, 4 opens, 12 reels
          // X: 28m, 9 opens, 0 reels
          // Chrome: 22m, 14 opens, 0 reels (PC)
          // WhatsApp: 18m, 25 opens, 0 reels
          // Reddit: 14m, 6 opens, 0 reels
          // Total screen time: 108 + 72 + 45 + 8 + 28 + 22 + 18 + 14 = 307m = 5h 07m
          // Total reels: 142 + 84 + 48 + 12 = 286 reels

          await _insertTotal(dayStr, 'com.instagram.android', phoneId, 108 * 60 * 1000, 23, 142);
          await _insertTotal(dayStr, 'com.zhiliaoapp.musically', phoneId, 72 * 60 * 1000, 18, 84);
          await _insertTotal(dayStr, 'com.google.android.youtube', phoneId, 45 * 60 * 1000, 12, 48);
          // Facebook: 0m time, 4 opens, 12 reels
          await _insertTotal(dayStr, 'com.facebook.katana', phoneId, 0, 4, 12);
          await _insertTotal(dayStr, 'com.twitter.android', phoneId, 28 * 60 * 1000, 9, 0);
          await _insertTotal(dayStr, 'chrome.exe', pcId, 22 * 60 * 1000, 14, 0);
          await _insertTotal(dayStr, 'com.whatsapp', phoneId, 18 * 60 * 1000, 25, 0);
          await _insertTotal(dayStr, 'com.reddit.frontpage', phoneId, 14 * 60 * 1000, 6, 0);
        } else if (i == 1) {
          // Yesterday: +14% screen time (~5h 57m = 357m), +8% reels (~310)
          await _insertTotal(dayStr, 'com.instagram.android', phoneId, 125 * 60 * 1000, 26, 155);
          await _insertTotal(dayStr, 'com.zhiliaoapp.musically', phoneId, 85 * 60 * 1000, 20, 92);
          await _insertTotal(dayStr, 'com.google.android.youtube', phoneId, 55 * 60 * 1000, 14, 51);
          await _insertTotal(dayStr, 'com.facebook.katana', phoneId, 10 * 60 * 1000, 5, 12);
          await _insertTotal(dayStr, 'com.twitter.android', phoneId, 32 * 60 * 1000, 10, 0);
          await _insertTotal(dayStr, 'chrome.exe', pcId, 25 * 60 * 1000, 16, 0);
          await _insertTotal(dayStr, 'com.whatsapp', phoneId, 25 * 60 * 1000, 30, 0);
        } else {
          // Historical plausible fluctuation
          final factor = 0.8 + ((i * 7) % 5) * 0.1;
          final baseReels = (250 * factor).round();
          final baseTimeMin = (300 * factor).round();

          await _insertTotal(dayStr, 'com.instagram.android', phoneId, (baseTimeMin * 0.35 * 60 * 1000).round(), 20, (baseReels * 0.5).round());
          await _insertTotal(dayStr, 'com.zhiliaoapp.musically', phoneId, (baseTimeMin * 0.25 * 60 * 1000).round(), 15, (baseReels * 0.3).round());
          await _insertTotal(dayStr, 'com.google.android.youtube', phoneId, (baseTimeMin * 0.20 * 60 * 1000).round(), 10, (baseReels * 0.2).round());
          await _insertTotal(dayStr, 'chrome.exe', pcId, (baseTimeMin * 0.20 * 60 * 1000).round(), 12, 0);
        }
      }
    });
  }

  Future<void> _insertTotal(
    String day,
    String package,
    String deviceId,
    int foregroundMs,
    int opens,
    int reels,
  ) {
    return db.into(db.dailyTotals).insertOnConflictUpdate(
      DailyTotalsCompanion.insert(
        day: day,
        package: package,
        deviceId: deviceId,
        foregroundMs: Value(foregroundMs),
        opens: Value(opens),
        reels: Value(reels),
      ),
    );
  }
}

