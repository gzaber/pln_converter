import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nbp_api/nbp_api.dart';

class BadRequestFailure implements Exception {
  BadRequestFailure(this.message);
  final String message;
}

class NotFoundFailure implements Exception {
  NotFoundFailure(this.message);
  final String message;
}

class NbpApiClient {
  NbpApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = 'http://api.nbp.pl/api/exchangerates';
    _dio.options.headers = {'Accept': 'application/json'};
    _dio.options.responseType = ResponseType.plain;
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 3000;
  }

  final Dio _dio;

  Future<CurrencyTable> getTable(String type) async {
    final currencyTableResponse = await _dio.get('/tables/$type');

    if (currencyTableResponse.statusCode != 200) {
      _checkStatusCode(currencyTableResponse);
    }

    final currencyTableJson =
        jsonDecode(currencyTableResponse.data.toString()) as List;

    return CurrencyTable.fromJson(
        currencyTableJson.first as Map<String, dynamic>);
  }

  Future<Currency> getCurrency(String table, String code) async {
    final currencyResponse = await _dio.get(
      '/rates/$table/$code',
    );

    if (currencyResponse.statusCode != 200) {
      _checkStatusCode(currencyResponse);
    }

    final currencyJson = jsonDecode(currencyResponse.data);

    return Currency.fromJson(currencyJson as Map<String, dynamic>);
  }

  void _checkStatusCode(Response response) {
    switch (response.statusCode) {
      case 400:
        throw BadRequestFailure(
            'Nieprawidłowe zapytanie lub przekroczony limit danych');
      case 404:
        throw NotFoundFailure('Brak danych');
    }
  }
}
