import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/app.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';
import 'package:resiboplease/l10n/app_localizations_fil.dart';

void main() {
  testWidgets('Settings changes the whole app language to Filipino', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final settings = AppSettingsController(store: MemorySettingsStore());
    addTearDown(settings.dispose);
    await tester.pumpWidget(ResiboPleaseApp(settingsController: settings));
    await tester.pump();

    await tester.tap(find.byKey(const Key('settings_button')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('settings_sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('language_filipino')));
    await tester.pump();

    final filipino = AppLocalizationsFil();
    expect(settings.language, AppLanguage.filipino);
    expect(find.text(filipino.language.toUpperCase()), findsOneWidget);
    expect(find.text(filipino.reduceMotion), findsOneWidget);
  });
}
