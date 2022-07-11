import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_api/settings_api.dart';
import 'package:shared_preferences_settings_api/shared_preferences_settings_api.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SharedPreferencesSettingsApi', () {
    late SharedPreferences prefs;

    final settings = Settings(
      currencyCode: 'USD',
      currencyTable: 'A',
      theme: AppTheme.light,
    );

    setUp(() {
      prefs = MockSharedPreferences();
      when(() => prefs.getString(any())).thenReturn(json.encode(settings));
      when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
    });

    SharedPreferencesSettingsApi createApi() {
      return SharedPreferencesSettingsApi(prefs: prefs);
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          () => createApi(),
          returnsNormally,
        );
      });
    });

    group('getSettings', () {
      test('returns null if no settings found', () {
        when(() => prefs.getString(any())).thenReturn(null);

        final sut = createApi();
        final result = sut.getSettings();

        expect(result, isNull);
      });

      test('returns settings when found', () {
        final sut = createApi();
        final result = sut.getSettings();

        expect(result, equals(settings));
        verify(
          () => prefs.getString('__settings_key__'),
        ).called(1);
      });
    });

    group('saveSettings', () {
      test('saves settings', () async {
        final sut = createApi();
        await sut.saveSettings(settings);

        verify(
          () => prefs.setString('__settings_key__', json.encode(settings)),
        ).called(1);
      });
    });
  });
}
