import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/public_city_snapshot.dart';

abstract interface class CityGalleryCache {
  Future<List<PublicCitySnapshot>> read();
  Future<void> write(List<PublicCitySnapshot> snapshots);
}

class SharedPreferencesCityGalleryCache implements CityGalleryCache {
  SharedPreferencesCityGalleryCache._(this._preferences);

  static const cacheKey = 'city_gallery.cached_snapshots.v1';

  final SharedPreferencesWithCache _preferences;

  static Future<SharedPreferencesCityGalleryCache> create() async {
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {cacheKey},
      ),
    );
    return SharedPreferencesCityGalleryCache._(preferences);
  }

  @override
  Future<List<PublicCitySnapshot>> read() async {
    final source = _preferences.getString(cacheKey);
    if (source == null) return const [];
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List) return const [];
      return List.unmodifiable(
        decoded.map(
          (item) => PublicCitySnapshot.fromJson(
            (item as Map).map((key, value) => MapEntry(key.toString(), value)),
          ),
        ),
      );
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> write(List<PublicCitySnapshot> snapshots) =>
      _preferences.setString(
        cacheKey,
        jsonEncode(snapshots.map((snapshot) => snapshot.toJson()).toList()),
      );
}

class MemoryCityGalleryCache implements CityGalleryCache {
  MemoryCityGalleryCache([List<PublicCitySnapshot> initial = const []])
    : _snapshots = List.of(initial);

  List<PublicCitySnapshot> _snapshots;

  @override
  Future<List<PublicCitySnapshot>> read() async => List.of(_snapshots);

  @override
  Future<void> write(List<PublicCitySnapshot> snapshots) async {
    _snapshots = List.of(snapshots);
  }
}
