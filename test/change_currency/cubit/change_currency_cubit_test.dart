import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/change_currency/change_currency.dart';

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

void main() {
  group('ChangeCurrencyCubit', () {
    late ExchangeRatesRepository repository;

    setUp(() {
      repository = MockExchangeRatesRepository();
    });

    ChangeCurrencyCubit buildCubit() => ChangeCurrencyCubit(repository);

    group('constructor', () {
      test('works properly', () {
        expect(() => buildCubit(), returnsNormally);
      });

      test('initial state is correct', () {
        expect(buildCubit().state, equals(const ChangeCurrencyState()));
      });
    });

    group('loadCurrencies', () {
      final usd = Currency(
          name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);

      blocTest<ChangeCurrencyCubit, ChangeCurrencyState>(
        'emits state with success status and currencies list when '
        'data successfully fetched',
        setUp: () {
          when(() => repository.getCurrencies()).thenAnswer((_) async => [usd]);
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.loadCurrencies(),
        expect: () => [
          const ChangeCurrencyState(status: ChangeCurrencyStatus.loading),
          ChangeCurrencyState(
            status: ChangeCurrencyStatus.success,
            currencies: [usd],
          ),
        ],
        verify: (_) {
          verify(() => repository.getCurrencies()).called(1);
        },
      );

      blocTest<ChangeCurrencyCubit, ChangeCurrencyState>(
        'emits state with failure status and error message when exception occurs',
        setUp: () {
          when(() => repository.getCurrencies())
              .thenThrow(Exception('failure'));
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.loadCurrencies(),
        expect: () => const [
          ChangeCurrencyState(status: ChangeCurrencyStatus.loading),
          ChangeCurrencyState(
            status: ChangeCurrencyStatus.failure,
            errorMessage: 'Exception: failure',
          ),
        ],
        verify: (_) {
          verify(() => repository.getCurrencies()).called(1);
        },
      );
    });
  });
}
