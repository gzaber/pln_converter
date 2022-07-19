import 'package:bloc/bloc.dart';
import 'package:settings_repository/settings_repository.dart';

class SettingsCubit extends Cubit<Settings> {
  SettingsCubit({required this.settingsRepository}) : super(defaultSettings);

  final SettingsRepository settingsRepository;

  static const defaultSettings = Settings(
    currencyCode: 'USD',
    currencyTable: 'A',
    theme: AppTheme.light,
  );

  void readSettings() {
    final settings = settingsRepository.getSettings();
    if (settings != null) {
      emit(settings);
    } else {
      emit(defaultSettings);
    }
  }

  saveCurrency(String code, String table) async {
    emit(state.copyWith(currencyCode: code, currencyTable: table));
    await settingsRepository.saveSettings(state);
  }

  saveTheme(AppTheme theme) async {
    emit(state.copyWith(theme: theme));
    await settingsRepository.saveSettings(state);
  }
}
