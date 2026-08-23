import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/persistence/living_city_codec.dart';
import 'package:resiboplease/data/seed_content/bayhaven_candidate_experience.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/city_indicator.dart';
import 'package:resiboplease/domain/models/living_city_simulation.dart';
import 'package:resiboplease/domain/simulation/living_city_engine.dart';
import 'package:resiboplease/core/state/game_controller.dart';

void main() {
  const engine = LivingCityEngine();

  LivingTermSimulation run(int seed) {
    final scenario = buildBayhavenScenario(seed: seed);
    final candidate = scenario.candidates.first;
    return engine.simulate(
      scenario: scenario,
      candidate: candidate,
      promises: bayhavenCandidateExperience.promisesFor(candidate.id),
    );
  }

  test('same seed and administration produce the same complete history', () {
    final first = run(5839201);
    final second = run(5839201);

    expect(
      jsonEncode(LivingCityCodec.encode(first)),
      jsonEncode(LivingCityCodec.encode(second)),
    );
  });

  test('different world seeds produce different event histories', () {
    final first = run(5839201);
    final second = run(5839202);

    expect(
      first.eventHistory.map((event) => event.templateId),
      isNot(equals(second.eventHistory.map((event) => event.templateId))),
    );
  });

  test('events obey prerequisites, cooldowns, and bounded state', () {
    for (var seed = 9000; seed < 9040; seed++) {
      final simulation = run(seed);
      final hooks = <String>{};
      final lastPhase = <String, int>{};
      for (final event in simulation.eventHistory) {
        expect(hooks, containsAll(event.requiredHooks));
        final previous = lastPhase[event.templateId];
        if (previous != null) {
          expect(event.phase - previous, greaterThan(1));
        }
        hooks.addAll(event.followUpHooks);
        hooks.removeAll(event.requiredHooks);
        lastPhase[event.templateId] = event.phase;
      }
      for (final indicator in CityIndicator.values) {
        expect(
          simulation.finalIndicators.valueOf(indicator),
          inInclusiveRange(0, 100),
        );
      }
      for (final issue in simulation.finalIssueStates.values) {
        expect(issue.severity, inInclusiveRange(0, 100));
      }
      expect(
        simulation.validate(
          candidateIds: buildBayhavenScenario(
            seed: seed,
          ).candidates.map((candidate) => candidate.id),
          problemIds: buildBayhavenScenario(
            seed: seed,
          ).city.problems.map((problem) => problem.id),
        ),
        isEmpty,
      );
    }
  });

  test('project lifecycle records one milestone per phase', () {
    final simulation = run(41717);

    expect(simulation.projects, isNotEmpty);
    for (final project in simulation.projects) {
      expect(project.milestones, hasLength(4));
      expect(project.progress, greaterThan(0));
      expect(
        project.milestones.map((milestone) => milestone.phase),
        orderedEquals([1, 2, 3, 4]),
      );
    }
  });

  test('living snapshot survives a JSON-safe persistence round trip', () {
    final original = run(41717);
    final json =
        jsonDecode(jsonEncode(LivingCityCodec.encode(original)))
            as Map<String, Object?>;
    final restored = LivingCityCodec.decode(json);

    expect(
      restored.eventHistory.map((event) => event.id),
      orderedEquals(original.eventHistory.map((event) => event.id)),
    );
    expect(restored.finalIndicators, original.finalIndicators);
    expect(
      restored.projects.map((project) => project.progress),
      orderedEquals(original.projects.map((project) => project.progress)),
    );
    expect(
      restored.newsCoverages.map((coverage) => coverage.eventId),
      orderedEquals(original.newsCoverages.map((coverage) => coverage.eventId)),
    );
  });

  test('one event truth is shared by Chronicle, News, TV, and CityBook', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    final candidate = controller.scenario.candidates.first;
    controller.castVote(
      candidate: candidate,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );
    final living = controller.termResult!.livingCity;
    final ecosystem = controller.informationEcosystem;
    final eventId = living.tvReportEventIds.first;

    expect(
      living.chronicleEntries.any((entry) => entry.eventId == eventId),
      isTrue,
    );
    expect(ecosystem.news.eventById(eventId), isNotNull);
    expect(ecosystem.news.coverageForEvent(eventId), isNotEmpty);
    expect(ecosystem.tvBroadcasts.forEvent(eventId), isNotNull);
    expect(
      ecosystem.cityBook.posts.any(
        (post) => post.relatedNewsEventIds.contains(eventId),
      ),
      isTrue,
    );
  });
}
