import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:pln_converter/app/app.dart';
import 'package:settings_repository/settings_repository.dart';
import 'package:shared_preferences_settings_api/shared_preferences_settings_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final settingsApi = SharedPreferencesSettingsApi(prefs: prefs);
  final settingsRepository = SettingsRepository(settingsApi: settingsApi);
  final exchangeRatesRepository = ExchangeRatesRepository();

  runApp(
    App(
      settingsRepository: settingsRepository,
      exchangeRatesRepository: exchangeRatesRepository,
    ),
  );
}
