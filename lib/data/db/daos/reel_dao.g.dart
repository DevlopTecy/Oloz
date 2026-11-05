// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reel_dao.dart';

// ignore_for_file: type=lint
mixin _$ReelDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppsTable get apps => attachedDatabase.apps;
  $ReelEventsTable get reelEvents => attachedDatabase.reelEvents;
  $DailyTotalsTable get dailyTotals => attachedDatabase.dailyTotals;
  ReelDaoManager get managers => ReelDaoManager(this);
}

class ReelDaoManager {
  final _$ReelDaoMixin _db;
  ReelDaoManager(this._db);
  $$AppsTableTableManager get apps =>
      $$AppsTableTableManager(_db.attachedDatabase, _db.apps);
  $$ReelEventsTableTableManager get reelEvents =>
      $$ReelEventsTableTableManager(_db.attachedDatabase, _db.reelEvents);
  $$DailyTotalsTableTableManager get dailyTotals =>
      $$DailyTotalsTableTableManager(_db.attachedDatabase, _db.dailyTotals);
}
