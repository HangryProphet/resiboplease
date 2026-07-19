import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/term_result.dart';
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
      expect(find.byKey(const Key('term_timeline_scroll')), findsOneWidget);

      for (var phase = 1; phase <= 4; phase++) {
        final advance = find.byKey(const Key('advance_term'));
        await tester.ensureVisible(advance);
        await tester.tap(advance);
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.byKey(Key('term_phase_$phase')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      final illustrated = controller.termResult!.phases
          .where((phase) => phase.eventKind.hasArtwork)
          .toList(growable: false);
      expect(illustrated, hasLength(2));
      for (final phase in illustrated) {
        expect(
          find.byKey(Key('term_event_art_${phase.eventKind.name}')),
          findsOneWidget,
        );
      }

      final report = find.byKey(const Key('advance_term'));
      await tester.ensureVisible(report);
      await tester.tap(report);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.byKey(const Key('term_report_scroll')), findsOneWidget);
      expect(find.byKey(const Key('restart_same_seed')), findsOneWidget);
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
    expect(find.text('KASALUKUYANG TERMINO'), findsOneWidget);
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
}
