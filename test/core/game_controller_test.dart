import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';

void main() {
  test('a new run becomes active and clears previous decisions', () {
    final controller = GameController();
    final candidate = controller.scenario.candidates.first;

    expect(controller.hasActiveRun, isFalse);
    controller.castVote(
      candidate: candidate,
      topIssue: 'flooding',
      confidence: .8,
    );
    controller.startNewRun();

    expect(controller.hasActiveRun, isTrue);
    expect(controller.selectedCandidate, isNull);
    expect(controller.termResult, isNull);
    expect(controller.topIssue, isNull);
    expect(controller.confidence, .5);
  });

  test('five city slots can be created, selected, and deleted', () {
    final controller = GameController();

    expect(controller.saveSlots, hasLength(GameController.saveSlotCount));
    expect(controller.saveSlots, everyElement(isNull));

    controller.createCity(slotIndex: 2, cityName: '  Harborlight  ');
    expect(controller.hasActiveRun, isTrue);
    expect(controller.activeSlotIndex, 2);
    expect(controller.activeCityName, 'Harborlight');
    expect(controller.saveSlots[2]!.cityName, 'Harborlight');

    controller.createCity(slotIndex: 4, cityName: 'Mabuhay');
    expect(controller.activeSlotIndex, 4);
    controller.continueCity(2);
    expect(controller.activeCityName, 'Harborlight');

    controller.deleteCity(2);
    expect(controller.saveSlots[2], isNull);
    expect(controller.activeSlotIndex, 4);
    expect(controller.activeCityName, 'Mabuhay');
  });

  test('an occupied slot cannot be overwritten', () {
    final controller = GameController();
    controller.createCity(slotIndex: 0, cityName: 'First City');

    expect(
      () => controller.createCity(slotIndex: 0, cityName: 'Replacement'),
      throwsStateError,
    );
    expect(controller.activeCityName, 'First City');
  });
}
