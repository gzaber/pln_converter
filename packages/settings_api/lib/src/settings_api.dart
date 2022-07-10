import 'package:settings_api/settings_api.dart';

abstract class SettingsApi {
  const SettingsApi();

  Settings? getSettings();
  Future<void> saveSettings(Settings settings);
}
