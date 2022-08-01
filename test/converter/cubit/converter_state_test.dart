import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pln_converter/converter/converter.dart';

void main() {
  group('ConverterState', () {
    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);

    ConverterState createState() => const ConverterState();

    test('constructor works properly', () {
      expect(() => createState(), returnsNormally);
    });

    test('supports value equality', () {
      expect(createState(), equals(createState()));
    });

    test('props are correct', () {
      expect(
        createState().props,
        equals(<Object?>[ConverterStatus.loading, null, true, 0.0, 0.0, '']),
      );
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          createState().copyWith(),
          equals(createState()),
        );
      });

      test('retains old parameter value if null is provided', () {
        expect(
          createState().copyWith(
              status: null,
              foreignCurrency: null,
              isPlnUp: null,
              plnValue: null,
              foreignCurrencyValue: null,
              errorMessage: null),
          equals(createState()),
        );
      });

      test('replaces non-null parameters', () {
        expect(
          createState().copyWith(
              status: ConverterStatus.failure,
              foreignCurrency: usd,
              isPlnUp: false,
              plnValue: usd.rate * 2,
              foreignCurrencyValue: 2,
              errorMessage: 'failure'),
          equals(
            ConverterState(
                status: ConverterStatus.failure,
                foreignCurrency: usd,
                isPlnUp: false,
                plnValue: usd.rate * 2,
                foreignCurrencyValue: 2,
                errorMessage: 'failure'),
          ),
        );
      });
    });
  });
}
