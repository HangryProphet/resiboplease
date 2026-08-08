import '../../data/seed_content/city_issue_library.dart';
import '../models/city_problem.dart';
import '../models/city_run_configuration.dart';
import 'seeded_random.dart';

class CityIssueGenerator {
  const CityIssueGenerator();

  List<CityProblem> generate({
    required int seed,
    required String cityName,
    required StartingPressure pressure,
    required List<CityConcern> priorities,
  }) {
    final random = SeededRandom(seed ^ _stableHash('city-issues'));
    final count = 4 + random.nextInt(3);
    final families = <CityIssueFamily>[];

    for (final concern in priorities) {
      final candidates = _familiesFor(
        concern,
      ).where((family) => !families.contains(family)).toList(growable: false);
      if (candidates.isNotEmpty) {
        families.add(candidates[random.nextInt(candidates.length)]);
      }
    }

    final remaining = CityIssueFamily.values
        .where((family) => !families.contains(family))
        .toList(growable: true);
    while (families.length < count && remaining.isNotEmpty) {
      families.add(remaining.removeAt(random.nextInt(remaining.length)));
    }

    final generated = <CityProblem>[];
    for (var index = 0; index < families.length; index++) {
      final source = cityIssueLibrary.firstWhere(
        (issue) => issue.family == families[index],
      );
      final isPriority = priorities.any(
        (concern) => _familiesFor(concern).contains(source.family),
      );
      final pressureDelta = switch (pressure) {
        StartingPressure.stable => -13,
        StartingPressure.strained => 0,
        StartingPressure.crisis => 11,
      };
      final priorityDelta = isPriority ? 7 : 0;
      final severity =
          (source.severity +
                  pressureDelta +
                  priorityDelta +
                  random.nextInt(15) -
                  7)
              .clamp(24, 96);
      final urgency =
          (source.urgency +
                  pressureDelta +
                  priorityDelta +
                  random.nextInt(13) -
                  6)
              .clamp(20, 98);
      var trend = _trendFor(
        random: random,
        pressure: pressure,
        severity: severity,
      );

      // Every generated city has at least one area that is holding steady or
      // recovering. A city is a mixed system, not a wall of red warnings.
      if (index == families.length - 1 &&
          generated.every(
            (issue) =>
                issue.trend == ProblemTrend.worsening ||
                issue.trend == ProblemTrend.rapidlyWorsening,
          )) {
        trend = pressure == StartingPressure.stable
            ? ProblemTrend.improving
            : ProblemTrend.stable;
      }

      generated.add(
        source.copyWith(
          description: source.description.replaceAll('the city', cityName),
          severity: severity,
          urgency: urgency,
          trend: trend,
        ),
      );
    }

    generated.sort((a, b) => b.issueWeight.compareTo(a.issueWeight));
    return List.unmodifiable(generated);
  }
}

List<CityIssueFamily> _familiesFor(CityConcern concern) => switch (concern) {
  CityConcern.food => const [CityIssueFamily.costOfLiving],
  CityConcern.poverty => const [
    CityIssueFamily.costOfLiving,
    CityIssueFamily.employmentQuality,
  ],
  CityConcern.health => const [CityIssueFamily.healthcareCapacity],
  CityConcern.education => const [CityIssueFamily.educationCapacity],
  CityConcern.water => const [CityIssueFamily.waterSupply],
  CityConcern.jobs => const [CityIssueFamily.employmentQuality],
  CityConcern.cityServices => const [
    CityIssueFamily.trafficTransport,
    CityIssueFamily.unfinishedRoads,
    CityIssueFamily.governmentServices,
  ],
  CityConcern.climate => const [CityIssueFamily.floodingDrainage],
};

ProblemTrend _trendFor({
  required SeededRandom random,
  required StartingPressure pressure,
  required int severity,
}) {
  final roll = random.nextInt(100);
  return switch (pressure) {
    StartingPressure.stable =>
      roll < 28
          ? ProblemTrend.improving
          : roll < 65
          ? ProblemTrend.stable
          : ProblemTrend.worsening,
    StartingPressure.strained =>
      roll < 12
          ? ProblemTrend.improving
          : roll < 35
          ? ProblemTrend.stable
          : roll < 88 || severity < 78
          ? ProblemTrend.worsening
          : ProblemTrend.rapidlyWorsening,
    StartingPressure.crisis =>
      roll < 15
          ? ProblemTrend.stable
          : roll < 63
          ? ProblemTrend.worsening
          : ProblemTrend.rapidlyWorsening,
  };
}

int _stableHash(String value) => value.codeUnits.fold(
  0,
  (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
);
