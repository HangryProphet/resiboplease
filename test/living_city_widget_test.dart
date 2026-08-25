import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';
import 'package:resiboplease/features/simulation/term_simulation_screen.dart';
import 'package:resiboplease/domain/models/living_city_simulation.dart';
import 'package:resiboplease/l10n/app_localizations.dart';

void main() {
  testWidgets('Living City uses an overhead interactive map and landmarks', (
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

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildResiboTheme(),
        home: TermSimulationScreen(controller: controller),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const Key('bayhaven_districts_topdown_map')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('bayhaven_interactive_map')), findsOneWidget);
    final viewer = tester.widget<InteractiveViewer>(
      find.byKey(const Key('bayhaven_interactive_map')),
    );
    expect(
      viewer.transformationController!.value.getMaxScaleOnAxis(),
      closeTo(1.65, .001),
    );
    expect(find.byKey(const Key('mayor_office_marker')), findsOneWidget);
    expect(find.byKey(const Key('map_landmark_hospital')), findsOneWidget);
    expect(
      find.byKey(const Key('map_landmark_news_headquarters')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('map_landmark_water_facility')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('map_landmark_shopping_mall')), findsOneWidget);

    await tester.tap(find.byKey(const Key('map_landmark_hospital')));
    await tester.pumpAndSettle();
    expect(find.text('PUBLIC HOSPITAL'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

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
    final event = controller.termResult!.livingCity.eventHistory.firstWhere((
      item,
    ) {
      final anchor = cityMapAnchorById(item.locationId);
      return item.importance != CityEventImportance.ambient &&
          anchor.x >= .32 &&
          anchor.x <= .68 &&
          anchor.y >= .25 &&
          anchor.y <= .70;
    });
    controller.advanceSimulationDays(
      event.day,
      interruptionPreference: CriticalEventInterruption.neverInterrupt,
    );

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
    expect(tester.getSize(marker), const Size(48, 48));
    await tester.tap(marker);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(event.title.toUpperCase()), findsOneWidget);
    expect(find.text(event.factualSummary), findsWidgets);
    expect(marker, findsNothing);
    expect(controller.inspectedCityEventIds, contains(event.id));
    expect(
      controller.termResult!.livingCity.eventHistory.map((item) => item.id),
      contains(event.id),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Auto Open pauses YEAR and opens the critical event sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(activeRun: true);
    final settings = AppSettingsController(store: MemorySettingsStore());
    addTearDown(controller.dispose);
    addTearDown(settings.dispose);
    await settings.setCriticalEventInterruption(
      CriticalEventInterruption.autoOpen,
    );
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );
    final critical = controller.termResult!.livingCity.eventHistory.firstWhere(
      (event) =>
          event.importance == CityEventImportance.critical ||
          event.importance == CityEventImportance.rare,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildResiboTheme(),
        home: TermSimulationScreen(
          controller: controller,
          settingsController: settings,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('simulation_speed_year')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.simulationDay, critical.day);
    expect(controller.simulationPaused, isTrue);
    expect(find.text(critical.title.toUpperCase()), findsOneWidget);
    expect(controller.inspectedCityEventIds, contains(critical.id));
  });

  testWidgets('Pause & Notify leaves critical event opening to the player', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(activeRun: true);
    final settings = AppSettingsController(store: MemorySettingsStore());
    addTearDown(controller.dispose);
    addTearDown(settings.dispose);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );
    final critical = controller.termResult!.livingCity.eventHistory.firstWhere(
      (event) =>
          event.importance == CityEventImportance.critical ||
          event.importance == CityEventImportance.rare,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildResiboTheme(),
        home: TermSimulationScreen(
          controller: controller,
          settingsController: settings,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('simulation_speed_year')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(controller.simulationDay, critical.day);
    expect(controller.simulationPaused, isTrue);
    expect(
      find.byKey(Key('critical_event_notice_${critical.id}')),
      findsOneWidget,
    );
    expect(controller.inspectedCityEventIds, isNot(contains(critical.id)));
    expect(find.text(critical.title.toUpperCase()), findsOneWidget);
  });
}
