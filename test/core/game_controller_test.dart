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
}
