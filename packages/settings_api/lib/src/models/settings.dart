import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonEnum()
enum AppTheme { light, dark }

@JsonSerializable()
class Settings extends Equatable {
  const Settings({
    required this.currencyCode,
    required this.currencyTable,
    required this.theme,
  });

  final String currencyCode;
  final String currencyTable;
  final AppTheme theme;

  Settings copyWith({
    String? currencyCode,
    String? currencyTable,
    AppTheme? theme,
  }) {
    return Settings(
      currencyCode: currencyCode ?? this.currencyCode,
      currencyTable: currencyTable ?? this.currencyTable,
      theme: theme ?? this.theme,
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  List<Object?> get props => [currencyCode, currencyTable, theme];
}
