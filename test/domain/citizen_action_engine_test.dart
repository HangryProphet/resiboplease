import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/persistence/living_city_codec.dart';
import 'package:resiboplease/data/seed_content/bayhaven_candidate_experience.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/citizen_action.dart';
import 'package:resiboplease/domain/models/city_indicator.dart';
import 'package:resiboplease/domain/models/scenario.dart';
import 'package:resiboplease/domain/models/term_result.dart';
import 'package:resiboplease/domain/simulation/citizen_action_engine.dart';
import 'package:resiboplease/domain/simulation/term_engine.dart';

void main() {
  const actionEngine = CitizenActionEngine();

  ({TermResult result, Scenario scenario}) createTerm() {
    final scenario = buildBayhavenScenario(seed: 5839201);
    final candidate = scenario.candidates.first;
    final result = const TermEngine().simulate(
      scenario: scenario,
      candidate: candidate,
      promises: bayhavenCandidateExperience.promisesFor(candidate.id),
    );
    return (result: result, scenario: scenario);
  }

  test('same action inputs produce the same future outcome', () {
    final first = createTerm();
    final second = createTerm();

    final firstResolution = actionEngine.apply(
      result: first.result,
      type: CitizenActionType.requestPublicRecords,
      currentDay: 80,
      problems: first.scenario.city.problems,
    );
    final secondResolution = actionEngine.apply(
      result: second.result,
      type: CitizenActionType.requestPublicRecords,
      currentDay: 80,
      problems: second.scenario.city.problems,
    );

    expect(firstResolution.outcome, secondResolution.outcome);
    expect(
      jsonEncode(LivingCityCodec.encode(firstResolution.termResult.livingCity)),
      jsonEncode(
        LivingCityCodec.encode(secondResolution.termResult.livingCity),
      ),
    );
  });

  test('action preserves observed history and adds one valid future event', () {
    final setup = createTerm();
    const currentDay = 120;
    final before = setup.result.livingCity;
    final observedBefore = before
        .eventsThroughDay(currentDay)
        .map(
          (event) => (
            event.id,
            event.templateId,
            event.day,
            event.title,
            event.indicatorEffects,
            event.issueSeverityEffects,
          ),
        )
        .toList(growable: false);

    final resolution = actionEngine.apply(
      result: setup.result,
      type: CitizenActionType.organizePetition,
      currentDay: currentDay,
      problems: setup.scenario.city.problems,
    );
    final after = resolution.termResult.livingCity;

    expect(resolution.outcomeEvent.day, greaterThan(currentDay));
    expect(resolution.checkpoint.day, currentDay);
    expect(after.eventHistory, hasLength(before.eventHistory.length + 1));
    expect(
      after
          .eventsThroughDay(currentDay)
          .map(
            (event) => (
              event.id,
              event.templateId,
              event.day,
              event.title,
              event.indicatorEffects,
              event.issueSeverityEffects,
            ),
          ),
      orderedEquals(observedBefore),
    );
    expect(
      before.eventHistory
          .map((event) => event.id)
          .toSet()
          .difference(after.eventHistory.map((event) => event.id).toSet()),
      isEmpty,
    );
    expect(
      after.validate(
        candidateIds: setup.scenario.candidates.map(
          (candidate) => candidate.id,
        ),
        problemIds: setup.scenario.city.problems.map((problem) => problem.id),
      ),
      isEmpty,
    );
    expect(
      actionEngine.checkpointFor(after, currentDay).stateFingerprint,
      resolution.checkpoint.stateFingerprint,
    );
  });

  test(
    'claim challenge requires reviewed-quality evidence and keeps its link',
    () {
      final setup = createTerm();
      final evidence = setup.scenario.candidates
          .expand((candidate) => candidate.evidence)
          .firstWhere(actionEngine.isQualifyingChallengeEvidence);

      expect(
        actionEngine.canPerform(
          simulation: setup.result.livingCity,
          type: CitizenActionType.challengeMisleadingClaim,
          currentDay: 90,
        ),
        isFalse,
      );
      final resolution = actionEngine.apply(
        result: setup.result,
        type: CitizenActionType.challengeMisleadingClaim,
        currentDay: 90,
        problems: setup.scenario.city.problems,
        supportingEvidence: evidence,
      );

      expect(resolution.outcomeEvent.relatedEvidenceIds, [evidence.id]);
      expect(
        resolution.outcomeEvent.explanation,
        isNot(contains('invalid evidence')),
      );
      final restored = LivingCityCodec.decode(
        LivingCityCodec.encode(resolution.termResult.livingCity),
      );
      expect(
        scheduledCitizenActions(restored).single.event.relatedEvidenceIds,
        [evidence.id],
      );
    },
  );

  test('action effects remain bounded and survive codec round trip', () {
    final setup = createTerm();
    final before = setup.result.livingCity.finalIndicators;
    final resolution = actionEngine.apply(
      result: setup.result,
      type: CitizenActionType.requestPublicRecords,
      currentDay: 160,
      problems: setup.scenario.city.problems,
    );
    final simulation = resolution.termResult.livingCity;

    for (final indicator in CityIndicator.values) {
      expect(
        (simulation.finalIndicators.valueOf(indicator) -
                before.valueOf(indicator))
            .abs(),
        lessThanOrEqualTo(2),
      );
    }
    final restored = LivingCityCodec.decode(LivingCityCodec.encode(simulation));
    expect(
      scheduledCitizenActions(restored).single.event.id,
      resolution.outcomeEvent.id,
    );
  });

  test('actions are limited to their window and once per type', () {
    final setup = createTerm();
    expect(
      actionEngine.canPerform(
        simulation: setup.result.livingCity,
        type: CitizenActionType.requestPublicRecords,
        currentDay: 29,
      ),
      isFalse,
    );
    final first = actionEngine.apply(
      result: setup.result,
      type: CitizenActionType.requestPublicRecords,
      currentDay: 80,
      problems: setup.scenario.city.problems,
    );
    expect(
      () => actionEngine.apply(
        result: first.termResult,
        type: CitizenActionType.requestPublicRecords,
        currentDay: 100,
        problems: setup.scenario.city.problems,
      ),
      throwsStateError,
    );
    expect(
      actionEngine.canPerform(
        simulation: first.termResult.livingCity,
        type: CitizenActionType.organizePetition,
        currentDay: 351,
      ),
      isFalse,
    );
  });

  test(
    'civic progression can shorten response time without changing outcome',
    () {
      final setup = createTerm();
      final standard = actionEngine.apply(
        result: setup.result,
        type: CitizenActionType.requestPublicRecords,
        currentDay: 80,
        problems: setup.scenario.city.problems,
      );
      final experienced = actionEngine.apply(
        result: setup.result,
        type: CitizenActionType.requestPublicRecords,
        currentDay: 80,
        problems: setup.scenario.city.problems,
        responseDelayReductionDays: 3,
      );

      expect(experienced.outcome, standard.outcome);
      expect(experienced.outcomeEvent.day, standard.outcomeEvent.day - 3);
      expect(
        experienced.outcomeEvent.indicatorEffects,
        standard.outcomeEvent.indicatorEffects,
      );
    },
  );
}
