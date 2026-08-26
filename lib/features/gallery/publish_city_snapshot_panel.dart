import 'package:flutter/material.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/audio/game_audio_service.dart';
import '../../data/gallery/city_gallery_api_service.dart';
import '../../data/gallery/city_gallery_repository.dart';
import '../../domain/models/public_city_snapshot.dart';
import '../../domain/models/player_profile.dart';
import '../../l10n/city_gallery_localizations.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';
import 'player_name_setup_dialog.dart';

enum _PublishState { ready, publishing, published, failed }

enum _PublishPrivacy { public, private }

class PublishCitySnapshotPanel extends StatefulWidget {
  const PublishCitySnapshotPanel({
    required this.controller,
    required this.repository,
    super.key,
  });

  final GameController controller;
  final CityGalleryRepository repository;

  @override
  State<PublishCitySnapshotPanel> createState() =>
      _PublishCitySnapshotPanelState();
}

class _PublishCitySnapshotPanelState extends State<PublishCitySnapshotPanel> {
  _PublishState _state = _PublishState.ready;
  bool? _publishedPublic;

  Future<void> _publish() async {
    if (_state == _PublishState.publishing) return;
    final result = widget.controller.termResult;
    final configuration = widget.controller.activeConfiguration;
    if (result == null || configuration == null) return;
    final strings = context.galleryStrings;
    PlayerProfile? profile;
    try {
      profile = await widget.repository.restoreProfile();
    } on CityGalleryApiException {
      if (mounted) setState(() => _state = _PublishState.failed);
      return;
    }
    if (!mounted) return;
    profile ??= await showPlayerNameSetupDialog(context, widget.repository);
    if (!mounted || profile == null) return;
    var privacy = _PublishPrivacy.public;
    final selectedPrivacy = await showDialog<_PublishPrivacy>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: PaperPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionLabel(
                    label: strings.publishTitle,
                    icon: Icons.public_rounded,
                    color: ResiboColors.teal,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${strings.publishExplanation}\n\nSharing as ${profile!.displayName}.',
                    style: const TextStyle(color: dossierInk, height: 1.4),
                  ),
                  const SizedBox(height: 13),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _PrivacyOption(
                            key: const Key('publish_privacy_public'),
                            label: 'Public',
                            description:
                                'Visible in Explore and player search.',
                            icon: Icons.public_rounded,
                            selected: privacy == _PublishPrivacy.public,
                            onTap: () => setDialogState(
                              () => privacy = _PublishPrivacy.public,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _PrivacyOption(
                            key: const Key('publish_privacy_private'),
                            label: 'Private',
                            description: 'Visible only in My Cities.',
                            icon: Icons.lock_rounded,
                            selected: privacy == _PublishPrivacy.private,
                            onTap: () => setDialogState(
                              () => privacy = _PublishPrivacy.private,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      ChunkyActionButton(
                        label: strings.cancel,
                        compact: true,
                        color: ResiboColors.navy,
                        sound: GameSound.uiBack,
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                      ChunkyActionButton(
                        buttonKey: const Key('confirm_publish_city_snapshot'),
                        label: strings.confirmPublish,
                        icon: Icons.cloud_upload_rounded,
                        compact: true,
                        color: ResiboColors.teal,
                        sound: GameSound.uiConfirm,
                        onPressed: () => Navigator.pop(dialogContext, privacy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (selectedPrivacy == null || !mounted) return;
    setState(() => _state = _PublishState.publishing);
    final isPublic = selectedPrivacy == _PublishPrivacy.public;
    final snapshot = buildPublicCitySnapshot(
      city: widget.controller.scenario.city,
      configuration: configuration,
      result: result,
      topIssueId: widget.controller.topIssue,
      isPublic: isPublic,
    );
    try {
      await widget.repository.publishSnapshot(snapshot);
      if (mounted) {
        setState(() {
          _state = _PublishState.published;
          _publishedPublic = isPublic;
        });
      }
    } on CityGalleryApiException {
      if (mounted) setState(() => _state = _PublishState.failed);
    } catch (_) {
      if (mounted) setState(() => _state = _PublishState.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.galleryStrings;
    final label = switch (_state) {
      _PublishState.ready => strings.publishAction,
      _PublishState.publishing => strings.publishing,
      _PublishState.published =>
        _publishedPublic == true ? 'Published Publicly' : 'Saved Privately',
      _PublishState.failed => strings.publishFailure,
    };
    final color = switch (_state) {
      _PublishState.published => const Color(0xFF3D875F),
      _PublishState.failed => ResiboColors.mutedRed,
      _ => const Color(0xFF2F718E),
    };
    return CityPaperPanel(
      key: const Key('publish_city_snapshot_panel'),
      color: const Color(0xFFF2DFAE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.public_rounded, color: ResiboColors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.publicSharingNote.toUpperCase(),
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontFamily: 'LilitaOne',
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ChunkyActionButton(
            buttonKey: const Key('publish_city_snapshot'),
            label: label,
            icon: _state == _PublishState.publishing
                ? Icons.sync_rounded
                : _state == _PublishState.published
                ? Icons.cloud_done_rounded
                : Icons.cloud_upload_rounded,
            color: color,
            onPressed:
                _state == _PublishState.publishing ||
                    _state == _PublishState.published
                ? null
                : _publish,
          ),
        ],
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  const _PrivacyOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFE2B653) : const Color(0xFFE7D5AA),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? ResiboColors.mutedRed : dossierInk,
            width: selected ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? ResiboColors.mutedRed : dossierInk),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: dossierInk,
                fontFamily: 'LilitaOne',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: dossierInk,
                fontSize: 9,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
