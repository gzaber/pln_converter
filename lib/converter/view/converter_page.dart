import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pln_converter/converter/cubit/converter_cubit.dart';
import 'package:pln_converter/settings/cubit/settings_cubit.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConverterCubit(
        context.read<ExchangeRatesRepository>(),
      )..getCurrency(
          table: context.read<SettingsCubit>().state.currencyTable,
          code: context.read<SettingsCubit>().state.currencyCode,
        ),
      child: const ConverterView(),
    );
  }
}

class ConverterView extends StatelessWidget {
  const ConverterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                              code: 'PLN',
                              name: 'polski złoty',
                              value: state.plnValue,
                              textFieldKey: const Key(
                                  'converterPage_pln_value_textField'),
                              onSubmitted: context
                                  .read<ConverterCubit>()
                                  .convertPlnToForeignCurrency,
                            )
                          : _CurrencyCard(
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
                              code: state.foreignCurrency!.code,
                              name: state.foreignCurrency!.name,
                              value: state.foreignCurrencyValue,
                              enabled: false,
                              textFieldKey: const Key(
                                  'converterPage_foreign_currency_value_textField'),
                            )
                          : _CurrencyCard(
                              code: 'PLN',
                              name: 'polski złoty',
                              value: state.plnValue,
                              enabled: false,
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
    required this.code,
    required this.name,
    required this.value,
    this.enabled = true,
    this.textFieldKey,
    this.onSubmitted,
  }) : super(key: key);

  final String code;
  final String name;
  final double value;
  final bool enabled;
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              key: textFieldKey,
              controller: TextEditingController(
                text: currencyFormat.format(value),
              ),
              enabled: enabled,
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
