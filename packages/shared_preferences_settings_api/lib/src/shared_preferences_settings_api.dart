import 'dart:convert';

import 'package:settings_api/settings_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSettingsApi extends SettingsApi {
  const SharedPreferencesSettingsApi({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;
  static const _settingsKey = '__settings_key__';

  @override
  Settings? getSettings() {
    final settings = _prefs.getString(_settingsKey);
    if (settings == null) {
      return null;
    } else {
      return Settings.fromJson(
        json.decode(settings),
      );
    }
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await _prefs.setString(
      _settingsKey,
      json.encode(settings.toJson()),
    );
  }
}
