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
    await controller.setSoundEffects(false);
    await controller.setMusic(false);
    await controller.setSfxVolume(.3);
    await controller.setMusicVolume(.25);
    await controller.setCriticalEventInterruption(
      CriticalEventInterruption.autoOpen,
    );

    final restored = AppSettingsController(store: store);
    expect(restored.language, AppLanguage.filipino);
    expect(restored.locale, const Locale('fil'));
    expect(restored.reduceMotion, isTrue);
    expect(restored.highContrast, isTrue);
    expect(restored.dialogueSounds, isFalse);
    expect(restored.soundEffects, isFalse);
    expect(restored.music, isFalse);
    expect(restored.sfxVolume, .3);
    expect(restored.musicVolume, .25);
    expect(
      restored.criticalEventInterruption,
      CriticalEventInterruption.autoOpen,
    );

    await restored.reset();
    final afterReset = AppSettingsController(store: store);
    expect(afterReset.language, AppLanguage.system);
    expect(afterReset.locale, isNull);
    expect(afterReset.reduceMotion, isFalse);
    expect(afterReset.highContrast, isFalse);
    expect(afterReset.dialogueSounds, isTrue);
    expect(afterReset.soundEffects, isTrue);
    expect(afterReset.music, isTrue);
    expect(afterReset.sfxVolume, .55);
    expect(afterReset.musicVolume, .42);
    expect(
      afterReset.criticalEventInterruption,
      CriticalEventInterruption.pauseAndNotify,
    );

    controller.dispose();
    restored.dispose();
    afterReset.dispose();
  });

  test('legacy auto-pause values migrate to interruption preferences', () {
    final neverStore = MemorySettingsStore({
      AppSettingsController.legacySimulationAutoPauseKey: 'never',
    });
    final legacyDefaultStore = MemorySettingsStore({
      AppSettingsController.legacySimulationAutoPauseKey:
          'importantAndCritical',
    });

    final never = AppSettingsController(store: neverStore);
    final legacyDefault = AppSettingsController(store: legacyDefaultStore);

    expect(
      never.criticalEventInterruption,
      CriticalEventInterruption.notifyOnly,
    );
    expect(
      legacyDefault.criticalEventInterruption,
      CriticalEventInterruption.pauseAndNotify,
    );

    never.dispose();
    legacyDefault.dispose();
  });
}
