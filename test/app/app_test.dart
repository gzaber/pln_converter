import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/app/app.dart';
import 'package:pln_converter/home/home.dart';
import 'package:pln_converter/settings/settings.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

class MockSettingsCubit extends MockCubit<Settings> implements SettingsCubit {}

void main() {
  group('App', () {
    late SettingsRepository settingsRepository;
    late ExchangeRatesRepository exchangeRatesRepository;

    setUp(() {
      settingsRepository = MockSettingsRepository();
      exchangeRatesRepository = MockExchangeRatesRepository();
    });

    testWidgets('Renders AppView', (tester) async {
      await tester.pumpWidget(
        App(
          settingsRepository: settingsRepository,
          exchangeRatesRepository: exchangeRatesRepository,
        ),
      );
      expect(find.byType(AppView), findsOneWidget);
    });
  });

  group('AppView', () {
    late ExchangeRatesRepository exchangeRatesRepository;
    late SettingsRepository settingsRepository;
    late SettingsCubit settingsCubit;

    setUp(() {
      exchangeRatesRepository = MockExchangeRatesRepository();
      settingsRepository = MockSettingsRepository();
      settingsCubit = MockSettingsCubit();
    });

    testWidgets('renders HomePage', (tester) async {
      const settings = Settings(
          currencyCode: 'USD', currencyTable: 'A', theme: AppTheme.light);
      when(() => settingsCubit.state).thenReturn(settings);
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(
              value: settingsRepository,
            ),
            RepositoryProvider.value(
              value: exchangeRatesRepository,
            ),
          ],
          child: BlocProvider.value(
            value: settingsCubit,
            child: const AppView(),
          ),
        ),
      );
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('has correct theme', (tester) async {
      const settings = Settings(
          currencyCode: 'USD', currencyTable: 'A', theme: AppTheme.dark);
      when(() => settingsCubit.state).thenReturn(settings);
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(
              value: settingsRepository,
            ),
            RepositoryProvider.value(value: exchangeRatesRepository),
          ],
          child: BlocProvider.value(
            value: settingsCubit,
            child: const AppView(),
          ),
        ),
      );
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.dark());
    });
  });
}
