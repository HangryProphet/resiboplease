import '../models/candidate.dart';
import '../models/citizen_action.dart';
import '../models/city_indicator.dart';
import '../models/city_indicator_set.dart';
import '../models/city_problem.dart';
import '../models/evidence_item.dart';
import '../models/living_city_simulation.dart';
import '../models/term_result.dart';

/// Adds bounded, deterministic citizen-action outcomes to the unseen future of
/// an already generated term. Existing events and project milestones are never
/// altered or rerolled.
class CitizenActionEngine {
  const CitizenActionEngine();

  static const firstActionDay = 30;
  static const lastActionDay = 350;

  bool canPerform({
    required LivingTermSimulation simulation,
    required CitizenActionType type,
    required int currentDay,
    EvidenceItem? supportingEvidence,
  }) =>
      currentDay >= firstActionDay &&
      currentDay <= lastActionDay &&
      (type != CitizenActionType.challengeMisleadingClaim ||
          isQualifyingChallengeEvidence(supportingEvidence)) &&
      !simulation.eventHistory.any(
        (event) => event.templateId == type.templateId,
      );

  bool isQualifyingChallengeEvidence(EvidenceItem? evidence) =>
      evidence != null &&
      evidence.reliability >= 75 &&
      const {
        EvidenceType.factCheck,
        EvidenceType.publicRecord,
        EvidenceType.budgetDocument,
        EvidenceType.controversy,
      }.contains(evidence.type) &&
      evidence.truthStatus != TruthStatus.unverified;

  CitizenActionResolution apply({
    required TermResult result,
    required CitizenActionType type,
    required int currentDay,
    required List<CityProblem> problems,
    int responseDelayReductionDays = 0,
    EvidenceItem? supportingEvidence,
  }) {
    final simulation = result.livingCity;
    if (!canPerform(
      simulation: simulation,
      type: type,
      currentDay: currentDay,
      supportingEvidence: supportingEvidence,
    )) {
      throw StateError(
        'Citizen action is unavailable at this point in the term.',
      );
    }

    final checkpoint = checkpointFor(simulation, currentDay);
    final currentIndicators = simulation.indicatorsThroughDay(currentDay);
    final currentIssues = simulation.issuesThroughDay(currentDay);
    final target = type == CitizenActionType.challengeMisleadingClaim
        ? null
        : _mostSevereProblem(problems, currentIssues);
    final roll = _stableRoll(
      '${simulation.seed}:${simulation.termNumber}:${result.candidate.id}:'
      '${type.name}:$currentDay:${target?.id ?? 'citywide'}:'
      '${supportingEvidence?.id ?? 'no-evidence'}',
    );
    final baseDelay = switch (type) {
      CitizenActionType.requestPublicRecords => 9 + (roll % 10),
      CitizenActionType.organizePetition => 14 + (roll % 12),
      CitizenActionType.challengeMisleadingClaim => 8 + (roll % 9),
    };
    final delay = (baseDelay - responseDelayReductionDays.clamp(0, 5)).clamp(
      5,
      30,
    );
    final outcomeDay = (currentDay + delay).clamp(currentDay + 1, 365);
    final outcome = _resolveOutcome(
      type: type,
      roll: roll,
      candidate: result.candidate,
      currentIndicators: currentIndicators,
      issueSeverity: target == null ? 50 : currentIssues[target.id]!.severity,
      evidenceReliability: supportingEvidence?.reliability,
    );
    final effects = _effects(type: type, outcome: outcome, target: target);
    final event = _buildEvent(
      simulation: simulation,
      candidate: result.candidate,
      type: type,
      outcome: outcome,
      performedDay: currentDay,
      outcomeDay: outcomeDay,
      target: target,
      indicatorEffects: effects.indicators,
      issueEffects: effects.issues,
      supportingEvidence: supportingEvidence,
    );
    final nextSimulation = _withEvent(simulation, event);
    final nextCheckpoint = checkpointFor(nextSimulation, currentDay);
    if (nextCheckpoint.stateFingerprint != checkpoint.stateFingerprint) {
      throw StateError(
        'Citizen action changed the observed simulation checkpoint.',
      );
    }
    final nextResult = TermResult(
      seed: result.seed,
      candidate: result.candidate,
      before: result.before,
      after: nextSimulation.finalIndicators,
      phases: result.phases,
      summary: '${result.summary} ${event.factualSummary}',
      livingCity: nextSimulation,
    );
    return CitizenActionResolution(
      type: type,
      outcome: outcome,
      performedDay: currentDay,
      outcomeEvent: event,
      termResult: nextResult,
      checkpoint: checkpoint,
    );
  }

  SimulationDayCheckpoint checkpointFor(
    LivingTermSimulation simulation,
    int day,
  ) {
    final checkpointDay = day.clamp(0, 365);
    final events = simulation.eventsThroughDay(checkpointDay);
    final milestones =
        simulation.projects
            .expand((project) => project.milestones)
            .where((milestone) => milestone.day <= checkpointDay)
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));
    final indicators = simulation.indicatorsThroughDay(checkpointDay);
    final issues = simulation.issuesThroughDay(checkpointDay).entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    final state = StringBuffer('day:$checkpointDay|');
    for (final event in events) {
      state.write(
        '${event.id}:${event.day}:${event.templateId}:${event.factualSummary}:'
        '${event.indicatorEffects}:${event.issueSeverityEffects}|',
      );
    }
    for (final milestone in milestones) {
      state.write(
        '${milestone.id}:${milestone.day}:${milestone.toState.name}:'
        '${milestone.progressDelta}|',
      );
    }
    for (final indicator in CityIndicator.values) {
      state.write('${indicator.name}:${indicators.valueOf(indicator)}|');
    }
    for (final issue in issues) {
      state.write(
        '${issue.key}:${issue.value.severity}:${issue.value.trend.name}|',
      );
    }
    return SimulationDayCheckpoint(
      day: checkpointDay,
      observedEventIds: List.unmodifiable(events.map((event) => event.id)),
      observedMilestoneIds: List.unmodifiable(
        milestones.map((milestone) => milestone.id),
      ),
      stateFingerprint: _stableRoll(state.toString()).toRadixString(16),
    );
  }

  CityProblem? _mostSevereProblem(
    List<CityProblem> problems,
    Map<String, CityIssueState> currentIssues,
  ) {
    final available = problems
        .where((problem) => currentIssues.containsKey(problem.id))
        .toList(growable: false);
    if (available.isEmpty) return null;
    available.sort((left, right) {
      final severity = currentIssues[right.id]!.severity.compareTo(
        currentIssues[left.id]!.severity,
      );
      return severity != 0 ? severity : left.id.compareTo(right.id);
    });
    return available.first;
  }

  CitizenActionOutcome _resolveOutcome({
    required CitizenActionType type,
    required int roll,
    required Candidate candidate,
    required CityIndicatorSet currentIndicators,
    required int issueSeverity,
    required int? evidenceReliability,
  }) {
    final capabilities = candidate.capabilities;
    final responseScore = switch (type) {
      CitizenActionType.requestPublicRecords =>
        (capabilities.integrity * 2 +
                capabilities.coalitionSkill +
                currentIndicators.valueOf(CityIndicator.publicTrust) -
                capabilities.corruptionRisk) ~/
            3,
      CitizenActionType.organizePetition =>
        (capabilities.coalitionSkill +
                capabilities.implementationSkill +
                currentIndicators.valueOf(CityIndicator.publicTrust) +
                currentIndicators.valueOf(CityIndicator.budgetHealth) -
                issueSeverity) ~/
            3,
      CitizenActionType.challengeMisleadingClaim =>
        ((evidenceReliability ?? 0) * 2 +
                currentIndicators.valueOf(CityIndicator.publicTrust) +
                capabilities.coalitionSkill +
                capabilities.integrity -
                capabilities.corruptionRisk) ~/
            4,
    };
    final score = responseScore + (roll % 41) - 20;
    if (score >= 53) return CitizenActionOutcome.succeeded;
    if (score >= 32) return CitizenActionOutcome.partial;
    return CitizenActionOutcome.resisted;
  }

  ({Map<CityIndicator, int> indicators, Map<String, int> issues}) _effects({
    required CitizenActionType type,
    required CitizenActionOutcome outcome,
    required CityProblem? target,
  }) {
    if (type == CitizenActionType.requestPublicRecords) {
      return switch (outcome) {
        CitizenActionOutcome.succeeded => (
          indicators: const {
            CityIndicator.publicTrust: 2,
            CityIndicator.corruptionPressure: -2,
          },
          issues: const {},
        ),
        CitizenActionOutcome.partial => (
          indicators: const {
            CityIndicator.publicTrust: 1,
            CityIndicator.corruptionPressure: -1,
          },
          issues: const {},
        ),
        CitizenActionOutcome.resisted => (
          indicators: const {
            CityIndicator.publicTrust: -2,
            CityIndicator.corruptionPressure: 1,
          },
          issues: const {},
        ),
      };
    }
    if (type == CitizenActionType.challengeMisleadingClaim) {
      return switch (outcome) {
        CitizenActionOutcome.succeeded => (
          indicators: const {
            CityIndicator.publicTrust: 2,
            CityIndicator.corruptionPressure: -1,
          },
          issues: const {},
        ),
        CitizenActionOutcome.partial => (
          indicators: const {CityIndicator.publicTrust: 1},
          issues: const {},
        ),
        CitizenActionOutcome.resisted => (
          indicators: const {CityIndicator.publicTrust: -1},
          issues: const {},
        ),
      };
    }
    final issueId = target?.id;
    final relevantIndicator =
        target?.primaryIndicator ?? CityIndicator.publicTrust;
    return switch (outcome) {
      CitizenActionOutcome.succeeded => (
        indicators: {CityIndicator.publicTrust: 1, relevantIndicator: 2},
        issues: {?issueId: -3},
      ),
      CitizenActionOutcome.partial => (
        indicators: {relevantIndicator: 1},
        issues: {?issueId: -1},
      ),
      CitizenActionOutcome.resisted => (
        indicators: const {CityIndicator.publicTrust: -1},
        issues: const {},
      ),
    };
  }

  CityEvent _buildEvent({
    required LivingTermSimulation simulation,
    required Candidate candidate,
    required CitizenActionType type,
    required CitizenActionOutcome outcome,
    required int performedDay,
    required int outcomeDay,
    required CityProblem? target,
    required Map<CityIndicator, int> indicatorEffects,
    required Map<String, int> issueEffects,
    required EvidenceItem? supportingEvidence,
  }) {
    final phase = _phaseForDay(outcomeDay);
    final phaseStep =
        simulation.eventHistory
            .where((event) => event.phase == phase)
            .fold<int>(
              0,
              (highest, event) => event.step > highest ? event.step : highest,
            ) +
        1;
    final targetTitle = target?.title ?? 'the citywide concern';
    final copy = _eventCopy(type, outcome, targetTitle);
    return CityEvent(
      id: 'citizen_${simulation.termNumber}_${type.name}_d$performedDay',
      templateId: type.templateId,
      chainFamily: 'citizen_action_${type.name}',
      category: CityEventCategory.political,
      severity: outcome == CitizenActionOutcome.resisted
          ? CityEventSeverity.moderate
          : CityEventSeverity.minor,
      importance: CityEventImportance.important,
      day: outcomeDay,
      phase: phase,
      step: phaseStep,
      title: copy.title,
      factualSummary: copy.summary,
      explanation: copy.explanation,
      fictionalDate: 'Day $outcomeDay, Term ${simulation.termNumber}',
      district: CitySimulationDistrict.civicCenter,
      locationId: BayhavenMapAnchors.cityHall.id,
      relatedIssueIds: target == null ? const [] : [target.id],
      relatedProjectIds: const [],
      relatedCandidateIds: [candidate.id],
      relatedEvidenceIds: supportingEvidence == null
          ? const []
          : [supportingEvidence.id],
      indicatorEffects: indicatorEffects,
      issueSeverityEffects: issueEffects,
      requiredHooks: const [],
      followUpHooks: ['citizen_action_recorded'],
      chronicleEligible: false,
      newsEligible: false,
      tvEligible: false,
      cityBookEligible: false,
      markerType: type == CitizenActionType.requestPublicRecords
          ? CityMapMarkerType.audit
          : type == CitizenActionType.challengeMisleadingClaim
          ? CityMapMarkerType.news
          : CityMapMarkerType.protest,
      markerX: BayhavenMapAnchors.cityHall.x,
      markerY: BayhavenMapAnchors.cityHall.y,
      markerLifetimeDays: 18,
    );
  }

  ({String title, String summary, String explanation}) _eventCopy(
    CitizenActionType type,
    CitizenActionOutcome outcome,
    String targetTitle,
  ) => switch ((type, outcome)) {
    (CitizenActionType.requestPublicRecords, CitizenActionOutcome.succeeded) => (
      title: 'City Hall releases requested records',
      summary:
          'A citizen records request produced a usable release and made public oversight easier.',
      explanation:
          'Administrative integrity, cooperation, and existing public trust helped the request succeed.',
    ),
    (CitizenActionType.requestPublicRecords, CitizenActionOutcome.partial) => (
      title: 'Records request receives a partial release',
      summary:
          'City Hall released some requested documents, but important gaps remain in the public record.',
      explanation:
          'The request created limited transparency, constrained by administrative capacity and resistance.',
    ),
    (CitizenActionType.requestPublicRecords, CitizenActionOutcome.resisted) => (
      title: 'City Hall resists records request',
      summary:
          'The requested records were delayed or withheld, increasing public concern over transparency.',
      explanation:
          'Weak cooperation, corruption pressure, or low trust outweighed the citizen request.',
    ),
    (CitizenActionType.organizePetition, CitizenActionOutcome.succeeded) => (
      title: 'Petition wins an official response',
      summary:
          'Organizers secured a concrete city response to $targetTitle and modest conditions improved.',
      explanation:
          'Public support combined with administrative capability and enough fiscal room to produce action.',
    ),
    (CitizenActionType.organizePetition, CitizenActionOutcome.partial) => (
      title: 'Petition earns a limited concession',
      summary:
          'Officials acknowledged the petition on $targetTitle, but the response addressed only part of the concern.',
      explanation:
          'Political pressure gained attention, while capacity and city constraints limited the response.',
    ),
    (CitizenActionType.organizePetition, CitizenActionOutcome.resisted) => (
      title: 'Petition is acknowledged but ignored',
      summary:
          'The petition on $targetTitle gathered attention without producing an official remedy.',
      explanation:
          'Issue difficulty and administrative constraints outweighed the pressure created by organizers.',
    ),
    (
      CitizenActionType.challengeMisleadingClaim,
      CitizenActionOutcome.succeeded,
    ) =>
      (
        title: 'Evidence challenge prompts a correction',
        summary:
            'Reviewed evidence prompted a public correction and added clearer context to the city record.',
        explanation:
            'Reliable reviewed evidence, public trust, and institutional cooperation helped the correction reach the record.',
      ),
    (CitizenActionType.challengeMisleadingClaim, CitizenActionOutcome.partial) => (
      title: 'Evidence challenge adds disputed context',
      summary:
          'The challenge was acknowledged and supporting context entered public discussion, but no full correction followed.',
      explanation:
          'The evidence remained valid, while limited reach or institutional resistance weakened its public effect.',
    ),
    (CitizenActionType.challengeMisleadingClaim, CitizenActionOutcome.resisted) => (
      title: 'Evidence challenge fails to gain traction',
      summary:
          'The reviewed evidence remained on record, but the challenged claim continued circulating without an official correction.',
      explanation:
          'This outcome reflects reach and institutional resistance; it does not invalidate the supporting evidence.',
    ),
  };

  LivingTermSimulation _withEvent(
    LivingTermSimulation simulation,
    CityEvent event,
  ) {
    final events = List<CityEvent>.of(simulation.eventHistory);
    final insertion = events.indexWhere((existing) => existing.day > event.day);
    if (insertion == -1) {
      events.add(event);
    } else {
      events.insert(insertion, event);
    }

    LivingTermSimulation draft() => LivingTermSimulation(
      generationVersion: simulation.generationVersion,
      seed: simulation.seed,
      termNumber: simulation.termNumber,
      candidateId: simulation.candidateId,
      initialIndicators: simulation.initialIndicators,
      finalIndicators: simulation.finalIndicators,
      initialIssueStates: simulation.initialIssueStates,
      finalIssueStates: simulation.finalIssueStates,
      projects: simulation.projects,
      phases: simulation.phases,
      eventHistory: events,
      chronicleEntries: simulation.chronicleEntries,
      newsCoverages: simulation.newsCoverages,
      tvReportEventIds: simulation.tvReportEventIds,
      cityBookPosts: simulation.cityBookPosts,
      cityBookCommentThreads: simulation.cityBookCommentThreads,
      summary: simulation.summary,
      worldConditions: simulation.worldConditions,
    );

    final withEvent = draft();
    final phases = simulation.phases
        .map(
          (phase) => LivingCityPhase(
            number: phase.number,
            title: phase.title,
            events: events
                .where((candidate) => candidate.phase == phase.number)
                .toList(growable: false),
            projectMilestones: phase.projectMilestones,
            indicatorsAfter: withEvent.indicatorsThroughDay(
              _phaseEndDay(phase.number),
            ),
            issueStatesAfter: withEvent.issuesThroughDay(
              _phaseEndDay(phase.number),
            ),
          ),
        )
        .toList(growable: false);
    return LivingTermSimulation(
      generationVersion: simulation.generationVersion,
      seed: simulation.seed,
      termNumber: simulation.termNumber,
      candidateId: simulation.candidateId,
      initialIndicators: simulation.initialIndicators,
      finalIndicators: withEvent.indicatorsThroughDay(365),
      initialIssueStates: simulation.initialIssueStates,
      finalIssueStates: withEvent.issuesThroughDay(365),
      projects: simulation.projects,
      phases: phases,
      eventHistory: events,
      chronicleEntries: simulation.chronicleEntries,
      newsCoverages: simulation.newsCoverages,
      tvReportEventIds: simulation.tvReportEventIds,
      cityBookPosts: simulation.cityBookPosts,
      cityBookCommentThreads: simulation.cityBookCommentThreads,
      summary: '${simulation.summary} ${event.factualSummary}',
      worldConditions: simulation.worldConditions,
    );
  }

  int _phaseForDay(int day) => switch (day) {
    <= 91 => 1,
    <= 182 => 2,
    <= 273 => 3,
    _ => 4,
  };

  int _phaseEndDay(int phase) => switch (phase) {
    1 => 91,
    2 => 182,
    3 => 273,
    _ => 365,
  };

  int _stableRoll(String input) {
    var hash = 0x811C9DC5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }
}
