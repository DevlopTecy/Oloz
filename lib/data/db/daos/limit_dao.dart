import 'package:drift/drift.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/tables.dart';

part 'limit_dao.g.dart';

@DriftAccessor(tables: [Limits])
class LimitDao extends DatabaseAccessor<AppDatabase> with _$LimitDaoMixin {
  LimitDao(super.attachedDatabase);

  /// Watch all configured limits.
  Stream<List<AppLimit>> watchAllLimits() => select(limits).watch();

  /// Watch limit for a specific scope and optional package.
  Stream<AppLimit?> watchLimit({required String scope, String? package}) {
    final query = select(limits)..where((tbl) => tbl.scope.equals(scope));
    if (package != null) {
      query.where((tbl) => tbl.package.equals(package));
    }
    return query.watchSingleOrNull();
  }

  /// Get limit for a specific scope and optional package.
  Future<AppLimit?> getLimit({required String scope, String? package}) {
    final query = select(limits)..where((tbl) => tbl.scope.equals(scope));
    if (package != null) {
      query.where((tbl) => tbl.package.equals(package));
    }
    return query.getSingleOrNull();
  }

  /// Set or update limit.
  Future<void> setLimit({
    required String scope,
    String? package,
    int? dailyLimitMs,
    int? dailyLimitReels,
    bool remind = true,
  }) async {
    final existing = await getLimit(scope: scope, package: package);

    if (existing == null) {
      await into(limits).insert(
        LimitsCompanion.insert(
          scope: scope,
          package: Value(package),
          dailyLimitMs: Value(dailyLimitMs),
          dailyLimitReels: Value(dailyLimitReels),
          remind: Value(remind),
        ),
      );
    } else {
      await (update(limits)..where((tbl) => tbl.id.equals(existing.id))).write(
        LimitsCompanion(
          dailyLimitMs: Value(dailyLimitMs),
          dailyLimitReels: Value(dailyLimitReels),
          remind: Value(remind),
        ),
      );
    }
  }

  /// Snooze a limit until a given UTC epoch ms timestamp.
  Future<void> snoozeLimit(int id, int untilMs) {
    return (update(limits)..where((tbl) => tbl.id.equals(id))).write(
      LimitsCompanion(
        snoozeUntilMs: Value(untilMs),
      ),
    );
  }
}

