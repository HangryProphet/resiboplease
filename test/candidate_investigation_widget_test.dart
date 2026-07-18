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

    expect(find.byKey(const Key('dossier_tab_overview')), findsOneWidget);
    expect(find.byKey(const Key('dossier_tab_platform')), findsOneWidget);
    expect(find.byKey(const Key('dossier_tab_evidence')), findsOneWidget);
    expect(find.text('MAYA VARGAS'), findsWidgets);

    final platformTab = find.byKey(const Key('dossier_tab_platform'));
    await tester.ensureVisible(platformTab);
    await tester.tap(platformTab);
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('Extend clinic hours and mobile care'), findsOneWidget);

    final evidenceTab = find.byKey(const Key('dossier_tab_evidence'));
    await tester.ensureVisible(evidenceTab);
    await tester.tap(evidenceTab);
    await tester.pump(const Duration(milliseconds: 220));
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
    final maya = controller.scenario.candidates.first;
    final paid = maya.evidence
        .where((item) => item.type.name != 'profile')
        .toList(growable: false);
    for (final item in paid.take(7)) {
      expect(controller.markEvidenceViewed(item.id), isTrue);
    }
    expect(controller.remainingInvestigationPoints, 0);

    await pumpRoute(
      tester,
      controller: controller,
      location: '/candidates/maya_vargas',
    );
    final evidenceTab = find.byKey(const Key('dossier_tab_evidence'));
    await tester.ensureVisible(evidenceTab);
    await tester.tap(evidenceTab);
    await tester.pump(const Duration(milliseconds: 220));

    final blockedFile = find.byKey(Key('evidence_${paid.last.id}'));
    await tester.ensureVisible(blockedFile);
    await tester.tap(blockedFile);
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const Key('no_investigation_points_dialog')),
      findsOneWidget,
    );
    expect(controller.isEvidenceViewed(paid.last.id), isFalse);

    await tester.tap(find.byKey(const Key('dismiss_no_points')));
    await tester.pump(const Duration(milliseconds: 250));
    final profileFile = find.byKey(const Key('evidence_maya_profile'));
    await tester.ensureVisible(profileFile);
    await tester.tap(profileFile);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const Key('evidence_reader_maya_profile')),
      findsOneWidget,
    );
    expect(controller.remainingInvestigationPoints, 0);
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
