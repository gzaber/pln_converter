import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:pln_converter/converter/converter.dart';
import 'package:pln_converter/home/cubit/home_cubit.dart';
import 'package:pln_converter/settings/settings.dart';
import 'package:settings_repository/settings_repository.dart';

extension PumpView on WidgetTester {
  Future<void> pumpConverterView({
    required ConverterCubit converterCubit,
    required HomeCubit homeCubit,
    required SettingsCubit settingsCubit,
  }) {
    return pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: converterCubit),
          BlocProvider.value(value: homeCubit),
          BlocProvider.value(value: settingsCubit),
        ],
        child: const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate],
          home: ConverterView(),
        ),
      ),
    );
  }
}

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

class MockConverterCubit extends MockCubit<ConverterState>
    implements ConverterCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockSettingsCubit extends MockCubit<Settings> implements SettingsCubit {}

void main() {
  group('ConverterPage', () {
    late ExchangeRatesRepository repository;
    late HomeCubit homeCubit;
    late SettingsCubit settingsCubit;

    setUp(() {
      repository = MockExchangeRatesRepository();
      homeCubit = MockHomeCubit();
      settingsCubit = MockSettingsCubit();

      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.converter));

      when(() => settingsCubit.state).thenReturn(
        const Settings(
          currencyCode: 'USD',
          currencyTable: 'A',
          theme: AppTheme.light,
        ),
      );
    });

    testWidgets('renders ConverterView', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: repository,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: settingsCubit,
              ),
              BlocProvider.value(
                value: homeCubit,
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: [AppLocalizations.delegate],
              home: ConverterPage(),
            ),
          ),
        ),
      );

      expect(find.byType(ConverterView), findsOneWidget);
    });
  });

  group('ConverterView', () {
    late ConverterCubit converterCubit;
    late HomeCubit homeCubit;
    late SettingsCubit settingsCubit;

    setUp(() {
      converterCubit = MockConverterCubit();
      homeCubit = MockHomeCubit();
      settingsCubit = MockSettingsCubit();

      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.converter));

      when(() => settingsCubit.state).thenReturn(
        const Settings(
          currencyCode: 'USD',
          currencyTable: 'A',
          theme: AppTheme.light,
        ),
      );
    });

    final usd = Currency(
        name: 'dolar amerykański', code: 'USD', table: 'A', rate: 4.8284);

    testWidgets('renders CircularProgressIndicator when data is loading',
        (tester) async {
      when(() => converterCubit.state).thenReturn(
        const ConverterState(status: ConverterStatus.loading),
      );

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders 2 ListTiles with data, change currency button '
        'and switch levels button when data is loaded successfully',
        (tester) async {
      when(() => converterCubit.state).thenReturn(
        ConverterState(status: ConverterStatus.success, foreignCurrency: usd),
      );

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.byType(Image), findsNWidgets(2));
      expect(find.text('PLN'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.byType(IconButton), findsNWidgets(2));
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('renders error icon when flag image is not found',
        (tester) async {
      when(() => converterCubit.state).thenReturn(
        ConverterState(
          status: ConverterStatus.success,
          foreignCurrency: Currency(
              name: 'SDR (MFW)', code: 'XDR', table: 'A', rate: 6.1441),
        ),
      );

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );
      await tester.pump();

      expect(find.byIcon(Icons.error), findsNWidgets(2));
    });

    testWidgets('shows SnackBar with error text when exception occurs',
        (tester) async {
      when(() => converterCubit.state)
          .thenReturn(const ConverterState(status: ConverterStatus.loading));
      whenListen(
          converterCubit,
          Stream.fromIterable([
            const ConverterState(
              status: ConverterStatus.failure,
              errorMessage: 'error',
            )
          ]));

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
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
      when(() => converterCubit.state)
          .thenReturn(const ConverterState(status: ConverterStatus.failure));

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders AppBar with text', (tester) async {
      when(() => converterCubit.state).thenReturn(const ConverterState());

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(AppBar),
            matching: find.text(AppLocalizationsEn().converterAppBarTitle)),
        findsOneWidget,
      );
    });

    testWidgets(
        'first TextField is for PLN and enabled, '
        'second is for USD and disabled', (tester) async {
      when(() => converterCubit.state).thenReturn(
        ConverterState(
          status: ConverterStatus.success,
          foreignCurrency: usd,
          plnValue: usd.rate,
          foreignCurrencyValue: 1.0,
        ),
      );

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );

      final plnTextField = tester.widget<TextField>(
          find.byKey(const Key('converterPage_pln_value_textField')));
      final usdTextField = tester.widget<TextField>(find
          .byKey(const Key('converterPage_foreign_currency_value_textField')));

      expect(plnTextField.controller?.text, '4.8284');
      expect(plnTextField.enabled, true);
      expect(usdTextField.controller?.text, '1');
      expect(usdTextField.enabled, false);
    });

    testWidgets('converts PLN to USD ', (tester) async {
      when(() => converterCubit.state).thenReturn(
        ConverterState(
          status: ConverterStatus.success,
          foreignCurrency: usd,
          plnValue: 2,
          foreignCurrencyValue: 0.4142,
        ),
      );

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );

      await tester.enterText(
        find.byKey(const Key('converterPage_pln_value_textField')),
        '2',
      );
      await tester.pump();

      final plnTextField = tester.widget<TextField>(
          find.byKey(const Key('converterPage_pln_value_textField')));
      final usdTextField = tester.widget<TextField>(find
          .byKey(const Key('converterPage_foreign_currency_value_textField')));

      expect(plnTextField.controller?.text, '2');
      expect(plnTextField.enabled, true);
      expect(usdTextField.controller?.text, '0.4142');
      expect(usdTextField.enabled, false);
    });

    testWidgets(
        'switches currency levels when icon button tapped '
        'and converts USD to PLN ', (tester) async {
      when(() => converterCubit.state).thenReturn(
        ConverterState(
          status: ConverterStatus.success,
          foreignCurrency: usd,
          plnValue: 9.6568,
          foreignCurrencyValue: 2,
          isPlnUp: false,
        ),
      );

      await tester.pumpConverterView(
        converterCubit: converterCubit,
        homeCubit: homeCubit,
        settingsCubit: settingsCubit,
      );

      await tester.tap(find.byIcon(Icons.unfold_more));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('converterPage_foreign_currency_value_textField')),
        '2',
      );
      await tester.pump();

      final usdTextField = tester.widget<TextField>(find
          .byKey(const Key('converterPage_foreign_currency_value_textField')));
      final plnTextField = tester.widget<TextField>(
          find.byKey(const Key('converterPage_pln_value_textField')));

      expect(usdTextField.controller?.text, '2');
      expect(usdTextField.enabled, true);
      expect(plnTextField.controller?.text, '9.6568');
      expect(plnTextField.enabled, false);
    });

    testWidgets(
        'routes to ChangeCurrencyPage when change currency '
        'button is tapped', (tester) async {
      final navigator = MockNavigator();
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});

      when(() => converterCubit.state).thenReturn(
        ConverterState(status: ConverterStatus.success, foreignCurrency: usd),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: converterCubit),
            BlocProvider.value(value: homeCubit),
            BlocProvider.value(value: settingsCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: const [AppLocalizations.delegate],
            home: MockNavigatorProvider(
              navigator: navigator,
              child: const ConverterView(),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_forward_ios));

      verify(() => navigator.push<void>(any(that: isRoute<void>()))).called(1);
    });
  });
}
