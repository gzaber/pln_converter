import 'package:settings_api/settings_api.dart';
import 'package:test/test.dart';

void main() {
  group('Settings', () {
    Settings createSettings() {
      return Settings(
        currencyCode: 'USD',
        currencyTable: 'A',
        theme: AppTheme.light,
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(() => createSettings(), returnsNormally);
      });
    });

    test('supports value equality', () {
      expect(
        createSettings(),
        equals(createSettings()),
      );
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          createSettings().copyWith(),
          equals(createSettings()),
        );
      });

      test('retains the old value for every null parameter', () {
        expect(
          createSettings().copyWith(
            currencyCode: null,
            currencyTable: null,
            theme: null,
          ),
          equals(createSettings()),
        );
      });

      test('replaces non null parameters', () {
        expect(
          createSettings().copyWith(
            currencyCode: 'BSD',
            currencyTable: 'B',
            theme: AppTheme.dark,
          ),
          equals(
            Settings(
              currencyCode: 'BSD',
              currencyTable: 'B',
              theme: AppTheme.dark,
            ),
          ),
        );
      });
    });

    group('fromJson', () {
      test('works correctly', () {
        expect(
          Settings.fromJson(<String, dynamic>{
            "currencyCode": "USD",
            "currencyTable": "A",
            "theme": "light"
          }),
          equals(createSettings()),
        );
      });
    });

    group('toJson', () {
      test('works correctly', () {
        expect(
          createSettings().toJson(),
          equals(<String, dynamic>{
            "currencyCode": "USD",
            "currencyTable": "A",
            "theme": "light"
          }),
        );
      });
    });
  });
}
