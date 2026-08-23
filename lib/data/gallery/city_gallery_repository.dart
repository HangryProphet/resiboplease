import '../../domain/models/public_city_snapshot.dart';
import 'city_gallery_api_service.dart';
import 'city_gallery_cache.dart';

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
  CityGalleryRepository({required this.remote, required this.cache});

  final CityGalleryRemoteDataSource remote;
  final CityGalleryCache cache;
  List<PublicCitySnapshot> _snapshots = const [];

  List<PublicCitySnapshot> get currentSnapshots => _snapshots;

  Future<CityGalleryLoadResult> fetchSnapshots() async {
    try {
      final live = await remote.fetchSnapshots();
      _snapshots = _newestFirst(live);
      await cache.write(_snapshots);
      return CityGalleryLoadResult(snapshots: _snapshots, fromCache: false);
    } on CityGalleryApiException catch (error) {
      if (error.failure == CityGalleryFailure.invalidResponse ||
          error.failure == CityGalleryFailure.notConfigured) {
        rethrow;
      }
      final saved = _newestFirst(await cache.read());
      if (saved.isEmpty) rethrow;
      _snapshots = saved;
      return CityGalleryLoadResult(
        snapshots: saved,
        fromCache: true,
        liveFailure: error.failure,
      );
    }
  }

  Future<PublicCitySnapshot> publishSnapshot(
    PublicCitySnapshot snapshot,
  ) async {
    final published = await remote.publishSnapshot(snapshot);
    _snapshots = _newestFirst([
      published,
      ..._snapshots.where((item) => item.id != published.id),
    ]);
    await cache.write(_snapshots);
    return published;
  }

  PublicCitySnapshot? findById(String id) =>
      _snapshots.where((snapshot) => snapshot.id == id).firstOrNull;

  void close() => remote.close();
}

List<PublicCitySnapshot> _newestFirst(Iterable<PublicCitySnapshot> snapshots) {
  final sorted = snapshots.toList(growable: false)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return List.unmodifiable(sorted.take(50));
}
