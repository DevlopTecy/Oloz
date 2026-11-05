// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'limit_dao.dart';

// ignore_for_file: type=lint
mixin _$LimitDaoMixin on DatabaseAccessor<AppDatabase> {
  $LimitsTable get limits => attachedDatabase.limits;
  LimitDaoManager get managers => LimitDaoManager(this);
}

class LimitDaoManager {
  final _$LimitDaoMixin _db;
  LimitDaoManager(this._db);
  $$LimitsTableTableManager get limits =>
      $$LimitsTableTableManager(_db.attachedDatabase, _db.limits);
}
