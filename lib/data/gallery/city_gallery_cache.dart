import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/player_profile.dart';
import '../../domain/models/public_city_snapshot.dart';

abstract interface class CityGalleryCache {
  Future<List<PublicCitySnapshot>> readPublic();
  Future<void> writePublic(List<PublicCitySnapshot> snapshots);
  Future<List<PublicCitySnapshot>> readOwn();
  Future<void> writeOwn(List<PublicCitySnapshot> snapshots);
  Future<PlayerProfile?> readProfile();
  Future<void> writeProfile(PlayerProfile profile);
}

class SharedPreferencesCityGalleryCache implements CityGalleryCache {
  SharedPreferencesCityGalleryCache._(this._preferences);

  static const publicCacheKey = 'city_gallery.cached_public.v2';
  static const ownCacheKey = 'city_gallery.cached_own.v2';
  static const profileCacheKey = 'city_gallery.cached_profile.v2';

  final SharedPreferencesWithCache _preferences;

  static Future<SharedPreferencesCityGalleryCache> create() async {
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {publicCacheKey, ownCacheKey, profileCacheKey},
      ),
    );
    return SharedPreferencesCityGalleryCache._(preferences);
  }

  @override
  Future<List<PublicCitySnapshot>> readPublic() =>
      _readSnapshots(publicCacheKey);

  @override
  Future<void> writePublic(List<PublicCitySnapshot> snapshots) =>
      _writeSnapshots(publicCacheKey, snapshots);

  @override
  Future<List<PublicCitySnapshot>> readOwn() => _readSnapshots(ownCacheKey);

  @override
  Future<void> writeOwn(List<PublicCitySnapshot> snapshots) =>
      _writeSnapshots(ownCacheKey, snapshots);

  Future<List<PublicCitySnapshot>> _readSnapshots(String key) async {
    final source = _preferences.getString(key);
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

  Future<void> _writeSnapshots(
    String key,
    List<PublicCitySnapshot> snapshots,
  ) => _preferences.setString(
    key,
    jsonEncode(snapshots.map((snapshot) => snapshot.toJson()).toList()),
  );

  @override
  Future<PlayerProfile?> readProfile() async {
    final source = _preferences.getString(profileCacheKey);
    if (source == null) return null;
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) return null;
      return PlayerProfile.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeProfile(PlayerProfile profile) => _preferences.setString(
    profileCacheKey,
    jsonEncode({
      'user_id': profile.userId,
      'display_name': profile.displayName,
      'created_at': profile.createdAt.toIso8601String(),
      'updated_at': profile.updatedAt.toIso8601String(),
    }),
  );
}

class MemoryCityGalleryCache implements CityGalleryCache {
  MemoryCityGalleryCache({
    List<PublicCitySnapshot> publicSnapshots = const [],
    List<PublicCitySnapshot> ownSnapshots = const [],
    PlayerProfile? profile,
  }) : _publicSnapshots = List.of(publicSnapshots),
       _ownSnapshots = List.of(ownSnapshots),
       // ignore: prefer_initializing_formals
       _profile = profile;

  List<PublicCitySnapshot> _publicSnapshots;
  List<PublicCitySnapshot> _ownSnapshots;
  PlayerProfile? _profile;

  @override
  Future<List<PublicCitySnapshot>> readPublic() async =>
      List.of(_publicSnapshots);

  @override
  Future<void> writePublic(List<PublicCitySnapshot> snapshots) async {
    _publicSnapshots = List.of(snapshots);
  }

  @override
  Future<List<PublicCitySnapshot>> readOwn() async => List.of(_ownSnapshots);

  @override
  Future<void> writeOwn(List<PublicCitySnapshot> snapshots) async {
    _ownSnapshots = List.of(snapshots);
  }

  @override
  Future<PlayerProfile?> readProfile() async => _profile;

  @override
  Future<void> writeProfile(PlayerProfile profile) async {
    _profile = profile;
  }
}
