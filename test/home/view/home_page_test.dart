import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/converter/converter.dart';
import 'package:pln_converter/exchange_rates/exchange_rates.dart';
import 'package:pln_converter/home/home.dart';
import 'package:pln_converter/settings/settings.dart';
import 'package:settings_repository/settings_repository.dart';

extension PumpView on WidgetTester {
  Future<void> pumpHomeView({
    required ExchangeRatesRepository exchangeRatesRepository,
    required SettingsCubit settingsCubit,
    required HomeCubit homeCubit,
  }) {
    return pumpWidget(
      RepositoryProvider.value(
        value: exchangeRatesRepository,
        child: BlocProvider.value(
          value: settingsCubit,
          child: MaterialApp(
            localizationsDelegates: const [AppLocalizations.delegate],
            home: BlocProvider.value(
              value: homeCubit,
              child: const HomeView(),
            ),
          ),
        ),
      ),
    );
  }
}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockSettingsCubit extends MockCubit<Settings> implements SettingsCubit {}

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

void main() {
  group('HomePage', () {
    late SettingsCubit settingsCubit;
    late ExchangeRatesRepository exchangeRatesRepository;

    setUp(() {
      settingsCubit = MockSettingsCubit();
      exchangeRatesRepository = MockExchangeRatesRepository();
      when(() => settingsCubit.state).thenReturn(
        const Settings(
          currencyCode: 'USD',
          currencyTable: 'A',
          theme: AppTheme.light,
        ),
      );
    });
    testWidgets('renders HomeView', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: exchangeRatesRepository,
          child: BlocProvider.value(
            value: settingsCubit,
            child: const MaterialApp(
              localizationsDelegates: [AppLocalizations.delegate],
              home: HomePage(),
            ),
          ),
        ),
      );

      expect(find.byType(HomeView), findsOneWidget);
    });
  });

  group('HomeView', () {
    late HomeCubit homeCubit;
    late SettingsCubit settingsCubit;
    late ExchangeRatesRepository exchangeRatesRepository;

    setUp(() {
      homeCubit = MockHomeCubit();
      settingsCubit = MockSettingsCubit();
      exchangeRatesRepository = MockExchangeRatesRepository();
      when(() => homeCubit.state).thenReturn(const HomeState());
      when(() => settingsCubit.state).thenReturn(
        const Settings(
          currencyCode: 'USD',
          currencyTable: 'A',
          theme: AppTheme.light,
        ),
      );
    });

    testWidgets('renders ConverterPage', (tester) async {
      when(() => homeCubit.state).thenReturn(const HomeState());

      await tester.pumpHomeView(
        exchangeRatesRepository: exchangeRatesRepository,
        settingsCubit: settingsCubit,
        homeCubit: homeCubit,
      );

      expect(find.byType(ConverterPage), findsOneWidget);
    });

    testWidgets('renders ExchangeRatesPage', (tester) async {
      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.exchangeRates));

      await tester.pumpHomeView(
        exchangeRatesRepository: exchangeRatesRepository,
        settingsCubit: settingsCubit,
        homeCubit: homeCubit,
      );

      expect(find.byType(ExchangeRatesPage), findsOneWidget);
    });

    testWidgets('renders SettingsPage', (tester) async {
      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.settings));

      await tester.pumpHomeView(
        exchangeRatesRepository: exchangeRatesRepository,
        settingsCubit: settingsCubit,
        homeCubit: homeCubit,
      );

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets(
        'calls setTab with HomeTab.converter on HomeCubit '
        'when converter button is pressed', (tester) async {
      await tester.pumpHomeView(
        exchangeRatesRepository: exchangeRatesRepository,
        settingsCubit: settingsCubit,
        homeCubit: homeCubit,
      );

      await tester.tap(find.byIcon(Icons.autorenew));

      verify(() => homeCubit.setTab(HomeTab.converter)).called(1);
    });

    testWidgets(
        'calls setTab with HomeTab.exchangeRates on HomeCubit '
        'when exchange rates button is pressed', (tester) async {
      await tester.pumpHomeView(
        exchangeRatesRepository: exchangeRatesRepository,
        settingsCubit: settingsCubit,
        homeCubit: homeCubit,
      );

      await tester.tap(find.byIcon(Icons.format_list_bulleted));

      verify(() => homeCubit.setTab(HomeTab.exchangeRates)).called(1);
    });

    testWidgets(
        'calls setTab with HomeTab.settings on HomeCubit '
        'when settings button is pressed', (tester) async {
      await tester.pumpHomeView(
        exchangeRatesRepository: exchangeRatesRepository,
        settingsCubit: settingsCubit,
        homeCubit: homeCubit,
      );

      await tester.tap(find.byIcon(Icons.settings));

      verify(() => homeCubit.setTab(HomeTab.settings)).called(1);
    });
  });
}
