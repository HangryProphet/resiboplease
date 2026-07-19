import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/app.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/data/persistence/run_repository.dart';
import 'package:resiboplease/data/persistence/run_save_data.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';

void main() {
  testWidgets('City Archive resumes a restored completed run at its report', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MemoryRunRepository();
    final firstSession = GameController(repository: repository);
    firstSession.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Persistent City'),
    );
    firstSession.castVote(
      candidate: firstSession.scenario.candidates.first,
      topIssue: firstSession.scenario.city.problems.first.id,
      confidence: .6,
    );
    for (var phase = 0; phase < 4; phase++) {
      firstSession.advanceTerm();
    }
    await firstSession.flushSaves();
    firstSession.dispose();

    final restored = GameController(repository: repository);
    await restored.restore();
    addTearDown(restored.dispose);
    await tester.pumpWidget(ResiboPleaseApp(gameController: restored));
    await tester.pump();

    await tester.tap(find.byKey(const Key('continue_city')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.byKey(const Key('city_slots_page')), findsOneWidget);
    expect(find.byKey(const Key('local_save_status')), findsOneWidget);
    expect(find.text('Saved on this device'), findsOneWidget);
    expect(find.text('Term report ready'), findsOneWidget);

    await tester.tap(find.byKey(const Key('continue_city_slot_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('TERM REPORT'), findsOneWidget);
    expect(find.text('Persistent City'), findsOneWidget);
    expect(find.text('ADMINISTRATION RECEIPT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('City Archive retries a failed local save', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FailOnceRunRepository();
    final controller = GameController(repository: repository);
    addTearDown(controller.dispose);
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Retry City'),
    );
    await controller.flushSaves();
    await tester.pumpWidget(ResiboPleaseApp(gameController: controller));
    await tester.pump();

    await tester.tap(find.byKey(const Key('continue_city')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.textContaining('could not be saved'), findsOneWidget);
    expect(find.byKey(const Key('retry_save')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry_save')));
    await controller.flushSaves();
    await tester.pump();

    expect(find.text('Saved on this device'), findsOneWidget);
    expect(repository.value, isNotNull);
    expect(tester.takeException(), isNull);
  });
}

class _FailOnceRunRepository implements RunRepository {
  bool _shouldFail = true;
  GameSaveData? value;

  @override
  Future<GameSaveData?> load() async => value;

  @override
  Future<void> save(GameSaveData nextValue) async {
    if (_shouldFail) {
      _shouldFail = false;
      throw StateError('Simulated disk failure.');
    }
    value = GameSaveData.fromJson(nextValue.toJson());
  }

  @override
  Future<void> close() async {}
}
