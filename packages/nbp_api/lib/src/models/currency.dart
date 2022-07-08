import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'currency.g.dart';

@JsonSerializable()
class Rate extends Equatable {
  Rate({
    required this.no,
    required this.effectiveDate,
    required this.mid,
  });

  factory Rate.fromJson(Map<String, dynamic> json) => _$RateFromJson(json);

  final String no;
  final String effectiveDate;
  final double mid;

  @override
  List<Object?> get props => [no, effectiveDate, mid];
}

@JsonSerializable()
class Currency extends Equatable {
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

  @override
  List<Object?> get props => [table, currency, code, rates];
}
