import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';

part 'exchange_rates_state.dart';

class ExchangeRatesCubit extends Cubit<ExchangeRatesState> {
  ExchangeRatesCubit(this._exchangeRatesRepository)
      : super(const ExchangeRatesState());

  final ExchangeRatesRepository _exchangeRatesRepository;

  void getExchangeRates() async {
    emit(state.copyWith(exchangeRatesStatus: ExchangeRatesStatus.loading));
    try {
      final result = await _exchangeRatesRepository.getCurrencies();
      emit(
        state.copyWith(
          exchangeRatesStatus: ExchangeRatesStatus.success,
          exchangeRates: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          exchangeRatesStatus: ExchangeRatesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void turnOnSearch() {
    emit(state.copyWith(searchStatus: SearchStatus.on));
  }

  void turnOffSearch() {
    emit(state.copyWith(searchStatus: SearchStatus.off));
  }

  List<Currency> search(String pattern) {
    return state.exchangeRates
        .where((currency) =>
            currency.name.contains(pattern) || currency.code.contains(pattern))
        .toList();
  }
}
