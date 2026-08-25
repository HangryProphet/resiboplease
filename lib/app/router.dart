import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/audio/game_audio_service.dart';
import '../core/state/game_controller.dart';
import '../data/gallery/city_gallery_api_service.dart';
import '../data/gallery/city_gallery_cache.dart';
import '../data/gallery/city_gallery_repository.dart';
import '../data/gallery/community_auth_service.dart';
import '../features/city/city_chronicle_screen.dart';
import '../features/city/city_overview_screen.dart';
import '../features/candidate_hub/candidate_hub_screen.dart';
import '../features/candidate_hub/receipts_board_screen.dart';
import '../features/dossier/candidate_dossier_screen.dart';
import '../features/dossier/candidate_roster_screen.dart';
import '../features/election/election_screen.dart';
import '../features/gallery/visit_cities_screen.dart';
import '../features/home/home_screen.dart';
import '../features/information/citybook_profile_screen.dart';
import '../features/information/news_article_screen.dart';
import '../features/information/news_coverage_screen.dart';
import '../features/results/term_report_screen.dart';
import '../features/simulation/term_simulation_screen.dart';
import '../features/tv/tv_broadcast_screen.dart';
import '../l10n/l10n_extensions.dart';

GoRouter buildRouter(
  GameController controller, [
  AppSettingsController? settingsController,
  CityGalleryRepository? galleryRepository,
  GameAudioService? audioService,
]) {
  final effectiveSettings =
      settingsController ?? AppSettingsController(store: MemorySettingsStore());
  final effectiveGallery = galleryRepository ?? _defaultGalleryRepository();
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.menu,
          HomeScreen(
            controller: controller,
            settingsController: effectiveSettings,
          ),
        ),
      ),
      GoRoute(
        path: '/visit-cities',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.menu,
          VisitCitiesScreen(repository: effectiveGallery),
        ),
        routes: [
          GoRoute(
            path: 'player/:userId',
            builder: (context, state) => _musicHost(
              audioService,
              GameMusicContext.menu,
              PlayerPublicCitiesScreen(
                repository: effectiveGallery,
                userId: state.pathParameters['userId']!,
              ),
            ),
          ),
          GoRoute(
            path: ':snapshotId',
            builder: (context, state) => _musicHost(
              audioService,
              GameMusicContext.menu,
              CitySnapshotDetailScreen(
                repository: effectiveGallery,
                snapshotId: state.pathParameters['snapshotId']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/city',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.investigation,
          CityOverviewScreen(controller: controller),
        ),
      ),
      GoRoute(
        path: '/city/chronicle',
        builder: (context, state) => _musicHost(
          audioService,
          _informationMusicContext(controller),
          CityChronicleScreen(controller: controller),
        ),
      ),
      GoRoute(
        path: '/candidates',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.investigation,
          CandidateRosterScreen(controller: controller),
        ),
      ),
      GoRoute(
        path: '/candidates/:candidateId/dossier',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.investigation,
          CandidateDossierScreen(
            controller: controller,
            candidateId: state.pathParameters['candidateId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/candidates/:candidateId',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.investigation,
          CandidateHubScreen(
            controller: controller,
            candidateId: state.pathParameters['candidateId']!,
            initialSection: candidateHubSectionFromName(
              state.uri.queryParameters['section'],
            ),
            initialPromiseId: state.uri.queryParameters['promise'],
            initialHistoryId: state.uri.queryParameters['history'],
          ),
        ),
      ),
      GoRoute(
        path: '/receipts',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.investigation,
          ReceiptsBoardScreen(controller: controller),
        ),
      ),
      GoRoute(
        path: '/citybook/:candidateId',
        builder: (context, state) => _musicHost(
          audioService,
          _informationMusicContext(controller),
          CityBookProfileScreen(
            controller: controller,
            candidateId: state.pathParameters['candidateId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/news/event/:eventId',
        builder: (context, state) => _musicHost(
          audioService,
          _informationMusicContext(controller),
          NewsCoverageScreen(
            controller: controller,
            eventId: state.pathParameters['eventId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/news/:coverageId',
        builder: (context, state) => _musicHost(
          audioService,
          _informationMusicContext(controller),
          NewsArticleScreen(
            controller: controller,
            coverageId: state.pathParameters['coverageId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/tv/:broadcastId',
        builder: (context, state) => _musicHost(
          audioService,
          _informationMusicContext(controller),
          TvBroadcastScreen(
            controller: controller,
            settingsController: effectiveSettings,
            broadcastId: state.pathParameters['broadcastId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/vote',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.investigation,
          ElectionScreen(controller: controller),
        ),
      ),
      GoRoute(
        path: '/simulation',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.simulation,
          TermSimulationScreen(
            controller: controller,
            settingsController: effectiveSettings,
          ),
        ),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => _musicHost(
          audioService,
          GameMusicContext.simulation,
          TermReportScreen(
            controller: controller,
            galleryRepository: effectiveGallery,
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.caseFileMissing),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/'),
              child: Text(context.l10n.returnHome),
            ),
          ],
        ),
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

GameMusicContext _informationMusicContext(GameController controller) =>
    controller.termResult == null
    ? GameMusicContext.investigation
    : GameMusicContext.simulation;

Widget _musicHost(
  GameAudioService? audio,
  GameMusicContext context,
  Widget child,
) => audio == null
    ? child
    : MusicContextHost(audio: audio, musicContext: context, child: child);
