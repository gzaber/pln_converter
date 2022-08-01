import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nbp_api/nbp_api.dart';

class NbpApiFailure implements Exception {
  const NbpApiFailure([this.message = 'An unknown exception occurred.']);

  factory NbpApiFailure.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.connectTimeout:
        return const NbpApiFailure('Connection timeout.');
      case DioErrorType.sendTimeout:
        return const NbpApiFailure('Send timeout.');
      case DioErrorType.receiveTimeout:
        return const NbpApiFailure('Receive timeout.');
      case DioErrorType.response:
        return NbpApiFailure('Response error');
      case DioErrorType.cancel:
        return const NbpApiFailure('Request cancelled');
      case DioErrorType.other:
        return dioError.message.contains('SocketException')
            ? NbpApiFailure('No Internet access.')
            : NbpApiFailure(dioError.message);
    }
  }

  final String message;

  @override
  String toString() {
    return message;
  }
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
    try {
      final currencyTableResponse = await _dio.get('/tables/$type');
      final currencyTableJson =
          jsonDecode(currencyTableResponse.data.toString()) as List;

      return CurrencyTable.fromJson(
        currencyTableJson.first as Map<String, dynamic>,
      );
    } on DioError catch (e) {
      throw NbpApiFailure.fromDioError(e);
    } catch (_) {
      throw const NbpApiFailure();
    }
  }

  Future<Currency> getCurrency(String table, String code) async {
    try {
      final currencyResponse = await _dio.get(
        '/rates/$table/$code',
      );
      final currencyJson = jsonDecode(currencyResponse.data);

      return Currency.fromJson(
        currencyJson as Map<String, dynamic>,
      );
    } on DioError catch (e) {
      throw NbpApiFailure.fromDioError(e);
    } catch (_) {
      throw const NbpApiFailure();
    }
  }
}
