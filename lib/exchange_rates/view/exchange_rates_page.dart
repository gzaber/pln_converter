import 'package:cached_network_image/cached_network_image.dart';
import 'package:exchange_rates_repository/exchange_rates_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pln_converter/exchange_rates/exchange_rates.dart';

class ExchangeRatesPage extends StatelessWidget {
  const ExchangeRatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExchangeRatesCubit(
        context.read<ExchangeRatesRepository>(),
      )..getExchangeRates(),
      child: const ExchangeRatesView(),
    );
  }
}

class ExchangeRatesView extends StatelessWidget {
  const ExchangeRatesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _SearchAppBar(),
      body: BlocConsumer<ExchangeRatesCubit, ExchangeRatesState>(
        listener: (context, state) {
          if (state.exchangeRatesStatus == ExchangeRatesStatus.failure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state.exchangeRatesStatus == ExchangeRatesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.exchangeRatesStatus == ExchangeRatesStatus.success) {
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
    return BlocBuilder<ExchangeRatesCubit, ExchangeRatesState>(
      builder: (context, state) {
        if (state.searchStatus == SearchStatus.on) {
          return AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                context.read<ExchangeRatesCubit>().turnOffSearch();
              },
            ),
            centerTitle: true,
            title: SizedBox(
              width: double.infinity,
              height: 40.0,
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {},
                  ),
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
          );
        }
        return AppBar(
          title: const Text('Exchange rates'),
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
  Size get preferredSize => const Size(double.infinity, 50);
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
      leading: CachedNetworkImage(
        imageUrl:
            'https://countryflagsapi.com/png/${currency.code.substring(0, 2)}',
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        width: 60,
        height: 40,
        fit: BoxFit.cover,
      ),
      title: Text(currency.code),
      subtitle: Text(currency.name),
      trailing: Text(currency.rate.toString()),
    );
  }
}
