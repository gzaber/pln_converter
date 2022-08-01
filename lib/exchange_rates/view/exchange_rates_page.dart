import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pln_converter/exchange_rates/exchange_rates.dart';
import 'package:pln_converter/home/cubit/home_cubit.dart';

class ExchangeRatesPage extends StatelessWidget {
  const ExchangeRatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExchangeRatesCubit(
        context.read<ExchangeRatesRepository>(),
      ),
      child: const ExchangeRatesView(),
    );
  }
}

class ExchangeRatesView extends StatelessWidget {
  const ExchangeRatesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected =
        context.select((HomeCubit c) => c.state.tab == HomeTab.exchangeRates);
    if (isSelected) {
      context.read<ExchangeRatesCubit>().getExchangeRates();
    }

    return Scaffold(
      appBar: const _SearchAppBar(),
      body: BlocConsumer<ExchangeRatesCubit, ExchangeRatesState>(
        listener: (context, state) {
          if (state.status == ExchangeRatesStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state.status == ExchangeRatesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.status == ExchangeRatesStatus.failure) {
            return const Center(
              child: Icon(Icons.error_outline, size: 64),
            );
          }
          if (state.status == ExchangeRatesStatus.success) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: state.exchangeRates.length,
                itemBuilder: (context, index) {
                  return _CurrencyListTile(
                      currency: state.exchangeRates[index]);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            );
          }
          if (state.status == ExchangeRatesStatus.search) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: state.filteredList.length,
                itemBuilder: (context, index) {
                  return _CurrencyListTile(currency: state.filteredList[index]);
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

class _SearchAppBar extends StatelessWidget with PreferredSizeWidget {
  const _SearchAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return BlocBuilder<ExchangeRatesCubit, ExchangeRatesState>(
      builder: (context, state) {
        if (state.status == ExchangeRatesStatus.search) {
          return AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                searchController.clear();
                context.read<ExchangeRatesCubit>().turnOffSearch();
              },
            ),
            centerTitle: true,
            title: SizedBox(
              width: double.infinity,
              height: 40.0,
              child: TextField(
                controller: searchController,
                onChanged: ((text) {
                  context.read<ExchangeRatesCubit>().search(text);
                }),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      context.read<ExchangeRatesCubit>().clearSearch();
                    },
                  ),
                  hintText: AppLocalizations.of(context)!.exchangeRatesSearch,
                  border: InputBorder.none,
                ),
              ),
            ),
          );
        }
        return AppBar(
          title: Text(AppLocalizations.of(context)!.exchangeRatesAppBarTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                context.read<ExchangeRatesCubit>().turnOnSearch();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 56);
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
      leading: Material(
        elevation: 8,
        child: Image.network(
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
      ),
      title: Text(currency.code),
      subtitle: Text(currency.name),
      trailing: Text(currency.rate.toString()),
    );
  }
}
