import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../l10n/l10n_extensions.dart';
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
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.settings_backup_restore_rounded),
        title: Text(l10n.resetSettingsQuestion),
        content: Text(l10n.resetSettingsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm_reset_settings'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.reset),
          ),
        ],
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
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Text(body),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(context.l10n.close),
        ),
      ],
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
        onTap: onPressed,
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
      onChanged: onChanged,
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
