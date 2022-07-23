import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/exchange_rates/exchange_rates.dart';

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

class MockExchangeRatesCubit extends MockCubit<ExchangeRatesState>
    implements ExchangeRatesCubit {}

void main() {
  group('ExchangeRatesPage', () {
    late ExchangeRatesRepository exchangeRatesRepository;

    setUp(() {
      exchangeRatesRepository = MockExchangeRatesRepository();
    });

    testWidgets('renders ExchangeRatesView', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: exchangeRatesRepository,
          child: const MaterialApp(
            home: ExchangeRatesPage(),
          ),
        ),
      );

      expect(find.byType(ExchangeRatesView), findsOneWidget);
      verify(() => exchangeRatesRepository.getCurrencies()).called(1);
    });
  });

  group('ExchangeRatesView', () {
    late ExchangeRatesCubit exchangeRatesCubit;

    setUp(() {
      exchangeRatesCubit = MockExchangeRatesCubit();
    });

    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);
    final aud = Currency(
        name: 'dolar australijski', code: 'AUD', table: 'A', rate: 3.2449);

    testWidgets('renders CircularProgressIndicator when data is loading',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(
          const ExchangeRatesState(status: ExchangeRatesStatus.loading));

      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders ListView with ListTiles when data is loaded successfully',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(
        ExchangeRatesState(
          status: ExchangeRatesStatus.success,
          exchangeRates: [usd, aud],
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('shows SnackBar with error text when exception occurs',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(
        const ExchangeRatesState(
          status: ExchangeRatesStatus.failure,
          errorMessage: 'error',
        ),
      );
      whenListen(
          exchangeRatesCubit,
          Stream.fromIterable([
            const ExchangeRatesState(
                status: ExchangeRatesStatus.failure, errorMessage: 'error'),
          ]));

      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('renders AppBar with search icon', (tester) async {
      when(() => exchangeRatesCubit.state)
          .thenReturn(const ExchangeRatesState());

      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets(
        'renders AppBar with TextField, back button and clear button'
        'when search icon tapped', (tester) async {
      when(() => exchangeRatesCubit.state)
          .thenReturn(const ExchangeRatesState());
      whenListen(
          exchangeRatesCubit,
          Stream.fromIterable([
            const ExchangeRatesState(
              status: ExchangeRatesStatus.search,
            ),
          ]));

      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      verify(() => exchangeRatesCubit.turnOnSearch()).called(1);
    });

    testWidgets('renders ListView with one ListTile when searching currency',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(ExchangeRatesState(
        status: ExchangeRatesStatus.search,
        exchangeRates: [usd, aud],
      ));
      whenListen(
          exchangeRatesCubit,
          Stream.fromIterable([
            ExchangeRatesState(
              status: ExchangeRatesStatus.search,
              exchangeRates: [usd, aud],
              filteredList: [aud],
            ),
          ]));

      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'aus');
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('dolar australijski'), findsOneWidget);
      verify(() => exchangeRatesCubit.search('aus')).called(1);
    });

    testWidgets('clears search TextField when clear button tapped',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(ExchangeRatesState(
        status: ExchangeRatesStatus.search,
        exchangeRates: [usd, aud],
      ));
      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'aus');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      final searchTextField = tester.widget<TextField>(find.byType(TextField));

      expect(searchTextField.controller?.text, isEmpty);
      verify(() => exchangeRatesCubit.clearSearch()).called(1);
    });

    testWidgets('closes search option when back button is tapped',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(ExchangeRatesState(
        status: ExchangeRatesStatus.search,
        exchangeRates: [usd, aud],
      ));
      whenListen(
          exchangeRatesCubit,
          Stream.fromIterable([
            ExchangeRatesState(
              status: ExchangeRatesStatus.success,
              exchangeRates: [usd, aud],
            ),
          ]));

      await tester.pumpWidget(
        BlocProvider.value(
          value: exchangeRatesCubit,
          child: const MaterialApp(
            home: ExchangeRatesView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
      verify(() => exchangeRatesCubit.turnOffSearch()).called(1);
    });
  });
}
