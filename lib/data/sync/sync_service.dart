import 'dart:async';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:oloz/data/db/app_database.dart';

abstract class SupabaseSyncClient {
  Future<void> upsertDailyTotals({
    required String userId,
    required List<Map<String, dynamic>> records,
  });

  Future<List<Map<String, dynamic>>> fetchRemoteDailyTotals({
    required String userId,
    required String excludeDeviceId,
    required String startDay,
  });

  Future<void> deleteUserCloudData({required String userId});
}

class SyncResult {
  const SyncResult({
    required this.success,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.errorMessage,
  });

  final bool success;
  final int uploadedCount;
  final int downloadedCount;
  final String? errorMessage;
}

class SyncService {
  SyncService({
    required this.database,
    required this.client,
  });

  final AppDatabase database;
  final SupabaseSyncClient client;
  final _dayFormat = DateFormat('yyyy-MM-dd');

  /// Uploads unsynced or modified daily_totals rows (batch <= 500).
  Future<SyncResult> uploadDirtyTotals({
    required String userId,
    required String deviceId,
    int? nowMs,
  }) async {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;

    try {
      // Find rows with synced_at IS NULL
      final query = database.select(database.dailyTotals).join([
        innerJoin(
          database.apps,
          database.apps.package.equalsExp(database.dailyTotals.package),
        ),
      ])
        ..where(database.dailyTotals.syncedAt.isNull())
        ..limit(500);

      final rows = await query.get();
      if (rows.isEmpty) {
        return const SyncResult(success: true);
      }

      final payload = <Map<String, dynamic>>[];
      final dirtyKeys = <(String day, String package, String deviceId)>[];

      for (final row in rows) {
        final total = row.readTable(database.dailyTotals);
        final app = row.readTable(database.apps);

        payload.add({
          'device_key': total.deviceId,
          'day': total.day,
          'package': total.package,
          'label': app.label,
          'category': app.category,
          'foreground_ms': total.foregroundMs,
          'opens': total.opens,
          'reels': total.reels,
          'updated_at': DateTime.fromMillisecondsSinceEpoch(now).toIso8601String(),
        });

        dirtyKeys.add((total.day, total.package, total.deviceId));
      }

      // Upsert to Supabase
      await client.upsertDailyTotals(userId: userId, records: payload);

      // Mark local rows as synced
      await database.transaction(() async {
        for (final key in dirtyKeys) {
          await (database.update(database.dailyTotals)
                ..where((tbl) =>
                    tbl.day.equals(key.$1) &
                    tbl.package.equals(key.$2) &
                    tbl.deviceId.equals(key.$3)))
              .write(DailyTotalsCompanion(syncedAt: Value(now)));
        }
      });

      return SyncResult(success: true, uploadedCount: payload.length);
    } on Object catch (e) {
      return SyncResult(success: false, errorMessage: e.toString());
    }
  }

  /// Downloads other devices' daily totals for the last 35 days.
  Future<SyncResult> downloadRemoteTotals({
    required String userId,
    required String currentDeviceId,
    DateTime? referenceDate,
  }) async {
    final refDate = referenceDate ?? DateTime.now();
    final startDay = _dayFormat.format(refDate.subtract(const Duration(days: 35)));

    try {
      final remoteRecords = await client.fetchRemoteDailyTotals(
        userId: userId,
        excludeDeviceId: currentDeviceId,
        startDay: startDay,
      );

      if (remoteRecords.isEmpty) {
        return const SyncResult(success: true);
      }

      var downloaded = 0;
      await database.transaction(() async {
        for (final rec in remoteRecords) {
          final day = rec['day'] as String? ?? '';
          final package = rec['package'] as String? ?? '';
          final deviceKey = rec['device_key'] as String? ?? 'remote';
          final label = rec['label'] as String? ?? package;
          final category = rec['category'] as String? ?? 'other';
          final platform = (rec['platform'] as String?) ?? (deviceKey == 'pc' ? 'windows' : 'android');
          final fgMs = (rec['foreground_ms'] as num?)?.toInt() ?? 0;
          final opens = (rec['opens'] as num?)?.toInt() ?? 0;
          final reels = (rec['reels'] as num?)?.toInt() ?? 0;

          if (day.isEmpty || package.isEmpty) continue;

          // Ensure app definition exists
          await database.usageDao.upsertApp(
            AppsCompanion.insert(
              package: package,
              label: label,
              platform: platform,
              category: category,
            ),
          );

          // Insert or update remote daily rollup
          await database.into(database.dailyTotals).insertOnConflictUpdate(
                DailyTotalsCompanion.insert(
                  day: day,
                  package: package,
                  deviceId: deviceKey,
                  foregroundMs: Value(fgMs),
                  opens: Value(opens),
                  reels: Value(reels),
                  syncedAt: const Value(null),
                ),
              );
          downloaded++;
        }
      });

      return SyncResult(success: true, downloadedCount: downloaded);
    } on Object catch (e) {
      return SyncResult(success: false, errorMessage: e.toString());
    }
  }

  /// Deletes all cloud data for the user and resets sync settings.
  Future<bool> deleteMyCloudData({required String userId}) async {
    try {
      await client.deleteUserCloudData(userId: userId);
      await database.settingsDao.setSetting('sync_enabled', 'false');
      await database.settingsDao.setSetting('last_sync_ms', '0');
      return true;
    } on Object catch (_) {
      return false;
    }
  }
}
