import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/l10n/app_localizations.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<GoRouter> pumpHub(
    WidgetTester tester,
    GameController controller, {
    Locale locale = const Locale('en'),
  }) async {
    final router = buildRouter(controller)..go('/candidates/maya_vargas');
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

  testWidgets('Biography citations and campaign trail preserve investigation', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    final router = await pumpHub(tester, controller);

    expect(find.byKey(const Key('candidate_biography_view')), findsOneWidget);
    expect(find.text('BAYHAVEN CIVIC ARCHIVE'), findsOneWidget);
    expect(
      find.byKey(const Key('history_event_maya_mobile_clinics_2022')),
      findsOneWidget,
    );

    final citation = find.byKey(
      const Key('bio_citation_maya_pilot_result_maya_publicRecord'),
    );
    await tester.ensureVisible(citation);
    await tester.tap(citation);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const Key('evidence_reader_maya_publicRecord')),
      findsOneWidget,
    );
    expect(controller.isEvidenceViewed('maya_publicRecord'), isTrue);
    final closeReader = find.byKey(const Key('close_evidence_reader_top'));
    Navigator.of(tester.element(closeReader)).pop();
    await tester.pump(const Duration(milliseconds: 300));

    final promisesTab = find.byKey(const Key('candidate_hub_promises'));
    await tester.ensureVisible(promisesTab);
    await tester.tap(promisesTab);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('candidate_promises_view')), findsOneWidget);
    expect(
      find.byKey(const Key('promise_card_promise_maya_clinic_access')),
      findsOneWidget,
    );

    final historyLink = find.byKey(
      const Key(
        'promise_history_promise_maya_clinic_access_maya_mobile_clinics_2022',
      ),
    );
    await tester.ensureVisible(historyLink);
    await tester.tap(historyLink);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('candidate_biography_view')), findsOneWidget);
    expect(
      find.byKey(const Key('history_event_maya_mobile_clinics_2022')),
      findsWidgets,
    );

    await tester.ensureVisible(promisesTab);
    await tester.tap(promisesTab);
    await tester.pump(const Duration(milliseconds: 250));

    final campaignTrail = find.byKey(const Key('campaign_trail_expansion'));
    await tester.ensureVisible(campaignTrail);
    await tester.tap(campaignTrail);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('candidate_pulse_feed')), findsOneWidget);
    for (final id in const [
      'pulse_maya_launch',
      'pulse_maya_volunteer',
      'pulse_maya_promise',
      'pulse_maya_donor',
      'pulse_maya_defense',
      'pulse_maya_correction',
    ]) {
      expect(find.byKey(Key('pulse_$id')), findsOneWidget);
    }
    expect(find.text('STRONG'), findsNothing);
    expect(find.text('COMPROMISED'), findsNothing);
    expect(
      find.textContaining('match score', findRichText: true),
      findsNothing,
    );

    final inspect = find.byKey(const Key('inspect_content_pulse_maya_donor'));
    tester.widget<OutlinedButton>(inspect).onPressed!();
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.textContaining(
        'All contracts will use published competitive bidding.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('pulse_evidence_pulse_maya_donor_maya_controversy')),
      findsOneWidget,
    );

    final donorPin = find.byKey(const Key('pin_content_pulse_maya_donor'));
    tester.widget<IconButton>(donorPin).onPressed!();
    await tester.pump();
    expect(controller.isContentPinned('pulse_maya_donor'), isTrue);

    final pin = find.byKey(const Key('pin_content_pulse_maya_launch'));
    tester.widget<IconButton>(pin).onPressed!();
    await tester.pump();
    expect(controller.isContentPinned('pulse_maya_launch'), isTrue);

    router.go('/receipts');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('receipts_board_scroll')), findsOneWidget);
    expect(
      find.text('Vargas opens with a packed clinic rally'),
      findsOneWidget,
    );
    expect(
      find.text('Medical supplier donations raise contract questions'),
      findsOneWidget,
    );
    expect(find.textContaining('No match score'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Debate is scrollable, linked, and player-curated', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpHub(tester, controller);

    final debateTab = find.byKey(const Key('candidate_hub_debate'));
    await tester.ensureVisible(debateTab);
    await tester.tap(debateTab);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const Key('debate_chat_view')), findsOneWidget);
    expect(find.byKey(const Key('debate_topic_debate_water')), findsOneWidget);
    expect(find.byKey(const Key('debate_topic_debate_jobs')), findsOneWidget);
    expect(
      find.byKey(const Key('debate_topic_debate_clinics')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('debate_message_dw01')), findsOneWidget);
    expect(find.byKey(const Key('debate_message_dw10')), findsOneWidget);
    expect(
      find.byKey(const Key('debate_evidence_maya_debateAnswer')),
      findsOneWidget,
    );

    final bookmark = find.byKey(const Key('bookmark_debate_dw03'));
    await tester.ensureVisible(bookmark);
    await tester.tap(bookmark);
    await tester.pump();
    expect(controller.isDebateBookmarked('dw03'), isTrue);

    final pin = find.byKey(const Key('pin_debate_dw03'));
    await tester.ensureVisible(pin);
    await tester.tap(pin);
    await tester.pump();
    expect(controller.isDebatePinned('dw03'), isTrue);

    final suspicious = find.byKey(const Key('suspicious_debate_dw03'));
    await tester.ensureVisible(suspicious);
    await tester.tap(suspicious);
    await tester.pump();
    expect(controller.isDebateSuspicious('dw03'), isTrue);

    final comparison = find.byKey(const Key('debate_comparison_dw07'));
    expect(comparison, findsOneWidget);
    tester.widget<ActionChip>(comparison).onPressed!();
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const Key('then_now_comparison_victor_coalition')),
      findsOneWidget,
    );
    Navigator.of(
      tester.element(
        find.byKey(const Key('then_now_comparison_victor_coalition')),
      ),
    ).pop();
    await tester.pump(const Duration(milliseconds: 250));

    final promiseTrail = find.byKey(
      const Key('debate_promise_dw02_promise_maya_water_testing'),
    );
    expect(promiseTrail, findsOneWidget);
    tester.widget<ActionChip>(promiseTrail).onPressed!();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('candidate_promises_view')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Candidate Hub chrome remains localized in Filipino', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpHub(tester, controller, locale: const Locale('fil'));

    expect(find.text('BIYOGRAPIYA'), findsOneWidget);
    expect(find.text('MGA PANGAKO'), findsOneWidget);
    expect(find.text('DEBATE'), findsOneWidget);
    expect(find.text('MGA REKORD'), findsOneWidget);
    expect(find.text('MGA TANONG NA HINDI PA SAGOT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide Candidate Hub lays out its fixed-aspect portrait safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(activeRun: true);

    await pumpHub(tester, controller);

    expect(find.byKey(const Key('candidate_biography_view')), findsOneWidget);
    expect(find.text('MAYA VARGAS'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
