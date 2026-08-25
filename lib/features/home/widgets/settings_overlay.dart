import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/audio/game_audio_service.dart';
import '../../../l10n/l10n_extensions.dart';
import '../../../l10n/tv_broadcast_localizations.dart';
import '../../../l10n/living_city_localizations.dart';
import 'game_overlay_shell.dart';

Future<void> showSettingsOverlay({
  required BuildContext context,
  required AppSettingsController controller,
}) => showGameOverlay<void>(
  context: context,
  builder: (overlayContext) => GameOverlayShell(
    kicker: overlayContext.l10n.accessibility,
    title: overlayContext.l10n.settings,
    onBack: () => Navigator.pop(overlayContext),
    child: _SettingsSheet(controller: controller),
  ),
);

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.controller});

  final AppSettingsController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final l10n = context.l10n;
      return ListView(
        key: const Key('settings_sheet'),
        padding: const EdgeInsets.fromLTRB(17, 4, 17, 26),
        children: [
          _SettingsSection(
            icon: Icons.language_rounded,
            title: l10n.language,
            subtitle: l10n.languageDescription,
            child: Column(
              children: [
                for (final language in AppLanguage.values) ...[
                  _LanguageChoice(
                    language: language,
                    selected: controller.language == language,
                    onPressed: () =>
                        unawaited(controller.setLanguage(language)),
                  ),
                  if (language != AppLanguage.values.last)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 13),
          _SettingsSection(
            icon: Icons.accessibility_new_rounded,
            title: l10n.accessibility,
            subtitle: l10n.deviceTextSizeDescription,
            child: Column(
              children: [
                _SettingsSwitch(
                  switchKey: const Key('reduce_motion_setting'),
                  icon: Icons.motion_photos_off_outlined,
                  title: l10n.reduceMotion,
                  subtitle: l10n.reduceMotionDescription,
                  value: controller.reduceMotion,
                  onChanged: (value) =>
                      unawaited(controller.setReduceMotion(value)),
                ),
                const SizedBox(height: 9),
                _SettingsSwitch(
                  switchKey: const Key('high_contrast_setting'),
                  icon: Icons.contrast_rounded,
                  title: l10n.highContrast,
                  subtitle: l10n.highContrastDescription,
                  value: controller.highContrast,
                  onChanged: (value) =>
                      unawaited(controller.setHighContrast(value)),
                ),
                const SizedBox(height: 9),
                _InformationTile(
                  icon: Icons.text_fields_rounded,
                  title: l10n.deviceTextSize,
                  subtitle: l10n.deviceTextSizeDescription,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _SettingsSection(
            icon: Icons.volume_up_rounded,
            title: l10n.audio,
            subtitle: l10n.audioDescription,
            child: Column(
              children: [
                _SettingsSwitch(
                  switchKey: const Key('sound_effects_setting'),
                  icon: Icons.touch_app_rounded,
                  title: l10n.soundEffects,
                  subtitle: l10n.soundEffectsDescription,
                  value: controller.soundEffects,
                  onChanged: (value) =>
                      unawaited(controller.setSoundEffects(value)),
                ),
                const SizedBox(height: 9),
                _VolumeSlider(
                  sliderKey: const Key('sfx_volume_setting'),
                  icon: Icons.volume_down_rounded,
                  label: l10n.sfxVolume,
                  value: controller.sfxVolume,
                  enabled: controller.soundEffects,
                  onChanged: (value) =>
                      unawaited(controller.setSfxVolume(value)),
                ),
                const SizedBox(height: 9),
                _SettingsSwitch(
                  switchKey: const Key('dialogue_sounds_setting'),
                  icon: Icons.graphic_eq_rounded,
                  title: context.tvStrings.dialogueSounds,
                  subtitle: context.tvStrings.dialogueSoundsDescription,
                  value: controller.dialogueSounds,
                  onChanged: (value) =>
                      unawaited(controller.setDialogueSounds(value)),
                ),
                const SizedBox(height: 9),
                _SettingsSwitch(
                  switchKey: const Key('music_setting'),
                  icon: Icons.music_note_rounded,
                  title: l10n.music,
                  subtitle: l10n.musicDescription,
                  value: controller.music,
                  onChanged: (value) => unawaited(controller.setMusic(value)),
                ),
                const SizedBox(height: 9),
                _VolumeSlider(
                  sliderKey: const Key('music_volume_setting'),
                  icon: Icons.library_music_rounded,
                  label: l10n.musicVolume,
                  value: controller.musicVolume,
                  enabled: controller.music,
                  onChanged: (value) =>
                      unawaited(controller.setMusicVolume(value)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _SettingsSection(
            icon: Icons.notification_important_rounded,
            title: context.criticalInterruption,
            subtitle: context.criticalInterruptionDescription,
            child: Column(
              children: [
                for (final mode in CriticalEventInterruption.values) ...[
                  _CriticalInterruptionChoice(
                    mode: mode,
                    selected: controller.criticalEventInterruption == mode,
                    onPressed: () => unawaited(
                      controller.setCriticalEventInterruption(mode),
                    ),
                  ),
                  if (mode != CriticalEventInterruption.values.last)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 13),
          _SettingsSection(
            icon: Icons.info_outline_rounded,
            title: l10n.information,
            subtitle: l10n.disclaimerBody,
            child: Column(
              children: [
                _InfoButton(
                  buttonKey: const Key('about_settings_item'),
                  icon: Icons.info_outline_rounded,
                  label: l10n.aboutTitle,
                  onPressed: () => _showInfo(
                    context,
                    title: l10n.aboutTitle,
                    body: l10n.aboutBody,
                  ),
                ),
                _InfoButton(
                  buttonKey: const Key('credits_settings_item'),
                  icon: Icons.groups_outlined,
                  label: l10n.creditsTitle,
                  onPressed: () => _showInfo(
                    context,
                    title: l10n.creditsTitle,
                    body: l10n.creditsBody,
                  ),
                ),
                _InfoButton(
                  buttonKey: const Key('disclaimer_settings_item'),
                  icon: Icons.gavel_outlined,
                  label: l10n.disclaimerTitle,
                  onPressed: () => _showInfo(
                    context,
                    title: l10n.disclaimerTitle,
                    body: l10n.disclaimerBody,
                  ),
                ),
                _InfoButton(
                  buttonKey: const Key('privacy_settings_item'),
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.privacyTitle,
                  onPressed: () => _showInfo(
                    context,
                    title: l10n.privacyTitle,
                    body: l10n.privacyBody,
                  ),
                ),
                _InformationTile(
                  icon: Icons.numbers_rounded,
                  title: l10n.appVersion,
                  subtitle: l10n.appVersionValue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ChunkyPaperButton(
            label: l10n.resetSettings,
            icon: Icons.settings_backup_restore_rounded,
            color: ResiboColors.mutedRed,
            buttonKey: const Key('reset_settings_button'),
            onPressed: () => _confirmReset(context),
          ),
          const SizedBox(height: 11),
          ChunkyPaperButton(
            label: l10n.backToMainMenu,
            icon: Icons.arrow_back_rounded,
            color: ResiboColors.navy,
            buttonKey: const Key('close_settings_button'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _SettingsDialog(
        icon: Icons.settings_backup_restore_rounded,
        title: l10n.resetSettingsQuestion,
        body: l10n.resetSettingsConfirmation,
        secondaryLabel: l10n.cancel,
        onSecondary: () => Navigator.pop(dialogContext, false),
        primaryKey: const Key('confirm_reset_settings'),
        primaryLabel: l10n.reset,
        onPrimary: () => Navigator.pop(dialogContext, true),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await controller.reset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.settingsResetNotice)));
  }

  Future<void> _showInfo(
    BuildContext context, {
    required String title,
    required String body,
  }) => showDialog<void>(
    context: context,
    builder: (dialogContext) => _SettingsDialog(
      icon: Icons.info_outline_rounded,
      title: title,
      body: body,
      primaryLabel: context.l10n.close,
      onPrimary: () => Navigator.pop(dialogContext),
    ),
  );
}

class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryKey,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final Key? primaryKey;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF4D5), Color(0xFFE8C989)],
          ),
          border: Border.all(color: const Color(0xFF101820), width: 4),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black87, offset: Offset(5, 7)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: ResiboColors.mutedRed, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF172332),
                      fontFamily: 'LilitaOne',
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                color: Color(0xFF172332),
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 9,
              runSpacing: 9,
              children: [
                if (secondaryLabel != null && onSecondary != null)
                  ChunkyPaperButton(
                    label: secondaryLabel!,
                    icon: Icons.arrow_back_rounded,
                    expand: false,
                    sound: GameSound.uiBack,
                    onPressed: onSecondary,
                  ),
                ChunkyPaperButton(
                  buttonKey: primaryKey,
                  label: primaryLabel,
                  icon: Icons.check_rounded,
                  expand: false,
                  color: ResiboColors.mutedRed,
                  sound: GameSound.uiConfirm,
                  onPressed: onPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
    decoration: BoxDecoration(
      color: const Color(0xEFFFF8E8),
      border: Border.all(color: const Color(0xFF725634), width: 2),
      borderRadius: BorderRadius.circular(5),
      boxShadow: const [
        BoxShadow(color: Color(0x2F5E3C20), offset: Offset(2, 3)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ResiboColors.navy, size: 27),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: ResiboColors.navy,
                      fontFamily: 'LilitaOne',
                      fontSize: 18,
                      letterSpacing: .55,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF65533D),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.language,
    required this.selected,
    required this.onPressed,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('language_${language.name}'),
        onTap: () {
          GameAudioScope.maybeOf(context)?.play(GameSound.uiTab);
          onPressed();
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFDCE9D4) : const Color(0xFFFFFCF1),
            border: Border.all(
              color: selected ? ResiboColors.teal : const Color(0xFF9B805B),
              width: selected ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.language_rounded,
                color: selected ? ResiboColors.teal : ResiboColors.navy,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.languageLabel(language),
                      style: const TextStyle(
                        color: ResiboColors.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      l10n.languageDetails(language),
                      style: const TextStyle(fontSize: 12, height: 1.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.switchKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Key switchKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFFCF1),
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Color(0xFF9B805B), width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: SwitchListTile(
      key: switchKey,
      secondary: Icon(icon, color: ResiboColors.navy),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (value) {
        GameAudioScope.maybeOf(context)?.play(GameSound.uiConfirm);
        onChanged(value);
      },
    ),
  );
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.sliderKey,
    required this.icon,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final Key sliderKey;
  final IconData icon;
  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 10, 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFCF1),
      border: Border.all(color: const Color(0xFF9B805B), width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Icon(icon, color: enabled ? ResiboColors.navy : Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label · ${(value * 100).round()}%',
                style: const TextStyle(
                  color: ResiboColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: ResiboColors.teal,
                  inactiveTrackColor: const Color(0xFFD7C7A7),
                  thumbColor: const Color(0xFFF0B64F),
                  overlayColor: ResiboColors.teal.withValues(alpha: .15),
                  trackHeight: 6,
                ),
                child: Slider(
                  key: sliderKey,
                  value: value,
                  divisions: 10,
                  onChanged: enabled ? onChanged : null,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CriticalInterruptionChoice extends StatelessWidget {
  const _CriticalInterruptionChoice({
    required this.mode,
    required this.selected,
    required this.onPressed,
  });

  final CriticalEventInterruption mode;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      key: Key('critical_interruption_${mode.name}'),
      onTap: () {
        GameAudioScope.maybeOf(context)?.play(GameSound.uiTab);
        onPressed();
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCE9D4) : const Color(0xFFFFFCF1),
          border: Border.all(
            color: selected ? ResiboColors.teal : const Color(0xFF9B805B),
            width: selected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.notification_important_rounded
                  : Icons.notifications_none_rounded,
              color: selected ? ResiboColors.teal : ResiboColors.navy,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.criticalInterruptionLabel(mode),
                    style: const TextStyle(
                      color: ResiboColors.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    context.criticalInterruptionDetails(mode),
                    style: const TextStyle(fontSize: 12, height: 1.25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      key: buttonKey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: ResiboColors.teal),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onPressed,
    ),
  );
}

class _InformationTile extends StatelessWidget {
  const _InformationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: ResiboColors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
    ),
  );
}
