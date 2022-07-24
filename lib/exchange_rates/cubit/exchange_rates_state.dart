part of 'exchange_rates_cubit.dart';

enum ExchangeRatesStatus { loading, success, failure, search }

class ExchangeRatesState extends Equatable {
  const ExchangeRatesState({
    this.status = ExchangeRatesStatus.loading,
    this.exchangeRates = const [],
    this.filteredList = const [],
    this.errorMessage = '',
  });

  final ExchangeRatesStatus status;
  final List<Currency> exchangeRates;
  final List<Currency> filteredList;
  final String errorMessage;

  ExchangeRatesState copyWith({
    ExchangeRatesStatus? status,
    List<Currency>? exchangeRates,
    List<Currency>? filteredList,
    String? errorMessage,
  }) {
    return ExchangeRatesState(
      status: status ?? this.status,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      filteredList: filteredList ?? this.filteredList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        status,
        exchangeRates,
        filteredList,
        errorMessage,
      ];
}
