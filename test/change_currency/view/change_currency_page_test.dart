import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:pln_converter/change_currency/change_currency.dart';
import 'package:pln_converter/settings/cubit/settings_cubit.dart';
import 'package:settings_repository/settings_repository.dart';

extension PumpView on WidgetTester {
  Future<void> pumpChangeCurrencyPage({
    required ChangeCurrencyCubit changeCurrencyCubit,
  }) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: changeCurrencyCubit,
          child: const ChangeCurrencyPage(),
        ),
      ),
    );
  }
}

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

class MockChangeCurrencyCubit extends MockCubit<ChangeCurrencyState>
    implements ChangeCurrencyCubit {}

class MockSettingsCubit extends MockCubit<Settings> implements SettingsCubit {}

void main() {
  group('ChangeCurrencyPage', () {
    late ExchangeRatesRepository repository;
    late ChangeCurrencyCubit changeCurrencyCubit;
    late SettingsCubit settingsCubit;

    setUp(() {
      repository = MockExchangeRatesRepository();
      changeCurrencyCubit = MockChangeCurrencyCubit();
      settingsCubit = MockSettingsCubit();
    });

    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);
    final aud = Currency(
        name: 'dolar australijski', code: 'AUD', table: 'A', rate: 3.2449);
    final eur = Currency(name: 'euro', code: 'EUR', table: 'A', rate: 4.7643);

    testWidgets('is routable', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: repository,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      ChangeCurrencyPage.route(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(ChangeCurrencyPage), findsOneWidget);
    });

    testWidgets('renders CircularProgressIndicator when data is loading',
        (tester) async {
      when(() => changeCurrencyCubit.state).thenReturn(
          const ChangeCurrencyState(status: ChangeCurrencyStatus.loading));

      await tester.pumpChangeCurrencyPage(
          changeCurrencyCubit: changeCurrencyCubit);

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

      await tester.pumpChangeCurrencyPage(
          changeCurrencyCubit: changeCurrencyCubit);

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

      await tester.pumpChangeCurrencyPage(
          changeCurrencyCubit: changeCurrencyCubit);

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

      await tester.pumpChangeCurrencyPage(
          changeCurrencyCubit: changeCurrencyCubit);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(SnackBar), matching: find.text('error')),
        findsOneWidget,
      );
    });

    testWidgets('renders error icon when exception occurs', (tester) async {
      when(() => changeCurrencyCubit.state).thenReturn(
        const ChangeCurrencyState(status: ChangeCurrencyStatus.failure),
      );

      await tester.pumpChangeCurrencyPage(
          changeCurrencyCubit: changeCurrencyCubit);

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders AppBar with text', (tester) async {
      when(() => changeCurrencyCubit.state)
          .thenReturn(const ChangeCurrencyState());

      await tester.pumpChangeCurrencyPage(
          changeCurrencyCubit: changeCurrencyCubit);

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.text('Change currency')),
        findsOneWidget,
      );
    });

    testWidgets('pops when select currency button is tapped', (tester) async {
      final navigator = MockNavigator();
      when(() => navigator.pop<void>()).thenAnswer((_) async {});

      when(() => changeCurrencyCubit.state).thenReturn(
        ChangeCurrencyState(
            status: ChangeCurrencyStatus.success, currencies: [usd]),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: settingsCubit,
          child: MaterialApp(
            home: MockNavigatorProvider(
              navigator: navigator,
              child: BlocProvider.value(
                value: changeCurrencyCubit,
                child: const ChangeCurrencyPage(),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_forward_ios));

      verify(() => navigator.pop<void>()).called(1);
    });
  });
}
