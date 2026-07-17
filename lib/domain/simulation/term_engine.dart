import '../models/candidate.dart';
import '../models/city_indicator.dart';
import '../models/scenario.dart';
import '../models/term_result.dart';
import 'seeded_random.dart';

class TermEngine {
  const TermEngine();

  TermResult simulate({
    required Scenario scenario,
    required Candidate candidate,
  }) {
    final random = SeededRandom(scenario.seed ^ _stableHash(candidate.id));
    final capabilities = candidate.capabilities;
    final phases = <TermPhase>[];

    final priority = scenario.city.problems.reduce((a, b) {
      // Squaring policy fit lets exceptional expertise influence the first
      // move without erasing the city's severity and urgency.
      final aPolicy = capabilities.policyFor(a.primaryIndicator);
      final bPolicy = capabilities.policyFor(b.primaryIndicator);
      final aScore = a.issueWeight * aPolicy * aPolicy;
      final bScore = b.issueWeight * bPolicy * bPolicy;
      return aScore >= bScore ? a : b;
    });

    final launchGain =
        (2 + capabilities.policyFor(priority.primaryIndicator) / 22).round();
    final launchCost = -(1 + (100 - capabilities.budgetDiscipline) / 24)
        .round();
    phases.add(
      TermPhase(
        number: 1,
        title: 'The first hundred days',
        narrative:
            '${candidate.name} directs the first major program toward ${priority.title.toLowerCase()}.',
        explanation:
            'The early gain reflects policy knowledge. The budget cost reflects how completely the launch was funded.',
        changes: {
          priority.primaryIndicator: launchGain,
          CityIndicator.budgetHealth: launchCost,
          CityIndicator.publicTrust: capabilities.integrity >= 75 ? 2 : 1,
        },
      ),
    );

    final stormReadiness =
        (capabilities.crisisResponse +
            capabilities.policyFor(CityIndicator.climateResilience) +
            capabilities.policyFor(CityIndicator.waterSecurity)) /
        3;
    final stormPenalty = -(7 - stormReadiness / 18).round().clamp(1, 6);
    phases.add(
      TermPhase(
        number: 2,
        title: 'Rain tests the administration',
        narrative:
            'Sustained rain floods low streets. Emergency crews contain some damage, but old systems still fail.',
        explanation:
            'Crisis response, climate planning, and water expertise reduce the seeded storm\'s impact.',
        changes: {
          CityIndicator.climateResilience: stormPenalty,
          CityIndicator.waterSecurity: stormPenalty,
          CityIndicator.publicHealth: (stormPenalty / 2).round(),
          CityIndicator.budgetHealth: -2,
        },
      ),
    );

    final corruptionChange = capabilities.corruptionRisk >= 70
        ? 5
        : capabilities.integrity >= 80
        ? -4
        : -1;
    final trustChange = corruptionChange > 0
        ? -4
        : capabilities.coalitionSkill < 50
        ? 0
        : 2;
    phases.add(
      TermPhase(
        number: 3,
        title: corruptionChange > 0
            ? 'Contract questions surface'
            : 'Records face public review',
        narrative: corruptionChange > 0
            ? 'Reporters trace a city contract to politically connected firms. Work continues while an inquiry opens.'
            : 'Procurement records are released for review. Critics still question the pace of council approvals.',
        explanation:
            'Integrity and corruption risk shape resource leakage; coalition skill affects whether transparency builds trust.',
        changes: {
          CityIndicator.corruptionPressure: corruptionChange,
          CityIndicator.publicTrust: trustChange,
          CityIndicator.budgetHealth: corruptionChange > 0 ? -3 : 1,
        },
      ),
    );

    final deliveryChanges = <CityIndicator, int>{};
    for (final problem in scenario.city.problems) {
      final capacity =
          (capabilities.policyFor(problem.primaryIndicator) * 0.35 +
              capabilities.implementationSkill * 0.25 +
              capabilities.crisisResponse * 0.15 +
              capabilities.integrity * 0.15 +
              capabilities.coalitionSkill * 0.10) /
          100;
      final feasibility =
          0.72 +
          capabilities.budgetDiscipline / 500 +
          capabilities.coalitionSkill / 700;
      final variation = random.between(0.90, 1.10);
      final gain =
          (7.5 * problem.issueWeight * capacity * feasibility * variation)
              .round()
              .clamp(1, 9);
      deliveryChanges.update(
        problem.primaryIndicator,
        (value) => value + gain,
        ifAbsent: () => gain,
      );
      for (final related in problem.relatedIndicators) {
        deliveryChanges.update(
          related,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    phases.add(
      TermPhase(
        number: 4,
        title: 'Promises meet delivery',
        narrative:
            'Projects reach the end of the term with a mix of completed work, partial fixes, and unfinished commitments.',
        explanation:
            'Final effects combine issue urgency, policy fit, implementation, integrity, coalition support, budget feasibility, and seeded variation.',
        changes: deliveryChanges,
      ),
    );

    var after = scenario.city.indicators;
    for (final phase in phases) {
      after = after.apply(phase.changes);
    }

    return TermResult(
      seed: scenario.seed,
      candidate: candidate,
      before: scenario.city.indicators,
      after: after,
      phases: phases,
      summary: _summary(candidate),
    );
  }

  String _summary(Candidate candidate) => switch (candidate.id) {
    'maya_vargas' =>
      'Clinic access improves and crisis messaging steadies the city, but aggressive spending leaves less fiscal room.',
    'julian_pratt' =>
      'Employment programs move quickly, while contracting concerns and weak flood planning erode part of the gain.',
    'victor_chen' =>
      'Water systems and public accountability improve, though limited council support slows broader economic action.',
    _ =>
      'The administration produces gains and costs shaped by its record and Bayhaven\'s conditions.',
  };

  int _stableHash(String value) => value.codeUnits.fold(
    0,
    (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
  );
}
