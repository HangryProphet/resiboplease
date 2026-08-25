import '../../domain/models/player_profile.dart';
import '../../domain/models/public_city_snapshot.dart';
import 'city_gallery_api_service.dart';
import 'city_gallery_cache.dart';
import 'community_auth_service.dart';

class CityGalleryLoadResult {
  const CityGalleryLoadResult({
    required this.snapshots,
    required this.fromCache,
    this.liveFailure,
  });

  final List<PublicCitySnapshot> snapshots;
  final bool fromCache;
  final CityGalleryFailure? liveFailure;
}

class CityGalleryRepository {
  CityGalleryRepository({
    required this.remote,
    required this.cache,
    required this.auth,
  });

  final CityGalleryRemoteDataSource remote;
  final CityGalleryCache cache;
  final CommunityAuthService auth;

  List<PublicCitySnapshot> _publicSnapshots = const [];
  List<PublicCitySnapshot> _ownSnapshots = const [];
  final Map<String, List<PublicCitySnapshot>> _playerSnapshots = {};
  final Map<String, PlayerProfile> _profiles = {};
  PlayerProfile? _currentProfile;

  PlayerProfile? get currentProfile => _currentProfile;
  List<PublicCitySnapshot> get currentSnapshots => _publicSnapshots;
  List<PublicCitySnapshot> get currentOwnSnapshots => _ownSnapshots;

  Future<PlayerProfile?> restoreProfile() async {
    final userId = await auth.restoreUserId();
    if (userId == null) return null;
    try {
      final profile = await remote.fetchProfile(userId);
      if (profile != null) await _rememberProfile(profile);
      return profile;
    } on CityGalleryApiException catch (error) {
      if (error.failure == CityGalleryFailure.notConfigured ||
          error.failure == CityGalleryFailure.invalidResponse ||
          error.failure == CityGalleryFailure.authentication) {
        rethrow;
      }
      final cached = await cache.readProfile();
      if (cached?.userId != userId) rethrow;
      _currentProfile = cached;
      _profiles[cached!.userId] = cached;
      return cached;
    }
  }

  Future<PlayerProfile> createProfile(String displayName) async {
    await auth.ensureAnonymousUser();
    final profile = await remote.createProfile(displayName);
    await _rememberProfile(profile);
    return profile;
  }

  Future<void> _rememberProfile(PlayerProfile profile) async {
    _currentProfile = profile;
    _profiles[profile.userId] = profile;
    await cache.writeProfile(profile);
  }

  Future<CityGalleryLoadResult> fetchSnapshots() => fetchPublicSnapshots();

  Future<CityGalleryLoadResult> fetchPublicSnapshots() async {
    try {
      final live = await remote.fetchPublicSnapshots();
      _publicSnapshots = _newestFirst(live);
      await cache.writePublic(_publicSnapshots);
      return CityGalleryLoadResult(
        snapshots: _publicSnapshots,
        fromCache: false,
      );
    } on CityGalleryApiException catch (error) {
      if (!_canUseCache(error.failure)) rethrow;
      final saved = _newestFirst(await cache.readPublic());
      if (saved.isEmpty) rethrow;
      _publicSnapshots = saved;
      return CityGalleryLoadResult(
        snapshots: saved,
        fromCache: true,
        liveFailure: error.failure,
      );
    }
  }

  Future<CityGalleryLoadResult> fetchOwnSnapshots() async {
    final profile = _currentProfile;
    if (profile == null) {
      throw const CityGalleryApiException(CityGalleryFailure.authentication);
    }
    try {
      final live = await remote.fetchOwnSnapshots(profile.userId);
      _ownSnapshots = _newestFirst(live);
      await cache.writeOwn(_ownSnapshots);
      return CityGalleryLoadResult(snapshots: _ownSnapshots, fromCache: false);
    } on CityGalleryApiException catch (error) {
      if (!_canUseCache(error.failure)) rethrow;
      final saved = _newestFirst(
        (await cache.readOwn()).where(
          (snapshot) => snapshot.ownerId == profile.userId,
        ),
      );
      if (saved.isEmpty) rethrow;
      _ownSnapshots = saved;
      return CityGalleryLoadResult(
        snapshots: saved,
        fromCache: true,
        liveFailure: error.failure,
      );
    }
  }

  Future<List<PlayerProfile>> searchProfiles(String query) async {
    final profiles = await remote.searchProfiles(query);
    for (final profile in profiles) {
      _profiles[profile.userId] = profile;
    }
    return profiles;
  }

  Future<List<PublicCitySnapshot>> fetchPlayerPublicCities(
    String userId,
  ) async {
    final snapshots = _newestFirst(
      await remote.fetchPublicSnapshots(ownerId: userId),
    );
    _playerSnapshots[userId] = snapshots;
    return snapshots;
  }

  PlayerProfile? findProfile(String userId) => _profiles[userId];

  List<PublicCitySnapshot> playerSnapshots(String userId) =>
      _playerSnapshots[userId] ?? const [];

  Future<PublicCitySnapshot> publishSnapshot(
    PublicCitySnapshot snapshot,
  ) async {
    if (_currentProfile == null) {
      throw const CityGalleryApiException(CityGalleryFailure.authentication);
    }
    final published = await remote.publishSnapshot(snapshot);
    _ownSnapshots = _replaceOrAdd(_ownSnapshots, published);
    await cache.writeOwn(_ownSnapshots);
    if (published.isPublic) {
      _publicSnapshots = _replaceOrAdd(_publicSnapshots, published);
      await cache.writePublic(_publicSnapshots);
    }
    return published;
  }

  Future<PublicCitySnapshot> setPrivacy(
    PublicCitySnapshot snapshot,
    bool isPublic,
  ) async {
    final updated = await remote.updateSnapshotPrivacy(snapshot, isPublic);
    _ownSnapshots = _replaceOrAdd(_ownSnapshots, updated);
    await cache.writeOwn(_ownSnapshots);
    if (updated.isPublic) {
      _publicSnapshots = _replaceOrAdd(_publicSnapshots, updated);
    } else {
      _publicSnapshots = _removeById(_publicSnapshots, updated.id);
    }
    await cache.writePublic(_publicSnapshots);
    return updated;
  }

  Future<void> deleteSnapshot(PublicCitySnapshot snapshot) async {
    await remote.deleteSnapshot(snapshot);
    _ownSnapshots = _removeById(_ownSnapshots, snapshot.id);
    _publicSnapshots = _removeById(_publicSnapshots, snapshot.id);
    await Future.wait([
      cache.writeOwn(_ownSnapshots),
      cache.writePublic(_publicSnapshots),
    ]);
  }

  PublicCitySnapshot? findById(String id) => [
    ..._ownSnapshots,
    ..._publicSnapshots,
    ..._playerSnapshots.values.expand((items) => items),
  ].where((snapshot) => snapshot.id == id).firstOrNull;

  void close() => remote.close();
}

bool _canUseCache(CityGalleryFailure failure) =>
    failure == CityGalleryFailure.network ||
    failure == CityGalleryFailure.server;

List<PublicCitySnapshot> _newestFirst(Iterable<PublicCitySnapshot> snapshots) {
  final sorted = snapshots.toList(growable: false)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return List.unmodifiable(sorted.take(50));
}

List<PublicCitySnapshot> _replaceOrAdd(
  List<PublicCitySnapshot> source,
  PublicCitySnapshot snapshot,
) =>
    _newestFirst([snapshot, ...source.where((item) => item.id != snapshot.id)]);

List<PublicCitySnapshot> _removeById(
  List<PublicCitySnapshot> source,
  String? id,
) => List.unmodifiable(source.where((item) => item.id != id));
