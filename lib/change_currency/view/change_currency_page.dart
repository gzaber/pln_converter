import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pln_converter/change_currency/change_currency.dart';
import 'package:pln_converter/settings/cubit/settings_cubit.dart';

class ChangeCurrencyPage extends StatelessWidget {
  const ChangeCurrencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangeCurrencyCubit(
        context.read<ExchangeRatesRepository>(),
      )..loadCurrencies(),
      child: const ChangeCurrencyView(),
    );
  }
}

class ChangeCurrencyView extends StatelessWidget {
  const ChangeCurrencyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change currency'),
        centerTitle: true,
      ),
      body: BlocConsumer<ChangeCurrencyCubit, ChangeCurrencyState>(
        listener: (context, state) {
          if (state.status == ChangeCurrencyStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state.status == ChangeCurrencyStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.status == ChangeCurrencyStatus.success) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: state.currencies.length,
                itemBuilder: (context, index) {
                  return _CurrencyListTile(currency: state.currencies[index]);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _CurrencyListTile extends StatelessWidget {
  const _CurrencyListTile({
    Key? key,
    required this.currency,
  }) : super(key: key);

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        'https://countryflagsapi.com/png/${currency.code.substring(0, 2)}',
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
      title: Text(currency.code),
      subtitle: Text(currency.name),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          context
              .read<SettingsCubit>()
              .saveCurrency(currency.code, currency.table);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
