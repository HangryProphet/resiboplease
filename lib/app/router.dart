import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/state/game_controller.dart';
import '../data/gallery/city_gallery_api_service.dart';
import '../data/gallery/city_gallery_cache.dart';
import '../data/gallery/city_gallery_repository.dart';
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
]) {
  final effectiveSettings =
      settingsController ?? AppSettingsController(store: MemorySettingsStore());
  final effectiveGallery =
      galleryRepository ??
      CityGalleryRepository(
        remote: CityGalleryApiService(
          config: CityGalleryApiConfig.fromEnvironment(),
        ),
        cache: MemoryCityGalleryCache(),
      );
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(
          controller: controller,
          settingsController: effectiveSettings,
        ),
      ),
      GoRoute(
        path: '/visit-cities',
        builder: (context, state) =>
            VisitCitiesScreen(repository: effectiveGallery),
        routes: [
          GoRoute(
            path: ':snapshotId',
            builder: (context, state) => CitySnapshotDetailScreen(
              repository: effectiveGallery,
              snapshotId: state.pathParameters['snapshotId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/city',
        builder: (context, state) => CityOverviewScreen(controller: controller),
      ),
      GoRoute(
        path: '/city/chronicle',
        builder: (context, state) =>
            CityChronicleScreen(controller: controller),
      ),
      GoRoute(
        path: '/candidates',
        builder: (context, state) =>
            CandidateRosterScreen(controller: controller),
      ),
      GoRoute(
        path: '/candidates/:candidateId/dossier',
        builder: (context, state) => CandidateDossierScreen(
          controller: controller,
          candidateId: state.pathParameters['candidateId']!,
        ),
      ),
      GoRoute(
        path: '/candidates/:candidateId',
        builder: (context, state) => CandidateHubScreen(
          controller: controller,
          candidateId: state.pathParameters['candidateId']!,
          initialSection: candidateHubSectionFromName(
            state.uri.queryParameters['section'],
          ),
          initialPromiseId: state.uri.queryParameters['promise'],
          initialHistoryId: state.uri.queryParameters['history'],
        ),
      ),
      GoRoute(
        path: '/receipts',
        builder: (context, state) =>
            ReceiptsBoardScreen(controller: controller),
      ),
      GoRoute(
        path: '/citybook/:candidateId',
        builder: (context, state) => CityBookProfileScreen(
          controller: controller,
          candidateId: state.pathParameters['candidateId']!,
        ),
      ),
      GoRoute(
        path: '/news/event/:eventId',
        builder: (context, state) => NewsCoverageScreen(
          controller: controller,
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/news/:coverageId',
        builder: (context, state) => NewsArticleScreen(
          controller: controller,
          coverageId: state.pathParameters['coverageId']!,
        ),
      ),
      GoRoute(
        path: '/tv/:broadcastId',
        builder: (context, state) => TvBroadcastScreen(
          controller: controller,
          settingsController: effectiveSettings,
          broadcastId: state.pathParameters['broadcastId']!,
        ),
      ),
      GoRoute(
        path: '/vote',
        builder: (context, state) => ElectionScreen(controller: controller),
      ),
      GoRoute(
        path: '/simulation',
        builder: (context, state) =>
            TermSimulationScreen(controller: controller),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => TermReportScreen(
          controller: controller,
          galleryRepository: effectiveGallery,
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
