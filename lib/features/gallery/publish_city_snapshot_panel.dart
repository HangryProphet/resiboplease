import 'package:flutter/material.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../data/gallery/city_gallery_api_service.dart';
import '../../data/gallery/city_gallery_repository.dart';
import '../../domain/models/public_city_snapshot.dart';
import '../../l10n/city_gallery_localizations.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';

enum _PublishState { ready, publishing, published, failed }

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

  Future<void> _publish() async {
    if (_state == _PublishState.publishing) return;
    final result = widget.controller.termResult;
    final configuration = widget.controller.activeConfiguration;
    if (result == null || configuration == null) return;
    final strings = context.galleryStrings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.public_rounded,
          color: ResiboColors.teal,
          size: 36,
        ),
        title: Text(strings.publishTitle),
        content: Text(strings.publishExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton.icon(
            key: const Key('confirm_publish_city_snapshot'),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.cloud_upload_rounded),
            label: Text(strings.confirmPublish),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _state = _PublishState.publishing);
    final snapshot = buildPublicCitySnapshot(
      city: widget.controller.scenario.city,
      configuration: configuration,
      result: result,
      topIssueId: widget.controller.topIssue,
    );
    try {
      await widget.repository.publishSnapshot(snapshot);
      if (mounted) setState(() => _state = _PublishState.published);
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
      _PublishState.published => strings.publishSuccess,
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
