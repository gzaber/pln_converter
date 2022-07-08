import 'package:nbp_api/nbp_api.dart';
import 'package:test/test.dart';

void main() {
  group('CurrencyRate', () {
    CurrencyRate createRate() {
      return CurrencyRate(
        currency: 'dolar amerykański',
        code: 'USD',
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
          CurrencyRate.fromJson(
            <String, dynamic>{
              'currency': 'dolar amerykański',
              'code': 'USD',
              'mid': 4.7417,
            },
          ),
          equals(createRate()),
        );
      });
    });
  });

  group('CurrencyTable', () {
    CurrencyTable createTable() {
      return CurrencyTable(
        table: 'A',
        no: '131/A/NBP/2022',
        effectiveDate: '2022-07-08',
        rates: [
          CurrencyRate(currency: 'bat (Tajlandia)', code: 'THB', mid: 0.1316),
          CurrencyRate(currency: 'dolar amerykański', code: 'USD', mid: 4.7417),
          CurrencyRate(
              currency: 'dolar australijski', code: 'AUD', mid: 3.2318),
        ],
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(() => createTable(), returnsNormally);
      });
    });

    test('supports value equality', () {
      expect(
        createTable(),
        equals(createTable()),
      );
    });

    group('fromJson', () {
      test('works correctly', () {
        expect(
          CurrencyTable.fromJson(
            <String, dynamic>{
              "table": "A",
              "no": "131/A/NBP/2022",
              "effectiveDate": "2022-07-08",
              "rates": [
                {"currency": "bat (Tajlandia)", "code": "THB", "mid": 0.1316},
                {"currency": "dolar amerykański", "code": "USD", "mid": 4.7417},
                {
                  "currency": "dolar australijski",
                  "code": "AUD",
                  "mid": 3.2318
                },
              ],
            },
          ),
          equals(createTable()),
        );
      });
    });
  });
}
