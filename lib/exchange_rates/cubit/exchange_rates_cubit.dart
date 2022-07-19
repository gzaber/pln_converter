import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';

part 'exchange_rates_state.dart';

class ExchangeRatesCubit extends Cubit<ExchangeRatesState> {
  ExchangeRatesCubit(this._exchangeRatesRepository)
      : super(const ExchangeRatesState());

  final ExchangeRatesRepository _exchangeRatesRepository;

  void getExchangeRates() async {
    emit(state.copyWith(status: ExchangeRatesStatus.loading));
    try {
      final result = await _exchangeRatesRepository.getCurrencies();
      emit(
        state.copyWith(
          status: ExchangeRatesStatus.success,
          exchangeRates: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExchangeRatesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  List<Currency> search(String pattern) {
    return state.exchangeRates
        .where((currency) =>
            currency.name.contains(pattern) || currency.code.contains(pattern))
        .toList();
  }
}
