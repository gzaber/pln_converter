import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nbp_api/nbp_api.dart' as nbp_api;
import 'package:test/test.dart';

class MockNbpApiClient extends Mock implements nbp_api.NbpApiClient {}

void main() {
  group('ExchangeRatesRepository', () {
    late nbp_api.NbpApiClient nbpApiClient;
    late ExchangeRatesRepository exchangeRatesRepository;

    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);
    final mga = Currency(
        name: 'ariary (Madagaskar)', code: 'MGA', table: 'B', rate: 0.001143);

    setUp(() {
      nbpApiClient = MockNbpApiClient();
      exchangeRatesRepository =
          ExchangeRatesRepository(nbpApiClient: nbpApiClient);
    });

    group('constructor', () {
      test('does not require NbpApiClient', () {
        expect(ExchangeRatesRepository(), isNotNull);
      });
    });

    group('getCurrency', () {
      test('throws an Exception when failure', () {
        final exception = Exception('failure');
        when(() => nbpApiClient.getCurrency(any(), any())).thenThrow(exception);

        expect(
          () async => await exchangeRatesRepository.getCurrency('C', 'XYZ'),
          throwsA(exception),
        );
      });

      test('returns correct currency when success', () async {
        final currency = nbp_api.Currency(
            table: 'A',
            currency: 'dolar amerykański',
            code: 'USD',
            rates: [
              nbp_api.Rate(
                no: '133/A/NBP/2022',
                effectiveDate: '2022-07-12',
                mid: 4.8284,
              ),
            ]);

        when(() => nbpApiClient.getCurrency(any(), any()))
            .thenAnswer((_) async => currency);

        final result = await exchangeRatesRepository.getCurrency('A', 'USD');

        expect(result, equals(usd));
      });
    });

    group('getCurrencies', () {
      test('throws an Exception when failure', () {
        final exception = Exception('failure');
        when(() => nbpApiClient.getTable(any())).thenThrow(exception);

        expect(
          () async => await exchangeRatesRepository.getCurrencies(),
          throwsA(exception),
        );
      });

      test('returns correct list of currencies when success', () async {
        final ratesA = nbp_api.CurrencyTable(
            table: 'A',
            no: '133/A/NBP/2022',
            effectiveDate: '2022-07-12',
            rates: [
              nbp_api.CurrencyRate(
                  currency: 'dolar amerykański', code: 'USD', mid: 4.8284),
            ]);
        final ratesB = nbp_api.CurrencyTable(
            table: 'B',
            no: '027/B/NBP/2022',
            effectiveDate: '2022-07-06',
            rates: [
              nbp_api.CurrencyRate(
                  currency: 'ariary (Madagaskar)', code: 'MGA', mid: 0.001143),
            ]);

        when(() => nbpApiClient.getTable('A')).thenAnswer((_) async => ratesA);
        when(() => nbpApiClient.getTable('B')).thenAnswer((_) async => ratesB);

        final result = await exchangeRatesRepository.getCurrencies();

        expect(
          result,
          equals([usd, mga]),
        );
      });
    });
  });
}
