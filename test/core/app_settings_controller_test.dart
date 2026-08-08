import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';

void main() {
  test('settings persist and can be reset to defaults', () async {
    final store = MemorySettingsStore();
    final controller = AppSettingsController(store: store);

    await controller.setLanguage(AppLanguage.filipino);
    await controller.setReduceMotion(true);
    await controller.setHighContrast(true);
    await controller.setDialogueSounds(false);

    final restored = AppSettingsController(store: store);
    expect(restored.language, AppLanguage.filipino);
    expect(restored.locale, const Locale('fil'));
    expect(restored.reduceMotion, isTrue);
    expect(restored.highContrast, isTrue);
    expect(restored.dialogueSounds, isFalse);

    await restored.reset();
    final afterReset = AppSettingsController(store: store);
    expect(afterReset.language, AppLanguage.system);
    expect(afterReset.locale, isNull);
    expect(afterReset.reduceMotion, isFalse);
    expect(afterReset.highContrast, isFalse);
    expect(afterReset.dialogueSounds, isTrue);

    controller.dispose();
    restored.dispose();
    afterReset.dispose();
  });
}
