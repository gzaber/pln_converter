part of 'exchange_rates_cubit.dart';

enum ExchangeRatesStatus { loading, success, failure }

class ExchangeRatesState extends Equatable {
  const ExchangeRatesState({
    this.exchangeRates = const [],
    this.status = ExchangeRatesStatus.loading,
    this.errorMessage = '',
  });

  final List<Currency> exchangeRates;
  final ExchangeRatesStatus status;
  final String errorMessage;

  ExchangeRatesState copyWith({
    List<Currency>? exchangeRates,
    ExchangeRatesStatus? status,
    String? errorMessage,
  }) {
    return ExchangeRatesState(
      exchangeRates: exchangeRates ?? this.exchangeRates,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [exchangeRates, status, errorMessage];
}
