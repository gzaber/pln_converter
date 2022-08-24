import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pln_converter/home/home.dart';
import 'package:pln_converter/settings/settings.dart';
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
        create: (context) => SettingsCubit(
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
    final appTheme = context.select((SettingsCubit cubit) => cubit.state.theme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appTheme == AppTheme.light
          ? ThemeData.light().copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Colors.amber,
                  selectionColor: Colors.amber,
                  selectionHandleColor: Colors.amber))
          : ThemeData.dark(),
      title: 'PLN converter',
      home: const HomePage(),
    );
  }
}
