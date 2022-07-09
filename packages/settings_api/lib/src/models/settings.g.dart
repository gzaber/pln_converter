// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      currency: json['currency'] as String,
      theme: $enumDecode(_$AppThemeEnumMap, json['theme']),
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'currency': instance.currency,
      'theme': _$AppThemeEnumMap[instance.theme]!,
    };

const _$AppThemeEnumMap = {
  AppTheme.light: 'light',
  AppTheme.dark: 'dark',
};
