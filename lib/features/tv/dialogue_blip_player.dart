import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

abstract interface class DialogueBlipPlayer {
  void playBlip();
  void stop();
  void dispose();
}

class AssetDialogueBlipPlayer implements DialogueBlipPlayer {
  AssetDialogueBlipPlayer({AudioPlayer? player})
    : _player = player ?? AudioPlayer(playerId: 'reporter-r8-dialogue') {
    _prepareFuture = _prepare();
  }

  static const assetPath = 'audio/dialogue/reporter_robot_blip.wav';

  final AudioPlayer _player;
  late final Future<void> _prepareFuture;
  bool _busy = false;
  bool _disposed = false;

  Future<void> _prepare() async {
    try {
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setVolume(.46);
      await _player.setSource(AssetSource(assetPath));
    } catch (_) {
      // Playback is retried after a user gesture. Browsers may reject the
      // automatic first attempt even when the bundled asset is valid.
    }
  }

  @override
  void playBlip() {
    if (_busy || _disposed) return;
    _busy = true;
    unawaited(_play());
  }

  Future<void> _play() async {
    try {
      await _prepareFuture;
      await _player.stop();
      await _player.resume();
    } catch (_) {
      // Missing, unsupported, or autoplay-blocked audio must never break the
      // report. Do not permanently disable retries: the next player gesture
      // may be the browser permission needed to unlock playback.
    } finally {
      _busy = false;
    }
  }

  @override
  void stop() {
    if (_disposed) return;
    unawaited(_player.stop().catchError((_) {}));
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_player.dispose().catchError((_) {}));
  }
}

class SilentDialogueBlipPlayer implements DialogueBlipPlayer {
  const SilentDialogueBlipPlayer();

  @override
  void dispose() {}

  @override
  void playBlip() {}

  @override
  void stop() {}
}
