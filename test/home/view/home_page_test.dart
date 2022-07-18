import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/converter/converter.dart';
import 'package:pln_converter/exchange_rates/exchange_rates.dart';
import 'package:pln_converter/home/home.dart';
import 'package:pln_converter/settings/settings.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  group('HomePage', () {
    testWidgets('renders HomeView', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byType(HomeView), findsOneWidget);
    });
  });

  group('HomeView', () {
    late HomeCubit homeCubit;

    setUp(() {
      homeCubit = MockHomeCubit();
      when(() => homeCubit.state).thenReturn(const HomeState());
    });

    testWidgets('renders ConverterPage', (tester) async {
      when(() => homeCubit.state).thenReturn(const HomeState());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: homeCubit,
            child: const HomeView(),
          ),
        ),
      );

      expect(find.byType(ConverterPage), findsOneWidget);
    });

    testWidgets('renders ExchangeRatesPage', (tester) async {
      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.exchangeRates));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: homeCubit,
            child: const HomeView(),
          ),
        ),
      );

      expect(find.byType(ExchangeRatesPage), findsOneWidget);
    });

    testWidgets('renders SettingsPage', (tester) async {
      when(() => homeCubit.state)
          .thenReturn(const HomeState(tab: HomeTab.settings));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: homeCubit,
            child: const HomeView(),
          ),
        ),
      );

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets(
        'calls setTab with HomeTab.converter on HomeCubit '
        'when converter button is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: homeCubit,
            child: const HomeView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.currency_exchange));

      verify(() => homeCubit.setTab(HomeTab.converter)).called(1);
    });

    testWidgets(
        'calls setTab with HomeTab.exchangeRates on HomeCubit '
        'when exchange rates button is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: homeCubit,
            child: const HomeView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_list_bulleted));

      verify(() => homeCubit.setTab(HomeTab.exchangeRates)).called(1);
    });

    testWidgets(
        'calls setTab with HomeTab.settings on HomeCubit '
        'when settings button is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: homeCubit,
            child: const HomeView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.settings));

      verify(() => homeCubit.setTab(HomeTab.settings)).called(1);
    });
  });
}
