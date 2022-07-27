import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/change_currency/change_currency.dart';

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

class MockChangeCurrencyCubit extends MockCubit<ChangeCurrencyState>
    implements ChangeCurrencyCubit {}

void main() {
  group('ChangeCurrencyPage', () {
    late ExchangeRatesRepository exchangeRatesRepository;

    setUp(() {
      exchangeRatesRepository = MockExchangeRatesRepository();
    });

    testWidgets('renders ChangeCurrencyView', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: exchangeRatesRepository,
          child: const MaterialApp(
            home: ChangeCurrencyPage(),
          ),
        ),
      );

      expect(find.byType(ChangeCurrencyView), findsOneWidget);
      verify(() => exchangeRatesRepository.getCurrencies()).called(1);
    });
  });

  group('ChangeCurrencyView', () {
    late ChangeCurrencyCubit changeCurrencyCubit;

    setUp(() {
      changeCurrencyCubit = MockChangeCurrencyCubit();
    });

    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);
    final aud = Currency(
        name: 'dolar australijski', code: 'AUD', table: 'A', rate: 3.2449);
    final eur = Currency(name: 'euro', code: 'EUR', table: 'A', rate: 4.7643);

    testWidgets('renders CircularProgressIndicator when data is loading',
        (tester) async {
      when(() => changeCurrencyCubit.state).thenReturn(
          const ChangeCurrencyState(status: ChangeCurrencyStatus.loading));

      await tester.pumpWidget(
        BlocProvider.value(
          value: changeCurrencyCubit,
          child: const MaterialApp(
            home: ChangeCurrencyView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders ListView with ListTiles, images, change currency icon buttons '
        'and Dividers when data is loaded successfully', (tester) async {
      when(() => changeCurrencyCubit.state).thenReturn(
        ChangeCurrencyState(
          status: ChangeCurrencyStatus.success,
          currencies: [usd, aud, eur],
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: changeCurrencyCubit,
          child: const MaterialApp(
            home: ChangeCurrencyView(),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.byType(Image), findsNWidgets(3));
      expect(find.byType(IconButton), findsNWidgets(3));
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));
    });

    testWidgets('renders error icon when flag image is not found',
        (tester) async {
      when(() => changeCurrencyCubit.state).thenReturn(
        ChangeCurrencyState(
          status: ChangeCurrencyStatus.success,
          currencies: [
            Currency(name: 'SDR (MFW)', code: 'XDR', table: 'A', rate: 6.1441),
          ],
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: changeCurrencyCubit,
          child: const MaterialApp(
            home: ChangeCurrencyView(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows SnackBar with error text when exception occurs',
        (tester) async {
      when(() => changeCurrencyCubit.state).thenReturn(
        const ChangeCurrencyState(status: ChangeCurrencyStatus.loading),
      );
      whenListen(
          changeCurrencyCubit,
          Stream.fromIterable([
            const ChangeCurrencyState(
                status: ChangeCurrencyStatus.failure, errorMessage: 'error'),
          ]));

      await tester.pumpWidget(
        BlocProvider.value(
          value: changeCurrencyCubit,
          child: const MaterialApp(
            home: ChangeCurrencyView(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('renders AppBar with text', (tester) async {
      when(() => changeCurrencyCubit.state)
          .thenReturn(const ChangeCurrencyState());

      await tester.pumpWidget(
        BlocProvider.value(
          value: changeCurrencyCubit,
          child: const MaterialApp(
            home: ChangeCurrencyView(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Change currency'), findsOneWidget);
    });
  });
}
