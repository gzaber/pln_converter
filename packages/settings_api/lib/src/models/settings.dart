import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonEnum()
enum AppTheme { light, dark }

@JsonSerializable()
class Settings extends Equatable {
  const Settings({
    required this.currency,
    required this.theme,
  });

  final String currency;
  final AppTheme theme;

  Settings copyWith({
    String? currency,
    AppTheme? theme,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  List<Object?> get props => [currency, theme];
}
