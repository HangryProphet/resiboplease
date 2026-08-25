export 'bayhaven_map_anchors.dart';

import 'bayhaven_map_anchors.dart';
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

enum CityEventImportance { ambient, minor, important, critical, rare }

enum SimulationSpeed {
  day(daysPerPulse: 1),
  week(daysPerPulse: 7),
  month(daysPerPulse: 30),
  year(daysPerPulse: 90);

  const SimulationSpeed({required this.daysPerPulse});

  final int daysPerPulse;
}

enum WorldConditionType {
  sunnyStretch,
  heavyRain,
  severeThunderstorms,
  heatWave,
  strongTyphoon,
  monsoonPeriod,
  oilPriceCrisis,
  fuelPriceDrop,
  supplyShortage,
  regionalEconomicSlowdown,
  businessExpansion,
  constructionMaterialIncrease,
  regionalPowerInstability,
  waterSupplyPressure,
  telecommunicationsOutage,
  logisticsDisruption,
  festivalWeek,
  schoolOpening,
  holidayRush,
  fluDengueSeason,
  graduationPeriod,
}

enum WorldConditionSource { natural, sandbox }

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

class WorldCondition {
  const WorldCondition({
    required this.id,
    required this.type,
    required this.source,
    required this.startDay,
    required this.durationDays,
    required this.intensity,
  });

  final String id;
  final WorldConditionType type;
  final WorldConditionSource source;
  final int startDay;
  final int durationDays;
  final int intensity;

  int get endDay => (startDay + durationDays - 1).clamp(1, 365);

  bool isActiveOn(int day) => day >= startDay && day <= endDay;

  int daysRemainingOn(int day) => isActiveOn(day) ? endDay - day + 1 : 0;

  double eventWeightMultiplier(
    CityMapMarkerType markerType,
    CityEventCategory category,
  ) {
    final strength = .72 + intensity.clamp(1, 100) / 180;
    final base = switch (type) {
      WorldConditionType.sunnyStretch => switch (markerType) {
        CityMapMarkerType.flood || CityMapMarkerType.water => .48,
        CityMapMarkerType.festival || CityMapMarkerType.community => 1.45,
        CityMapMarkerType.weather => 1.18,
        _ => 1.0,
      },
      WorldConditionType.heavyRain ||
      WorldConditionType.monsoonPeriod => switch (markerType) {
        CityMapMarkerType.flood => 1.9,
        CityMapMarkerType.water || CityMapMarkerType.transport => 1.45,
        CityMapMarkerType.power || CityMapMarkerType.weather => 1.35,
        _ => 1.0,
      },
      WorldConditionType.severeThunderstorms ||
      WorldConditionType.strongTyphoon => switch (markerType) {
        CityMapMarkerType.flood || CityMapMarkerType.weather => 2.35,
        CityMapMarkerType.power || CityMapMarkerType.transport => 1.8,
        CityMapMarkerType.water || CityMapMarkerType.clinic => 1.55,
        _ => 1.0,
      },
      WorldConditionType.heatWave => switch (markerType) {
        CityMapMarkerType.clinic || CityMapMarkerType.power => 1.7,
        CityMapMarkerType.water || CityMapMarkerType.weather => 1.5,
        _ => 1.0,
      },
      WorldConditionType.oilPriceCrisis ||
      WorldConditionType.supplyShortage => switch (markerType) {
        CityMapMarkerType.transport || CityMapMarkerType.market => 1.75,
        CityMapMarkerType.jobs || CityMapMarkerType.power => 1.35,
        _ => 1.0,
      },
      WorldConditionType.fuelPriceDrop ||
      WorldConditionType.businessExpansion => switch (markerType) {
        CityMapMarkerType.jobs || CityMapMarkerType.opportunity => 1.65,
        CityMapMarkerType.transport || CityMapMarkerType.market => 1.25,
        _ => category == CityEventCategory.positiveOpportunity ? 1.35 : 1.0,
      },
      WorldConditionType.regionalEconomicSlowdown ||
      WorldConditionType.constructionMaterialIncrease => switch (markerType) {
        CityMapMarkerType.jobs || CityMapMarkerType.roadworks => 1.6,
        CityMapMarkerType.market || CityMapMarkerType.transport => 1.3,
        _ => 1.0,
      },
      WorldConditionType.regionalPowerInstability =>
        markerType == CityMapMarkerType.power ? 2.4 : 1.0,
      WorldConditionType.waterSupplyPressure => switch (markerType) {
        CityMapMarkerType.water => 2.25,
        CityMapMarkerType.clinic || CityMapMarkerType.market => 1.3,
        _ => 1.0,
      },
      WorldConditionType.telecommunicationsOutage =>
        markerType == CityMapMarkerType.news ? 1.9 : 1.0,
      WorldConditionType.logisticsDisruption => switch (markerType) {
        CityMapMarkerType.transport || CityMapMarkerType.market => 1.75,
        CityMapMarkerType.jobs => 1.35,
        _ => 1.0,
      },
      WorldConditionType.festivalWeek ||
      WorldConditionType.holidayRush => switch (markerType) {
        CityMapMarkerType.festival || CityMapMarkerType.community => 1.9,
        CityMapMarkerType.transport || CityMapMarkerType.market => 1.35,
        _ => 1.0,
      },
      WorldConditionType.schoolOpening ||
      WorldConditionType.graduationPeriod => switch (markerType) {
        CityMapMarkerType.school => 1.85,
        CityMapMarkerType.transport || CityMapMarkerType.community => 1.25,
        _ => 1.0,
      },
      WorldConditionType.fluDengueSeason => switch (markerType) {
        CityMapMarkerType.clinic => 2.05,
        CityMapMarkerType.water => 1.25,
        _ => 1.0,
      },
    };
    if (base == 1) return 1;
    return base > 1 ? 1 + (base - 1) * strength : 1 - (1 - base) * strength;
  }

  int get projectProgressModifier => switch (type) {
    WorldConditionType.sunnyStretch ||
    WorldConditionType.businessExpansion ||
    WorldConditionType.fuelPriceDrop => 2,
    WorldConditionType.strongTyphoon => -5,
    WorldConditionType.heavyRain ||
    WorldConditionType.severeThunderstorms ||
    WorldConditionType.monsoonPeriod ||
    WorldConditionType.constructionMaterialIncrease ||
    WorldConditionType.logisticsDisruption => -3,
    WorldConditionType.oilPriceCrisis ||
    WorldConditionType.supplyShortage ||
    WorldConditionType.regionalPowerInstability => -2,
    _ => 0,
  };
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
    required this.day,
    required this.phase,
    required this.fromState,
    required this.toState,
    required this.progressDelta,
    required this.summary,
    this.indicatorEffects = const {},
    this.issueSeverityEffects = const {},
  });

  final String id;
  final String projectId;
  final int day;
  final int phase;
  final AdministrationProjectState fromState;
  final AdministrationProjectState toState;
  final int progressDelta;
  final String summary;
  final Map<CityIndicator, int> indicatorEffects;
  final Map<String, int> issueSeverityEffects;
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
    required this.importance,
    required this.day,
    required this.phase,
    required this.step,
    required this.title,
    required this.factualSummary,
    required this.explanation,
    required this.fictionalDate,
    required this.district,
    required this.locationId,
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
    required this.markerLifetimeDays,
    this.parentEventId,
    this.visualAssetKey,
  });

  final String id;
  final String templateId;
  final String chainFamily;
  final CityEventCategory category;
  final CityEventSeverity severity;
  final CityEventImportance importance;
  final int day;
  final int phase;
  final int step;
  final String title;
  final String factualSummary;
  final String explanation;
  final String fictionalDate;
  final CitySimulationDistrict district;
  final String locationId;
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
  final int markerLifetimeDays;
  final String? parentEventId;
  final String? visualAssetKey;

  int get budgetEffect => indicatorEffects[CityIndicator.budgetHealth] ?? 0;

  bool get isMajor =>
      severity == CityEventSeverity.major ||
      severity == CityEventSeverity.critical ||
      severity == CityEventSeverity.rare;

  bool isMarkerActiveOn(int simulatedDay) =>
      day <= simulatedDay && day + markerLifetimeDays >= simulatedDay;
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
    this.worldConditions = const [],
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
  final List<WorldCondition> worldConditions;

  OverallCityCondition get initialCondition =>
      overallCityCondition(initialIndicators);
  OverallCityCondition get finalCondition =>
      overallCityCondition(finalIndicators);

  int get totalDays => 365;

  CityIndicatorSet indicatorsThroughDay(int day) {
    var current = initialIndicators;
    final boundedDay = day.clamp(0, totalDays);
    final developments = <({int day, Map<CityIndicator, int> effects})>[
      for (final event in eventHistory)
        if (event.day <= boundedDay)
          (day: event.day, effects: event.indicatorEffects),
      for (final milestone in projects.expand((project) => project.milestones))
        if (milestone.day <= boundedDay)
          (day: milestone.day, effects: milestone.indicatorEffects),
    ]..sort((left, right) => left.day.compareTo(right.day));
    for (final development in developments) {
      current = current.apply(development.effects);
    }
    return current;
  }

  Map<String, CityIssueState> issuesThroughDay(int day) {
    var current = Map<String, CityIssueState>.of(initialIssueStates);
    final boundedDay = day.clamp(0, totalDays);
    final developments = <({int day, Map<String, int> effects})>[
      for (final event in eventHistory)
        if (event.day <= boundedDay)
          (day: event.day, effects: event.issueSeverityEffects),
      for (final milestone in projects.expand((project) => project.milestones))
        if (milestone.day <= boundedDay)
          (day: milestone.day, effects: milestone.issueSeverityEffects),
    ]..sort((left, right) => left.day.compareTo(right.day));
    for (final development in developments) {
      current = {
        for (final entry in current.entries)
          entry.key: entry.value.apply(development.effects[entry.key] ?? 0),
      };
    }
    return Map.unmodifiable(current);
  }

  List<CityEvent> eventsThroughDay(int day) =>
      eventHistory.where((event) => event.day <= day).toList(growable: false);

  List<CityEvent> activeMarkersOnDay(int day) => eventHistory
      .where(
        (event) =>
            event.importance != CityEventImportance.ambient &&
            event.isMarkerActiveOn(day),
      )
      .toList(growable: false);

  List<WorldCondition> worldConditionsOnDay(int day) => worldConditions
      .where((condition) => condition.isActiveOn(day))
      .toList(growable: false);

  LivingTermSimulation visibleThroughDay(int day) {
    final visibleIds = eventsThroughDay(day).map((event) => event.id).toSet();
    return LivingTermSimulation(
      generationVersion: generationVersion,
      seed: seed,
      termNumber: termNumber,
      candidateId: candidateId,
      initialIndicators: initialIndicators,
      finalIndicators: indicatorsThroughDay(day),
      initialIssueStates: initialIssueStates,
      finalIssueStates: issuesThroughDay(day),
      projects: projects,
      phases: phases,
      eventHistory: eventHistory
          .where((event) => visibleIds.contains(event.id))
          .toList(growable: false),
      chronicleEntries: chronicleEntries
          .where((entry) => visibleIds.contains(entry.eventId))
          .toList(growable: false),
      newsCoverages: newsCoverages
          .where((coverage) => visibleIds.contains(coverage.eventId))
          .toList(growable: false),
      tvReportEventIds: tvReportEventIds
          .where(visibleIds.contains)
          .toList(growable: false),
      cityBookPosts: cityBookPosts
          .where((post) => post.relatedNewsEventIds.any(visibleIds.contains))
          .toList(growable: false),
      cityBookCommentThreads: {
        for (final post in cityBookPosts)
          if (post.relatedNewsEventIds.any(visibleIds.contains))
            if (cityBookCommentThreads.containsKey(post.commentThreadId))
              post.commentThreadId:
                  cityBookCommentThreads[post.commentThreadId]!,
      },
      summary: summary,
      worldConditions: worldConditions,
    );
  }

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
      if (event.day < 1 || event.day > totalDays) {
        errors.add('Event ${event.id} has an invalid simulated day.');
      }
      if (!cityMapAnchors.any((anchor) => anchor.id == event.locationId)) {
        errors.add('Event ${event.id} has an invalid map location.');
      }
      if (event.parentEventId != null &&
          !eventIds.contains(event.parentEventId)) {
        errors.add('Event ${event.id} has an orphaned parent event.');
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
        if (milestone.day < 1 || milestone.day > totalDays) {
          errors.add('Milestone ${milestone.id} has an invalid simulated day.');
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
