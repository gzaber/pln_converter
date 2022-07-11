import 'package:settings_api/settings_api.dart';

class SettingsRepository {
  const SettingsRepository({
    required SettingsApi settingsApi,
  }) : _settingsApi = settingsApi;

  final SettingsApi _settingsApi;

  Settings? getSettings() => _settingsApi.getSettings();

  Future<void> saveSettings(Settings settings) async =>
      await _settingsApi.saveSettings(settings);
}
