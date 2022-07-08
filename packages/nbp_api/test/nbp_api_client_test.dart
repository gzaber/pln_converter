import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nbp_api/nbp_api.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  group('NbpApiClient', () {
    late Dio dioHttpClient;
    late NbpApiClient nbpApiClient;

    setUp(() {
      dioHttpClient = MockDio();
      when(() => dioHttpClient.options).thenAnswer((_) => BaseOptions());
      nbpApiClient = NbpApiClient(dio: dioHttpClient);
    });

    group('constructor', () {
      test('does not require an http client', () {
        expect(NbpApiClient(), isNotNull);
      });
    });

    group('getTable', () {
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.data).thenReturn('data');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        try {
          await nbpApiClient.getTable('A');
        } catch (_) {}
        verify(
          () => dioHttpClient.get('/tables/A'),
        ).called(1);
      });

      test('throws BadRequestFailure on bad request or time limit exceeded',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => response.data).thenReturn('data');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await nbpApiClient.getTable('A'),
          throwsA(isA<BadRequestFailure>()),
        );
      });

      test('throws NotFoundFailure on no data found', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(404);
        when(() => response.data).thenReturn('[{data}]');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await nbpApiClient.getTable('A'),
          throwsA(isA<NotFoundFailure>()),
        );
      });

      test('returns CurrencyTable on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.data).thenReturn('''[{
              "table": "A",
              "no": "131/A/NBP/2022",
              "effectiveDate": "2022-07-08",
              "rates": [
                {"currency": "bat (Tajlandia)", "code": "THB", "mid": 0.1316},
                {"currency": "dolar amerykański", "code": "USD", "mid": 4.7417},
                {"currency": "dolar australijski", "code": "AUD", "mid": 3.2318}
              ]
            }]
            ''');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        final actual = await nbpApiClient.getTable('A');
        expect(
          actual,
          isA<CurrencyTable>()
              .having((ct) => ct.table, 'table', 'A')
              .having((ct) => ct.no, 'no', '131/A/NBP/2022')
              .having((ct) => ct.effectiveDate, 'effectiveDate', '2022-07-08')
              .having(
                (ct) => ct.rates,
                'rates',
                isA<List<CurrencyRate>>()
                    .having(
                        (cr) => cr[0].currency, 'currency', 'bat (Tajlandia)')
                    .having((cr) => cr[0].code, 'code', 'THB')
                    .having((cr) => cr[0].mid, 'mid', 0.1316)
                    .having(
                        (cr) => cr[1].currency, 'currency', 'dolar amerykański')
                    .having((cr) => cr[1].code, 'code', 'USD')
                    .having((cr) => cr[1].mid, 'mid', 4.7417)
                    .having((cr) => cr[2].currency, 'currency',
                        'dolar australijski')
                    .having((cr) => cr[2].code, 'code', 'AUD')
                    .having((cr) => cr[2].mid, 'mid', 3.2318),
              ),
        );
      });
    });

    group('getCurrency', () {
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.data).thenReturn('data');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        try {
          await nbpApiClient.getCurrency('A', 'USD');
        } catch (_) {}
        verify(
          () => dioHttpClient.get('/rates/A/USD'),
        ).called(1);
      });

      test('throws BadRequestFailure on bad request or time limit exceeded',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => response.data).thenReturn('data');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await nbpApiClient.getCurrency('A', 'USD'),
          throwsA(isA<BadRequestFailure>()),
        );
      });

      test('throws NotFoundFailure on no data found', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(404);
        when(() => response.data).thenReturn('[{data}]');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await nbpApiClient.getCurrency('A', 'USD'),
          throwsA(isA<NotFoundFailure>()),
        );
      });

      test('returns Currency on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.data).thenReturn('''{
              "table": "A",
              "currency": "dolar amerykański",
              "code": "USD",
              "rates": [
                {"no": "131/A/NBP/2022", "effectiveDate": "2022-07-08", "mid": 4.7417}
              ]
            }
            ''');
        when(() => dioHttpClient.get(any())).thenAnswer((_) async => response);
        final actual = await nbpApiClient.getCurrency('A', 'USD');
        expect(
          actual,
          isA<Currency>()
              .having((c) => c.table, 'table', 'A')
              .having((c) => c.currency, 'currency', 'dolar amerykański')
              .having((c) => c.code, 'code', 'USD')
              .having(
                (c) => c.rates,
                'rates',
                isA<List<Rate>>()
                    .having((r) => r[0].no, 'no', '131/A/NBP/2022')
                    .having((r) => r[0].effectiveDate, 'effectiveDate',
                        '2022-07-08')
                    .having((r) => r[0].mid, 'mid', 4.7417),
              ),
        );
      });
    });
  });
}
