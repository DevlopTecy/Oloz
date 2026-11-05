import 'package:drift/drift.dart';

/// Apps table: Tracked applications on Android or Windows.
class Apps extends Table {
  TextColumn get package => text()();
  TextColumn get label => text()();
  TextColumn get platform => text()(); // 'android' | 'windows'
  TextColumn get category => text()(); // 'social' | 'video' | 'browsing' | 'messaging' | 'utility' | 'other'
  BoolColumn get isShortVideo => boolean().withDefault(const Constant(false))();
  BoolColumn get tracked => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {package};
}

/// Sessions table: One row per foreground session.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get package => text().references(Apps, #package)();
  TextColumn get deviceId => text()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get day => text()(); // 'yyyy-MM-dd'

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (package) REFERENCES apps(package) ON DELETE CASCADE',
  ];
}

/// ReelEvents table: One row per reel viewed.
class ReelEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get package => text()();
  TextColumn get deviceId => text()();
  IntColumn get atMs => integer()();
  IntColumn get dwellMs => integer()();
  TextColumn get day => text()(); // 'yyyy-MM-dd'
}

/// DailyTotals table: Incremental rollup per day, package, and device.
class DailyTotals extends Table {
  TextColumn get day => text()(); // 'yyyy-MM-dd'
  TextColumn get package => text()();
  TextColumn get deviceId => text()();
  IntColumn get foregroundMs => integer().withDefault(const Constant(0))();
  IntColumn get opens => integer().withDefault(const Constant(0))();
  IntColumn get reels => integer().withDefault(const Constant(0))();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {day, package, deviceId};
}

/// Limits table: Screen time and reel limits.
@DataClassName('AppLimit')
class Limits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get scope => text()(); // 'app' | 'total' | 'reels_total'
  TextColumn get package => text().nullable()(); // null unless scope == 'app'
  IntColumn get dailyLimitMs => integer().nullable()(); // for app/total
  IntColumn get dailyLimitReels => integer().nullable()(); // for reels_total
  BoolColumn get remind => boolean().withDefault(const Constant(true))();
  IntColumn get snoozeUntilMs => integer().nullable()();
}

/// Settings table: Key-value store.
class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

