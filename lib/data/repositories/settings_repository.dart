import 'package:oloz/data/db/daos/settings_dao.dart';

class SettingsRepository {
  const SettingsRepository(this._settingsDao);

  final SettingsDao _settingsDao;

  Stream<bool> watchOnboarded() => _settingsDao.watchBool('onboarded');
  Future<void> setOnboarded({required bool onboarded}) => _settingsDao.setBool('onboarded', value: onboarded);

  Stream<String> watchTheme() => _settingsDao.watchSetting('theme').map((v) => v ?? 'auto');
  Future<void> setTheme(String theme) => _settingsDao.setSetting('theme', theme);

  Stream<bool> watchNotifications() => _settingsDao.watchBool('notifications', defaultValue: true);
  Future<void> setNotifications({required bool enabled}) => _settingsDao.setBool('notifications', value: enabled);

  Stream<int> watchReminderInterval() => _settingsDao.watchInt('reminder_interval_min', defaultValue: 15);
  Future<void> setReminderInterval(int minutes) => _settingsDao.setInt('reminder_interval_min', minutes);

  Stream<bool> watchSyncEnabled() => _settingsDao.watchBool('sync_enabled');
  Future<void> setSyncEnabled({required bool enabled}) => _settingsDao.setBool('sync_enabled', value: enabled);
}

