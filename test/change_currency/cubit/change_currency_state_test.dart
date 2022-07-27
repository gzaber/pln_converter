import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pln_converter/change_currency/change_currency.dart';

void main() {
  group('ChangeCurrencyState', () {
    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);

    ChangeCurrencyState createState() => const ChangeCurrencyState();

    test('constructor works properly', () {
      expect(() => createState(), returnsNormally);
    });

    test('supports value equality', () {
      expect(createState(), equals(createState()));
    });

    test('props are correct', () {
      expect(createState().props,
          equals(<Object?>[ChangeCurrencyStatus.loading, const [], '']));
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
          createState()
              .copyWith(status: null, currencies: null, errorMessage: null),
          createState(),
        );
      });

      test('replaces non-null parameters', () {
        expect(
          createState().copyWith(
              status: ChangeCurrencyStatus.failure,
              currencies: [usd],
              errorMessage: 'failure'),
          ChangeCurrencyState(
            status: ChangeCurrencyStatus.failure,
            currencies: [usd],
            errorMessage: 'failure',
          ),
        );
      });
    });
  });
}
