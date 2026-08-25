import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings/app_settings_controller.dart';

enum GameSound {
  uiTap('ui_tap.ogg'),
  uiBack('ui_back.ogg'),
  uiTab('ui_tab.ogg'),
  uiConfirm('ui_confirm.ogg'),
  uiError('ui_error.ogg'),
  documentOpen('document_open.ogg'),
  bookmark('bookmark.ogg'),
  notification('notification.ogg'),
  criticalAlert('critical_alert.ogg'),
  chatMessage('chat_message.ogg'),
  socialReaction('social_reaction.ogg'),
  receiptFound('receipt_found.ogg'),
  voteSelect('vote_select.ogg'),
  ballotDrop('ballot_drop.ogg'),
  positiveEvent('positive_event.ogg'),
  negativeEvent('negative_event.ogg');

  const GameSound(this.fileName);

  final String fileName;
  String get assetPath => 'audio/sfx/$fileName';
}

enum GameMusicContext { none, menu, investigation, simulation }

abstract interface class GameAudioBackend {
  Future<void> preloadSfx(Iterable<String> assetPaths);
  Future<void> playSfx(String assetPath, double volume);
  Future<void> playMusic(String assetPath, double volume);
  Future<void> setMusicVolume(double volume);
  Future<void> pauseMusic();
  Future<void> resumeMusic();
  Future<void> stopMusic();
  Future<void> dispose();
}

/// Audioplayers-backed output with a small reusable SFX voice pool.
///
/// Four voices permit short sounds to overlap without creating a new native
/// player for every tap. Assets are cached once and all playback failures are
/// contained by [GameAudioService].
class AudioplayersGameAudioBackend implements GameAudioBackend {
  AudioplayersGameAudioBackend({int sfxVoices = 4})
    : _sfxPlayers = List.generate(
        sfxVoices,
        (index) => AudioPlayer(playerId: 'resibo-sfx-$index'),
      ),
      _musicPlayer = AudioPlayer(playerId: 'resibo-music');

  final List<AudioPlayer> _sfxPlayers;
  final AudioPlayer _musicPlayer;
  static final AudioContext _sfxAudioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
  );
  static final AudioContext _musicAudioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );

  @visibleForTesting
  static AudioContext get sfxAudioContext => _sfxAudioContext;

  @visibleForTesting
  static AudioContext get musicAudioContext => _musicAudioContext;

  var _nextVoice = 0;
  bool _musicContextConfigured = false;
  bool _disposed = false;

  @override
  Future<void> preloadSfx(Iterable<String> assetPaths) async {
    await AudioCache.instance.loadAll(assetPaths.toList(growable: false));
    for (final player in _sfxPlayers) {
      await player.setPlayerMode(PlayerMode.lowLatency);
      // UI effects belong to the same game mix as the background track. They
      // must not request their own Android audio focus or they can pause the
      // music player permanently after an ordinary menu tap.
      await player.setAudioContext(_sfxAudioContext);
    }
  }

  @override
  Future<void> playSfx(String assetPath, double volume) async {
    if (_disposed) return;
    final player = _sfxPlayers[_nextVoice];
    _nextVoice = (_nextVoice + 1) % _sfxPlayers.length;
    await player.stop();
    await player.play(
      AssetSource(assetPath),
      volume: volume,
      mode: PlayerMode.lowLatency,
    );
  }

  @override
  Future<void> playMusic(String assetPath, double volume) async {
    if (_disposed) return;
    if (!_musicContextConfigured) {
      await _musicPlayer.setAudioContext(_musicAudioContext);
      _musicContextConfigured = true;
    }
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource(assetPath), volume: volume);
  }

  @override
  Future<void> setMusicVolume(double volume) => _musicPlayer.setVolume(volume);

  @override
  Future<void> pauseMusic() => _musicPlayer.pause();

  @override
  Future<void> resumeMusic() => _musicPlayer.resume();

  @override
  Future<void> stopMusic() => _musicPlayer.stop();

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await Future.wait([
      ..._sfxPlayers.map((player) => player.dispose()),
      _musicPlayer.dispose(),
    ]);
  }
}

/// Central release-safe audio coordinator for UI SFX and future music.
class GameAudioService {
  GameAudioService(this._settings, {GameAudioBackend? backend})
    : _backend = backend ?? AudioplayersGameAudioBackend() {
    _settings.addListener(_onSettingsChanged);
    _prepareFuture = _prepare();
  }

  static const _musicAssets = <GameMusicContext, String>{
    GameMusicContext.menu: 'audio/music/menu/menu_theme.ogg',
    GameMusicContext.investigation:
        'audio/music/investigation/investigation_theme.ogg',
    GameMusicContext.simulation: 'audio/music/simulation/simulation_theme.ogg',
  };

  final AppSettingsController _settings;
  final GameAudioBackend _backend;
  final Map<GameSound, DateTime> _lastPlayed = {};
  final Set<String> _missingMusicAssets = {};
  late final Future<void> _prepareFuture;
  GameMusicContext _musicContext = GameMusicContext.none;
  bool _musicPlaying = false;
  bool _musicPaused = false;
  bool _musicDucked = false;
  bool _disposed = false;
  int _transitionToken = 0;

  GameMusicContext get musicContext => _musicContext;
  bool get musicDucked => _musicDucked;

  Future<void> _prepare() async {
    try {
      await _backend.preloadSfx(
        GameSound.values.map((sound) => sound.assetPath),
      );
    } catch (error) {
      if (kDebugMode) debugPrint('[GameAudio] SFX preload unavailable: $error');
    }
  }

  void play(GameSound sound) {
    if (_disposed || !_settings.soundEffects || _settings.sfxVolume <= 0) {
      return;
    }
    final now = DateTime.now();
    final previous = _lastPlayed[sound];
    if (previous != null && now.difference(previous).inMilliseconds < 55) {
      return;
    }
    _lastPlayed[sound] = now;
    unawaited(_play(sound));
  }

  Future<void> _play(GameSound sound) async {
    try {
      await _prepareFuture;
      if (_disposed || !_settings.soundEffects) return;
      await _backend.playSfx(sound.assetPath, _settings.sfxVolume);
    } catch (error) {
      if (kDebugMode) debugPrint('[GameAudio] SFX unavailable: $error');
    }
  }

  void setMusicContext(GameMusicContext context) {
    if (_disposed || _musicContext == context) return;
    _musicContext = context;
    unawaited(_transitionMusic());
  }

  Future<void> _transitionMusic() async {
    final token = ++_transitionToken;
    if (!_settings.music || _musicContext == GameMusicContext.none) {
      await _fadeOutAndStop(token);
      return;
    }
    final assetPath = _musicAssets[_musicContext];
    if (assetPath == null || _missingMusicAssets.contains(assetPath)) {
      await _fadeOutAndStop(token);
      return;
    }
    try {
      await rootBundle.load('assets/$assetPath');
    } catch (_) {
      _missingMusicAssets.add(assetPath);
      await _fadeOutAndStop(token);
      return;
    }
    await _fadeOutAndStop(token);
    if (_disposed || token != _transitionToken || !_settings.music) return;
    try {
      await _backend.playMusic(assetPath, 0);
      _musicPlaying = true;
      _musicPaused = false;
      await _fadeTo(_effectiveMusicVolume, token);
    } catch (error) {
      _musicPlaying = false;
      if (kDebugMode) debugPrint('[GameAudio] Music unavailable: $error');
    }
  }

  void setMusicDucked(bool value) {
    if (_disposed || _musicDucked == value) return;
    _musicDucked = value;
    if (_musicPlaying) unawaited(_setMusicVolume(_effectiveMusicVolume));
  }

  void pauseMusic() {
    if (_disposed || !_musicPlaying || _musicPaused) return;
    _musicPaused = true;
    unawaited(_backend.pauseMusic().catchError((_) {}));
  }

  void resumeMusic() {
    if (_disposed || !_musicPlaying || !_musicPaused || !_settings.music) {
      return;
    }
    _musicPaused = false;
    unawaited(_backend.resumeMusic().catchError((_) {}));
  }

  double get _effectiveMusicVolume =>
      _settings.musicVolume * (_musicDucked ? .28 : 1);

  Future<void> _fadeOutAndStop(int token) async {
    if (!_musicPlaying) return;
    await _fadeTo(0, token);
    if (_disposed || token != _transitionToken) return;
    try {
      await _backend.stopMusic();
    } catch (_) {}
    _musicPlaying = false;
    _musicPaused = false;
  }

  Future<void> _fadeTo(double target, int token) async {
    const steps = 6;
    final start = target == 0 ? _effectiveMusicVolume : 0.0;
    for (var step = 1; step <= steps; step++) {
      if (_disposed || token != _transitionToken) return;
      final volume = start + (target - start) * step / steps;
      await _setMusicVolume(volume);
      await Future<void>.delayed(const Duration(milliseconds: 35));
    }
  }

  Future<void> _setMusicVolume(double volume) async {
    try {
      await _backend.setMusicVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  void _onSettingsChanged() {
    if (_disposed) return;
    if (!_settings.music) {
      unawaited(_transitionMusic());
    } else if (_musicPlaying) {
      unawaited(_setMusicVolume(_effectiveMusicVolume));
    } else if (_musicContext != GameMusicContext.none) {
      _missingMusicAssets.remove(_musicAssets[_musicContext]);
      unawaited(_transitionMusic());
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _settings.removeListener(_onSettingsChanged);
    _transitionToken++;
    unawaited(_backend.dispose().catchError((_) {}));
  }
}

class GameAudioScope extends InheritedWidget {
  const GameAudioScope({required this.audio, required super.child, super.key});

  final GameAudioService audio;

  static GameAudioService? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameAudioScope>()?.audio;

  @override
  bool updateShouldNotify(GameAudioScope oldWidget) => audio != oldWidget.audio;
}

class MusicContextHost extends StatefulWidget {
  const MusicContextHost({
    required this.audio,
    required this.musicContext,
    required this.child,
    super.key,
  });

  final GameAudioService audio;
  final GameMusicContext musicContext;
  final Widget child;

  @override
  State<MusicContextHost> createState() => _MusicContextHostState();
}

class _MusicContextHostState extends State<MusicContextHost> {
  @override
  void initState() {
    super.initState();
    widget.audio.setMusicContext(widget.musicContext);
  }

  @override
  void didUpdateWidget(MusicContextHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio != widget.audio ||
        oldWidget.musicContext != widget.musicContext) {
      widget.audio.setMusicContext(widget.musicContext);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
