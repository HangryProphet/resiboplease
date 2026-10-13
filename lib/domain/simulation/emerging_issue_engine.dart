import '../../data/seed_content/city_issue_library.dart';
import '../models/city_indicator.dart';
import '../models/city_indicator_set.dart';
import '../models/city_problem.dart';
import '../models/living_city_simulation.dart';
import 'seed_derivation.dart';
import 'seeded_random.dart';

class EmergingIssueTransition {
  const EmergingIssueTransition({
    required this.activeProblems,
    this.emergedProblem,
    this.resolvedProblem,
  });

  final List<CityProblem> activeProblems;
  final CityProblem? emergedProblem;
  final CityProblem? resolvedProblem;
}

/// Carries active civic problems into a later election and permits one bounded,
/// evidence-based development in the city's agenda.
///
/// The engine never rewrites an archived administration. A problem that leaves
/// the active brief remains present in that administration's issue snapshots.
/// New problems are selected only from the authored issue library, so their
/// causes, policy hooks, visuals, and SDG links remain coherent.
class EmergingIssueEngine {
  const EmergingIssueEngine();

  static const minActiveProblems = 4;
  static const maxActiveProblems = 6;

  EmergingIssueTransition transition({
    required List<CityProblem> currentProblems,
    required Map<String, CityIssueState> finalIssueStates,
    required CityIndicatorSet before,
    required CityIndicatorSet after,
    required List<AdministrationProject> projects,
    required int worldSeed,
    required int nextTerm,
    required String cityName,
  }) {
    final inherited = currentProblems
        .map((problem) {
          final state = finalIssueStates[problem.id];
          if (state == null) return problem;
          final severityChange = state.severity - problem.severity;
          return problem.copyWith(
            severity: state.severity,
            urgency: (problem.urgency + (severityChange / 3).round()).clamp(
              10,
              100,
            ),
            trend: state.trend,
          );
        })
        .toList(growable: true);

    CityProblem? resolved;
    if (inherited.length > minActiveProblems) {
      final resolutionCandidates =
          inherited
              .where(
                (problem) =>
                    problem.severity <= 18 ||
                    (problem.severity <= 27 &&
                        problem.trend == ProblemTrend.improving),
              )
              .toList(growable: false)
            ..sort(
              (left, right) => left.issueWeight.compareTo(right.issueWeight),
            );
      if (resolutionCandidates.isNotEmpty) {
        resolved = resolutionCandidates.first;
        inherited.removeWhere((problem) => problem.id == resolved!.id);
      }
    }

    CityProblem? emerged;
    if (inherited.length < maxActiveProblems) {
      final activeFamilies = inherited.map((problem) => problem.family).toSet();
      final candidates =
          cityIssueLibrary
              .where(
                (problem) =>
                    !activeFamilies.contains(problem.family) &&
                    problem.id != resolved?.id,
              )
              .map(
                (problem) => (
                  problem: problem,
                  pressure: _pressureFor(
                    problem.family,
                    before: before,
                    after: after,
                    projects: projects,
                  ),
                ),
              )
              .toList(growable: false)
            ..sort((left, right) {
              final byPressure = right.pressure.compareTo(left.pressure);
              return byPressure != 0
                  ? byPressure
                  : left.problem.id.compareTo(right.problem.id);
            });

      if (candidates.isNotEmpty && candidates.first.pressure >= 58) {
        final strongest = candidates.first.pressure;
        final nearTies = candidates
            .where((candidate) => candidate.pressure >= strongest - 3)
            .toList(growable: false);
        final random = SeededRandom(
          SeedDerivation.derive(
            worldSeed: worldSeed,
            generationVersion: 1,
            path: 'emerging-issue:election:$nextTerm',
          ),
        );
        final selected = nearTies[random.nextInt(nearTies.length)];
        final severity = (36 + selected.pressure * .38 + random.nextInt(7))
            .round()
            .clamp(42, 76);
        final urgency = (40 + selected.pressure * .4 + random.nextInt(7))
            .round()
            .clamp(45, 82);
        emerged = selected.problem.copyWith(
          description: selected.problem.description.replaceAll(
            'the city',
            cityName,
          ),
          severity: severity,
          urgency: urgency,
          trend: selected.pressure >= 82
              ? ProblemTrend.rapidlyWorsening
              : ProblemTrend.worsening,
          tags: [...selected.problem.tags, 'emerged', 'election_$nextTerm'],
        );
        inherited.add(emerged);
      }
    }

    inherited.sort(
      (left, right) => right.issueWeight.compareTo(left.issueWeight),
    );
    return EmergingIssueTransition(
      activeProblems: List.unmodifiable(inherited),
      emergedProblem: emerged,
      resolvedProblem: resolved,
    );
  }

  int _pressureFor(
    CityIssueFamily family, {
    required CityIndicatorSet before,
    required CityIndicatorSet after,
    required List<AdministrationProject> projects,
  }) {
    int low(CityIndicator indicator) => 100 - after.valueOf(indicator);
    int decline(CityIndicator indicator) =>
        (before.valueOf(indicator) - after.valueOf(indicator)).clamp(0, 100);
    int gain(CityIndicator indicator) =>
        (after.valueOf(indicator) - before.valueOf(indicator)).clamp(0, 100);
    int average(Iterable<int> values) {
      final items = values.toList(growable: false);
      return items.reduce((left, right) => left + right) ~/ items.length;
    }

    var pressure = switch (family) {
      CityIssueFamily.floodingDrainage => average([
        low(CityIndicator.climateResilience),
        low(CityIndicator.urbanResilience),
        decline(CityIndicator.climateResilience) * 3,
      ]),
      CityIssueFamily.corruptionPublicFunds => average([
        after.corruptionPressure,
        low(CityIndicator.publicTrust),
        low(CityIndicator.budgetHealth),
      ]),
      CityIssueFamily.unfinishedRoads => average([
        low(CityIndicator.urbanResilience),
        low(CityIndicator.budgetHealth),
        decline(CityIndicator.urbanResilience) * 3,
      ]),
      CityIssueFamily.drugsCommunitySafety => average([
        low(CityIndicator.urbanResilience),
        low(CityIndicator.employmentQuality),
        low(CityIndicator.publicTrust),
      ]),
      CityIssueFamily.garbageCleanliness => average([
        low(CityIndicator.urbanResilience),
        low(CityIndicator.publicHealth),
        low(CityIndicator.waterSecurity),
      ]),
      CityIssueFamily.trafficTransport => average([
        low(CityIndicator.urbanResilience),
        gain(CityIndicator.employmentQuality) * 4,
        gain(CityIndicator.povertyReduction) * 3,
      ]),
      CityIssueFamily.waterSupply => average([
        low(CityIndicator.waterSecurity),
        low(CityIndicator.climateResilience),
        gain(CityIndicator.employmentQuality) * 3,
      ]),
      CityIssueFamily.healthcareCapacity => average([
        low(CityIndicator.publicHealth),
        low(CityIndicator.budgetHealth),
        decline(CityIndicator.publicHealth) * 4,
      ]),
      CityIssueFamily.employmentQuality => average([
        low(CityIndicator.employmentQuality),
        low(CityIndicator.povertyReduction),
        decline(CityIndicator.employmentQuality) * 4,
      ]),
      CityIssueFamily.costOfLiving => average([
        low(CityIndicator.foodSecurity),
        low(CityIndicator.povertyReduction),
        low(CityIndicator.employmentQuality),
      ]),
      CityIssueFamily.governmentServices => average([
        low(CityIndicator.urbanResilience),
        low(CityIndicator.publicTrust),
        after.corruptionPressure,
      ]),
      CityIssueFamily.educationCapacity => average([
        low(CityIndicator.educationQuality),
        low(CityIndicator.budgetHealth),
        decline(CityIndicator.educationQuality) * 4,
      ]),
    };

    for (final project in projects) {
      final unfinished = project.state != AdministrationProjectState.completed;
      if (project.relatedIssueFamily == family && unfinished) pressure += 7;
      if (project.state == AdministrationProjectState.cancelled ||
          project.state == AdministrationProjectState.stalled ||
          project.state == AdministrationProjectState.underInvestigation) {
        if (family == CityIssueFamily.corruptionPublicFunds) pressure += 4;
        if (family == CityIssueFamily.governmentServices) pressure += 3;
      }
      if (project.state == AdministrationProjectState.completed &&
          project.relatedIssueFamily == CityIssueFamily.employmentQuality) {
        if (family == CityIssueFamily.trafficTransport ||
            family == CityIssueFamily.waterSupply) {
          pressure += 5;
        }
      }
      if (project.state == AdministrationProjectState.completed &&
          project.relatedIssueFamily == CityIssueFamily.unfinishedRoads &&
          family == CityIssueFamily.trafficTransport) {
        pressure += 4;
      }
    }
    return pressure.clamp(0, 100);
  }
}
