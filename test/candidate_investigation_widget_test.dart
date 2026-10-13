import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
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
    WidgetTester tester, {
    required GameController controller,
    required String location,
    Locale locale = const Locale('en'),
  }) async {
    final router = buildRouter(controller)..go(location);
    addTearDown(router.dispose);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        debugShowCheckedModeBanner: false,
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

  testWidgets('a normal city exposes all five generated candidate files', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Fivefold City'),
      worldSeed: 6042026,
    );
    await pumpRoute(tester, controller: controller, location: '/candidates');

    expect(controller.scenario.candidates, hasLength(5));
    for (final candidate in controller.scenario.candidates) {
      expect(find.byKey(Key('candidate_${candidate.id}')), findsOneWidget);
    }

    final lastCandidate = controller.scenario.candidates.last;
    final lastCard = find.byKey(Key('candidate_${lastCandidate.id}'));
    await tester.ensureVisible(lastCard);
    await tester.tap(lastCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text(lastCandidate.name.toUpperCase()), findsWidgets);
    expect(find.byKey(const Key('candidate_hub_bio')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('roster and dossier form a responsive investigation flow', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(tester, controller: controller, location: '/candidates');

    for (final candidate in controller.scenario.candidates) {
      expect(find.byKey(Key('candidate_${candidate.id}')), findsOneWidget);
    }
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('BEST', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);

    final mayaCard = find.byKey(const Key('candidate_maya_vargas'));
    await tester.ensureVisible(mayaCard);
    await tester.tap(mayaCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('candidate_hub_bio')), findsOneWidget);
    expect(find.byKey(const Key('candidate_hub_promises')), findsOneWidget);
    expect(find.byKey(const Key('candidate_hub_debate')), findsOneWidget);
    expect(find.byKey(const Key('candidate_hub_records')), findsOneWidget);
    expect(find.text('MAYA VARGAS'), findsWidgets);

    final hubDossier = find.byKey(const Key('candidate_hub_records'));
    await tester.ensureVisible(hubDossier);
    await tester.tap(hubDossier);
    await tester.pump(const Duration(milliseconds: 220));
    final openArchive = find.byKey(const Key('open_full_dossier'));
    await tester.ensureVisible(openArchive);
    await tester.tap(openArchive);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('dossier_tab_overview')), findsOneWidget);
    expect(find.byKey(const Key('dossier_tab_platform')), findsOneWidget);
    expect(find.byKey(const Key('dossier_tab_evidence')), findsOneWidget);

    final platformTab = find.byKey(const Key('dossier_tab_platform'));
    await tester.ensureVisible(platformTab);
    await tester.tap(platformTab);
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('Extend clinic hours and mobile care'), findsOneWidget);

    final evidenceTab = find.byKey(const Key('dossier_tab_evidence'));
    await tester.ensureVisible(evidenceTab);
    await tester.tap(evidenceTab);
    await tester.pump(const Duration(milliseconds: 220));
    expect(tester.takeException(), isNull);
    final profileFile = find.byKey(const Key('evidence_maya_profile'));
    await tester.ensureVisible(profileFile);
    await tester.tap(profileFile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const Key('evidence_reader_maya_profile')),
      findsOneWidget,
    );
    expect(controller.remainingInvestigationPoints, 12);
    final bookmark = find.byKey(const Key('bookmark_maya_profile'));
    await tester.ensureVisible(bookmark);
    await tester.tap(bookmark);
    await tester.pump();
    expect(controller.isBookmarked('maya_profile'), isTrue);
    expect(find.textContaining('Closure:'), findsNothing);

    await tester.tap(find.byKey(const Key('close_evidence_reader_top')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(controller.isEvidenceViewed('maya_profile'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('global point limit blocks a new paid file but not a profile', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(
        cityName: 'Point Limit City',
      ).copyWith(investigationTime: InvestigationTime.limited),
    );
    final spentIds = <String>[];
    var plannedSpend = 0;
    for (final candidate in controller.scenario.candidates) {
      for (final evidence in candidate.evidence) {
        final cost = controller.evidenceInvestigationCost(evidence.id);
        if (cost <= 0 || plannedSpend + cost > 7) continue;
        spentIds.add(evidence.id);
        plannedSpend += cost;
        if (plannedSpend == 7) break;
      }
      if (plannedSpend == 7) break;
    }
    expect(plannedSpend, 7);
    for (final id in spentIds) {
      expect(controller.markEvidenceViewed(id), isTrue);
    }
    expect(controller.remainingInvestigationPoints, 0);

    final blockedCandidate = controller.scenario.candidates.firstWhere(
      (candidate) => candidate.evidence.any(
        (item) =>
            !spentIds.contains(item.id) &&
            controller.evidenceInvestigationCost(item.id) > 0,
      ),
    );
    final blockedEvidence = blockedCandidate.evidence.firstWhere(
      (item) =>
          !spentIds.contains(item.id) &&
          controller.evidenceInvestigationCost(item.id) > 0,
    );
    final profileEvidence = blockedCandidate.evidence.firstWhere(
      (item) => item.type.name == 'profile',
    );

    await pumpRoute(
      tester,
      controller: controller,
      location: '/candidates/${blockedCandidate.id}/dossier',
    );
    final evidenceTab = find.byKey(const Key('dossier_tab_evidence'));
    await tester.ensureVisible(evidenceTab);
    await tester.tap(evidenceTab);
    await tester.pump(const Duration(milliseconds: 220));
    expect(tester.takeException(), isNull);

    final blockedFile = find.byKey(Key('evidence_${blockedEvidence.id}'));
    await tester.ensureVisible(blockedFile);
    await tester.tap(blockedFile);
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const Key('no_investigation_points_dialog')),
      findsOneWidget,
    );
    expect(controller.isEvidenceViewed(blockedEvidence.id), isFalse);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('dismiss_no_points')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
    final profileFile = find.byKey(Key('evidence_${profileEvidence.id}'));
    await tester.ensureVisible(profileFile);
    await tester.tap(profileFile);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(Key('evidence_reader_${profileEvidence.id}')),
      findsOneWidget,
    );
    expect(controller.remainingInvestigationPoints, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('research level two unlocks the optional Source Desk organizer', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Research City'),
      worldSeed: 1042027,
    );
    final candidate = controller.scenario.candidates.first;
    for (final evidence in candidate.evidence.take(4)) {
      expect(controller.markEvidenceViewed(evidence.id), isTrue);
      controller.toggleBookmark(evidence.id);
    }
    expect(controller.civicProgression.evidenceOrganizerUnlocked, isTrue);

    await pumpRoute(
      tester,
      controller: controller,
      location: '/candidates/${candidate.id}/dossier',
    );
    final evidenceTab = find.byKey(const Key('dossier_tab_evidence'));
    await tester.ensureVisible(evidenceTab);
    await tester.tap(evidenceTab);
    await tester.pump(const Duration(milliseconds: 220));

    final organizer = find.byKey(const Key('evidence_organizer_toggle'));
    expect(organizer, findsOneWidget);
    await tester.ensureVisible(organizer);
    await tester.tap(organizer);
    await tester.pump(const Duration(milliseconds: 220));
    expect(
      find.textContaining('Bookmarked and reviewed files'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('candidate dossier chrome and content switch to Filipino', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(
      tester,
      controller: controller,
      location: '/candidates/maya_vargas',
      locale: const Locale('fil'),
    );

    expect(find.text('BIYOGRAPIYA'), findsOneWidget);
    expect(find.text('MGA PANGAKO'), findsOneWidget);
    expect(find.text('DEBATE'), findsOneWidget);
    expect(find.text('MGA REKORD'), findsOneWidget);

    final hubDossier = find.byKey(const Key('candidate_hub_records'));
    await tester.ensureVisible(hubDossier);
    await tester.tap(hubDossier);
    await tester.pump(const Duration(milliseconds: 220));
    final openArchive = find.byKey(const Key('open_full_dossier'));
    await tester.ensureVisible(openArchive);
    await tester.tap(openArchive);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('BUOD'), findsOneWidget);
    expect(find.text('PLATAPORMA'), findsOneWidget);
    expect(find.text('EBIDENSYA'), findsOneWidget);
    expect(
      find.textContaining('Dating direktor ng community health'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
