import 'package:sembast/sembast.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';

class SettingsRepository extends ChangeNotifier {
  SettingsRepository(Database database)
    : _settings = stringMapStoreFactory.store('settings'),
      _database = database;

  final Database _database;
  final StoreRef<String, Map<String, Object?>> _settings;
  static const _settingsKey = 'app';

  AppSettings current = AppSettings.defaults;

  Future<void> load() async {
    current = await getSettings();
  }

  Future<AppSettings> getSettings() async {
    final map = await _settings.record(_settingsKey).get(_database);
    return map == null ? AppSettings.defaults : AppSettings.fromMap(map);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settings.record(_settingsKey).put(_database, settings.toMap());
    current = settings;
    notifyListeners();
  }
}
