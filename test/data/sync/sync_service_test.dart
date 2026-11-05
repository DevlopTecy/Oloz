import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/sync/sync_service.dart';

class FakeSupabaseSyncClient implements SupabaseSyncClient {
  final List<Map<String, dynamic>> uploadedRecords = [];
  final List<Map<String, dynamic>> remoteRecordsToReturn = [];
  bool shouldThrow = false;
  bool deleteCalled = false;

  @override
  Future<void> upsertDailyTotals({
    required String userId,
    required List<Map<String, dynamic>> records,
  }) async {
    if (shouldThrow) throw Exception('Network unreachable');
    uploadedRecords.addAll(records);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRemoteDailyTotals({
    required String userId,
    required String excludeDeviceId,
    required String startDay,
  }) async {
    if (shouldThrow) throw Exception('Network timeout');
    return remoteRecordsToReturn
        .where((r) => r['device_key'] != excludeDeviceId)
        .toList();
  }

  @override
  Future<void> deleteUserCloudData({required String userId}) async {
    if (shouldThrow) throw Exception('Network error');
    deleteCalled = true;
    uploadedRecords.clear();
  }
}

void main() {
  late AppDatabase db;
  late FakeSupabaseSyncClient fakeClient;
  late SyncService syncService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeClient = FakeSupabaseSyncClient();
    syncService = SyncService(database: db, client: fakeClient);

    // Seed test apps
    await db.usageDao.upsertApp(
      const AppsCompanion(
        package: Value('com.instagram.android'),
        label: Value('Instagram'),
        platform: Value('android'),
        category: Value('social'),
      ),
    );
    await db.usageDao.upsertApp(
      const AppsCompanion(
        package: Value('com.zhiliaoapp.musically'),
        label: Value('TikTok'),
        platform: Value('android'),
        category: Value('social'),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncService', () {
    test('uploads dirty unsynced daily totals and updates synced_at timestamp', () async {
      // 1. Insert 2 local unsynced rows (syncedAt is null)
      await db.into(db.dailyTotals).insert(
            const DailyTotalsCompanion(
              day: Value('2026-11-06'),
              package: Value('com.instagram.android'),
              deviceId: Value('phone'),
              foregroundMs: Value(6480000), // 1h 48m
              opens: Value(23),
              reels: Value(142),
            ),
          );

      await db.into(db.dailyTotals).insert(
            const DailyTotalsCompanion(
              day: Value('2026-11-06'),
              package: Value('com.zhiliaoapp.musically'),
              deviceId: Value('phone'),
              foregroundMs: Value(4320000), // 1h 12m
              opens: Value(14),
              reels: Value(84),
            ),
          );

      // 2. Perform upload
      final result = await syncService.uploadDirtyTotals(
        userId: 'user_123',
        deviceId: 'phone',
        nowMs: 1762416000000,
      );

      expect(result.success, isTrue);
      expect(result.uploadedCount, equals(2));
      expect(fakeClient.uploadedRecords.length, equals(2));
      expect(fakeClient.uploadedRecords.first['package'], equals('com.instagram.android'));
      expect(fakeClient.uploadedRecords.first['label'], equals('Instagram'));

      // 3. Verify local records were updated with syncedAt timestamp
      final rows = await db.select(db.dailyTotals).get();
      for (final r in rows) {
        expect(r.syncedAt, equals(1762416000000));
      }

      // 4. Subsequent upload finds 0 dirty rows (idempotent)
      final secondRun = await syncService.uploadDirtyTotals(
        userId: 'user_123',
        deviceId: 'phone',
      );
      expect(secondRun.success, isTrue);
      expect(secondRun.uploadedCount, equals(0));
    });

    test('downloads remote device totals and inserts into local database', () async {
      // Setup remote records from Windows PC
      fakeClient.remoteRecordsToReturn.add({
        'day': '2026-11-06',
        'package': 'chrome.exe',
        'device_key': 'pc',
        'label': 'Google Chrome',
        'category': 'browsing',
        'platform': 'windows',
        'foreground_ms': 1320000, // 22m
        'opens': 5,
        'reels': 0,
      });

      final result = await syncService.downloadRemoteTotals(
        userId: 'user_123',
        currentDeviceId: 'phone',
      );

      expect(result.success, isTrue);
      expect(result.downloadedCount, equals(1));

      // Verify app was added to apps table
      final apps = await db.select(db.apps).get();
      expect(apps.any((a) => a.package == 'chrome.exe'), isTrue);

      // Verify daily total was inserted with deviceId = 'pc'
      final totals = await (db.select(db.dailyTotals)
            ..where((tbl) => tbl.deviceId.equals('pc')))
          .get();
      expect(totals.length, equals(1));
      expect(totals.first.package, equals('chrome.exe'));
      expect(totals.first.foregroundMs, equals(1320000));
    });

    test('handles offline network errors gracefully without corrupting database', () async {
      // Set client to throw network exception
      fakeClient.shouldThrow = true;

      await db.into(db.dailyTotals).insert(
            const DailyTotalsCompanion(
              day: Value('2026-11-06'),
              package: Value('com.instagram.android'),
              deviceId: Value('phone'),
              foregroundMs: Value(6480000),
            ),
          );

      final result = await syncService.uploadDirtyTotals(
        userId: 'user_123',
        deviceId: 'phone',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Network unreachable'));

      // Verify local row remained unsynced
      final row = await db.select(db.dailyTotals).getSingle();
      expect(row.syncedAt, isNull);
    });

    test('deletes user cloud data and updates local settings', () async {
      final success = await syncService.deleteMyCloudData(userId: 'user_123');

      expect(success, isTrue);
      expect(fakeClient.deleteCalled, isTrue);

      final syncEnabled = await db.settingsDao.getSetting('sync_enabled');
      expect(syncEnabled, equals('false'));
    });
  });
}
