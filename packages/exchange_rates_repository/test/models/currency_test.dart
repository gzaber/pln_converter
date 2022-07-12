import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:test/test.dart';

void main() {
  group('Currency', () {
    Currency createCurrency() {
      return Currency(
        name: 'dolar amerykański',
        code: 'USD',
        table: 'A',
        rate: 4.8284,
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          () => createCurrency(),
          returnsNormally,
        );
      });
    });

    test('supports value equality', () {
      expect(
        createCurrency(),
        equals(createCurrency()),
      );
    });
  });
}
