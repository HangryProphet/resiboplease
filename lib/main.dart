import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/state/game_controller.dart';
import 'data/gallery/city_gallery_api_service.dart';
import 'data/gallery/city_gallery_cache.dart';
import 'data/gallery/city_gallery_repository.dart';
import 'data/gallery/community_auth_service.dart';
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
  final galleryConfig = CityGalleryApiConfig.fromEnvironment();
  CommunityAuthService communityAuth = const UnavailableCommunityAuthService();
  if (galleryConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: galleryConfig.projectUrl,
        publishableKey: galleryConfig.anonKey,
      );
      communityAuth = SupabaseCommunityAuthService(Supabase.instance.client);
    } catch (_) {
      communityAuth = const UnavailableCommunityAuthService();
    }
  }
  final galleryRepository = CityGalleryRepository(
    remote: CityGalleryApiService(config: galleryConfig, auth: communityAuth),
    cache: galleryCache,
    auth: communityAuth,
  );
  runApp(
    ResiboPleaseApp(
      gameController: gameController,
      settingsController: AppSettingsController(store: store),
      galleryRepository: galleryRepository,
    ),
  );
}
