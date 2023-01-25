import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pln_converter/settings/settings.dart';
import 'package:settings_repository/settings_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<SettingsCubit>().state.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsAppBarTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsTheme,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            RadioListTile<AppTheme>(
              key: const Key('settingsPage_lightTheme_radioListTile'),
              title: Text(AppLocalizations.of(context)!.settingsLight),
              value: AppTheme.light,
              groupValue: appTheme,
              onChanged: (theme) async {
                await context.read<SettingsCubit>().saveTheme(theme!);
              },
            ),
            RadioListTile<AppTheme>(
              key: const Key('settingsPage_darkTheme_radioListTile'),
              title: Text(AppLocalizations.of(context)!.settingsDark),
              value: AppTheme.dark,
              groupValue: appTheme,
              onChanged: (theme) async {
                await context.read<SettingsCubit>().saveTheme(theme!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
