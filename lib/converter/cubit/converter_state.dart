part of 'converter_cubit.dart';

enum ConverterStatus { loading, success, failure }

class ConverterState extends Equatable {
  const ConverterState({
    this.status = ConverterStatus.loading,
    this.foreignCurrency,
    this.isPlnUp = true,
    this.plnValue = 0.0,
    this.foreignCurrencyValue = 0.0,
    this.errorMessage = '',
  });

  final ConverterStatus status;
  final Currency? foreignCurrency;
  final bool isPlnUp;
  final double plnValue;
  final double foreignCurrencyValue;
  final String errorMessage;

  @override
  List<Object?> get props => [
        foreignCurrency,
        status,
        isPlnUp,
        plnValue,
        foreignCurrencyValue,
        errorMessage,
      ];

  ConverterState copyWith({
    ConverterStatus? status,
    Currency? foreignCurrency,
    bool? isPlnUp,
    double? plnValue,
    double? foreignCurrencyValue,
    String? errorMessage,
  }) {
    return ConverterState(
      status: status ?? this.status,
      foreignCurrency: foreignCurrency ?? this.foreignCurrency,
      isPlnUp: isPlnUp ?? this.isPlnUp,
      plnValue: plnValue ?? this.plnValue,
      foreignCurrencyValue: foreignCurrencyValue ?? this.foreignCurrencyValue,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
