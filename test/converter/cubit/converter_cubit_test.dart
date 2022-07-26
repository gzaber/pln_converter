import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/converter/cubit/converter_cubit.dart';

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

void main() {
  group('ConverterCubit', () {
    late ExchangeRatesRepository repository;

    setUp(() {
      repository = MockExchangeRatesRepository();
    });

    ConverterCubit buildCubit() => ConverterCubit(repository);

    group('constructor', () {
      test('works properly', () {
        expect(() => buildCubit(), returnsNormally);
      });

      test('initial state is correct', () {
        expect(buildCubit().state, equals(const ConverterState()));
      });
    });

    group('getCurrency', () {
      const table = 'A';
      const code = 'USD';
      final usd = Currency(
          name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);

      blocTest<ConverterCubit, ConverterState>(
        'emits state with success status and fetched data',
        setUp: () {
          when(() => repository.getCurrency(any(), any()))
              .thenAnswer((_) async => usd);
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.getCurrency(table: table, code: code),
        expect: () => [
          const ConverterState(status: ConverterStatus.loading),
          ConverterState(
            status: ConverterStatus.success,
            foreignCurrency: usd,
            plnValue: usd.rate,
            foreignCurrencyValue: 1.0,
          ),
        ],
        verify: (_) {
          verify(() => repository.getCurrency(table, code)).called(1);
        },
      );

      blocTest<ConverterCubit, ConverterState>(
        'emits state with failure status and error message',
        setUp: () {
          when(() => repository.getCurrency(any(), any()))
              .thenThrow(Exception('failure'));
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.getCurrency(table: table, code: code),
        expect: () => const [
          ConverterState(status: ConverterStatus.loading),
          ConverterState(
            status: ConverterStatus.failure,
            errorMessage: 'Exception: failure',
          ),
        ],
        verify: (_) {
          verify(() => repository.getCurrency(table, code)).called(1);
        },
      );
    });

    group('changeLevels', () {
      blocTest<ConverterCubit, ConverterState>(
        'emits state with inverted PLN currency level',
        build: () => buildCubit(),
        act: (cubit) => cubit.changeLevels(),
        expect: () => const [ConverterState(isPlnUp: false)],
      );
    });

    group('convertForeignCurrencyToPln', () {
      final usd = Currency(
          name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);
      blocTest<ConverterCubit, ConverterState>(
        'emits state with converted foreign currency to PLN',
        build: () => buildCubit(),
        seed: () => ConverterState(foreignCurrency: usd),
        act: (cubit) => cubit.convertForeignCurrencyToPln('2'),
        expect: () => [
          ConverterState(
            foreignCurrency: usd,
            plnValue: 9.6568,
            foreignCurrencyValue: 2,
          )
        ],
      );
    });

    group('convertPlnToForeignCurrency', () {
      final usd = Currency(
          name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);
      blocTest<ConverterCubit, ConverterState>(
        'emits state with converted PLN to foreign currency',
        build: () => buildCubit(),
        seed: () => ConverterState(foreignCurrency: usd),
        act: (cubit) => cubit.convertPlnToForeignCurrency('2'),
        expect: () => [
          ConverterState(
            foreignCurrency: usd,
            plnValue: 2,
            foreignCurrencyValue: 2 / usd.rate,
          )
        ],
      );
    });
  });
}
