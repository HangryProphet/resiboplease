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

abstract interface class AppSettingsStore {
  String? readString(String key);
  bool? readBool(String key);
  Future<void> writeString(String key, String value);
  Future<void> writeBool(String key, bool value);
  Future<void> remove(String key);
}

class SharedPreferencesSettingsStore implements AppSettingsStore {
  SharedPreferencesSettingsStore._(this._preferences);

  static const _allowedKeys = <String>{
    AppSettingsController.languageKey,
    AppSettingsController.reduceMotionKey,
    AppSettingsController.highContrastKey,
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
  Future<void> writeString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> writeBool(String key, bool value) =>
      _preferences.setBool(key, value);

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
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> writeBool(String key, bool value) async {
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
  }

  static const languageKey = 'settings.language';
  static const reduceMotionKey = 'settings.reduce_motion';
  static const highContrastKey = 'settings.high_contrast';

  final AppSettingsStore _store;
  late AppLanguage _language;
  late bool _reduceMotion;
  late bool _highContrast;

  AppLanguage get language => _language;
  Locale? get locale => _language.locale;
  bool get reduceMotion => _reduceMotion;
  bool get highContrast => _highContrast;

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

  Future<void> reset() async {
    _language = AppLanguage.system;
    _reduceMotion = false;
    _highContrast = false;
    notifyListeners();
    await Future.wait([
      _store.remove(languageKey),
      _store.remove(reduceMotionKey),
      _store.remove(highContrastKey),
    ]);
  }
}
