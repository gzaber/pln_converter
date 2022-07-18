import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pln_converter/app/cubit/app_cubit.dart';
import 'package:pln_converter/home/home.dart';
import 'package:settings_repository/settings_repository.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.settingsRepository,
    required this.exchangeRatesRepository,
  }) : super(key: key);

  final SettingsRepository settingsRepository;
  final ExchangeRatesRepository exchangeRatesRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: exchangeRatesRepository),
      ],
      child: BlocProvider(
        create: (context) => AppCubit(
          settingsRepository: context.read<SettingsRepository>(),
        )..readSettings(),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: context.read<AppCubit>().state.theme == AppTheme.light
          ? ThemeMode.light
          : ThemeMode.dark,
      title: 'PLN converter',
      home: const HomePage(),
    );
  }
}
