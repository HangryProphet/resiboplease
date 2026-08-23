import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/state/game_controller.dart';
import 'data/gallery/city_gallery_api_service.dart';
import 'data/gallery/city_gallery_cache.dart';
import 'data/gallery/city_gallery_repository.dart';
import 'data/persistence/run_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppSettingsStore store;
  try {
    store = await SharedPreferencesSettingsStore.create();
  } catch (_) {
    store = MemorySettingsStore();
  }
  RunRepository runRepository;
  try {
    runRepository = await SembastRunRepository.create();
  } catch (error) {
    runRepository = UnavailableRunRepository(error);
  }
  final gameController = GameController(repository: runRepository);
  await gameController.restore();
  CityGalleryCache galleryCache;
  try {
    galleryCache = await SharedPreferencesCityGalleryCache.create();
  } catch (_) {
    galleryCache = MemoryCityGalleryCache();
  }
  final galleryRepository = CityGalleryRepository(
    remote: CityGalleryApiService(
      config: CityGalleryApiConfig.fromEnvironment(),
    ),
    cache: galleryCache,
  );
  runApp(
    ResiboPleaseApp(
      gameController: gameController,
      settingsController: AppSettingsController(store: store),
      galleryRepository: galleryRepository,
    ),
  );
}
