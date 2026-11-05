import 'package:drift/drift.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/tables.dart';

part 'reel_dao.g.dart';

class PlatformReelSummary {
  const PlatformReelSummary({
    required this.package,
    required this.name,
    required this.count,
  });

  final String package;
  final String name;
  final int count;
}

class DailyReelPoint {
  const DailyReelPoint({
    required this.day,
    required this.count,
  });

  final String day;
  final int count;
}

@DriftAccessor(tables: [Apps, ReelEvents, DailyTotals])
class ReelDao extends DatabaseAccessor<AppDatabase> with _$ReelDaoMixin {
  ReelDao(super.attachedDatabase);

  /// Watch total reels count for date range.
  Stream<int> watchTotalReelsForRange({
    required String startDay,
    required String endDay,
    String? deviceId,
  }) {
    final query = select(dailyTotals)
      ..where((tbl) =>
          tbl.day.isBiggerOrEqualValue(startDay) &
          tbl.day.isSmallerOrEqualValue(endDay));

    if (deviceId != null) {
      query.where((tbl) => tbl.deviceId.equals(deviceId));
    }

    return query.watch().map((rows) {
      var total = 0;
      for (final row in rows) {
        total += row.reels;
      }
      return total;
    });
  }

  /// Watch reels by platform (Instagram, TikTok, YouTube Shorts, Facebook).
  Stream<List<PlatformReelSummary>> watchReelsByPlatformForRange({
    required String startDay,
    required String endDay,
  }) {
    final query = select(dailyTotals).join([
      innerJoin(apps, apps.package.equalsExp(dailyTotals.package)),
    ])
      ..where(dailyTotals.day.isBiggerOrEqualValue(startDay))
      ..where(dailyTotals.day.isSmallerOrEqualValue(endDay))
      ..where(apps.isShortVideo.equals(true));

    return query.watch().map((rows) {
      final grouped = <String, PlatformReelSummary>{};

      for (final row in rows) {
        final total = row.readTable(dailyTotals);
        final app = row.readTable(apps);

        if (!grouped.containsKey(total.package)) {
          grouped[total.package] = PlatformReelSummary(
            package: total.package,
            name: app.label,
            count: total.reels,
          );
        } else {
          final existing = grouped[total.package]!;
          grouped[total.package] = PlatformReelSummary(
            package: existing.package,
            name: existing.name,
            count: existing.count + total.reels,
          );
        }
      }

      final list = grouped.values.toList()
        ..sort((a, b) => b.count.compareTo(a.count));
      return list;
    });
  }

  /// Watch daily reel series for a sequence of days.
  Stream<List<DailyReelPoint>> watchDailyReelSeries(List<String> days) {
    if (days.isEmpty) return Stream.value([]);

    final query = select(dailyTotals)
      ..where((tbl) => tbl.day.isIn(days));

    return query.watch().map((rows) {
      final map = <String, int>{for (final d in days) d: 0};
      for (final row in rows) {
        map[row.day] = (map[row.day] ?? 0) + row.reels;
      }
      return days.map((d) => DailyReelPoint(day: d, count: map[d] ?? 0)).toList();
    });
  }

  /// Record an incoming reel scroll event and update daily totals.
  Future<void> recordReelEvent({
    required String package,
    required String deviceId,
    required int atMs,
    required int dwellMs,
    required String day,
  }) async {
    await transaction(() async {
      await into(reelEvents).insert(
        ReelEventsCompanion.insert(
          package: package,
          deviceId: deviceId,
          atMs: atMs,
          dwellMs: dwellMs,
          day: day,
        ),
      );

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
            foregroundMs: const Value(0),
            opens: const Value(0),
            reels: const Value(1),
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
            reels: Value(existing.reels + 1),
          ),
        );
      }
    });
  }
}

