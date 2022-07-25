import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';

part 'converter_state.dart';

class ConverterCubit extends Cubit<ConverterState> {
  ConverterCubit(this._exchangeRatesRepository) : super(const ConverterState());

  final ExchangeRatesRepository _exchangeRatesRepository;

  void getCurrency({required String table, required String code}) async {
    emit(state.copyWith(status: ConverterStatus.loading));
    try {
      final currency = await _exchangeRatesRepository.getCurrency(table, code);
      emit(
        state.copyWith(
          status: ConverterStatus.success,
          foreignCurrency: currency,
          plnValue: currency.rate,
          foreignCurrencyValue: 1.0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConverterStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void changeLevels() {
    emit(state.copyWith(isPlnUp: !state.isPlnUp));
  }

  void convertForeignCurrencyToPln(String value) {
    if (value.isEmpty) {
      value = '0';
    }
    emit(
      state.copyWith(
        foreignCurrencyValue: double.parse(value),
        plnValue: double.parse(value) * state.foreignCurrency!.rate,
      ),
    );
  }

  void convertPlnToForeignCurrency(String value) {
    if (value.isEmpty) {
      value = '0';
    }
    emit(state.copyWith(
      plnValue: double.parse(value),
      foreignCurrencyValue: double.parse(value) / state.foreignCurrency!.rate,
    ));
  }
}
