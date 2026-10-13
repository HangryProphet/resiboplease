import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/persistence/living_city_codec.dart';
import 'package:resiboplease/data/seed_content/bayhaven_candidate_experience.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/data/seed_content/living_city_event_library.dart';
import 'package:resiboplease/domain/models/city_indicator.dart';
import 'package:resiboplease/domain/models/living_city_simulation.dart';
import 'package:resiboplease/domain/simulation/living_city_engine.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';

void main() {
  const engine = LivingCityEngine();

  test(
    'historical repetition pressure preserves unresolved issue recurrence',
    () {
      expect(
        historicalTemplateMultiplier(priorUses: 0, unresolvedSeverity: 20),
        1,
      );
      final firstUse = historicalTemplateMultiplier(
        priorUses: 1,
        unresolvedSeverity: 35,
      );
      final repeated = historicalTemplateMultiplier(
        priorUses: 3,
        unresolvedSeverity: 35,
      );
      final unresolved = historicalTemplateMultiplier(
        priorUses: 3,
        unresolvedSeverity: 82,
      );

      expect(firstUse, lessThan(1));
      expect(repeated, lessThan(firstUse));
      expect(unresolved, greaterThan(repeated));
      expect(unresolved, .68);
    },
  );

  test(
    'historical visual pressure cools combinations without banning crises',
    () {
      expect(
        historicalVisualMultiplier(priorUses: 0, unresolvedSeverity: 30),
        1,
      );
      final repeated = historicalVisualMultiplier(
        priorUses: 3,
        unresolvedSeverity: 35,
      );
      final severe = historicalVisualMultiplier(
        priorUses: 3,
        unresolvedSeverity: 82,
      );

      expect(repeated, lessThan(1));
      expect(severe, greaterThan(repeated));
      expect(severe, .78);
    },
  );

  test(
    'historical news framing cooldown is bounded and never bans a frame',
    () {
      expect(historicalNewsFramingMultiplier(priorUses: 0), 1);
      final recent = historicalNewsFramingMultiplier(priorUses: 2);
      final repeated = historicalNewsFramingMultiplier(priorUses: 20);

      expect(recent, lessThan(1));
      expect(repeated, lessThan(recent));
      expect(repeated, .24);
    },
  );

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

  test(
    'later-term history pressure changes selection without invalid events',
    () {
      final scenario = buildBayhavenScenario(seed: 5839201);
      final termTwo = scenario.copyWith(city: scenario.city.copyWith(term: 2));
      final candidate = termTwo.candidates.first;
      final baseline = engine.simulate(
        scenario: termTwo,
        candidate: candidate,
        promises: bayhavenCandidateExperience.promisesFor(candidate.id),
      );
      final repeatedTemplates = baseline.eventHistory
          .where((event) => !event.templateId.startsWith('project_milestone_'))
          .take(8)
          .map((event) => event.templateId);
      final pressured = engine.simulate(
        scenario: termTwo,
        candidate: candidate,
        promises: bayhavenCandidateExperience.promisesFor(candidate.id),
        historicalTemplatePressure: {
          for (final templateId in repeatedTemplates) templateId: 3,
        },
      );

      expect(
        pressured.eventHistory.map((event) => event.templateId),
        isNot(equals(baseline.eventHistory.map((event) => event.templateId))),
      );
      expect(
        pressured.validate(
          candidateIds: termTwo.candidates.map((item) => item.id),
          problemIds: termTwo.city.problems.map((problem) => problem.id),
        ),
        isEmpty,
      );
    },
  );

  test(
    'news framing memory varies presentation without changing event truth',
    () {
      final scenario = buildBayhavenScenario(seed: 5839201);
      final termTwo = scenario.copyWith(city: scenario.city.copyWith(term: 2));
      final candidate = termTwo.candidates.first;
      final baseline = engine.simulate(
        scenario: termTwo,
        candidate: candidate,
        promises: bayhavenCandidateExperience.promisesFor(candidate.id),
      );
      final pressure = <String, int>{};
      for (final coverage in baseline.newsCoverages.take(3)) {
        pressure[newsFramingKey(
              outletId: coverage.outletId,
              framingAngle: coverage.framingAngle,
            )] =
            20;
      }
      final reframed = engine.simulate(
        scenario: termTwo,
        candidate: candidate,
        promises: bayhavenCandidateExperience.promisesFor(candidate.id),
        historicalNewsFramingPressure: pressure,
      );

      expect(
        reframed.eventHistory.map((event) => event.id),
        orderedEquals(baseline.eventHistory.map((event) => event.id)),
      );
      expect(
        reframed.newsCoverages.map((coverage) => coverage.id),
        orderedEquals(baseline.newsCoverages.map((coverage) => coverage.id)),
      );
      expect(
        reframed.newsCoverages.map((coverage) => coverage.articleSummary),
        orderedEquals(
          baseline.newsCoverages.map((coverage) => coverage.articleSummary),
        ),
      );
      expect(
        reframed.newsCoverages.map((coverage) => coverage.framingAngle),
        isNot(
          orderedEquals(
            baseline.newsCoverages.map((coverage) => coverage.framingAngle),
          ),
        ),
      );
    },
  );

  test(
    'repeated issue events acknowledge prior administrations in public copy',
    () {
      final scenario = buildBayhavenScenario(seed: 778899);
      final termThree = scenario.copyWith(
        city: scenario.city.copyWith(term: 3),
      );
      final candidate = termThree.candidates.first;
      final issueTemplates = livingCityEventLibrary.where(
        (template) =>
            template.issueFamily != null && template.requiredHook == null,
      );
      final simulation = engine.simulate(
        scenario: termThree,
        candidate: candidate,
        promises: bayhavenCandidateExperience.promisesFor(candidate.id),
        historicalTemplatePressure: {
          for (final template in issueTemplates) template.id: 1,
        },
      );
      final issueTemplateIds = issueTemplates
          .map((template) => template.id)
          .toSet();
      final repeatedEvents = simulation.eventHistory
          .where((event) => issueTemplateIds.contains(event.templateId))
          .toList(growable: false);

      expect(repeatedEvents, isNotEmpty);
      expect(
        repeatedEvents.every(
          (event) => event.title.startsWith('Recurring civic pressure:'),
        ),
        isTrue,
      );
      expect(
        repeatedEvents.every(
          (event) => event.factualSummary.contains('earlier administration'),
        ),
        isTrue,
      );
    },
  );

  test('world conditions are deterministic, bounded, and naturally tagged', () {
    final scenario = buildBayhavenScenario(seed: 5839201);
    final first = engine.generateWorldConditions(scenario);
    final second = engine.generateWorldConditions(scenario);

    expect(first, hasLength(8));
    expect(
      first.map(
        (condition) => (
          condition.id,
          condition.type,
          condition.startDay,
          condition.durationDays,
          condition.intensity,
        ),
      ),
      orderedEquals(
        second.map(
          (condition) => (
            condition.id,
            condition.type,
            condition.startDay,
            condition.durationDays,
            condition.intensity,
          ),
        ),
      ),
    );
    for (final condition in first) {
      expect(condition.source, WorldConditionSource.natural);
      expect(condition.startDay, inInclusiveRange(1, 365));
      expect(condition.endDay, inInclusiveRange(1, 365));
      expect(condition.intensity, inInclusiveRange(1, 100));
    }
  });

  test('active conditions expose remaining days and semantic weights', () {
    const rain = WorldCondition(
      id: 'test_rain',
      type: WorldConditionType.heavyRain,
      source: WorldConditionSource.sandbox,
      startDay: 40,
      durationDays: 7,
      intensity: 80,
    );

    expect(rain.isActiveOn(39), isFalse);
    expect(rain.isActiveOn(40), isTrue);
    expect(rain.daysRemainingOn(42), 5);
    expect(rain.isActiveOn(47), isFalse);
    expect(
      rain.eventWeightMultiplier(
        CityMapMarkerType.flood,
        CityEventCategory.externalShock,
      ),
      greaterThan(1),
    );
    expect(
      rain.eventWeightMultiplier(
        CityMapMarkerType.festival,
        CityEventCategory.cityLife,
      ),
      1,
    );
  });

  test('sandbox-injected conditions remain tagged through persistence', () {
    final scenario = buildBayhavenScenario(seed: 771122);
    final injected = engine.sandboxCondition(
      id: 'sandbox_typhoon',
      type: WorldConditionType.strongTyphoon,
      startDay: 120,
      durationDays: 5,
      intensity: 91,
    );
    final simulation = engine.simulate(
      scenario: scenario,
      candidate: scenario.candidates.first,
      promises: bayhavenCandidateExperience.promisesFor(
        scenario.candidates.first.id,
      ),
      injectedWorldConditions: [injected],
    );
    final restored = LivingCityCodec.decode(LivingCityCodec.encode(simulation));
    final sandbox = restored.worldConditions.firstWhere(
      (condition) => condition.id == injected.id,
    );

    expect(sandbox.source, WorldConditionSource.sandbox);
    expect(sandbox.type, WorldConditionType.strongTyphoon);
    expect(restored.worldConditionsOnDay(122), contains(sandbox));
    expect(restored.worldConditionsOnDay(126), isNot(contains(sandbox)));
  });

  test('Bayhaven map anchors describe unique normalized geography', () {
    expect(cityMapAnchors, hasLength(27));
    expect(
      cityMapAnchors.map((anchor) => anchor.id).toSet(),
      hasLength(cityMapAnchors.length),
    );
    expect(
      cityMapAnchors.map((anchor) => anchor.id),
      containsAll(const [
        'city_hall',
        'riverside',
        'hospital',
        'school_district',
        'public_market',
        'transport_terminal',
        'industrial_zone',
        'news_headquarters',
        'waste_segregation_center',
        'subdivision_area',
        'shopping_mall',
        'police_hq',
        'fire_disaster_center',
        'water_facility',
        'government_services_center',
        'riverside_community',
        'university',
        'warehouse_logistics',
      ]),
    );
    for (final anchor in cityMapAnchors) {
      expect(anchor.labelKey, isNotEmpty);
      expect(anchor.x, inInclusiveRange(0.0, 1.0));
      expect(anchor.y, inInclusiveRange(0.0, 1.0));
    }
    expect(BayhavenMapAnchors.persistentLandmarks, hasLength(19));
    expect(
      BayhavenMapAnchors.persistentLandmarks
          .map((anchor) => anchor.x)
          .reduce((left, right) => left < right ? left : right),
      lessThan(.10),
    );
    expect(
      BayhavenMapAnchors.persistentLandmarks
          .map((anchor) => anchor.x)
          .reduce((left, right) => left > right ? left : right),
      greaterThan(.90),
    );
  });

  test('procedural histories use distributed semantic city locations', () {
    final used = <String>{};
    for (var seed = 16000; seed < 16030; seed++) {
      used.addAll(run(seed).eventHistory.map((event) => event.locationId));
    }
    expect(
      used,
      containsAll(const [
        'riverside_community',
        'water_facility',
        'government_services_center',
        'shopping_mall',
        'industrial_zone',
        'university',
      ]),
    );
    expect(used.length, greaterThanOrEqualTo(16));
  });

  test('location-sensitive templates target matching map landmarks', () {
    List<String> locationsFor(String id) => livingCityEventLibrary
        .firstWhere((template) => template.id == id)
        .preferredLocationIds;

    expect(locationsFor('clinic_surge'), ['hospital']);
    expect(locationsFor('school_repairs'), ['school_district']);
    expect(locationsFor('market_prices_rise'), ['public_market']);
    expect(locationsFor('factory_closure'), ['industrial_zone']);
    expect(locationsFor('protest_at_city_hall'), ['city_hall', 'city_plaza']);
    expect(locationsFor('drainage_overflow'), [
      'riverside',
      'west_residential',
    ]);
  });

  test('events obey prerequisites, cooldowns, and bounded state', () {
    for (var seed = 9000; seed < 9040; seed++) {
      final simulation = run(seed);
      final hooks = <String>{};
      final lastDay = <String, int>{};
      for (final event in simulation.eventHistory) {
        expect(hooks, containsAll(event.requiredHooks));
        final previous = lastDay[event.templateId];
        if (previous != null) {
          expect(event.day - previous, greaterThanOrEqualTo(18));
        }
        hooks.addAll(event.followUpHooks);
        hooks.removeAll(event.requiredHooks);
        lastDay[event.templateId] = event.day;
        expect(
          cityMapAnchors.map((anchor) => anchor.id),
          contains(event.locationId),
        );
        expect(event.day, inInclusiveRange(1, 365));
        if (event.parentEventId != null) {
          final parent = simulation.eventHistory.firstWhere(
            (item) => item.id == event.parentEventId,
          );
          expect(parent.day, lessThan(event.day));
        }
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

  test(
    'multiple worlds produce positive, neutral, and chained city stories',
    () {
      final categories = <CityEventCategory>{};
      var chained = false;
      for (var seed = 12000; seed < 12040; seed++) {
        final simulation = run(seed);
        categories.addAll(
          simulation.eventHistory.map((event) => event.category),
        );
        chained |= simulation.eventHistory.any(
          (event) => event.parentEventId != null,
        );
      }

      expect(categories, contains(CityEventCategory.positiveOpportunity));
      expect(categories, contains(CityEventCategory.cityLife));
      expect(chained, isTrue);
    },
  );

  test(
    'candidate abilities change project delivery without changing the seed',
    () {
      final scenario = buildBayhavenScenario(seed: 727272);
      final base = scenario.candidates.first;
      final promises = bayhavenCandidateExperience.promisesFor(base.id);
      final strong = base.copyWith(
        capabilities: base.capabilities.copyWith(
          implementationSkill: 92,
          coalitionSkill: 88,
          budgetDiscipline: 90,
          corruptionRisk: 12,
        ),
      );
      final weak = base.copyWith(
        capabilities: base.capabilities.copyWith(
          implementationSkill: 28,
          coalitionSkill: 31,
          budgetDiscipline: 27,
          corruptionRisk: 86,
        ),
      );

      final strongRun = engine.simulate(
        scenario: scenario,
        candidate: strong,
        promises: promises,
      );
      final weakRun = engine.simulate(
        scenario: scenario,
        candidate: weak,
        promises: promises,
      );
      final strongProgress = strongRun.projects.fold<int>(
        0,
        (sum, project) => sum + project.progress,
      );
      final weakProgress = weakRun.projects.fold<int>(
        0,
        (sum, project) => sum + project.progress,
      );

      expect(strongProgress, greaterThan(weakProgress));
    },
  );

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
    controller.advanceSimulationDays(
      365,
      interruptionPreference: CriticalEventInterruption.neverInterrupt,
    );
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
