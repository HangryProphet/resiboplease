import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/accountability_journal.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';

void main() {
  test(
    'journal derives stable promise outcomes from sealed administrations',
    () {
      final controller = GameController();
      addTearDown(controller.dispose);
      controller.createCity(
        slotIndex: 0,
        configuration: CityRunConfiguration.defaults(cityName: 'Receipt City'),
        worldSeed: 553311,
      );
      final mayor = controller.scenario.candidates.first;
      controller.castVote(
        candidate: mayor,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .64,
      );
      while (!controller.isTermReportReady) {
        controller.advanceTerm();
      }
      controller.continueToNextElection();

      final first = controller.accountabilityJournal;
      final second = controller.accountabilityJournal;
      expect(first.promises, hasLength(4));
      expect(first.forTerm(1), hasLength(4));
      expect(first.forCandidate(mayor.id), hasLength(4));
      expect(
        first.promises.map((item) => item.id),
        orderedEquals(second.promises.map((item) => item.id)),
      );
      expect(
        first.promises.map((item) => item.promiseId).toSet(),
        hasLength(4),
      );
      expect(
        first.promises.map((item) => item.outcome),
        everyElement(isA<AccountabilityOutcome>()),
      );
      expect(
        first.promises.map((item) => item.outcomeExplanation),
        everyElement(isNotEmpty),
      );
      for (final promise in first.promises) {
        expect(promise.termNumber, 1);
        expect(promise.candidateId, mayor.id);
        expect(promise.projectProgress, inInclusiveRange(0, 100));
      }

      final returningMayor = controller.candidateById(mayor.id);
      controller.castVote(
        candidate: returningMayor,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .59,
      );
      while (!controller.isTermReportReady) {
        controller.advanceTerm();
      }
      controller.continueToNextElection();

      final multiTerm = controller.accountabilityJournal;
      expect(multiTerm.promises, hasLength(8));
      expect(multiTerm.recurringPromises, isNotEmpty);
      expect(multiTerm.recurringControversies, isNotEmpty);
      expect(
        multiTerm.recurringPromises.expand((item) => item.termNumbers).toSet(),
        containsAll([1, 2]),
      );
      expect(multiTerm.recurringControversies.first.candidateId, mayor.id);
    },
  );
}
