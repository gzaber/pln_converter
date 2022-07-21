part of 'exchange_rates_cubit.dart';

enum ExchangeRatesStatus { loading, success, failure }

enum SearchStatus { on, off }

class ExchangeRatesState extends Equatable {
  const ExchangeRatesState({
    this.exchangeRatesStatus = ExchangeRatesStatus.loading,
    this.searchStatus = SearchStatus.off,
    this.exchangeRates = const [],
    this.errorMessage = '',
  });

  final ExchangeRatesStatus exchangeRatesStatus;
  final SearchStatus searchStatus;
  final List<Currency> exchangeRates;
  final String errorMessage;

  ExchangeRatesState copyWith({
    ExchangeRatesStatus? exchangeRatesStatus,
    SearchStatus? searchStatus,
    List<Currency>? exchangeRates,
    String? errorMessage,
  }) {
    return ExchangeRatesState(
      exchangeRatesStatus: exchangeRatesStatus ?? this.exchangeRatesStatus,
      searchStatus: searchStatus ?? this.searchStatus,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props =>
      [exchangeRatesStatus, searchStatus, exchangeRates, errorMessage];
}
