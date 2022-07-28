import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';

part 'change_currency_state.dart';

class ChangeCurrencyCubit extends Cubit<ChangeCurrencyState> {
  ChangeCurrencyCubit(this._exchangeRatesRepository)
      : super(const ChangeCurrencyState());

  final ExchangeRatesRepository _exchangeRatesRepository;

  void loadCurrencies() async {
    emit(state.copyWith(status: ChangeCurrencyStatus.loading));
    try {
      final currencies = await _exchangeRatesRepository.getCurrencies();
      emit(state.copyWith(
        status: ChangeCurrencyStatus.success,
        currencies: currencies,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChangeCurrencyStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
