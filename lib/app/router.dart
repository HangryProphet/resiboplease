import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/state/game_controller.dart';
import '../features/city/city_overview_screen.dart';
import '../features/dossier/candidate_dossier_screen.dart';
import '../features/dossier/candidate_roster_screen.dart';
import '../features/election/election_screen.dart';
import '../features/home/home_screen.dart';
import '../features/results/term_report_screen.dart';
import '../features/simulation/term_simulation_screen.dart';

GoRouter buildRouter(GameController controller) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(controller: controller),
    ),
    GoRoute(
      path: '/city',
      builder: (context, state) => CityOverviewScreen(controller: controller),
    ),
    GoRoute(
      path: '/candidates',
      builder: (context, state) =>
          CandidateRosterScreen(controller: controller),
    ),
    GoRoute(
      path: '/candidates/:candidateId',
      builder: (context, state) => CandidateDossierScreen(
        controller: controller,
        candidateId: state.pathParameters['candidateId']!,
      ),
    ),
    GoRoute(
      path: '/vote',
      builder: (context, state) => ElectionScreen(controller: controller),
    ),
    GoRoute(
      path: '/simulation',
      builder: (context, state) => TermSimulationScreen(controller: controller),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => TermReportScreen(controller: controller),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('That case file could not be found.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Return home'),
          ),
        ],
      ),
    ),
  ),
);
