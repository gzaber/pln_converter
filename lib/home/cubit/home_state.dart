part of 'home_cubit.dart';

enum HomeTab { converter, exchangeRates, settings }

class HomeState extends Equatable {
  const HomeState({
    this.tab = HomeTab.converter,
  });

  final HomeTab tab;

  @override
  List<Object?> get props => [tab];
}
