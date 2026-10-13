import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/term_result.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/l10n/app_localizations.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<GoRouter> pumpRoute(
    WidgetTester tester,
    GameController controller,
    String location, {
    Locale locale = const Locale('en'),
  }) async {
    final router = buildRouter(controller)..go(location);
    addTearDown(router.dispose);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildResiboTheme(),
        routerConfig: router,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    return router;
  }

  testWidgets(
    'ballot, winner reveal, term events, and report form one MVP loop',
    (tester) async {
      usePhoneViewport(tester);
      final controller = GameController(activeRun: true);
      await pumpRoute(tester, controller, '/vote');

      expect(find.byKey(const Key('election_scroll')), findsOneWidget);
      expect(find.byKey(const Key('ballot_maya_vargas')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('ballot_maya_vargas')));
      await tester.pump();
      final issue = find.byKey(
        Key('ballot_issue_${controller.scenario.city.problems.first.id}'),
      );
      await tester.ensureVisible(issue);
      await tester.tap(issue);
      await tester.pump();
      final healthPrediction = find.byKey(
        const Key('prediction_health_access'),
      );
      await tester.ensureVisible(healthPrediction);
      await tester.tap(healthPrediction);
      await tester.pump();
      final budgetPrediction = find.byKey(
        const Key('prediction_budget_protection'),
      );
      await tester.ensureVisible(budgetPrediction);
      await tester.tap(budgetPrediction);
      await tester.pump();
      expect(controller.predictionIds, {'health_access', 'budget_protection'});
      final castVote = find.byKey(const Key('cast_vote'));
      await tester.ensureVisible(castVote);
      await tester.pump();
      await tester.tap(castVote);
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byKey(const Key('confirm_vote')), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm_vote')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));
      expect(find.byKey(const Key('winner_portrait')), findsOneWidget);
      expect(find.byKey(const Key('begin_term')), findsOneWidget);
      expect(controller.selectedCandidate?.id, 'maya_vargas');
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('begin_term')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.byKey(const Key('simulation_pause')), findsOneWidget);
      expect(find.byKey(const Key('simulation_speed_day')), findsOneWidget);
      expect(find.byKey(const Key('simulation_speed_week')), findsOneWidget);
      expect(find.byKey(const Key('simulation_speed_month')), findsOneWidget);
      expect(find.byKey(const Key('simulation_speed_year')), findsOneWidget);

      for (var phase = 1; phase <= 4; phase++) {
        controller.advanceTerm();
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull);
      }

      final illustrated = controller.termResult!.phases
          .where((phase) => phase.eventKind.hasArtwork)
          .toList(growable: false);
      expect(illustrated, hasLength(2));
      final report = find.byKey(const Key('open_term_report'));
      await tester.tap(report);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.byKey(const Key('term_report_scroll')), findsOneWidget);
      expect(find.byKey(const Key('restart_same_seed')), findsOneWidget);
      expect(
        find.byKey(const Key('continue_to_next_election')),
        findsOneWidget,
      );
      expect(find.text('YOUR EXPECTATION RECEIPT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Filipino election, term, and report chrome fit a phone', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    final router = await pumpRoute(
      tester,
      controller,
      '/vote',
      locale: const Locale('fil'),
    );

    expect(find.text('ARAW NG ELEKSYON'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.castVote(
      candidate: controller.scenario.candidates.last,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .5,
    );
    router.go('/simulation');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('BUHAY NA LUNGSOD'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (var phase = 0; phase < 4; phase++) {
      controller.advanceTerm();
    }
    router.go('/report');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('ULAT NG TERMINO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('political history opens an immutable completed term receipt', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    final firstMayor = controller.scenario.candidates.first;
    controller.togglePrediction('health_access');
    controller.castVote(
      candidate: firstMayor,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .73,
    );
    while (!controller.isTermReportReady) {
      controller.advanceTerm();
    }
    controller.continueToNextElection();

    final router = await pumpRoute(tester, controller, '/city');
    final openHistory = find.byKey(const Key('open_political_history'));
    await tester.ensureVisible(openHistory);
    await tester.tap(openHistory);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('political_history_scroll')), findsOneWidget);
    expect(find.byKey(const Key('administration_card_1')), findsOneWidget);
    expect(find.text(firstMayor.name.toUpperCase()), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('administration_card_1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(router.state.uri.path, '/history/1');
    expect(find.text('HISTORICAL RECEIPT'), findsOneWidget);
    expect(find.text('CITY OUTCOME'), findsOneWidget);
    expect(find.text('ELECTION RECEIPT'), findsOneWidget);
    expect(find.text('YOUR EXPECTATION RECEIPT'), findsOneWidget);
    expect(controller.currentElectionNumber, 2);
    expect(controller.administrationHistory, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Civic Profile shows derived tracks and accomplishments on phone',
    (tester) async {
      usePhoneViewport(tester);
      final controller = GameController(activeRun: true);
      controller.castVote(
        candidate: controller.scenario.candidates.first,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .68,
      );
      while (!controller.isTermReportReady) {
        controller.advanceTerm();
      }
      controller.continueToNextElection();

      final router = await pumpRoute(tester, controller, '/history');
      await tester.tap(find.byKey(const Key('open_civic_profile')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(router.state.uri.path, '/civic-profile');
      expect(find.text('CIVIC PROFILE'), findsOneWidget);
      expect(find.byKey(const Key('civic_track_research')), findsOneWidget);
      expect(
        find.byKey(const Key('civic_track_publicAccountability')),
        findsOneWidget,
      );
      final firstMilestone = find.byKey(
        const Key('civic_accomplishment_first_administration'),
      );
      await tester.ensureVisible(firstMilestone);
      expect(firstMilestone, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Resibo ng Bayan promise journal and filters fit a phone', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Journal City'),
      worldSeed: 7102026,
    );
    final mayorId = controller.scenario.candidates.first.id;
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .6,
    );
    while (!controller.isTermReportReady) {
      controller.advanceTerm();
    }
    controller.continueToNextElection();
    controller.castVote(
      candidate: controller.candidateById(mayorId),
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .55,
    );
    while (!controller.isTermReportReady) {
      controller.advanceTerm();
    }
    controller.continueToNextElection();

    await pumpRoute(tester, controller, '/accountability');
    expect(
      find.byKey(const Key('accountability_journal_scroll')),
      findsOneWidget,
    );
    expect(find.text('PUBLIC ACCOUNTABILITY JOURNAL'), findsOneWidget);
    expect(find.byKey(const Key('journal_filter_all')), findsOneWidget);
    expect(find.byKey(const Key('journal_filter_delivered')), findsOneWidget);
    expect(find.byKey(const Key('journal_filter_unresolved')), findsOneWidget);
    expect(find.text('RECURRING RECORDS'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('journal_filter_unresolved')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
    expect(controller.accountabilityJournal.promises, hasLength(8));

    await tester.tap(find.byKey(const Key('journal_filter_all')));
    await tester.pump(const Duration(milliseconds: 200));
    final promise = controller.accountabilityJournal.promises.first;
    final openEvidence = find.byKey(
      Key('open_historical_evidence_${promise.id}'),
    );
    await tester.ensureVisible(openEvidence);
    await tester.tap(openEvidence);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('historical_evidence_scroll')), findsOneWidget);
    expect(find.text('Sealed election snapshot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
