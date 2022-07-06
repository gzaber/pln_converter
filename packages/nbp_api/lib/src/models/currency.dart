import 'package:json_annotation/json_annotation.dart';

part 'currency.g.dart';

@JsonSerializable()
class Currency {
  Currency({
    required this.table,
    required this.currency,
    required this.code,
    required this.rates,
  });

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);

  final String table;
  final String currency;
  final String code;
  final List<Rate> rates;
}

@JsonSerializable()
class Rate {
  Rate({
    required this.no,
    required this.effectiveDate,
    required this.mid,
  });

  factory Rate.fromJson(Map<String, dynamic> json) => _$RateFromJson(json);

  final String no;
  final String effectiveDate;
  final double mid;
}
