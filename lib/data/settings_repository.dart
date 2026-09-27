import 'package:sembast/sembast.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(Database database)
    : _settings = stringMapStoreFactory.store('settings'),
      _database = database;

  final Database _database;
  final StoreRef<String, Map<String, Object?>> _settings;
  static const _settingsKey = 'app';

  Future<AppSettings> getSettings() async {
    final map = await _settings.record(_settingsKey).get(_database);
    return map == null ? AppSettings.defaults : AppSettings.fromMap(map);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settings.record(_settingsKey).put(_database, settings.toMap());
  }
}
