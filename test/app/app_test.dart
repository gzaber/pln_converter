import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/app/app.dart';
import 'package:pln_converter/app/cubit/app_cubit.dart';
import 'package:pln_converter/home/home.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

class MockAppCubit extends MockCubit<Settings> implements AppCubit {}

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
    late SettingsRepository settingsRepository;
    late AppCubit appCubit;

    setUp(() {
      settingsRepository = MockSettingsRepository();
      appCubit = MockAppCubit();
    });

    testWidgets('renders HomePage', (tester) async {
      const settings = Settings(
          currencyCode: 'USD', currencyTable: 'A', theme: AppTheme.light);
      when(() => appCubit.state).thenReturn(settings);
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: settingsRepository,
          child: BlocProvider.value(
            value: appCubit,
            child: const AppView(),
          ),
        ),
      );
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('has correct theme', (tester) async {
      const settings = Settings(
          currencyCode: 'USD', currencyTable: 'A', theme: AppTheme.dark);
      when(() => appCubit.state).thenReturn(settings);
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: settingsRepository,
          child: BlocProvider.value(
            value: appCubit,
            child: const AppView(),
          ),
        ),
      );
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });
}
