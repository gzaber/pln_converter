import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pln_converter/settings/settings.dart';
import 'package:settings_repository/settings_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<SettingsCubit>().state.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.headline5,
            ),
            RadioListTile<AppTheme>(
              key: const Key('settingsPage_lightTheme_radioListTile'),
              title: const Text('light'),
              value: AppTheme.light,
              groupValue: appTheme,
              onChanged: (theme) async {
                await context.read<SettingsCubit>().saveTheme(theme!);
              },
            ),
            RadioListTile<AppTheme>(
              key: const Key('settingsPage_darkTheme_radioListTile'),
              title: const Text('dark'),
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
