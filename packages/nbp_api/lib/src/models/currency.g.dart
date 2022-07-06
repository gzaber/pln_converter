// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Currency _$CurrencyFromJson(Map<String, dynamic> json) => Currency(
      table: json['table'] as String,
      currency: json['currency'] as String,
      code: json['code'] as String,
      rates: (json['rates'] as List<dynamic>)
          .map((e) => Rate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Rate _$RateFromJson(Map<String, dynamic> json) => Rate(
      no: json['no'] as String,
      effectiveDate: json['effectiveDate'] as String,
      mid: (json['mid'] as num).toDouble(),
    );
