// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_dao.dart';

// ignore_for_file: type=lint
mixin _$UsageDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppsTable get apps => attachedDatabase.apps;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $DailyTotalsTable get dailyTotals => attachedDatabase.dailyTotals;
  UsageDaoManager get managers => UsageDaoManager(this);
}

class UsageDaoManager {
  final _$UsageDaoMixin _db;
  UsageDaoManager(this._db);
  $$AppsTableTableManager get apps =>
      $$AppsTableTableManager(_db.attachedDatabase, _db.apps);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$DailyTotalsTableTableManager get dailyTotals =>
      $$DailyTotalsTableTableManager(_db.attachedDatabase, _db.dailyTotals);
}
