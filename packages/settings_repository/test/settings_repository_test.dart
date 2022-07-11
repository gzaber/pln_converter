import 'package:mocktail/mocktail.dart';
import 'package:settings_api/settings_api.dart';
import 'package:settings_repository/settings_repository.dart';
import 'package:test/test.dart';

class MockSettingsApi extends Mock implements SettingsApi {}

class FakeSettings extends Fake implements Settings {}

void main() {
  group('SettingsRepository', () {
    late SettingsApi settingsApi;

    final settings = Settings(
      currencyCode: 'USD',
      currencyTable: 'A',
      theme: AppTheme.light,
    );

    SettingsRepository createRepository() =>
        SettingsRepository(settingsApi: settingsApi);

    setUpAll(() {
      registerFallbackValue(FakeSettings());
    });

    setUp(() {
      settingsApi = MockSettingsApi();
      when(() => settingsApi.getSettings()).thenReturn(settings);
      when(() => settingsApi.saveSettings(any()))
          .thenAnswer((invocation) async => Future.value());
    });

    group('constructor', () {
      test('works properly', () {
        expect(
          () => createRepository(),
          returnsNormally,
        );
      });
    });

    group('getSettings', () {
      test('returns null if settings not found', () {
        when(() => settingsApi.getSettings()).thenReturn(null);

        final sut = createRepository();
        final result = sut.getSettings();

        expect(result, isNull);
      });

      test('returns settings when found', () {
        final sut = createRepository();
        final result = sut.getSettings();

        expect(result, equals(settings));

        verify(() => settingsApi.getSettings()).called(1);
      });
    });

    group('saveSettings', () {
      test('saves settings', () async {
        final sut = createRepository();

        await sut.saveSettings(settings);

        verify(
          () => settingsApi.saveSettings(settings),
        ).called(1);
      });
    });
  });
}
