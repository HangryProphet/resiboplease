import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/audio/game_audio_service.dart';
import '../core/state/game_controller.dart';
import '../data/gallery/city_gallery_api_service.dart';
import '../data/gallery/city_gallery_cache.dart';
import '../data/gallery/city_gallery_repository.dart';
import '../data/gallery/community_auth_service.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/resibo_theme.dart';

class ResiboPleaseApp extends StatefulWidget {
  const ResiboPleaseApp({
    this.gameController,
    this.settingsController,
    this.galleryRepository,
    this.audioService,
    super.key,
  });

  final GameController? gameController;
  final AppSettingsController? settingsController;
  final CityGalleryRepository? galleryRepository;
  final GameAudioService? audioService;

  @override
  State<ResiboPleaseApp> createState() => _ResiboPleaseAppState();
}

class _ResiboPleaseAppState extends State<ResiboPleaseApp>
    with WidgetsBindingObserver {
  late final GameController _controller;
  late final bool _ownsGameController;
  late final AppSettingsController _settingsController;
  late final bool _ownsSettingsController;
  late final CityGalleryRepository _galleryRepository;
  late final bool _ownsGalleryRepository;
  late final GoRouter _router;
  late final GameAudioService _audioService;
  late final bool _ownsAudioService;

  @override
  void initState() {
    super.initState();
    _ownsGameController = widget.gameController == null;
    _controller = widget.gameController ?? GameController();
    _ownsSettingsController = widget.settingsController == null;
    _settingsController =
        widget.settingsController ??
        AppSettingsController(store: MemorySettingsStore());
    _ownsAudioService = widget.audioService == null;
    _audioService =
        widget.audioService ?? GameAudioService(_settingsController);
    _ownsGalleryRepository = widget.galleryRepository == null;
    _galleryRepository =
        widget.galleryRepository ?? _defaultGalleryRepository();
    _router = buildRouter(
      _controller,
      _settingsController,
      _galleryRepository,
      _audioService,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _audioService.resumeMusic();
      case AppLifecycleState.inactive ||
          AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        _audioService.pauseMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    if (_ownsGalleryRepository) _galleryRepository.close();
    if (_ownsGameController) _controller.dispose();
    if (_ownsAudioService) _audioService.dispose();
    if (_ownsSettingsController) _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _settingsController,
    builder: (context, _) => ProviderScope(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        locale: _settingsController.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildResiboTheme(highContrast: _settingsController.highContrast),
        highContrastTheme: buildResiboTheme(highContrast: true),
        routerConfig: _router,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              disableAnimations:
                  mediaQuery.disableAnimations ||
                  _settingsController.reduceMotion,
            ),
            child: GameAudioScope(
              audio: _audioService,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    ),
  );
}

CityGalleryRepository _defaultGalleryRepository() {
  const auth = UnavailableCommunityAuthService();
  return CityGalleryRepository(
    remote: CityGalleryApiService(
      config: CityGalleryApiConfig.fromEnvironment(),
      auth: auth,
    ),
    cache: MemoryCityGalleryCache(),
    auth: auth,
  );
}
