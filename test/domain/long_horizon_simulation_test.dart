import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/data/persistence/run_repository.dart';
import 'package:resiboplease/domain/models/city_indicator.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';

void main() {
  for (final seed in const [22017, 83041]) {
    test('ten-administration stability holds for additional seed $seed', () {
      final controller = GameController();
      addTearDown(controller.dispose);
      controller.createCity(
        slotIndex: 0,
        configuration: CityRunConfiguration.defaults(cityName: 'Stress $seed'),
        worldSeed: seed,
      );
      final usedTemplates = <String>{};

      for (var term = 1; term <= 10; term++) {
        expect(controller.currentElectionNumber, term);
        expect(
          controller.scenario.city.problems.length,
          inInclusiveRange(4, 6),
        );
        expect(
          controller.scenario.city.problems
              .map((problem) => problem.family)
              .toSet()
              .length,
          controller.scenario.city.problems.length,
        );
        final roster = controller.scenario.candidates;
        final candidate = roster[(seed + term) % roster.length];
        controller.castVote(
          candidate: candidate,
          topIssue: controller.scenario.city.problems.first.id,
          confidence: .55,
        );
        controller.fastForwardToYearEnd(
          interruptionPreference: CriticalEventInterruption.neverInterrupt,
        );
        final simulation = controller.termResult!.livingCity;
        expect(
          simulation.validate(
            candidateIds: roster.map((item) => item.id),
            problemIds: controller.scenario.city.problems.map(
              (problem) => problem.id,
            ),
          ),
          isEmpty,
        );
        for (final indicator in CityIndicator.values) {
          expect(
            simulation.finalIndicators.valueOf(indicator),
            inInclusiveRange(0, 100),
          );
        }
        usedTemplates.addAll(
          simulation.eventHistory
              .where(
                (event) =>
                    !event.templateId.startsWith('project_milestone_') &&
                    !event.templateId.startsWith('citizen_action_'),
              )
              .map((event) => event.templateId),
        );
        controller.continueToNextElection();
      }

      expect(controller.currentElectionNumber, 11);
      expect(controller.administrationHistory, hasLength(10));
      expect(usedTemplates.length, greaterThanOrEqualTo(28));
    });
  }

  test(
    'ten administrations remain bounded, valid, diverse, and restorable',
    () async {
      final repository = MemoryRunRepository();
      final controller = GameController(repository: repository);
      addTearDown(controller.dispose);
      controller.createCity(
        slotIndex: 0,
        configuration: CityRunConfiguration.defaults(cityName: 'Longview City'),
        worldSeed: 10122026,
      );

      final usedTemplates = <String>{};
      final electedIds = <String>[];
      for (var term = 1; term <= 10; term++) {
        expect(controller.currentElectionNumber, term);
        final candidate = controller.scenario.candidates.first;
        electedIds.add(candidate.id);
        controller.castVote(
          candidate: candidate,
          topIssue: controller.scenario.city.problems.first.id,
          confidence: .6,
        );
        controller.fastForwardToYearEnd(
          interruptionPreference: CriticalEventInterruption.neverInterrupt,
        );
        final simulation = controller.termResult!.livingCity;
        expect(simulation.termNumber, term);
        expect(
          simulation.validate(
            candidateIds: controller.scenario.candidates.map((item) => item.id),
            problemIds: controller.scenario.city.problems.map(
              (problem) => problem.id,
            ),
          ),
          isEmpty,
        );
        for (final indicator in CityIndicator.values) {
          expect(
            simulation.finalIndicators.valueOf(indicator),
            inInclusiveRange(0, 100),
          );
        }
        for (final issue in simulation.finalIssueStates.values) {
          expect(issue.severity, inInclusiveRange(0, 100));
        }
        usedTemplates.addAll(
          simulation.eventHistory
              .where(
                (event) =>
                    !event.templateId.startsWith('project_milestone_') &&
                    !event.templateId.startsWith('citizen_action_'),
              )
              .map((event) => event.templateId),
        );
        controller.continueToNextElection();
      }
      await controller.flushSaves();

      expect(controller.currentElectionNumber, 11);
      expect(controller.administrationHistory, hasLength(10));
      expect(
        controller.administrationHistory.map((record) => record.id).toSet(),
        hasLength(10),
      );
      expect(usedTemplates.length, greaterThanOrEqualTo(30));
      expect(electedIds.toSet().length, greaterThanOrEqualTo(3));

      final restored = GameController(repository: repository);
      addTearDown(restored.dispose);
      await restored.restore();
      expect(restored.currentElectionNumber, 11);
      expect(restored.administrationHistory, hasLength(10));
      expect(
        restored.administrationHistory.last.livingCity.finalIndicators,
        controller.administrationHistory.last.livingCity.finalIndicators,
      );
      expect(
        restored.administrationHistory.last.livingCity.eventHistory.map(
          (event) => event.id,
        ),
        orderedEquals(
          controller.administrationHistory.last.livingCity.eventHistory.map(
            (event) => event.id,
          ),
        ),
      );
    },
  );
}
