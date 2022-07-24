import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/exchange_rates/cubit/exchange_rates_cubit.dart';

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

void main() {
  group('ExchangeRatesCubit', () {
    late ExchangeRatesRepository repository;

    setUp(() {
      repository = MockExchangeRatesRepository();
    });

    ExchangeRatesCubit buildCubit() => ExchangeRatesCubit(repository);

    group('constructor', () {
      test('works properly', () {
        expect(() => buildCubit(), returnsNormally);
      });

      test('initial state is correct', () {
        expect(buildCubit().state, equals(const ExchangeRatesState()));
      });
    });

    group('getExchangeRates', () {
      final usd = Currency(
          name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);

      blocTest<ExchangeRatesCubit, ExchangeRatesState>(
        'emits state with success status and exchange rates list when '
        'data successfully fetched',
        setUp: () {
          when(() => repository.getCurrencies()).thenAnswer((_) async => [usd]);
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.getExchangeRates(),
        expect: () => [
          const ExchangeRatesState(status: ExchangeRatesStatus.loading),
          ExchangeRatesState(
            status: ExchangeRatesStatus.success,
            exchangeRates: [usd],
          ),
        ],
        verify: (_) {
          verify(() => repository.getCurrencies()).called(1);
        },
      );

      blocTest<ExchangeRatesCubit, ExchangeRatesState>(
        'emits state with failure status and error message when exception occurs',
        setUp: () {
          when(() => repository.getCurrencies())
              .thenThrow(Exception('failure'));
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.getExchangeRates(),
        expect: () => const [
          ExchangeRatesState(status: ExchangeRatesStatus.loading),
          ExchangeRatesState(
            status: ExchangeRatesStatus.failure,
            errorMessage: 'Exception: failure',
          ),
        ],
        verify: (_) {
          verify(() => repository.getCurrencies()).called(1);
        },
      );
    });

    group('turnOnSearch', () {
      blocTest<ExchangeRatesCubit, ExchangeRatesState>(
        'emits state with search status and empty filtered list',
        build: () => buildCubit(),
        act: (cubit) => cubit.turnOnSearch(),
        expect: () => const [
          ExchangeRatesState(
            status: ExchangeRatesStatus.search,
            filteredList: [],
          ),
        ],
      );
    });

    group('turnOffSearch', () {
      blocTest<ExchangeRatesCubit, ExchangeRatesState>(
        'emits state with success status',
        build: () => buildCubit(),
        act: (cubit) => cubit.turnOffSearch(),
        expect: () => const [
          ExchangeRatesState(
            status: ExchangeRatesStatus.success,
          ),
        ],
      );
    });

    group('search', () {
      final usd = Currency(
          name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);
      final aud = Currency(
          name: 'dolar australijski', code: 'AUD', table: 'A', rate: 3.2449);

      blocTest<ExchangeRatesCubit, ExchangeRatesState>(
        'emits filtered list',
        seed: () => ExchangeRatesState(
            status: ExchangeRatesStatus.search,
            exchangeRates: [aud, usd],
            filteredList: const []),
        build: () => buildCubit(),
        act: (cubit) => cubit.search('ame'),
        expect: () => [
          ExchangeRatesState(
            status: ExchangeRatesStatus.search,
            exchangeRates: [aud, usd],
            filteredList: [usd],
          ),
        ],
      );
    });
    group('clearSearch', () {
      blocTest<ExchangeRatesCubit, ExchangeRatesState>(
        'emits state with empty filtered list',
        build: () => buildCubit(),
        act: (cubit) => cubit.clearSearch(),
        expect: () => const [
          ExchangeRatesState(
            filteredList: [],
          ),
        ],
      );
    });
  });
}
