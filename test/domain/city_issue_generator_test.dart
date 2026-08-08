import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/seed_content/city_issue_library.dart';
import 'package:resiboplease/domain/models/city_problem.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/simulation/city_issue_generator.dart';

void main() {
  const generator = CityIssueGenerator();

  test('library covers all twelve civic issue families', () {
    expect(cityIssueLibrary, hasLength(CityIssueFamily.values.length));
    expect(
      cityIssueLibrary.map((issue) => issue.family).toSet(),
      CityIssueFamily.values.toSet(),
    );
    for (final issue in cityIssueLibrary) {
      expect(issue.affectedGroups, isNotEmpty);
      expect(issue.possibleCauses, isNotEmpty);
      expect(issue.policyHooks, isNotEmpty);
      expect(issue.chronicleHooks, isNotEmpty);
      expect(issue.communityVoiceHooks, isNotEmpty);
      expect(issue.eventHooks, isNotEmpty);
      expect(issue.visualKey, isNotEmpty);
      expect(issue.tags, isNotEmpty);
    }
  });

  test('same seed creates the same mixed four-to-six issue city', () {
    final first = generator.generate(
      seed: 908172,
      cityName: 'Harborlight',
      pressure: StartingPressure.strained,
      priorities: const [CityConcern.water, CityConcern.education],
    );
    final second = generator.generate(
      seed: 908172,
      cityName: 'Harborlight',
      pressure: StartingPressure.strained,
      priorities: const [CityConcern.water, CityConcern.education],
    );

    expect(first.length, inInclusiveRange(4, 6));
    expect(
      first.map(
        (issue) => (issue.id, issue.severity, issue.urgency, issue.trend),
      ),
      second.map(
        (issue) => (issue.id, issue.severity, issue.urgency, issue.trend),
      ),
    );
    expect(first.map((issue) => issue.family).toSet().length, first.length);
    expect(
      first.map((issue) => issue.family),
      containsAll([
        CityIssueFamily.waterSupply,
        CityIssueFamily.educationCapacity,
      ]),
    );
    expect(
      first.any(
        (issue) =>
            issue.trend == ProblemTrend.stable ||
            issue.trend == ProblemTrend.improving,
      ),
      isTrue,
    );
  });

  test('different seeds vary the active issue mix', () {
    List<String> ids(int seed) => generator
        .generate(
          seed: seed,
          cityName: 'Harborlight',
          pressure: StartingPressure.strained,
          priorities: const [CityConcern.health],
        )
        .map((issue) => issue.id)
        .toList();

    expect(ids(101), isNot(ids(202)));
  });
}
