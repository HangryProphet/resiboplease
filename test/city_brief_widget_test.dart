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

  testWidgets('city hub is a responsive frozen pre-election snapshot', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(tester, controller: controller, location: '/city');

    expect(find.byKey(const Key('pre_election_frozen_notice')), findsOneWidget);
    expect(find.byKey(const Key('city_hub_scroll')), findsOneWidget);
    for (final problem in controller.scenario.city.problems) {
      expect(find.byKey(Key('city_hotspot_${problem.id}')), findsOneWidget);
    }
    expect(find.textContaining('Advance to phase'), findsNothing);
    expect(find.textContaining('Term in progress'), findsNothing);
    expect(tester.takeException(), isNull);

    final firstProblem = controller.scenario.city.problems.first;
    await tester.tap(find.byKey(Key('city_hotspot_${firstProblem.id}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('concern_detail_${firstProblem.id}')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chronicle uses artwork and retains pre-election navigation', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(
      tester,
      controller: controller,
      location: '/city/chronicle',
    );

    expect(find.byKey(const Key('community_voices_asset')), findsOneWidget);
    expect(find.byKey(const Key('pre_election_frozen_notice')), findsOneWidget);
    expect(find.byKey(const Key('pre_election_nav_chronicle')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('pre_election_nav_dossiers')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('candidate_roster_scroll')), findsOneWidget);
    expect(find.byKey(const Key('pre_election_nav_dossiers')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Filipino city brief fits a narrow phone screen', (tester) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    await pumpRoute(
      tester,
      controller: controller,
      location: '/city',
      locale: const Locale('fil'),
    );

    expect(find.text('ANG LUNGSOD BAGO ANG BOTOHAN'), findsOneWidget);
    expect(find.textContaining('Hindi uusad ang lungsod'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
