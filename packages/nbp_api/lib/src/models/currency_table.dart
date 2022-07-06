import 'package:json_annotation/json_annotation.dart';

part 'currency_table.g.dart';

@JsonSerializable()
class CurrencyTable {
  const CurrencyTable({
    required this.table,
    required this.no,
    required this.effectiveDate,
    required this.rates,
  });

  factory CurrencyTable.fromJson(Map<String, dynamic> json) =>
      _$CurrencyTableFromJson(json);

  final String table;
  final String no;
  final String effectiveDate;
  final List<CurrencyRate> rates;
}

@JsonSerializable()
class CurrencyRate {
  const CurrencyRate({
    required this.currency,
    required this.code,
    required this.mid,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) =>
      _$CurrencyRateFromJson(json);

  final String currency;
  final String code;
  final double mid;
}
