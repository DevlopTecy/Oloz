import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:oloz/data/db/daos/limit_dao.dart';
import 'package:oloz/data/db/daos/reel_dao.dart';
import 'package:oloz/data/db/daos/settings_dao.dart';
import 'package:oloz/data/db/daos/usage_dao.dart';
import 'package:oloz/data/db/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'oloz.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [Apps, Sessions, ReelEvents, DailyTotals, Limits, SettingsEntries],
  daos: [UsageDao, ReelDao, LimitDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // Create indices
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_sessions_day ON sessions(day, package);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_reels_day ON reel_events(day, package);',
          );

          // Seed defaults at first launch
          await into(limits).insert(
            LimitsCompanion.insert(
              scope: 'total',
              dailyLimitMs: const Value(6 * 60 * 60 * 1000), // 6h
              remind: const Value(true),
            ),
          );

          await into(limits).insert(
            LimitsCompanion.insert(
              scope: 'reels_total',
              dailyLimitReels: const Value(350), // 350 reels
              remind: const Value(true),
            ),
          );

          await into(settingsEntries).insert(
            const SettingsEntriesCompanion(
              key: Value('reminder_interval_min'),
              value: Value('15'),
            ),
          );
          await into(settingsEntries).insert(
            const SettingsEntriesCompanion(
              key: Value('theme'),
              value: Value('auto'),
            ),
          );
          await into(settingsEntries).insert(
            const SettingsEntriesCompanion(
              key: Value('notifications'),
              value: Value('true'),
            ),
          );
        },
      );
}

