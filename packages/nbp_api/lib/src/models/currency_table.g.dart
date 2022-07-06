// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyTable _$CurrencyTableFromJson(Map<String, dynamic> json) =>
    CurrencyTable(
      table: json['table'] as String,
      no: json['no'] as String,
      effectiveDate: json['effectiveDate'] as String,
      rates: (json['rates'] as List<dynamic>)
          .map((e) => CurrencyRate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

CurrencyRate _$CurrencyRateFromJson(Map<String, dynamic> json) => CurrencyRate(
      currency: json['currency'] as String,
      code: json['code'] as String,
      mid: (json['mid'] as num).toDouble(),
    );
