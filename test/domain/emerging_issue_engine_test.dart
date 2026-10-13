import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/seed_content/city_issue_library.dart';
import 'package:resiboplease/domain/models/city_indicator_set.dart';
import 'package:resiboplease/domain/models/city_problem.dart';
import 'package:resiboplease/domain/models/living_city_simulation.dart';
import 'package:resiboplease/domain/simulation/emerging_issue_engine.dart';

void main() {
  const engine = EmergingIssueEngine();

  test('a supported emerging issue enters a bounded later-election brief', () {
    final current = cityIssueLibrary.take(4).toList(growable: false);
    final result = engine.transition(
      currentProblems: current,
      finalIssueStates: _issueStates(current),
      before: _indicators(education: 60, budget: 60),
      after: _indicators(education: 10, budget: 20),
      projects: const [],
      worldSeed: 44021,
      nextTerm: 2,
      cityName: 'Harbor City',
    );

    expect(result.activeProblems, hasLength(5));
    expect(result.emergedProblem?.family, CityIssueFamily.educationCapacity);
    expect(result.emergedProblem?.tags, contains('election_2'));
    expect(result.activeProblems.length, lessThanOrEqualTo(6));
  });

  test('one resolved concern can leave as one new concern emerges', () {
    final current = cityIssueLibrary.take(6).toList(growable: false);
    final finalStates = _issueStates(current)
      ..[current.first.id] = CityIssueState(
        problemId: current.first.id,
        family: current.first.family,
        severity: 15,
        trend: ProblemTrend.improving,
      );
    final result = engine.transition(
      currentProblems: current,
      finalIssueStates: finalStates,
      before: _indicators(education: 65, budget: 55),
      after: _indicators(education: 8, budget: 18),
      projects: const [],
      worldSeed: 715,
      nextTerm: 4,
      cityName: 'Continuity City',
    );

    expect(result.resolvedProblem?.id, current.first.id);
    expect(result.emergedProblem?.family, CityIssueFamily.educationCapacity);
    expect(result.activeProblems, hasLength(6));
    expect(
      result.activeProblems.map((problem) => problem.id),
      isNot(contains(current.first.id)),
    );
  });

  test('the same city history produces the same issue transition', () {
    final current = cityIssueLibrary.take(4).toList(growable: false);
    EmergingIssueTransition run() => engine.transition(
      currentProblems: current,
      finalIssueStates: _issueStates(current),
      before: _indicators(education: 60, budget: 60),
      after: _indicators(education: 10, budget: 20),
      projects: const [],
      worldSeed: 99212,
      nextTerm: 3,
      cityName: 'Repeatable City',
    );

    final first = run();
    final second = run();
    expect(first.emergedProblem?.id, second.emergedProblem?.id);
    expect(first.emergedProblem?.severity, second.emergedProblem?.severity);
    expect(first.emergedProblem?.urgency, second.emergedProblem?.urgency);
    expect(
      first.activeProblems.map((problem) => problem.id),
      orderedEquals(second.activeProblems.map((problem) => problem.id)),
    );
  });
}

Map<String, CityIssueState> _issueStates(List<CityProblem> problems) => {
  for (final problem in problems)
    problem.id: CityIssueState(
      problemId: problem.id,
      family: problem.family,
      severity: problem.severity,
      trend: problem.trend,
    ),
};

CityIndicatorSet _indicators({required int education, required int budget}) =>
    CityIndicatorSet(
      foodSecurity: 60,
      povertyReduction: 60,
      publicHealth: 60,
      educationQuality: education,
      waterSecurity: 60,
      employmentQuality: 60,
      urbanResilience: 60,
      climateResilience: 60,
      budgetHealth: budget,
      publicTrust: 60,
      corruptionPressure: 40,
    );
