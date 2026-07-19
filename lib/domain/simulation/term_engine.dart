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
    final eventRandom = SeededRandom(
      scenario.seed ^ _stableHash(candidate.id) ^ _stableHash('event-deck'),
    );
    final capabilities = candidate.capabilities;
    final phases = <TermPhase>[];
    final majorEvents = _selectMajorEvents(scenario, eventRandom);

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
        eventKind: TermEventKind.policyLaunch,
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

    final firstEvent = majorEvents.first;
    final firstEventChanges = _eventChanges(
      event: firstEvent,
      scenario: scenario,
      candidate: candidate,
      random: eventRandom,
    );
    phases.add(
      TermPhase(
        number: 2,
        eventKind: firstEvent.kind,
        title: firstEvent.title,
        narrative: firstEvent.narrative,
        explanation: _eventExplanation(firstEvent),
        changes: firstEventChanges,
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
        eventKind: TermEventKind.recordsReview,
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
    final secondEvent = majorEvents.last;
    final secondEventChanges = _eventChanges(
      event: secondEvent,
      scenario: scenario,
      candidate: candidate,
      random: eventRandom,
      lateTerm: true,
    );
    phases.add(
      TermPhase(
        number: 4,
        eventKind: secondEvent.kind,
        title: secondEvent.title,
        narrative:
            '${secondEvent.narrative} Meanwhile, projects reach the end of the term with a mix of completed work, partial fixes, and unfinished commitments.',
        explanation:
            '${_eventExplanation(secondEvent)} Final delivery also combines issue urgency, policy fit, implementation, integrity, coalition support, budget feasibility, and seeded variation.',
        changes: _mergeChanges(deliveryChanges, secondEventChanges),
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

  List<_TermEventDefinition> _selectMajorEvents(
    Scenario scenario,
    SeededRandom random,
  ) {
    final ranked = <({double score, _TermEventDefinition event})>[];
    for (final event in _majorEventPool) {
      final averageCondition =
          event.indicators
              .map(scenario.city.indicators.valueOf)
              .reduce((a, b) => a + b) /
          event.indicators.length;
      var problemRelevance = 0.0;
      for (final problem in scenario.city.problems) {
        if (event.indicators.contains(problem.primaryIndicator)) {
          if (problem.issueWeight > problemRelevance) {
            problemRelevance = problem.issueWeight;
          }
        } else if (problem.relatedIndicators.any(event.indicators.contains)) {
          final relatedRelevance = problem.issueWeight * .45;
          if (relatedRelevance > problemRelevance) {
            problemRelevance = relatedRelevance;
          }
        }
      }
      final score =
          (100 - averageCondition) / 100 * .62 +
          problemRelevance * .78 +
          random.between(0, .16);
      ranked.add((score: score, event: event));
    }
    ranked.sort((a, b) => b.score.compareTo(a.score));
    return List.unmodifiable(ranked.take(2).map((item) => item.event));
  }

  Map<CityIndicator, int> _eventChanges({
    required _TermEventDefinition event,
    required Scenario scenario,
    required Candidate candidate,
    required SeededRandom random,
    bool lateTerm = false,
  }) {
    final capabilities = candidate.capabilities;
    final condition =
        event.indicators
            .map(scenario.city.indicators.valueOf)
            .reduce((a, b) => a + b) /
        event.indicators.length;
    final policy =
        event.indicators.map(capabilities.policyFor).reduce((a, b) => a + b) /
        event.indicators.length;
    final response =
        policy * .38 +
        capabilities.crisisResponse * .30 +
        capabilities.implementationSkill * .20 +
        capabilities.budgetDiscipline * .12;
    final rawPenalty =
        5.2 +
        (52 - condition) / 15 -
        response / 34 +
        random.between(-.55, .55) -
        (lateTerm ? .35 : 0);
    final penalty = -rawPenalty.round().clamp(1, 6);
    final trustChange = response >= 70
        ? 1
        : response < 52
        ? -2
        : -1;
    final budgetCost = capabilities.budgetDiscipline >= 72 ? -1 : -2;

    return switch (event.kind) {
      TermEventKind.typhoonResponse => {
        CityIndicator.climateResilience: penalty,
        CityIndicator.waterSecurity: (penalty * .75).round(),
        CityIndicator.publicHealth: penalty <= -4 ? -2 : -1,
        CityIndicator.budgetHealth: budgetCost,
        CityIndicator.publicTrust: trustChange,
      },
      TermEventKind.clinicOutbreak => {
        CityIndicator.publicHealth: penalty,
        CityIndicator.povertyReduction: penalty <= -4 ? -2 : -1,
        CityIndicator.budgetHealth: budgetCost,
        CityIndicator.publicTrust: trustChange,
      },
      TermEventKind.waterEmergency => {
        CityIndicator.waterSecurity: penalty,
        CityIndicator.publicHealth: (penalty * .5).round(),
        CityIndicator.budgetHealth: budgetCost,
        CityIndicator.publicTrust: trustChange,
      },
      TermEventKind.jobsShock => {
        CityIndicator.employmentQuality: penalty,
        CityIndicator.povertyReduction: (penalty * .5).round(),
        CityIndicator.foodSecurity: penalty <= -4 ? -2 : -1,
        CityIndicator.publicTrust: trustChange,
      },
      TermEventKind.transportDisruption => {
        CityIndicator.urbanResilience: penalty,
        CityIndicator.employmentQuality: penalty <= -4 ? -2 : -1,
        CityIndicator.budgetHealth: budgetCost,
        CityIndicator.publicTrust: trustChange,
      },
      _ => const {},
    };
  }

  String _eventExplanation(_TermEventDefinition event) =>
      'The event is selected from the city seed and starting pressures. '
      'Its impact is reduced by relevant policy knowledge, crisis response, '
      'implementation skill, and budget discipline.';

  Map<CityIndicator, int> _mergeChanges(
    Map<CityIndicator, int> first,
    Map<CityIndicator, int> second,
  ) {
    final merged = <CityIndicator, int>{...first};
    for (final entry in second.entries) {
      merged.update(
        entry.key,
        (value) => value + entry.value,
        ifAbsent: () => entry.value,
      );
    }
    return merged;
  }

  int _stableHash(String value) => value.codeUnits.fold(
    0,
    (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
  );
}

class _TermEventDefinition {
  const _TermEventDefinition({
    required this.kind,
    required this.title,
    required this.narrative,
    required this.indicators,
  });

  final TermEventKind kind;
  final String title;
  final String narrative;
  final List<CityIndicator> indicators;
}

const _majorEventPool = <_TermEventDefinition>[
  _TermEventDefinition(
    kind: TermEventKind.typhoonResponse,
    title: 'Typhoon reaches Bayhaven',
    narrative:
        'A powerful storm floods low streets as emergency workers move residents toward safer ground.',
    indicators: [
      CityIndicator.climateResilience,
      CityIndicator.waterSecurity,
      CityIndicator.publicHealth,
    ],
  ),
  _TermEventDefinition(
    kind: TermEventKind.clinicOutbreak,
    title: 'Clinics face an illness surge',
    narrative:
        'A respiratory illness surge fills neighborhood clinics and forces staff to organize outdoor triage.',
    indicators: [CityIndicator.publicHealth, CityIndicator.povertyReduction],
  ),
  _TermEventDefinition(
    kind: TermEventKind.waterEmergency,
    title: 'A damaged line contaminates water',
    narrative:
        'A cracked municipal line triggers a safe-water distribution effort while repair crews trace the failure.',
    indicators: [CityIndicator.waterSecurity, CityIndicator.publicHealth],
  ),
  _TermEventDefinition(
    kind: TermEventKind.jobsShock,
    title: 'A factory closure shakes local jobs',
    narrative:
        'A waterfront factory closes without warning, leaving workers and nearby market businesses uncertain.',
    indicators: [
      CityIndicator.employmentQuality,
      CityIndicator.povertyReduction,
      CityIndicator.foodSecurity,
    ],
  ),
  _TermEventDefinition(
    kind: TermEventKind.transportDisruption,
    title: 'Road failures disrupt daily travel',
    narrative:
        'A damaged corridor stalls buses and lengthens commutes while temporary shuttles and repair crews mobilize.',
    indicators: [
      CityIndicator.urbanResilience,
      CityIndicator.employmentQuality,
    ],
  ),
];
