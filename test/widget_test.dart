import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/app.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/features/home/home_screen.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> finishOverlayAnimation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
  }

  testWidgets('main menu fits a 390 by 844 phone viewport', (tester) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(const ResiboPleaseApp());
    await tester.pump();

    expect(find.text('START NEW CITY'), findsNWidgets(2));
    expect(find.text('HOW TO PLAY'), findsNWidgets(2));
    expect(find.text('VISIT CITIES'), findsNWidgets(2));
    expect(find.text('About'), findsNothing);
    expect(find.textContaining('Seed 5839201'), findsNothing);
    final splash = tester.widget<Text>(
      find.byKey(const Key('menu_splash_text')),
    );
    expect(splash.data, isNot(contains('\n')));
    expect(splash.data!.length, lessThanOrEqualTo(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('How to Play opens as a full-screen paper game guide', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const ResiboPleaseApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('how_to_play_button')));
    await finishOverlayAnimation(tester);

    expect(find.byKey(const Key('how_to_play_sheet')), findsOneWidget);
    expect(find.text('YOU ARE THE VOTER'), findsOneWidget);
    expect(find.text('READ THE CITY'), findsOneWidget);
    expect(find.text('CHECK THE CANDIDATES'), findsOneWidget);
    expect(find.text('CHOOSE FOR YOURSELF'), findsOneWidget);
    expect(find.text('WATCH THE TERM'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('how_to_play_sheet')),
      const Offset(0, -450),
    );
    await tester.pump();
    expect(find.text('FIND THE RECEIPTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new-city flow configures all seven city settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController();
    final router = buildRouter(controller);
    addTearDown(router.dispose);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildResiboTheme(), routerConfig: router),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_bayhaven')));
    await finishOverlayAnimation(tester);

    expect(find.byKey(const Key('city_slots_page')), findsOneWidget);
    for (var index = 0; index < GameController.saveSlotCount; index++) {
      expect(find.byKey(Key('start_city_slot_$index')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('start_city_slot_0')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('city_name_page')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('city_name_field')),
      'Harborlight',
    );
    await tester.tap(find.byKey(const Key('starting_pressure_crisis')));
    await tester.tap(find.byKey(const Key('city_concern_health')));
    await tester.tap(find.byKey(const Key('city_concern_climate')));
    await tester.tap(find.byKey(const Key('candidate_field_seasoned')));
    await tester.tap(find.byKey(const Key('assistance_mode_standard')));
    await tester.tap(find.byKey(const Key('campaign_noise_noisy')));
    await tester.tap(find.byKey(const Key('investigation_time_limited')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('create_city_submit')));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('HARBORLIGHT'), findsOneWidget);
    expect(find.text('CITY BRIEF'), findsOneWidget);
    expect(find.text('THE CITY BEFORE THE VOTE'), findsOneWidget);
    expect(
      controller.activeConfiguration!.startingPressure,
      StartingPressure.crisis,
    );
    expect(
      controller.activeConfiguration!.mainConcerns,
      containsAll(<CityConcern>[
        CityConcern.water,
        CityConcern.jobs,
        CityConcern.climate,
      ]),
    );
    expect(
      controller.activeConfiguration!.candidateField,
      CandidateField.seasoned,
    );
    expect(controller.assistanceMode, AssistanceMode.standard);
    expect(controller.activeConfiguration!.campaignNoise, CampaignNoise.noisy);
    expect(
      controller.activeConfiguration!.investigationTime,
      InvestigationTime.limited,
    );
    expect(find.byKey(const Key('guided_resi_note')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seven-setting form scrolls safely on a phone viewport', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const ResiboPleaseApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_bayhaven')));
    await finishOverlayAnimation(tester);
    await tester.tap(find.byKey(const Key('start_city_slot_0')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const Key('city_configuration_page')), findsOneWidget);
    expect(find.byKey(const Key('city_name_field')), findsOneWidget);

    await tester.fling(
      find.byKey(const Key('city_name_page')),
      const Offset(0, -3200),
      2500,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.fling(
      find.byKey(const Key('city_name_page')),
      const Offset(0, -3200),
      2500,
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('create_city_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active run keeps a matching Start New City menu button', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildResiboTheme(),
        home: HomeScreen(controller: controller),
      ),
    );
    await tester.pump();

    expect(find.text('CONTINUE CITY'), findsNWidgets(2));
    expect(find.byKey(const Key('start_new_city_secondary')), findsOneWidget);

    await tester.tap(find.byKey(const Key('start_new_city_secondary')));
    await finishOverlayAnimation(tester);

    expect(find.byKey(const Key('city_slots_page')), findsOneWidget);
    expect(find.text('OCCUPIED'), findsOneWidget);
    expect(find.byKey(const Key('start_city_slot_1')), findsOneWidget);
    expect(controller.hasActiveRun, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continue City offers continue and confirmed delete actions', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildResiboTheme(),
        home: HomeScreen(controller: controller),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('continue_city')));
    await finishOverlayAnimation(tester);
    expect(find.byKey(const Key('continue_city_slot_0')), findsOneWidget);
    expect(find.byKey(const Key('delete_city_slot_0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete_city_slot_0')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('delete_city_confirmation')), findsOneWidget);
    expect(controller.hasActiveRun, isTrue);

    await tester.tap(find.byKey(const Key('confirm_delete_city')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(controller.hasActiveRun, isFalse);
    expect(find.textContaining('was removed from Save Slot 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
