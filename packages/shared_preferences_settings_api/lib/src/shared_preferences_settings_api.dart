import 'package:settings_api/settings_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSettingsApi extends SettingsApi {
  const SharedPreferencesSettingsApi({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Settings? getSettings() {
    final currencyCode = _prefs.getString('currencyCode');
    final currencyTable = _prefs.getString('currencyTable');
    final theme = _prefs.getString('theme');

    if (currencyCode == null || currencyTable == null || theme == null) {
      return null;
    } else {
      return Settings(
        currencyCode: currencyCode,
        currencyTable: currencyTable,
        theme: AppTheme.values.byName(theme),
      );
    }
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await _prefs.setString('currencyCode', settings.currencyCode);
    await _prefs.setString('currencyTable', settings.currencyTable);
    await _prefs.setString('theme', settings.theme.name);
  }
}
