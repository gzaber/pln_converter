import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/exchange_rates/exchange_rates.dart';

extension PumpView on WidgetTester {
  Future<void> pumpExchangeRatesView({
    required ExchangeRatesCubit exchangeRatesCubit,
  }) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: exchangeRatesCubit,
          child: const ExchangeRatesView(),
        ),
      ),
    );
  }
}

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
    final eur = Currency(name: 'euro', code: 'EUR', table: 'A', rate: 4.7643);

    testWidgets('renders CircularProgressIndicator when data is loading',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(
          const ExchangeRatesState(status: ExchangeRatesStatus.loading));

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders ListView with ListTiles and Dividers when data is loaded successfully',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(
        ExchangeRatesState(
          status: ExchangeRatesStatus.success,
          exchangeRates: [usd, aud, eur],
        ),
      );

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('renders error icon when flag image is not found',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(ExchangeRatesState(
          status: ExchangeRatesStatus.success,
          exchangeRates: [
            Currency(name: 'SDR (MFW)', code: 'XDR', table: 'A', rate: 6.1441),
          ]));

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

      await tester.pump();

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows SnackBar with error text when exception occurs',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(
          const ExchangeRatesState(status: ExchangeRatesStatus.loading));
      whenListen(
          exchangeRatesCubit,
          Stream.fromIterable([
            const ExchangeRatesState(
                status: ExchangeRatesStatus.failure, errorMessage: 'error'),
          ]));

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(SnackBar), matching: find.text('error')),
        findsOneWidget,
      );
    });

    testWidgets('renders AppBar with text and search icon', (tester) async {
      when(() => exchangeRatesCubit.state)
          .thenReturn(const ExchangeRatesState());

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.text('Exchange rates')),
        findsOneWidget,
      );
      expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.byIcon(Icons.search)),
        findsOneWidget,
      );
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

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      verify(() => exchangeRatesCubit.turnOnSearch()).called(1);
    });

    testWidgets('renders ListView with ListTiles when searching currency',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(ExchangeRatesState(
        status: ExchangeRatesStatus.search,
        exchangeRates: [usd, aud, eur],
      ));
      whenListen(
          exchangeRatesCubit,
          Stream.fromIterable([
            ExchangeRatesState(
              status: ExchangeRatesStatus.search,
              exchangeRates: [usd, aud, eur],
              filteredList: [aud, usd],
            ),
          ]));

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

      await tester.enterText(find.byType(TextField), 'dol');
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
      verify(() => exchangeRatesCubit.search('dol')).called(1);
    });

    testWidgets('clears search TextField when clear button tapped',
        (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(ExchangeRatesState(
        status: ExchangeRatesStatus.search,
        exchangeRates: [usd, aud],
      ));

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

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

      await tester.pumpExchangeRatesView(
          exchangeRatesCubit: exchangeRatesCubit);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
      verify(() => exchangeRatesCubit.turnOffSearch()).called(1);
    });
  });
}
