import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:nbp_api/nbp_api.dart' hide Currency;

class ExchangeRatesRepository {
  ExchangeRatesRepository({NbpApiClient? nbpApiClient})
      : _nbpApiClient = nbpApiClient ?? NbpApiClient();

  final NbpApiClient _nbpApiClient;

  Future<Currency> getCurrency(String table, String code) async {
    final currency = await _nbpApiClient.getCurrency(table, code);

    return Currency(
      name: currency.currency,
      code: currency.code,
      table: currency.table,
      rate: currency.rates.first.mid,
    );
  }

  Future<List<Currency>> getCurrencies() async {
    final tableA = await _nbpApiClient.getTable('A');
    final tableB = await _nbpApiClient.getTable('B');

    final currenciesA = tableA.rates
        .map(
          (cr) => Currency(
            name: cr.currency,
            code: cr.code,
            table: tableA.table,
            rate: cr.mid,
          ),
        )
        .toList();
    final currenciesB = tableB.rates
        .map(
          (cr) => Currency(
            name: cr.currency,
            code: cr.code,
            table: tableB.table,
            rate: cr.mid,
          ),
        )
        .toList();

    return [...currenciesA, ...currenciesB];
  }
}
