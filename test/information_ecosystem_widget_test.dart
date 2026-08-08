import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/pre_election_city_brief.dart';
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
    String route,
  ) async {
    final router = buildRouter(controller)..go(route);
    addTearDown(router.dispose);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildResiboTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    return router;
  }

  testWidgets('CityBook supports comments, history context, and records', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(tester, controller, '/citybook/maya_vargas');

    expect(find.byKey(const Key('citybook_profile_header')), findsOneWidget);
    expect(find.byKey(const Key('citybook_feed')), findsOneWidget);
    expect(
      find.byKey(const Key('citybook_post_cb_maya_clinics')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Reactions show public sentiment'),
      findsNothing,
    );

    final comments = find.byKey(const Key('citybook_comments_cb_maya_clinics'));
    await tester.ensureVisible(comments);
    await tester.tap(comments);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('citybook_comments_sheet')), findsOneWidget);
    expect(
      find.byKey(const Key('citybook_comment_thread_cb_maya_clinics_0')),
      findsOneWidget,
    );
    Navigator.of(
      tester.element(find.byKey(const Key('citybook_comments_sheet'))),
    ).pop();
    await tester.pump(const Duration(milliseconds: 250));

    final contextButton = find.byKey(
      const Key('citybook_context_cb_maya_old_scale'),
    );
    await tester.ensureVisible(contextButton);
    await tester.tap(contextButton);
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const Key('then_now_comparison_maya_scale')),
      findsOneWidget,
    );
    Navigator.of(
      tester.element(find.byKey(const Key('then_now_comparison_maya_scale'))),
    ).pop();
    await tester.pump(const Duration(milliseconds: 250));

    final record = find.byKey(
      const Key('citybook_evidence_cb_maya_old_scale_maya_publicRecord'),
    );
    await tester.ensureVisible(record);
    await tester.tap(record);
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      find.byKey(const Key('evidence_reader_maya_publicRecord')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('transparency_portal_record')), findsOneWidget);
    expect(controller.isEvidenceViewed('maya_publicRecord'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chronicle opens three framings and a full news article', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(tester, controller, '/city/chronicle');

    final chronicle = controller.preElectionBrief.news.firstWhere(
      (item) => item.kind == ChronicleStoryKind.issue,
    );
    final event = controller.informationEcosystem.news.eventForChronicle(
      chronicle.id,
    )!;
    final readCoverage = find.byKey(Key('read_coverage_${chronicle.id}'));
    await tester.ensureVisible(readCoverage);
    await tester.tap(readCoverage);
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('underlying_news_event_${event.id}')),
      findsOneWidget,
    );
    final articles = controller.informationEcosystem.news.coverageForEvent(
      event.id,
    );
    for (final article in articles) {
      expect(find.byKey(Key('news_coverage_${article.id}')), findsOneWidget);
    }

    final open = find.byKey(Key('open_news_${articles.first.id}'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('news_article_${articles.first.id}')),
      findsOneWidget,
    );
    final articleBack = find.byKey(const Key('back_from_news_article'));
    expect(articleBack, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('news_article_scroll')),
        matching: articleBack,
      ),
      findsNothing,
    );
    expect(find.text(articles.first.headline), findsOneWidget);
    expect(find.textContaining('same underlying event'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Candidate Hub keeps quick content and exposes media routes', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(tester, controller, '/candidates/maya_vargas');

    expect(find.byKey(const Key('candidate_biography_view')), findsOneWidget);
    expect(
      find.byKey(const Key('candidate_information_strip')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('open_candidate_citybook')), findsOneWidget);
    expect(
      find.byKey(const Key('open_recent_candidate_coverage')),
      findsOneWidget,
    );
    expect(find.text('MAYA VARGAS'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
