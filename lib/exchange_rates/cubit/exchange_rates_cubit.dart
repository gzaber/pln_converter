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

  void turnOnSearch() {
    emit(state.copyWith(
      status: ExchangeRatesStatus.search,
      filteredList: const [],
    ));
  }

  void turnOffSearch() {
    emit(
      state.copyWith(status: ExchangeRatesStatus.success),
    );
  }

  void search(String pattern) {
    final filteredList = state.exchangeRates
        .where((currency) =>
            currency.code.toLowerCase().contains(pattern.toLowerCase()) ||
            currency.name.toLowerCase().contains(pattern.toLowerCase()))
        .toList();
    emit(
      state.copyWith(
        filteredList: filteredList,
      ),
    );
  }

  void clearSearch() {
    emit(state.copyWith(filteredList: const []));
  }
}
