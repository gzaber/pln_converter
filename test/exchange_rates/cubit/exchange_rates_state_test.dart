import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pln_converter/exchange_rates/cubit/exchange_rates_cubit.dart';

void main() {
  group('ExchangeRatesState', () {
    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);

    ExchangeRatesState createState() => const ExchangeRatesState();

    test('constructor works properly', () {
      expect(() => createState(), returnsNormally);
    });

    test('supports value equality', () {
      expect(createState(), equals(createState()));
    });

    test('props are correct', () {
      expect(
        createState().props,
        equals(<Object?>[ExchangeRatesStatus.loading, const [], const [], '']),
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
              exchangeRates: null,
              filteredList: null,
              errorMessage: null),
          equals(createState()),
        );
      });

      test('replaces non-null parameters', () {
        expect(
          createState().copyWith(
              status: ExchangeRatesStatus.failure,
              exchangeRates: [usd],
              filteredList: [usd],
              errorMessage: 'failure'),
          equals(ExchangeRatesState(
            status: ExchangeRatesStatus.failure,
            exchangeRates: [usd],
            filteredList: [usd],
            errorMessage: 'failure',
          )),
        );
      });
    });
  });
}
