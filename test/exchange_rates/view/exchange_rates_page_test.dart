import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/exchange_rates/exchange_rates.dart';
import 'package:pln_converter/home/cubit/home_cubit.dart';

extension PumpView on WidgetTester {
  Future<void> pumpExchangeRatesView({
    required ExchangeRatesCubit exchangeRatesCubit,
    required HomeCubit homeCubit,
  }) {
    return pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: exchangeRatesCubit),
          BlocProvider.value(value: homeCubit),
        ],
        child: const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate],
          home: ExchangeRatesView(),
        ),
      ),
    );
  }
}

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

class MockExchangeRatesCubit extends MockCubit<ExchangeRatesState>
    implements ExchangeRatesCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  group('ExchangeRatesPage', () {
    late ExchangeRatesRepository exchangeRatesRepository;
    late HomeCubit homeCubit;

    setUp(() {
      exchangeRatesRepository = MockExchangeRatesRepository();
      homeCubit = MockHomeCubit();

      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.exchangeRates));
    });

    testWidgets('renders ExchangeRatesView', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: exchangeRatesRepository,
          child: BlocProvider.value(
            value: homeCubit,
            child: const MaterialApp(
              localizationsDelegates: [AppLocalizations.delegate],
              home: ExchangeRatesPage(),
            ),
          ),
        ),
      );

      expect(find.byType(ExchangeRatesView), findsOneWidget);
      verify(() => exchangeRatesRepository.getCurrencies()).called(1);
    });
  });

  group('ExchangeRatesView', () {
    late ExchangeRatesCubit exchangeRatesCubit;
    late HomeCubit homeCubit;

    setUp(() {
      exchangeRatesCubit = MockExchangeRatesCubit();
      homeCubit = MockHomeCubit();

      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.exchangeRates));
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
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

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
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

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
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

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
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(SnackBar), matching: find.text('error')),
        findsOneWidget,
      );
    });

    testWidgets('renders error icon when exception occurs', (tester) async {
      when(() => exchangeRatesCubit.state).thenReturn(
          const ExchangeRatesState(status: ExchangeRatesStatus.failure));

      await tester.pumpExchangeRatesView(
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders AppBar with text and search icon', (tester) async {
      when(() => exchangeRatesCubit.state)
          .thenReturn(const ExchangeRatesState());

      await tester.pumpExchangeRatesView(
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(AppBar),
            matching: find.text(AppLocalizationsEn().exchangeRatesAppBarTitle)),
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
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

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
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

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
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
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

      await tester.pumpExchangeRatesView(
        exchangeRatesCubit: exchangeRatesCubit,
        homeCubit: homeCubit,
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
      verify(() => exchangeRatesCubit.turnOffSearch()).called(1);
    });
  });
}
