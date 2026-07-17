import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/app.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/features/home/home_screen.dart';

void main() {
  testWidgets('main menu fits a 390 by 844 phone viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

  testWidgets('active run shows Continue and protects New City', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    await tester.pump();

    expect(find.text('Start a new city?'), findsOneWidget);
    expect(find.text('Keep current city'), findsOneWidget);
    expect(controller.hasActiveRun, isTrue);

    await tester.tap(find.text('Keep current city'));
    await tester.pump();
    expect(find.text('Start a new city?'), findsNothing);
    expect(controller.hasActiveRun, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the Bayhaven election brief', (tester) async {
    await tester.pumpWidget(const ResiboPleaseApp());
    await tester.pump();

    expect(find.text('RESIBO,'), findsNWidgets(2));
    expect(find.text('PLEASE'), findsOneWidget);
    expect(find.textContaining('fictional', findRichText: true), findsWidgets);

    await tester.tap(find.byKey(const Key('start_bayhaven')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('The city before the vote'), findsOneWidget);
    expect(find.text('Post-flood water contamination'), findsOneWidget);
    expect(find.text('Rising unemployment'), findsOneWidget);
    expect(find.text('Overcrowded public clinics'), findsOneWidget);
  });
}
