import 'candidate.dart';
import 'candidate_generation.dart';
import 'city_indicator.dart';
import 'city_indicator_set.dart';
import 'city_problem.dart';
import 'citybook.dart';
import 'news_media.dart';

enum CityEventCategory {
  issueDriven,
  indicatorDriven,
  administration,
  externalShock,
  positiveOpportunity,
  political,
  cityLife,
  rare,
}

enum CityEventSeverity { ambient, minor, moderate, major, critical, rare }

enum CityMapMarkerType {
  flood,
  clinic,
  water,
  roadworks,
  transport,
  jobs,
  market,
  publicSafety,
  waste,
  school,
  government,
  protest,
  audit,
  opportunity,
  festival,
  community,
  power,
  weather,
  news,
}

enum AdministrationProjectState {
  proposed,
  planning,
  awaitingFunding,
  funded,
  procurement,
  implementation,
  underConstruction,
  partiallyCompleted,
  completed,
  delayed,
  stalled,
  cancelled,
  underInvestigation,
}

enum PromiseProgressStatus {
  announced,
  started,
  progressing,
  delayed,
  completed,
  abandoned,
  compromised,
}

enum OverallCityCondition {
  thriving,
  improving,
  stable,
  strained,
  deteriorating,
  crisis,
}

enum CitySimulationDistrict {
  civicCenter,
  riverside,
  oldMarket,
  northWard,
  southPoint,
  harborDistrict,
  hillview,
  industrialBelt,
}

class CityIssueState {
  const CityIssueState({
    required this.problemId,
    required this.family,
    required this.severity,
    required this.trend,
  });

  final String problemId;
  final CityIssueFamily family;
  final int severity;
  final ProblemTrend trend;

  CityIssueState apply(int severityDelta) {
    final next = (severity + severityDelta).clamp(0, 100);
    final nextTrend = severityDelta >= 5
        ? ProblemTrend.rapidlyWorsening
        : severityDelta > 0
        ? ProblemTrend.worsening
        : severityDelta <= -4
        ? ProblemTrend.improving
        : ProblemTrend.stable;
    return CityIssueState(
      problemId: problemId,
      family: family,
      severity: next,
      trend: nextTrend,
    );
  }
}

class ProjectMilestone {
  const ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.phase,
    required this.fromState,
    required this.toState,
    required this.progressDelta,
    required this.summary,
  });

  final String id;
  final String projectId;
  final int phase;
  final AdministrationProjectState fromState;
  final AdministrationProjectState toState;
  final int progressDelta;
  final String summary;
}

class AdministrationProject {
  const AdministrationProject({
    required this.id,
    required this.candidateId,
    required this.promiseId,
    required this.title,
    required this.relatedIssueFamily,
    required this.relatedProblemId,
    required this.relevantIndicator,
    required this.cost,
    required this.estimatedPhases,
    required this.priority,
    required this.difficulty,
    required this.corruptionExposure,
    required this.publicVisibility,
    required this.progress,
    required this.state,
    required this.promiseStatus,
    required this.outcomeEffects,
    required this.milestones,
  });

  final String id;
  final String candidateId;
  final String promiseId;
  final String title;
  final CityIssueFamily relatedIssueFamily;
  final String relatedProblemId;
  final CityIndicator relevantIndicator;
  final int cost;
  final int estimatedPhases;
  final int priority;
  final int difficulty;
  final int corruptionExposure;
  final int publicVisibility;
  final int progress;
  final AdministrationProjectState state;
  final PromiseProgressStatus promiseStatus;
  final Map<CityIndicator, int> outcomeEffects;
  final List<ProjectMilestone> milestones;

  AdministrationProject copyWith({
    int? progress,
    AdministrationProjectState? state,
    PromiseProgressStatus? promiseStatus,
    List<ProjectMilestone>? milestones,
  }) => AdministrationProject(
    id: id,
    candidateId: candidateId,
    promiseId: promiseId,
    title: title,
    relatedIssueFamily: relatedIssueFamily,
    relatedProblemId: relatedProblemId,
    relevantIndicator: relevantIndicator,
    cost: cost,
    estimatedPhases: estimatedPhases,
    priority: priority,
    difficulty: difficulty,
    corruptionExposure: corruptionExposure,
    publicVisibility: publicVisibility,
    progress: progress ?? this.progress,
    state: state ?? this.state,
    promiseStatus: promiseStatus ?? this.promiseStatus,
    outcomeEffects: outcomeEffects,
    milestones: milestones ?? this.milestones,
  );
}

class CityEvent {
  const CityEvent({
    required this.id,
    required this.templateId,
    required this.chainFamily,
    required this.category,
    required this.severity,
    required this.phase,
    required this.step,
    required this.title,
    required this.factualSummary,
    required this.explanation,
    required this.fictionalDate,
    required this.district,
    required this.relatedIssueIds,
    required this.relatedProjectIds,
    required this.relatedCandidateIds,
    required this.indicatorEffects,
    required this.issueSeverityEffects,
    required this.requiredHooks,
    required this.followUpHooks,
    required this.chronicleEligible,
    required this.newsEligible,
    required this.tvEligible,
    required this.cityBookEligible,
    required this.markerType,
    required this.markerX,
    required this.markerY,
    this.visualAssetKey,
  });

  final String id;
  final String templateId;
  final String chainFamily;
  final CityEventCategory category;
  final CityEventSeverity severity;
  final int phase;
  final int step;
  final String title;
  final String factualSummary;
  final String explanation;
  final String fictionalDate;
  final CitySimulationDistrict district;
  final List<String> relatedIssueIds;
  final List<String> relatedProjectIds;
  final List<String> relatedCandidateIds;
  final Map<CityIndicator, int> indicatorEffects;
  final Map<String, int> issueSeverityEffects;
  final List<String> requiredHooks;
  final List<String> followUpHooks;
  final bool chronicleEligible;
  final bool newsEligible;
  final bool tvEligible;
  final bool cityBookEligible;
  final CityMapMarkerType markerType;
  final double markerX;
  final double markerY;
  final String? visualAssetKey;

  int get budgetEffect => indicatorEffects[CityIndicator.budgetHealth] ?? 0;

  bool get isMajor =>
      severity == CityEventSeverity.major ||
      severity == CityEventSeverity.critical ||
      severity == CityEventSeverity.rare;
}

class LivingChronicleEntry {
  const LivingChronicleEntry({
    required this.id,
    required this.eventId,
    required this.headline,
    required this.summary,
    required this.sourceLabel,
    required this.fictionalDate,
    required this.communityVoice,
  });

  final String id;
  final String eventId;
  final String headline;
  final String summary;
  final String sourceLabel;
  final String fictionalDate;
  final String communityVoice;
}

class LivingCityPhase {
  const LivingCityPhase({
    required this.number,
    required this.title,
    required this.events,
    required this.projectMilestones,
    required this.indicatorsAfter,
    required this.issueStatesAfter,
  });

  final int number;
  final String title;
  final List<CityEvent> events;
  final List<ProjectMilestone> projectMilestones;
  final CityIndicatorSet indicatorsAfter;
  final Map<String, CityIssueState> issueStatesAfter;

  Map<CityIndicator, int> changesFrom(CityIndicatorSet before) => {
    for (final indicator in CityIndicator.values)
      indicator: indicatorsAfter.valueOf(indicator) - before.valueOf(indicator),
  }..removeWhere((_, change) => change == 0);
}

class LivingTermSimulation {
  const LivingTermSimulation({
    required this.generationVersion,
    required this.seed,
    required this.termNumber,
    required this.candidateId,
    required this.initialIndicators,
    required this.finalIndicators,
    required this.initialIssueStates,
    required this.finalIssueStates,
    required this.projects,
    required this.phases,
    required this.eventHistory,
    required this.chronicleEntries,
    required this.newsCoverages,
    required this.tvReportEventIds,
    required this.cityBookPosts,
    required this.cityBookCommentThreads,
    required this.summary,
  });

  final int generationVersion;
  final int seed;
  final int termNumber;
  final String candidateId;
  final CityIndicatorSet initialIndicators;
  final CityIndicatorSet finalIndicators;
  final Map<String, CityIssueState> initialIssueStates;
  final Map<String, CityIssueState> finalIssueStates;
  final List<AdministrationProject> projects;
  final List<LivingCityPhase> phases;
  final List<CityEvent> eventHistory;
  final List<LivingChronicleEntry> chronicleEntries;
  final List<NewsCoverage> newsCoverages;
  final List<String> tvReportEventIds;
  final List<CityBookPost> cityBookPosts;
  final Map<String, CityBookCommentThread> cityBookCommentThreads;
  final String summary;

  OverallCityCondition get initialCondition =>
      overallCityCondition(initialIndicators);
  OverallCityCondition get finalCondition =>
      overallCityCondition(finalIndicators);

  List<String> validate({
    required Iterable<String> candidateIds,
    required Iterable<String> problemIds,
  }) {
    final errors = <String>[];
    final candidates = candidateIds.toSet();
    final problems = problemIds.toSet();
    final eventIds = eventHistory.map((event) => event.id).toSet();
    final projectIds = projects.map((project) => project.id).toSet();
    if (phases.length != 4 ||
        phases.map((phase) => phase.number).toSet().length != 4) {
      errors.add('A living term must contain four unique phases.');
    }
    if (eventIds.length != eventHistory.length) {
      errors.add('City event IDs must be unique.');
    }
    if (projectIds.length != projects.length) {
      errors.add('Administration project IDs must be unique.');
    }
    if (!candidates.contains(candidateId)) {
      errors.add('The elected candidate is not in the saved roster.');
    }
    for (final event in eventHistory) {
      if (!candidates.containsAll(event.relatedCandidateIds)) {
        errors.add('Event ${event.id} has an unknown candidate.');
      }
      if (!problems.containsAll(event.relatedIssueIds)) {
        errors.add('Event ${event.id} has an unknown issue.');
      }
      if (!projectIds.containsAll(event.relatedProjectIds)) {
        errors.add('Event ${event.id} has an unknown project.');
      }
      if (event.phase < 1 || event.phase > 4 || event.step < 1) {
        errors.add('Event ${event.id} has an invalid timeline position.');
      }
      if (event.markerX < 0 ||
          event.markerX > 1 ||
          event.markerY < 0 ||
          event.markerY > 1) {
        errors.add('Event ${event.id} has an invalid map marker.');
      }
    }
    final phaseEventIds = phases
        .expand((phase) => phase.events)
        .map((event) => event.id)
        .toList(growable: false);
    if (phaseEventIds.toSet().difference(eventIds).isNotEmpty ||
        eventIds.difference(phaseEventIds.toSet()).isNotEmpty) {
      errors.add('Phase events must exactly match the event history.');
    }
    for (final project in projects) {
      if (!candidates.contains(project.candidateId)) {
        errors.add('Project ${project.id} has an unknown administration.');
      }
      if (!problems.contains(project.relatedProblemId)) {
        errors.add('Project ${project.id} has an unknown issue.');
      }
      if (project.progress < 0 || project.progress > 100) {
        errors.add('Project ${project.id} has invalid progress.');
      }
      for (final milestone in project.milestones) {
        if (milestone.projectId != project.id) {
          errors.add('Milestone ${milestone.id} has an orphaned project.');
        }
      }
    }
    if (initialIssueStates.keys.toSet().difference(problems).isNotEmpty ||
        finalIssueStates.keys.toSet().difference(problems).isNotEmpty) {
      errors.add('Issue state contains an unknown problem.');
    }
    for (final state in [
      ...initialIssueStates.values,
      ...finalIssueStates.values,
    ]) {
      if (state.severity < 0 || state.severity > 100) {
        errors.add('Issue ${state.problemId} has invalid severity.');
      }
    }
    for (final coverage in newsCoverages) {
      if (!eventIds.contains(coverage.eventId)) {
        errors.add('News ${coverage.id} has an orphaned event.');
      }
    }
    for (final eventId in tvReportEventIds) {
      final event = eventHistory
          .where((item) => item.id == eventId)
          .firstOrNull;
      if (event == null || !event.tvEligible) {
        errors.add('TV report has an invalid event: $eventId.');
      }
    }
    for (final entry in chronicleEntries) {
      if (!eventIds.contains(entry.eventId)) {
        errors.add('Chronicle ${entry.id} has an orphaned event.');
      }
    }
    for (final post in cityBookPosts) {
      if (!candidates.contains(post.candidateId)) {
        errors.add('CityBook ${post.id} has an unknown candidate.');
      }
      if (!post.relatedNewsEventIds.every(eventIds.contains)) {
        errors.add('CityBook ${post.id} has an orphaned event.');
      }
      if (!cityBookCommentThreads.containsKey(post.commentThreadId)) {
        errors.add('CityBook ${post.id} has no comment thread.');
      }
    }
    return errors;
  }
}

OverallCityCondition overallCityCondition(CityIndicatorSet indicators) {
  var total = 0;
  for (final indicator in CityIndicator.values) {
    final value = indicators.valueOf(indicator);
    total += indicator == CityIndicator.corruptionPressure
        ? 100 - value
        : value;
  }
  final average = total / CityIndicator.values.length;
  return switch (average) {
    >= 73 => OverallCityCondition.thriving,
    >= 62 => OverallCityCondition.improving,
    >= 51 => OverallCityCondition.stable,
    >= 41 => OverallCityCondition.strained,
    >= 30 => OverallCityCondition.deteriorating,
    _ => OverallCityCondition.crisis,
  };
}

CandidateTruthSnapshot truthSnapshotFromCandidate(Candidate candidate) =>
    CandidateTruthSnapshot(
      generalCompetence:
          (candidate.capabilities.implementationSkill +
              candidate.capabilities.coalitionSkill) ~/
          2,
      implementationSkill: candidate.capabilities.implementationSkill,
      integrity: candidate.capabilities.integrity,
      corruptionRisk: candidate.capabilities.corruptionRisk,
      coalitionSkill: candidate.capabilities.coalitionSkill,
      communication: candidate.capabilities.coalitionSkill,
      budgetDiscipline: candidate.capabilities.budgetDiscipline,
      crisisResponse: candidate.capabilities.crisisResponse,
      adaptability: candidate.capabilities.crisisResponse,
      experience: candidate.capabilities.implementationSkill,
      policyScores: candidate.capabilities.policyScores,
    );

CandidateTruthSnapshot truthSnapshotFromProfile(
  CandidateTruthProfile profile,
  Candidate candidate,
) {
  final policyScores = Map<CityIndicator, int>.of(
    candidate.capabilities.policyScores,
  );
  const keys = <String, CityIndicator>{
    'water': CityIndicator.waterSecurity,
    'health': CityIndicator.publicHealth,
    'employment': CityIndicator.employmentQuality,
    'food': CityIndicator.foodSecurity,
    'education': CityIndicator.educationQuality,
    'climate': CityIndicator.climateResilience,
    'infrastructure': CityIndicator.urbanResilience,
  };
  for (final entry in profile.policyScores.entries) {
    final indicator = keys[entry.key];
    if (indicator != null) policyScores[indicator] = entry.value;
  }
  return CandidateTruthSnapshot(
    generalCompetence: profile.generalCompetence,
    implementationSkill: profile.implementationSkill,
    integrity: profile.integrity,
    corruptionRisk: profile.corruptionRisk,
    coalitionSkill: profile.coalitionSkill,
    communication: profile.communication,
    budgetDiscipline: profile.budgetDiscipline,
    crisisResponse: profile.crisisResponse,
    adaptability: profile.adaptability,
    experience: profile.experience,
    policyScores: Map.unmodifiable(policyScores),
  );
}

class CandidateTruthSnapshot {
  const CandidateTruthSnapshot({
    required this.generalCompetence,
    required this.implementationSkill,
    required this.integrity,
    required this.corruptionRisk,
    required this.coalitionSkill,
    required this.communication,
    required this.budgetDiscipline,
    required this.crisisResponse,
    required this.adaptability,
    required this.experience,
    required this.policyScores,
  });

  final int generalCompetence;
  final int implementationSkill;
  final int integrity;
  final int corruptionRisk;
  final int coalitionSkill;
  final int communication;
  final int budgetDiscipline;
  final int crisisResponse;
  final int adaptability;
  final int experience;
  final Map<CityIndicator, int> policyScores;

  int policyFor(CityIndicator indicator) => policyScores[indicator] ?? 50;
}
