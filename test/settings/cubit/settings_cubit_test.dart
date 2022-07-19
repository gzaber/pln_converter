import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/settings/settings.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockSettings extends Mock implements Settings {}

void main() {
  group('SettingsCubit', () {
    late SettingsRepository settingsRepository;
    late SettingsCubit settingsCubit;

    setUp(() {
      settingsRepository = MockSettingsRepository();
      settingsCubit = SettingsCubit(settingsRepository: settingsRepository);
    });

    setUpAll(() {
      registerFallbackValue(MockSettings());
    });

    const defaultSettings = Settings(
      currencyCode: 'USD',
      currencyTable: 'A',
      theme: AppTheme.light,
    );

    const storedSettings = Settings(
      currencyCode: 'FJD',
      currencyTable: 'B',
      theme: AppTheme.dark,
    );

    test('initial state is correct', () {
      expect(settingsCubit.state, equals(defaultSettings));
    });

    group('readSettings', () {
      blocTest<SettingsCubit, Settings>(
        'emits stored settings when read settings successfully',
        setUp: () => when(() => settingsRepository.getSettings())
            .thenReturn(storedSettings),
        build: () => settingsCubit,
        act: (cubit) => cubit.readSettings(),
        expect: () => const <Settings>[storedSettings],
      );

      blocTest<SettingsCubit, Settings>(
        'emits default settings when read settings failure',
        setUp: () =>
            when(() => settingsRepository.getSettings()).thenReturn(null),
        build: () => settingsCubit,
        act: (cubit) => cubit.readSettings(),
        expect: () => const <Settings>[defaultSettings],
      );
    });

    group('saveCurrency', () {
      final codeTableBasedSettings =
          defaultSettings.copyWith(currencyCode: 'FJD', currencyTable: 'B');

      blocTest<SettingsCubit, Settings>(
        'emits settings based on currency code and table',
        setUp: () => when(() => settingsRepository.saveSettings(any()))
            .thenAnswer((_) => Future.value()),
        build: () => settingsCubit,
        act: (cubit) => cubit.saveCurrency('FJD', 'B'),
        expect: () => <Settings>[codeTableBasedSettings],
      );
    });

    group('saveTheme', () {
      final themeBasedSettings = defaultSettings.copyWith(theme: AppTheme.dark);
      blocTest<SettingsCubit, Settings>(
        'emits settings based on app theme',
        setUp: () => when(() => settingsRepository.saveSettings(any()))
            .thenAnswer((_) => Future.value()),
        build: () => settingsCubit,
        act: (cubit) => cubit.saveTheme(AppTheme.dark),
        expect: () => <Settings>[themeBasedSettings],
      );
    });
  });
}
