import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/data/configuration/configured_scenario.dart';
import 'package:resiboplease/domain/models/city_indicator.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/models/term_result.dart';
import 'package:resiboplease/domain/simulation/seeded_random.dart';
import 'package:resiboplease/domain/simulation/term_engine.dart';

void main() {
  group('SeededRandom', () {
    test('repeats the same sequence for the same seed', () {
      final first = SeededRandom(5839201);
      final second = SeededRandom(5839201);

      expect(
        List.generate(20, (_) => first.nextInt(1000)),
        List.generate(20, (_) => second.nextInt(1000)),
      );
    });
  });

  group('TermEngine', () {
    const engine = TermEngine();

    test('repeats a candidate outcome for the same scenario seed', () {
      final scenario = buildBayhavenScenario(seed: 41717);
      final candidate = scenario.candidates.first;

      final first = engine.simulate(scenario: scenario, candidate: candidate);
      final second = engine.simulate(scenario: scenario, candidate: candidate);

      expect(first.after, second.after);
      expect(first.totalChanges, second.totalChanges);
      expect(
        first.phases.map((phase) => phase.changes),
        second.phases.map((phase) => phase.changes),
      );
    });

    test('candidate tradeoffs produce meaningfully different outcomes', () {
      final scenario = buildBayhavenScenario();
      final results = {
        for (final candidate in scenario.candidates)
          candidate.id: engine.simulate(
            scenario: scenario,
            candidate: candidate,
          ),
      };

      expect(
        results['julian_pratt']!.totalChanges[CityIndicator.employmentQuality],
        greaterThan(
          results['victor_chen']!.totalChanges[CityIndicator
              .employmentQuality]!,
        ),
      );
      expect(
        results['victor_chen']!.totalChanges[CityIndicator.corruptionPressure],
        lessThan(
          results['julian_pratt']!.totalChanges[CityIndicator
              .corruptionPressure]!,
        ),
      );
      expect(
        results['maya_vargas']!.totalChanges[CityIndicator.publicHealth],
        greaterThan(0),
      );
    });

    test('uses exactly four explainable phases', () {
      final scenario = buildBayhavenScenario();
      final result = engine.simulate(
        scenario: scenario,
        candidate: scenario.candidates.last,
      );

      expect(result.phases, hasLength(4));
      expect(
        result.phases.every((phase) => phase.explanation.isNotEmpty),
        isTrue,
      );
      expect(
        result.phases.expand((phase) => phase.changes.entries),
        isNotEmpty,
      );
      expect(
        result.phases.where((phase) => phase.eventKind.hasArtwork),
        hasLength(2),
      );
    });

    test('configured cities can surface every authored major event family', () {
      final seen = <TermEventKind>{};
      const concerns = <CityConcern>[
        CityConcern.climate,
        CityConcern.health,
        CityConcern.water,
        CityConcern.jobs,
        CityConcern.cityServices,
      ];
      for (final concern in concerns) {
        for (var seedOffset = 0; seedOffset < 8; seedOffset++) {
          final configuration = CityRunConfiguration.defaults().copyWith(
            mainConcerns: [concern],
          );
          final scenario = buildConfiguredScenario(
            base: buildBayhavenScenario(seed: 8000 + seedOffset),
            configuration: configuration,
          );
          final result = engine.simulate(
            scenario: scenario,
            candidate: scenario.candidates.first,
          );
          seen.addAll(
            result.phases
                .where((phase) => phase.eventKind.hasArtwork)
                .map((phase) => phase.eventKind),
          );
        }
      }

      expect(
        seen,
        containsAll(<TermEventKind>{
          TermEventKind.typhoonResponse,
          TermEventKind.clinicOutbreak,
          TermEventKind.waterEmergency,
          TermEventKind.jobsShock,
          TermEventKind.transportDisruption,
        }),
      );
    });
  });
}
