import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/app/cubit/app_cubit.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockSettings extends Mock implements Settings {}

void main() {
  group('AppCubit', () {
    late SettingsRepository settingsRepository;
    late AppCubit appCubit;

    setUp(() {
      settingsRepository = MockSettingsRepository();
      appCubit = AppCubit(settingsRepository: settingsRepository);
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
      expect(appCubit.state, equals(defaultSettings));
    });

    group('readSettings', () {
      blocTest<AppCubit, Settings>(
        'emits stored settings when read settings successfully',
        setUp: () => when(() => settingsRepository.getSettings())
            .thenReturn(storedSettings),
        build: () => appCubit,
        act: (cubit) => cubit.readSettings(),
        expect: () => const <Settings>[storedSettings],
      );

      blocTest<AppCubit, Settings>(
        'emits default settings when read settings failure',
        setUp: () =>
            when(() => settingsRepository.getSettings()).thenReturn(null),
        build: () => appCubit,
        act: (cubit) => cubit.readSettings(),
        expect: () => const <Settings>[defaultSettings],
      );
    });

    group('saveCurrency', () {
      final codeTableBasedSettings =
          defaultSettings.copyWith(currencyCode: 'FJD', currencyTable: 'B');

      blocTest<AppCubit, Settings>(
        'emits settings based on currency code and table',
        setUp: () => when(() => settingsRepository.saveSettings(any()))
            .thenAnswer((_) => Future.value()),
        build: () => appCubit,
        act: (cubit) => cubit.saveCurrency('FJD', 'B'),
        expect: () => <Settings>[codeTableBasedSettings],
      );
    });

    group('saveTheme', () {
      final themeBasedSettings = defaultSettings.copyWith(theme: AppTheme.dark);
      blocTest<AppCubit, Settings>(
        'emits settings based on app theme',
        setUp: () => when(() => settingsRepository.saveSettings(any()))
            .thenAnswer((_) => Future.value()),
        build: () => appCubit,
        act: (cubit) => cubit.saveTheme(AppTheme.dark),
        expect: () => <Settings>[themeBasedSettings],
      );
    });
  });
}
