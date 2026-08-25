import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:resiboplease/core/audio/game_audio_service.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Android game mix prevents menu SFX from stealing music focus', () {
    final sfx = AudioplayersGameAudioBackend.sfxAudioContext.android;
    final music = AudioplayersGameAudioBackend.musicAudioContext.android;

    expect(sfx.contentType, AndroidContentType.sonification);
    expect(sfx.usageType, AndroidUsageType.game);
    expect(sfx.audioFocus, AndroidAudioFocus.none);
    expect(music.contentType, AndroidContentType.music);
    expect(music.usageType, AndroidUsageType.game);
    expect(music.audioFocus, AndroidAudioFocus.gain);
  });

  test('every mapped release SFX asset is bundled', () async {
    for (final sound in GameSound.values) {
      final data = await rootBundle.load('assets/${sound.assetPath}');
      expect(data.lengthInBytes, greaterThan(0), reason: sound.assetPath);
    }
  });

  test(
    'SFX use one centralized backend and respect persisted settings',
    () async {
      final settings = AppSettingsController(store: MemorySettingsStore());
      final backend = _RecordingAudioBackend();
      final audio = GameAudioService(settings, backend: backend);
      addTearDown(() {
        audio.dispose();
        settings.dispose();
      });

      audio.play(GameSound.uiTap);
      await _flushAudio();
      expect(backend.preloaded, contains(GameSound.uiTap.assetPath));
      expect(backend.playedSfx, [GameSound.uiTap.assetPath]);
      expect(backend.sfxVolumes.single, closeTo(.55, .001));

      await settings.setSoundEffects(false);
      audio.play(GameSound.uiConfirm);
      await _flushAudio();
      expect(backend.playedSfx, hasLength(1));

      await settings.setSoundEffects(true);
      await settings.setSfxVolume(.2);
      audio.play(GameSound.uiConfirm);
      await _flushAudio();
      expect(backend.playedSfx.last, GameSound.uiConfirm.assetPath);
      expect(backend.sfxVolumes.last, closeTo(.2, .001));
    },
  );

  test(
    'optional music plays when present, fails safely when absent, and ducks',
    () async {
      final settings = AppSettingsController(store: MemorySettingsStore());
      final backend = _RecordingAudioBackend();
      final audio = GameAudioService(settings, backend: backend);
      addTearDown(() {
        audio.dispose();
        settings.dispose();
      });

      audio.setMusicContext(GameMusicContext.investigation);
      audio.setMusicDucked(true);
      await _flushAudio();

      expect(audio.musicContext, GameMusicContext.investigation);
      expect(audio.musicDucked, isTrue);
      var bundled = true;
      try {
        await rootBundle.load(
          'assets/audio/music/investigation/investigation_theme.ogg',
        );
      } catch (_) {
        bundled = false;
      }
      expect(
        backend.playedMusic,
        bundled
            ? ['audio/music/investigation/investigation_theme.ogg']
            : isEmpty,
      );
    },
  );
}

Future<void> _flushAudio() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

class _RecordingAudioBackend implements GameAudioBackend {
  final List<String> preloaded = [];
  final List<String> playedSfx = [];
  final List<double> sfxVolumes = [];
  final List<String> playedMusic = [];

  @override
  Future<void> preloadSfx(Iterable<String> assetPaths) async {
    preloaded.addAll(assetPaths);
  }

  @override
  Future<void> playSfx(String assetPath, double volume) async {
    playedSfx.add(assetPath);
    sfxVolumes.add(volume);
  }

  @override
  Future<void> playMusic(String assetPath, double volume) async {
    playedMusic.add(assetPath);
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> pauseMusic() async {}

  @override
  Future<void> resumeMusic() async {}

  @override
  Future<void> setMusicVolume(double volume) async {}

  @override
  Future<void> stopMusic() async {}
}
