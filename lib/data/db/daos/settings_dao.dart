import 'package:drift/drift.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [SettingsEntries])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  /// Watch setting string value by key.
  Stream<String?> watchSetting(String key) {
    return (select(settingsEntries)..where((tbl) => tbl.key.equals(key)))
        .watchSingleOrNull()
        .map((entry) => entry?.value);
  }

  /// Get setting string value by key.
  Future<String?> getSetting(String key) async {
    final entry = await (select(settingsEntries)..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    return entry?.value;
  }

  /// Set setting key-value pair.
  Future<void> setSetting(String key, String value) {
    return into(settingsEntries).insertOnConflictUpdate(
      SettingsEntriesCompanion.insert(key: key, value: value),
    );
  }

  /// Watch boolean setting with default value.
  Stream<bool> watchBool(String key, {bool defaultValue = false}) {
    return watchSetting(key).map((v) => v != null ? v == 'true' : defaultValue);
  }

  /// Set boolean setting.
  Future<void> setBool(String key, {required bool value}) {
    return setSetting(key, value ? 'true' : 'false');
  }

  /// Watch int setting with default value.
  Stream<int> watchInt(String key, {int defaultValue = 0}) {
    return watchSetting(key).map((v) => v != null ? int.tryParse(v) ?? defaultValue : defaultValue);
  }

  /// Set int setting.
  Future<void> setInt(String key, int value) {
    return setSetting(key, value.toString());
  }
}

