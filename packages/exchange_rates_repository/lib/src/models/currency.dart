import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  Currency({
    required this.name,
    required this.code,
    required this.table,
    required this.rate,
  });

  final String name;
  final String code;
  final String table;
  final double rate;

  @override
  List<Object?> get props => [name, code, table, rate];
}
