import 'package:settings_api/settings_api.dart';

abstract class SettingsApi {
  const SettingsApi();

  Stream<Settings> getSettings();
  Future<void> saveSettings(Settings settings);
}
