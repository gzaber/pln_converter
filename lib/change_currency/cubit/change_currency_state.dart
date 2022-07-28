part of 'change_currency_cubit.dart';

enum ChangeCurrencyStatus { loading, success, failure }

class ChangeCurrencyState extends Equatable {
  const ChangeCurrencyState({
    this.status = ChangeCurrencyStatus.loading,
    this.currencies = const [],
    this.errorMessage = '',
  });

  final ChangeCurrencyStatus status;
  final List<Currency> currencies;
  final String errorMessage;

  @override
  List<Object> get props => [status, currencies, errorMessage];

  ChangeCurrencyState copyWith({
    ChangeCurrencyStatus? status,
    List<Currency>? currencies,
    String? errorMessage,
  }) {
    return ChangeCurrencyState(
      status: status ?? this.status,
      currencies: currencies ?? this.currencies,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
