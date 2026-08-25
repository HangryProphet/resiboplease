import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  system,
  english,
  filipino;

  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.filipino => const Locale('fil'),
  };
}

enum AppContrast { standard, high }

enum CriticalEventInterruption {
  autoOpen,
  pauseAndNotify,
  notifyOnly,
  neverInterrupt;

  bool get pausesSimulation =>
      this == CriticalEventInterruption.autoOpen ||
      this == CriticalEventInterruption.pauseAndNotify;

  bool get opensEvent => this == CriticalEventInterruption.autoOpen;

  bool get showsNotification =>
      this != CriticalEventInterruption.neverInterrupt;
}

abstract interface class AppSettingsStore {
  String? readString(String key);
  bool? readBool(String key);
  double? readDouble(String key);
  Future<void> writeString(String key, String value);
  Future<void> writeBool(String key, bool value);
  Future<void> writeDouble(String key, double value);
  Future<void> remove(String key);
}

class SharedPreferencesSettingsStore implements AppSettingsStore {
  SharedPreferencesSettingsStore._(this._preferences);

  static const _allowedKeys = <String>{
    AppSettingsController.languageKey,
    AppSettingsController.reduceMotionKey,
    AppSettingsController.highContrastKey,
    AppSettingsController.dialogueSoundsKey,
    AppSettingsController.soundEffectsKey,
    AppSettingsController.musicKey,
    AppSettingsController.sfxVolumeKey,
    AppSettingsController.musicVolumeKey,
    AppSettingsController.criticalEventInterruptionKey,
    AppSettingsController.legacySimulationAutoPauseKey,
  };

  final SharedPreferencesWithCache _preferences;

  static Future<SharedPreferencesSettingsStore> create() async {
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: _allowedKeys,
      ),
    );
    return SharedPreferencesSettingsStore._(preferences);
  }

  @override
  String? readString(String key) => _preferences.getString(key);

  @override
  bool? readBool(String key) => _preferences.getBool(key);

  @override
  double? readDouble(String key) => _preferences.getDouble(key);

  @override
  Future<void> writeString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> writeBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  Future<void> writeDouble(String key, double value) =>
      _preferences.setDouble(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

class MemorySettingsStore implements AppSettingsStore {
  MemorySettingsStore([Map<String, Object>? values]) : _values = {...?values};

  final Map<String, Object> _values;

  @override
  String? readString(String key) => _values[key] as String?;

  @override
  bool? readBool(String key) => _values[key] as bool?;

  @override
  double? readDouble(String key) => (_values[key] as num?)?.toDouble();

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> writeDouble(String key, double value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({required AppSettingsStore store}) : this._(store);

  AppSettingsController._(this._store) {
    _language = AppLanguage.values.firstWhere(
      (value) => value.name == _store.readString(languageKey),
      orElse: () => AppLanguage.system,
    );
    _reduceMotion = _store.readBool(reduceMotionKey) ?? false;
    _highContrast = _store.readBool(highContrastKey) ?? false;
    _dialogueSounds = _store.readBool(dialogueSoundsKey) ?? true;
    _soundEffects = _store.readBool(soundEffectsKey) ?? true;
    _music = _store.readBool(musicKey) ?? true;
    _sfxVolume = (_store.readDouble(sfxVolumeKey) ?? .55)
        .clamp(0.0, 1.0)
        .toDouble();
    _musicVolume = (_store.readDouble(musicVolumeKey) ?? .42)
        .clamp(0.0, 1.0)
        .toDouble();
    final savedInterruption = _store.readString(criticalEventInterruptionKey);
    _criticalEventInterruption = CriticalEventInterruption.values.firstWhere(
      (value) => value.name == savedInterruption,
      orElse: () => switch (_store.readString(legacySimulationAutoPauseKey)) {
        'never' => CriticalEventInterruption.notifyOnly,
        _ => CriticalEventInterruption.pauseAndNotify,
      },
    );
  }

  static const languageKey = 'settings.language';
  static const reduceMotionKey = 'settings.reduce_motion';
  static const highContrastKey = 'settings.high_contrast';
  static const dialogueSoundsKey = 'settings.dialogue_sounds';
  static const soundEffectsKey = 'settings.sound_effects';
  static const musicKey = 'settings.music';
  static const sfxVolumeKey = 'settings.sfx_volume';
  static const musicVolumeKey = 'settings.music_volume';
  static const criticalEventInterruptionKey =
      'settings.critical_event_interruption';
  static const legacySimulationAutoPauseKey = 'settings.simulation_auto_pause';

  final AppSettingsStore _store;
  late AppLanguage _language;
  late bool _reduceMotion;
  late bool _highContrast;
  late bool _dialogueSounds;
  late bool _soundEffects;
  late bool _music;
  late double _sfxVolume;
  late double _musicVolume;
  late CriticalEventInterruption _criticalEventInterruption;

  AppLanguage get language => _language;
  Locale? get locale => _language.locale;
  bool get reduceMotion => _reduceMotion;
  bool get highContrast => _highContrast;
  bool get dialogueSounds => _dialogueSounds;
  bool get soundEffects => _soundEffects;
  bool get music => _music;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;
  CriticalEventInterruption get criticalEventInterruption =>
      _criticalEventInterruption;

  Future<void> setLanguage(AppLanguage value) async {
    if (_language == value) return;
    _language = value;
    notifyListeners();
    await _store.writeString(languageKey, value.name);
  }

  Future<void> setReduceMotion(bool value) async {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    notifyListeners();
    await _store.writeBool(reduceMotionKey, value);
  }

  Future<void> setHighContrast(bool value) async {
    if (_highContrast == value) return;
    _highContrast = value;
    notifyListeners();
    await _store.writeBool(highContrastKey, value);
  }

  Future<void> setDialogueSounds(bool value) async {
    if (_dialogueSounds == value) return;
    _dialogueSounds = value;
    notifyListeners();
    await _store.writeBool(dialogueSoundsKey, value);
  }

  Future<void> setSoundEffects(bool value) async {
    if (_soundEffects == value) return;
    _soundEffects = value;
    notifyListeners();
    await _store.writeBool(soundEffectsKey, value);
  }

  Future<void> setMusic(bool value) async {
    if (_music == value) return;
    _music = value;
    notifyListeners();
    await _store.writeBool(musicKey, value);
  }

  Future<void> setSfxVolume(double value) async {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    if (_sfxVolume == normalized) return;
    _sfxVolume = normalized;
    notifyListeners();
    await _store.writeDouble(sfxVolumeKey, normalized);
  }

  Future<void> setMusicVolume(double value) async {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    if (_musicVolume == normalized) return;
    _musicVolume = normalized;
    notifyListeners();
    await _store.writeDouble(musicVolumeKey, normalized);
  }

  Future<void> setCriticalEventInterruption(
    CriticalEventInterruption value,
  ) async {
    if (_criticalEventInterruption == value) return;
    _criticalEventInterruption = value;
    notifyListeners();
    await Future.wait([
      _store.writeString(criticalEventInterruptionKey, value.name),
      _store.remove(legacySimulationAutoPauseKey),
    ]);
  }

  Future<void> reset() async {
    _language = AppLanguage.system;
    _reduceMotion = false;
    _highContrast = false;
    _dialogueSounds = true;
    _soundEffects = true;
    _music = true;
    _sfxVolume = .55;
    _musicVolume = .42;
    _criticalEventInterruption = CriticalEventInterruption.pauseAndNotify;
    notifyListeners();
    await Future.wait([
      _store.remove(languageKey),
      _store.remove(reduceMotionKey),
      _store.remove(highContrastKey),
      _store.remove(dialogueSoundsKey),
      _store.remove(soundEffectsKey),
      _store.remove(musicKey),
      _store.remove(sfxVolumeKey),
      _store.remove(musicVolumeKey),
      _store.remove(criticalEventInterruptionKey),
      _store.remove(legacySimulationAutoPauseKey),
    ]);
  }
}
