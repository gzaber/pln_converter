import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pln_converter/change_currency/change_currency.dart';
import 'package:pln_converter/converter/cubit/converter_cubit.dart';
import 'package:pln_converter/home/home.dart';
import 'package:pln_converter/settings/cubit/settings_cubit.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConverterCubit(
        context.read<ExchangeRatesRepository>(),
      ),
      child: const ConverterView(),
    );
  }
}

class ConverterView extends StatelessWidget {
  const ConverterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected =
        context.select((HomeCubit c) => c.state.tab == HomeTab.converter);
    if (isSelected) {
      context.read<ConverterCubit>().getCurrency(
            table: context.read<SettingsCubit>().state.currencyTable,
            code: context.read<SettingsCubit>().state.currencyCode,
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLN converter'),
        centerTitle: true,
      ),
      body: BlocConsumer<ConverterCubit, ConverterState>(
        listener: (context, state) {
          if (state.status == ConverterStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state.status == ConverterStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.status == ConverterStatus.success) {
            if (state.foreignCurrency != null) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      state.isPlnUp
                          ? _CurrencyCard(
                              value: state.plnValue,
                              textFieldKey: const Key(
                                  'converterPage_pln_value_textField'),
                              onSubmitted: context
                                  .read<ConverterCubit>()
                                  .convertPlnToForeignCurrency,
                            )
                          : _CurrencyCard(
                              isForeignCurrency: true,
                              code: state.foreignCurrency!.code,
                              name: state.foreignCurrency!.name,
                              value: state.foreignCurrencyValue,
                              textFieldKey: const Key(
                                  'converterPage_foreign_currency_value_textField'),
                              onSubmitted: context
                                  .read<ConverterCubit>()
                                  .convertForeignCurrencyToPln,
                            ),
                      _SwitchRow(
                        code: state.foreignCurrency!.code,
                        rate: state.foreignCurrency!.rate,
                      ),
                      state.isPlnUp
                          ? _CurrencyCard(
                              isForeignCurrency: true,
                              code: state.foreignCurrency!.code,
                              name: state.foreignCurrency!.name,
                              value: state.foreignCurrencyValue,
                              isEnabled: false,
                              textFieldKey: const Key(
                                  'converterPage_foreign_currency_value_textField'),
                            )
                          : _CurrencyCard(
                              value: state.plnValue,
                              isEnabled: false,
                              textFieldKey: const Key(
                                  'converterPage_pln_value_textField'),
                            ),
                    ],
                  ),
                ),
              );
            }
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    Key? key,
    required this.code,
    required this.rate,
  }) : super(key: key);

  final String code;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('1 $code = $rate PLN'),
          IconButton(
            icon: const Icon(Icons.unfold_more),
            onPressed: () {
              context.read<ConverterCubit>().changeLevels();
            },
          ),
        ],
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    Key? key,
    this.code = 'PLN',
    this.name = 'polski złoty',
    required this.value,
    this.isEnabled = true,
    this.isForeignCurrency = false,
    this.textFieldKey,
    this.onSubmitted,
  }) : super(key: key);

  final String code;
  final String name;
  final double value;
  final bool isEnabled;
  final bool isForeignCurrency;
  final Key? textFieldKey;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#.####");
    return Card(
      elevation: 8,
      child: Column(
        children: [
          ListTile(
            leading: Image.network(
              'https://countryflagsapi.com/png/${code.substring(0, 2)}',
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (_, __, ___) {
                return const SizedBox(
                  width: 60,
                  height: 40,
                  child: Icon(Icons.error),
                );
              },
              width: 60,
              height: 40,
              fit: BoxFit.cover,
            ),
            title: Text(code),
            subtitle: Text(name),
            trailing: isForeignCurrency
                ? IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.of(context)
                          .push<void>(ChangeCurrencyPage.route())
                          .then(
                            (_) => context.read<ConverterCubit>().getCurrency(
                                  table: context
                                      .read<SettingsCubit>()
                                      .state
                                      .currencyTable,
                                  code: context
                                      .read<SettingsCubit>()
                                      .state
                                      .currencyCode,
                                ),
                          );
                    })
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              key: textFieldKey,
              controller: TextEditingController(
                text: currencyFormat.format(value),
              ),
              enabled: isEnabled,
              textAlign: TextAlign.right,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,4})')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
