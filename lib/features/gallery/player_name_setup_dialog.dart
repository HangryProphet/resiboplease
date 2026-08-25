import 'package:flutter/material.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/audio/game_audio_service.dart';
import '../../data/gallery/city_gallery_api_service.dart';
import '../../data/gallery/city_gallery_repository.dart';
import '../../domain/models/player_profile.dart';
import '../dossier/widgets/dossier_ui.dart';

Future<PlayerProfile?> showPlayerNameSetupDialog(
  BuildContext context,
  CityGalleryRepository repository,
) => showDialog<PlayerProfile>(
  context: context,
  barrierDismissible: false,
  builder: (context) => _PlayerNameSetupDialog(repository: repository),
);

class _PlayerNameSetupDialog extends StatefulWidget {
  const _PlayerNameSetupDialog({required this.repository});

  final CityGalleryRepository repository;

  @override
  State<_PlayerNameSetupDialog> createState() => _PlayerNameSetupDialogState();
}

class _PlayerNameSetupDialogState extends State<_PlayerNameSetupDialog> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_saving) return;
    try {
      validatePlayerDisplayName(_controller.text);
    } on FormatException {
      setState(() {
        _error = 'Use 3–24 letters, numbers, spaces, or underscores.';
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final profile = await widget.repository.createProfile(_controller.text);
      if (mounted) Navigator.pop(context, profile);
    } on CityGalleryApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (error.failure) {
          CityGalleryFailure.duplicateName =>
            'That name is already being used. Try another.',
          CityGalleryFailure.notConfigured =>
            'Community sharing has not been connected yet.',
          CityGalleryFailure.authentication =>
            'Could not create your community identity. Please try again.',
          _ => 'A connection is required to save your player name.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'A connection is required to save your player name.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    key: const Key('player_name_setup_dialog'),
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(18),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 470),
      child: PaperPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionLabel(
              label: 'Choose a Player Name',
              icon: Icons.badge_rounded,
              color: ResiboColors.teal,
            ),
            const SizedBox(height: 10),
            const Text(
              'This name is only used when sharing and viewing public cities.',
              style: TextStyle(color: dossierInk, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('player_name_input'),
              controller: _controller,
              enabled: !_saving,
              autofocus: true,
              maxLength: 24,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _continue(),
              decoration: InputDecoration(
                labelText: 'Player Name',
                errorText: _error,
                filled: true,
                fillColor: const Color(0xFFFFF0C9),
                labelStyle: const TextStyle(
                  color: ResiboColors.navy,
                  fontFamily: 'LilitaOne',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: dossierInk, width: 2.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ResiboColors.teal,
                    width: 3,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ResiboColors.mutedRed,
                    width: 2.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ResiboColors.mutedRed,
                    width: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 9,
              runSpacing: 9,
              children: [
                ChunkyActionButton(
                  buttonKey: const Key('cancel_player_name'),
                  label: 'Back',
                  compact: true,
                  color: ResiboColors.navy,
                  sound: GameSound.uiBack,
                  onPressed: _saving ? null : () => Navigator.pop(context),
                ),
                ChunkyActionButton(
                  buttonKey: const Key('save_player_name'),
                  label: _saving ? 'Saving...' : 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  compact: true,
                  color: ResiboColors.teal,
                  sound: GameSound.uiConfirm,
                  onPressed: _saving ? null : _continue,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
