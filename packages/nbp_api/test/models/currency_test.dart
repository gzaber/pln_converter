import 'package:nbp_api/nbp_api.dart';
import 'package:test/test.dart';

void main() {
  group('Rate', () {
    Rate createRate() {
      return Rate(
        no: '131/A/NBP/2022',
        effectiveDate: '2022-07-08',
        mid: 4.7417,
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(() => createRate(), returnsNormally);
      });
    });

    test('supports value equality', () {
      expect(
        createRate(),
        equals(createRate()),
      );
    });

    group('fromJson', () {
      test('works correctly', () {
        expect(
          Rate.fromJson(
            <String, dynamic>{
              'no': '131/A/NBP/2022',
              'effectiveDate': '2022-07-08',
              'mid': 4.7417,
            },
          ),
          equals(createRate()),
        );
      });
    });
  });

  group('Currency', () {
    Currency createCurrency() {
      return Currency(
        table: 'A',
        currency: 'dolar amerykański',
        code: 'USD',
        rates: [
          Rate(no: '131/A/NBP/2022', effectiveDate: '2022-07-08', mid: 4.7417)
        ],
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(() => createCurrency(), returnsNormally);
      });
    });

    test('supports value equality', () {
      expect(
        createCurrency(),
        equals(createCurrency()),
      );
    });

    group('fromJson', () {
      test('works correctly', () {
        expect(
          Currency.fromJson(
            <String, dynamic>{
              "table": "A",
              "currency": "dolar amerykański",
              "code": "USD",
              "rates": [
                {
                  "no": "131/A/NBP/2022",
                  "effectiveDate": "2022-07-08",
                  "mid": 4.7417
                }
              ]
            },
          ),
          equals(createCurrency()),
        );
      });
    });
  });
}
