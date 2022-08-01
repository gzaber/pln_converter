import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pln_converter/settings/settings.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsCubit extends MockCubit<Settings> implements SettingsCubit {}

void main() {
  group('SettingsPage', () {
    late SettingsCubit settingsCubit;

    setUp(() {
      settingsCubit = MockSettingsCubit();
      when(() => settingsCubit.state).thenReturn(
        const Settings(
          currencyCode: 'USD',
          currencyTable: 'A',
          theme: AppTheme.light,
        ),
      );
    });

    testWidgets('renders correct widgets', (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: settingsCubit,
          child: const MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: SettingsPage(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(RadioListTile<AppTheme>), findsNWidgets(2));

      expect(
          find.text(AppLocalizationsEn().settingsAppBarTitle), findsOneWidget);
      expect(find.text(AppLocalizationsEn().settingsTheme), findsOneWidget);
      expect(find.text(AppLocalizationsEn().settingsLight), findsOneWidget);
      expect(find.text(AppLocalizationsEn().settingsDark), findsOneWidget);
    });

    testWidgets('proper radio is checked', (tester) async {
      when(() => settingsCubit.state).thenReturn(
        const Settings(
          currencyCode: 'USD',
          currencyTable: 'A',
          theme: AppTheme.dark,
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: settingsCubit,
          child: const MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: SettingsPage(),
          ),
        ),
      );

      final radioLight = tester.widget<RadioListTile>(
          find.byKey(const Key('settingsPage_lightTheme_radioListTile')));
      final radioDark = tester.widget<RadioListTile>(
          find.byKey(const Key('settingsPage_darkTheme_radioListTile')));

      expect(radioLight.checked, false);
      expect(radioDark.checked, true);
    });

    testWidgets('updates settings cubit when dark theme radio tapped',
        (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: settingsCubit,
          child: const MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: SettingsPage(),
          ),
        ),
      );

      await tester
          .tap(find.byKey(const Key('settingsPage_darkTheme_radioListTile')));
      await tester.pumpAndSettle();

      verify(() => settingsCubit.saveTheme(AppTheme.dark)).called(1);
    });

    testWidgets('updates settings cubit when light theme radio tapped',
        (tester) async {
      when(() => settingsCubit.state).thenReturn(
        const Settings(
          currencyCode: 'USD',
          currencyTable: 'A',
          theme: AppTheme.dark,
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: settingsCubit,
          child: const MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            home: SettingsPage(),
          ),
        ),
      );

      await tester
          .tap(find.byKey(const Key('settingsPage_lightTheme_radioListTile')));
      await tester.pumpAndSettle();

      verify(() => settingsCubit.saveTheme(AppTheme.light)).called(1);
    });
  });
}
