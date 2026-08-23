import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/features/simulation/term_simulation_screen.dart';
import 'package:resiboplease/l10n/app_localizations.dart';

void main() {
  testWidgets('revealed city events create inspectable map markers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );
    controller.advanceTerm();
    final event = controller.termResult!.livingCity.phases.first.events.first;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildResiboTheme(),
        home: TermSimulationScreen(controller: controller),
      ),
    );
    await tester.pump();

    final marker = find.byKey(Key('city_event_marker_${event.id}'));
    expect(marker, findsOneWidget);
    await tester.tap(marker);
    await tester.pumpAndSettle();
    expect(find.text(event.title.toUpperCase()), findsOneWidget);
    expect(find.text(event.factualSummary), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
