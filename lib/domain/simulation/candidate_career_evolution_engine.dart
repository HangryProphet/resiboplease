import '../models/candidate_generation.dart';
import '../models/city_indicator.dart';
import '../models/living_city_simulation.dart';

class CandidateCareerEvolutionResult {
  const CandidateCareerEvolutionResult({
    required this.truth,
    required this.publicReasons,
    required this.attributeDeltas,
  });

  final CandidateTruthProfile truth;

  /// Player-safe causal explanations. These explain the historical input, not
  /// hidden values or an objective quality verdict.
  final List<String> publicReasons;

  /// Simulation-only audit data. Never render these values in candidate UI.
  final Map<String, int> attributeDeltas;
}

/// Applies small, deterministic career changes from one sealed administration.
///
/// Foundational identity, motivations, relationships, controversies, career
/// origin, personality, and quality band remain stable. Only skills and
/// pressures that have an observable causal basis in the completed term move.
class CandidateCareerEvolutionEngine {
  const CandidateCareerEvolutionEngine();

  CandidateCareerEvolutionResult evolve({
    required CandidateTruthProfile baseline,
    required LivingTermSimulation administration,
  }) {
    final projects = administration.projects;
    final completedProjects = projects
        .where(
          (project) => project.state == AdministrationProjectState.completed,
        )
        .length;
    final unresolvedProjects = projects.length - completedProjects;
    final completionRatio = projects.isEmpty
        ? 0.0
        : completedProjects / projects.length;
    final majorEvents = administration.eventHistory
        .where((event) => event.isMajor)
        .length;

    final implementationDelta = completionRatio >= .67
        ? 3
        : completionRatio >= .34
        ? 1
        : -1;
    final experienceDelta = (3 + majorEvents.clamp(0, 3)).clamp(3, 6);
    final budgetChange = _change(administration, CityIndicator.budgetHealth);
    final budgetDelta = _signedStep(budgetChange, positive: 2, negative: -2);
    final trustChange = _change(administration, CityIndicator.publicTrust);
    final communicationDelta = _signedStep(
      trustChange,
      positive: 2,
      negative: -2,
    );
    final corruptionChange = _change(
      administration,
      CityIndicator.corruptionPressure,
    );
    final integrityDelta = corruptionChange <= -3
        ? 2
        : corruptionChange >= 3
        ? -2
        : 0;
    final corruptionRiskDelta = -integrityDelta;

    final crisisIndicators = const [
      CityIndicator.publicHealth,
      CityIndicator.waterSecurity,
      CityIndicator.urbanResilience,
      CityIndicator.climateResilience,
    ];
    final crisisMovement = crisisIndicators
        .map((indicator) => _change(administration, indicator))
        .fold<int>(0, (total, change) => total + change);
    final crisisDelta = majorEvents == 0
        ? 0
        : crisisMovement >= 4
        ? 3
        : crisisMovement <= -4
        ? -2
        : 1;

    final initialIssueAverage = _averageSeverity(
      administration.initialIssueStates,
    );
    final finalIssueAverage = _averageSeverity(administration.finalIssueStates);
    final issueMovement = initialIssueAverage - finalIssueAverage;
    final adaptabilityDelta = issueMovement >= 4
        ? 2
        : issueMovement <= -4
        ? -2
        : 0;
    final coalitionDelta = completedProjects > unresolvedProjects
        ? 2
        : unresolvedProjects > completedProjects
        ? -1
        : 0;
    final competenceDelta = ((implementationDelta + adaptabilityDelta) / 2)
        .round()
        .clamp(-2, 3);
    final reformCredibilityDelta =
        ((completionRatio >= .67
                    ? 2
                    : completionRatio < .34
                    ? -1
                    : 0) +
                (corruptionChange <= -3
                    ? 2
                    : corruptionChange >= 3
                    ? -3
                    : 0) +
                (trustChange >= 3
                    ? 1
                    : trustChange <= -3
                    ? -1
                    : 0))
            .clamp(-4, 4);
    final politicalFatigueDelta =
        (3 +
                majorEvents.clamp(0, 3) +
                (unresolvedProjects > completedProjects ? 2 : 0) +
                (trustChange <= -3 ? 2 : 0) -
                (trustChange >= 5 ? 1 : 0))
            .clamp(1, 9);
    final institutionalStandingDelta =
        ((completedProjects > unresolvedProjects
                    ? 2
                    : unresolvedProjects > completedProjects
                    ? -2
                    : 0) +
                (trustChange >= 3
                    ? 1
                    : trustChange <= -3
                    ? -1
                    : 0) +
                (budgetChange <= -3 ? -1 : 0))
            .clamp(-3, 3);
    final procurementScrutiny = administration.eventHistory.any(
      (event) =>
          event.templateId == 'procurement_questions' ||
          event.templateId == 'anonymous_documents',
    );
    final evolvedControversies = [...baseline.controversies];
    final administrationScrutinyId =
        'administration_${administration.termNumber}_procurement_scrutiny';
    if (procurementScrutiny &&
        !evolvedControversies.any(
          (controversy) => controversy.id == administrationScrutinyId,
        )) {
      evolvedControversies.add(
        CandidateControversyTruth(
          id: administrationScrutinyId,
          kind: 'administration procurement scrutiny',
          summary:
              'The Administration ${administration.termNumber} record includes procurement questions that remained subject to document review.',
          status: CandidateControversyStatus.unresolved,
          relatedIssueKeys: const ['corruptionPublicFunds'],
        ),
      );
    }

    final deltas = <String, int>{
      'generalCompetence': competenceDelta,
      'implementationSkill': implementationDelta,
      'experience': experienceDelta,
      'budgetDiscipline': budgetDelta,
      'communication': communicationDelta,
      'integrity': integrityDelta,
      'corruptionRisk': corruptionRiskDelta,
      'crisisResponse': crisisDelta,
      'adaptability': adaptabilityDelta,
      'coalitionSkill': coalitionDelta,
      'reformCredibility': reformCredibilityDelta,
      'politicalFatigue': politicalFatigueDelta,
      'institutionalStanding': institutionalStandingDelta,
    };

    final evolvedPolicy = <String, int>{};
    for (final entry in baseline.policyScores.entries) {
      final indicator = CityIndicator.values
          .where((item) => item.name == entry.key)
          .firstOrNull;
      if (indicator == null) {
        evolvedPolicy[entry.key] = entry.value;
        continue;
      }
      final movement = _change(administration, indicator);
      final healthyMovement = indicator == CityIndicator.corruptionPressure
          ? -movement
          : movement;
      final delta = healthyMovement >= 5
          ? 2
          : healthyMovement <= -5
          ? -2
          : 0;
      evolvedPolicy[entry.key] = _bounded(entry.value + delta);
    }

    final reasons = <String>[
      'The archived term adds direct governing experience.',
      if (projects.isNotEmpty)
        '$completedProjects of ${projects.length} recorded projects reached completion; $unresolvedProjects remained unresolved.',
      if (majorEvents > 0)
        'The administration faced $majorEvents major city event(s), creating documented crisis experience.',
      if (budgetChange != 0)
        'Budget health moved ${_direction(budgetChange)} during the term.',
      if (trustChange != 0)
        'Public trust moved ${_direction(trustChange)} during the term.',
      if (corruptionChange != 0)
        'Corruption pressure moved ${_direction(corruptionChange)} during the term.',
      if (issueMovement.abs() >= 4)
        'Average recorded issue severity ${issueMovement > 0 ? 'fell' : 'rose'} across the administration.',
      if (reformCredibilityDelta != 0)
        'The combination of delivery, public trust, and corruption pressure ${reformCredibilityDelta > 0 ? 'strengthened' : 'weakened'} the administration\'s reform record.',
      if (institutionalStandingDelta != 0)
        'Recorded project delivery and public conditions ${institutionalStandingDelta > 0 ? 'strengthened' : 'strained'} working relationships with city institutions.',
      'A completed term added political fatigue through sustained governing pressure.',
      if (procurementScrutiny)
        'New procurement scrutiny from Administration ${administration.termNumber} remains part of the candidate\'s historical record.',
    ];

    return CandidateCareerEvolutionResult(
      truth: CandidateTruthProfile(
        qualityBand: baseline.qualityBand,
        generalCompetence: _bounded(
          baseline.generalCompetence + competenceDelta,
        ),
        implementationSkill: _bounded(
          baseline.implementationSkill + implementationDelta,
        ),
        integrity: _bounded(baseline.integrity + integrityDelta),
        corruptionRisk: _bounded(baseline.corruptionRisk + corruptionRiskDelta),
        coalitionSkill: _bounded(baseline.coalitionSkill + coalitionDelta),
        communication: _bounded(baseline.communication + communicationDelta),
        budgetDiscipline: _bounded(baseline.budgetDiscipline + budgetDelta),
        policyScores: Map.unmodifiable(evolvedPolicy),
        motivations: baseline.motivations,
        hiddenRisks: baseline.hiddenRisks,
        crisisResponse: _bounded(baseline.crisisResponse + crisisDelta),
        adaptability: _bounded(baseline.adaptability + adaptabilityDelta),
        experience: _bounded(baseline.experience + experienceDelta),
        populism: baseline.populism,
        ambition: baseline.ambition,
        reformCredibility: _bounded(
          baseline.reformCredibility + reformCredibilityDelta,
        ),
        politicalFatigue: _bounded(
          baseline.politicalFatigue + politicalFatigueDelta,
        ),
        institutionalStanding: _bounded(
          baseline.institutionalStanding + institutionalStandingDelta,
        ),
        informationFootprint: baseline.informationFootprint,
        careerOrigin: baseline.careerOrigin,
        personalityTags: baseline.personalityTags,
        controversies: List.unmodifiable(evolvedControversies),
        relationships: baseline.relationships,
      ),
      publicReasons: List.unmodifiable(reasons),
      attributeDeltas: Map.unmodifiable(deltas),
    );
  }

  int _change(LivingTermSimulation term, CityIndicator indicator) =>
      term.finalIndicators.valueOf(indicator) -
      term.initialIndicators.valueOf(indicator);

  int _signedStep(int value, {required int positive, required int negative}) =>
      value >= 3
      ? positive
      : value <= -3
      ? negative
      : 0;

  double _averageSeverity(Map<String, CityIssueState> issues) {
    if (issues.isEmpty) return 0;
    return issues.values
            .map((issue) => issue.severity)
            .fold<int>(0, (total, value) => total + value) /
        issues.length;
  }

  String _direction(int change) => change > 0 ? 'up' : 'down';

  int _bounded(int value) => value.clamp(5, 95);
}
