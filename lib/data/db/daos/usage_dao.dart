import 'package:drift/drift.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/tables.dart';

part 'usage_dao.g.dart';

class AppUsageSummary {
  const AppUsageSummary({
    required this.package,
    required this.label,
    required this.platform,
    required this.category,
    required this.foregroundMs,
    required this.opens,
    required this.reels,
  });

  final String package;
  final String label;
  final String platform;
  final String category;
  final int foregroundMs;
  final int opens;
  final int reels;
}

class DailyUsagePoint {
  const DailyUsagePoint({
    required this.day,
    required this.foregroundMs,
  });

  final String day;
  final int foregroundMs;
}

@DriftAccessor(tables: [Apps, Sessions, DailyTotals])
class UsageDao extends DatabaseAccessor<AppDatabase> with _$UsageDaoMixin {
  UsageDao(super.attachedDatabase);

  /// Watch total foreground time in ms for a given date range [startDay, endDay].
  /// Optionally filter by [platform] or [deviceId].
  Stream<int> watchTotalTimeForRange({
    required String startDay,
    required String endDay,
    String? platform,
    String? deviceId,
  }) {
    final query = select(dailyTotals).join([
      innerJoin(apps, apps.package.equalsExp(dailyTotals.package)),
    ])
      ..where(dailyTotals.day.isBiggerOrEqualValue(startDay))
      ..where(dailyTotals.day.isSmallerOrEqualValue(endDay));

    if (platform != null) {
      query.where(apps.platform.equals(platform));
    }
    if (deviceId != null) {
      query.where(dailyTotals.deviceId.equals(deviceId));
    }

    return query.watch().map((rows) {
      var total = 0;
      for (final row in rows) {
        total += row.readTable(dailyTotals).foregroundMs;
      }
      return total;
    });
  }

  /// Get total foreground time in ms for a given date range.
  Future<int> getTotalTimeForRange({
    required String startDay,
    required String endDay,
    String? platform,
    String? deviceId,
  }) async {
    final stream = watchTotalTimeForRange(
      startDay: startDay,
      endDay: endDay,
      platform: platform,
      deviceId: deviceId,
    );
    return await stream.first;
  }

  /// Watch per-app summaries sorted by usage descending.
  Stream<List<AppUsageSummary>> watchAppsSummaryForRange({
    required String startDay,
    required String endDay,
    String? platform,
    int? limit,
  }) {
    final query = select(dailyTotals).join([
      innerJoin(apps, apps.package.equalsExp(dailyTotals.package)),
    ])
      ..where(dailyTotals.day.isBiggerOrEqualValue(startDay))
      ..where(dailyTotals.day.isSmallerOrEqualValue(endDay));

    if (platform != null) {
      query.where(apps.platform.equals(platform));
    }

    return query.watch().map((rows) {
      final grouped = <String, AppUsageSummary>{};

      for (final row in rows) {
        final total = row.readTable(dailyTotals);
        final app = row.readTable(apps);

        if (!grouped.containsKey(total.package)) {
          grouped[total.package] = AppUsageSummary(
            package: total.package,
            label: app.label,
            platform: app.platform,
            category: app.category,
            foregroundMs: total.foregroundMs,
            opens: total.opens,
            reels: total.reels,
          );
        } else {
          final existing = grouped[total.package]!;
          grouped[total.package] = AppUsageSummary(
            package: existing.package,
            label: existing.label,
            platform: existing.platform,
            category: existing.category,
            foregroundMs: existing.foregroundMs + total.foregroundMs,
            opens: existing.opens + total.opens,
            reels: existing.reels + total.reels,
          );
        }
      }

      final list = grouped.values.toList()
        ..sort((a, b) => b.foregroundMs.compareTo(a.foregroundMs));

      if (limit != null && list.length > limit) {
        return list.sublist(0, limit);
      }
      return list;
    });
  }

  /// Watch daily time series for a sequence of days (e.g. 7 or 30 days ending today).
  Stream<List<DailyUsagePoint>> watchDailySeries(List<String> days) {
    if (days.isEmpty) {
      return Stream.value([]);
    }

    final query = select(dailyTotals)
      ..where((tbl) => tbl.day.isIn(days));

    return query.watch().map((rows) {
      final map = <String, int>{for (final d in days) d: 0};
      for (final row in rows) {
        map[row.day] = (map[row.day] ?? 0) + row.foregroundMs;
      }
      return days.map((d) => DailyUsagePoint(day: d, foregroundMs: map[d] ?? 0)).toList();
    });
  }

  /// Insert or update an app definition.
  Future<void> upsertApp(AppsCompanion app) async {
    await into(apps).insertOnConflictUpdate(app);
  }

  /// Upsert a session and update daily totals incrementally.
  Future<void> recordSession({
    required String package,
    required String deviceId,
    required int startMs,
    required int endMs,
    required String day,
  }) async {
    final durationMs = endMs - startMs;
    if (durationMs <= 0) return;

    await transaction(() async {
      // 1. Insert session
      await into(sessions).insert(
        SessionsCompanion.insert(
          package: package,
          deviceId: deviceId,
          startMs: startMs,
          endMs: endMs,
          day: day,
        ),
      );

      // 2. Incremental rollup into daily_totals
      final existing = await (select(dailyTotals)
            ..where((tbl) =>
                tbl.day.equals(day) &
                tbl.package.equals(package) &
                tbl.deviceId.equals(deviceId)))
          .getSingleOrNull();

      if (existing == null) {
        await into(dailyTotals).insert(
          DailyTotalsCompanion.insert(
            day: day,
            package: package,
            deviceId: deviceId,
            foregroundMs: Value(durationMs),
            opens: const Value(1),
            reels: const Value(0),
          ),
        );
      } else {
        await (update(dailyTotals)
              ..where((tbl) =>
                  tbl.day.equals(day) &
                  tbl.package.equals(package) &
                  tbl.deviceId.equals(deviceId)))
            .write(
          DailyTotalsCompanion(
            foregroundMs: Value(existing.foregroundMs + durationMs),
            opens: Value(existing.opens + 1),
          ),
        );
      }
    });
  }
}

