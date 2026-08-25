import '../../data/seed_content/living_city_event_library.dart';
import '../models/candidate.dart';
import '../models/candidate_biography.dart';
import '../models/city_indicator.dart';
import '../models/city_indicator_set.dart';
import '../models/city_problem.dart';
import '../models/citybook.dart';
import '../models/living_city_simulation.dart';
import '../models/news_media.dart';
import '../models/scenario.dart';
import 'seed_derivation.dart';
import 'seeded_random.dart';
import 'citybook_comment_reaction_engine.dart';

class LivingCityEngine {
  const LivingCityEngine();

  static const generationVersion = 4;
  static const totalDays = 365;

  LivingTermSimulation simulate({
    required Scenario scenario,
    required Candidate candidate,
    CandidateTruthSnapshot? truth,
    List<CandidatePromise> promises = const [],
    List<WorldCondition> injectedWorldConditions = const [],
  }) {
    final candidateTruth = truth ?? truthSnapshotFromCandidate(candidate);
    var indicators = scenario.city.indicators;
    final initialIssues = <String, CityIssueState>{
      for (final problem in scenario.city.problems)
        problem.id: CityIssueState(
          problemId: problem.id,
          family: problem.family,
          severity: problem.severity,
          trend: problem.trend,
        ),
    };
    var issues = Map<String, CityIssueState>.of(initialIssues);
    final worldConditions = [
      ...generateWorldConditions(scenario),
      ...injectedWorldConditions.where(
        (condition) => condition.source == WorldConditionSource.sandbox,
      ),
    ]..sort((left, right) => left.startDay.compareTo(right.startDay));
    var projects = _createProjects(
      scenario: scenario,
      candidate: candidate,
      promises: promises,
      truth: candidateTruth,
    );
    final projectReviewDays = {
      for (final project in projects)
        project.id: _projectReviewDays(scenario, project),
    };

    final history = <CityEvent>[];
    final pendingHooks = <String, _PendingHook>{};
    final usedTemplateIds = <String>{};
    final lastTemplateDay = <String, int>{};
    final lastChainDay = <String, int>{};
    final lastLocationDay = <String, int>{};
    final lastIssueDay = <CityIssueFamily, int>{};
    final phaseEvents = <int, List<CityEvent>>{
      for (var phase = 1; phase <= 4; phase++) phase: [],
    };
    final phaseMilestones = <int, List<ProjectMilestone>>{
      for (var phase = 1; phase <= 4; phase++) phase: [],
    };
    final phaseIndicators = <int, CityIndicatorSet>{};
    final phaseIssues = <int, Map<String, CityIssueState>>{};
    final phaseSteps = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};
    var lastNarrativeDay = 0;

    for (var day = 1; day <= totalDays; day++) {
      final phase = phaseForDay(day);
      final activeWorldConditions = worldConditions
          .where((condition) => condition.isActiveOn(day))
          .toList(growable: false);
      pendingHooks.removeWhere((_, hook) => day > hook.expiresDay);

      for (
        var projectIndex = 0;
        projectIndex < projects.length;
        projectIndex++
      ) {
        final project = projects[projectIndex];
        if (!projectReviewDays[project.id]!.contains(day)) continue;
        final advance = _advanceProject(
          scenario: scenario,
          truth: candidateTruth,
          project: project,
          day: day,
          phase: phase,
          indicators: indicators,
          worldConditions: activeWorldConditions,
        );
        projects = [...projects]..[projectIndex] = advance.project;
        indicators = indicators.apply(advance.milestone.indicatorEffects);
        issues = _applyIssueEffects(
          issues,
          advance.milestone.issueSeverityEffects,
        );
        phaseMilestones[phase]!.add(advance.milestone);
        phaseSteps[phase] = phaseSteps[phase]! + 1;
        final projectEvent = _projectEvent(
          scenario: scenario,
          candidate: candidate,
          project: advance.project,
          milestone: advance.milestone,
          day: day,
          phase: phase,
          step: phaseSteps[phase]!,
        );
        history.add(projectEvent);
        phaseEvents[phase]!.add(projectEvent);
        lastChainDay[projectEvent.chainFamily] = day;
      }

      final eventRandom = SeededRandom(
        SeedDerivation.derive(
          worldSeed: scenario.seed,
          generationVersion: generationVersion,
          path: 'term:${scenario.city.term}:day:$day:event-roll',
        ),
      );
      final eligibleHookExists = pendingHooks.values.any(
        (hook) => day >= hook.eligibleDay && day <= hook.expiresDay,
      );
      var dailyChance = .078;
      if (day - lastNarrativeDay >= 10) dailyChance += .11;
      if (day - lastNarrativeDay >= 16) dailyChance += .55;
      if (eligibleHookExists) dailyChance += .12;
      if (phaseEvents[phase]!.any((event) => event.day == day)) {
        dailyChance *= .35;
      }
      if (eventRandom.nextDouble() <= dailyChance.clamp(.02, .86)) {
        final selected = _selectDailyEvent(
          scenario: scenario,
          truth: candidateTruth,
          day: day,
          phase: phase,
          indicators: indicators,
          issues: issues,
          projects: projects,
          history: history,
          pendingHooks: pendingHooks,
          usedTemplateIds: usedTemplateIds,
          lastTemplateDay: lastTemplateDay,
          lastChainDay: lastChainDay,
          lastLocationDay: lastLocationDay,
          lastIssueDay: lastIssueDay,
          worldConditions: activeWorldConditions,
        );
        if (selected != null) {
          final sourceHook = selected.requiredHook == null
              ? null
              : pendingHooks[selected.requiredHook!];
          phaseSteps[phase] = phaseSteps[phase]! + 1;
          final event = _materializeEvent(
            scenario: scenario,
            candidate: candidate,
            truth: candidateTruth,
            projects: projects,
            template: selected,
            day: day,
            phase: phase,
            step: phaseSteps[phase]!,
            parentEventId: sourceHook?.sourceEventId,
          );
          history.add(event);
          phaseEvents[phase]!.add(event);
          indicators = indicators.apply(event.indicatorEffects);
          issues = _applyIssueEffects(issues, event.issueSeverityEffects);
          lastNarrativeDay = day;
          usedTemplateIds.add(event.templateId);
          lastTemplateDay[event.templateId] = day;
          lastChainDay[event.chainFamily] = day;
          lastLocationDay[event.locationId] = day;
          if (selected.issueFamily case final family?) {
            lastIssueDay[family] = day;
          }
          if (selected.requiredHook case final required?) {
            pendingHooks.remove(required);
          }
          for (final hookName in selected.followUpHooks) {
            final hookRandom = SeededRandom(
              SeedDerivation.derive(
                worldSeed: scenario.seed,
                generationVersion: generationVersion,
                path:
                    'term:${scenario.city.term}:day:$day:event:${event.id}:hook:$hookName',
              ),
            );
            final delay = selected.followUpDelayDays + hookRandom.nextInt(10);
            pendingHooks[hookName] = _PendingHook(
              sourceEventId: event.id,
              eligibleDay: (day + delay).clamp(1, totalDays),
              expiresDay: (day + selected.followUpWindowDays).clamp(
                1,
                totalDays,
              ),
            );
          }
        }
      }

      if (day == 91 || day == 182 || day == 273 || day == totalDays) {
        phaseIndicators[phase] = indicators;
        phaseIssues[phase] = Map.unmodifiable(Map.of(issues));
      }
    }

    final phases = [
      for (var phase = 1; phase <= 4; phase++)
        LivingCityPhase(
          number: phase,
          title: _phaseTitle(phase),
          events: List.unmodifiable(phaseEvents[phase]!),
          projectMilestones: List.unmodifiable(phaseMilestones[phase]!),
          indicatorsAfter: phaseIndicators[phase]!,
          issueStatesAfter: phaseIssues[phase]!,
        ),
    ];
    final orderedHistory = [...history]
      ..sort((left, right) {
        final dayOrder = left.day.compareTo(right.day);
        return dayOrder != 0 ? dayOrder : left.id.compareTo(right.id);
      });
    final chronicle = _chronicleEntries(orderedHistory);
    final news = _newsCoverages(orderedHistory);
    final cityBook = _cityBookArtifacts(candidate, orderedHistory, projects);
    final tvEvents = orderedHistory
        .where(
          (event) =>
              event.tvEligible &&
              (event.importance == CityEventImportance.important ||
                  event.importance == CityEventImportance.critical ||
                  event.importance == CityEventImportance.rare),
        )
        .map((event) => event.id)
        .take(8)
        .toList(growable: false);
    final simulation = LivingTermSimulation(
      generationVersion: generationVersion,
      seed: scenario.seed,
      termNumber: scenario.city.term,
      candidateId: candidate.id,
      initialIndicators: scenario.city.indicators,
      finalIndicators: indicators,
      initialIssueStates: Map.unmodifiable(initialIssues),
      finalIssueStates: Map.unmodifiable(issues),
      projects: List.unmodifiable(projects),
      phases: List.unmodifiable(phases),
      eventHistory: List.unmodifiable(orderedHistory),
      chronicleEntries: List.unmodifiable(chronicle),
      newsCoverages: List.unmodifiable(news),
      tvReportEventIds: List.unmodifiable(tvEvents),
      cityBookPosts: List.unmodifiable(cityBook.$1),
      cityBookCommentThreads: Map.unmodifiable(cityBook.$2),
      summary: _termSummary(candidate, indicators, projects),
      worldConditions: List.unmodifiable(worldConditions),
    );
    final errors = simulation.validate(
      candidateIds: scenario.candidates.map((item) => item.id),
      problemIds: scenario.city.problems.map((item) => item.id),
    );
    if (errors.isNotEmpty) {
      throw StateError('Invalid living city simulation: ${errors.join(' ')}');
    }
    return simulation;
  }

  static int phaseForDay(int day) => switch (day.clamp(1, totalDays)) {
    <= 91 => 1,
    <= 182 => 2,
    <= 273 => 3,
    _ => 4,
  };

  List<WorldCondition> generateWorldConditions(Scenario scenario) {
    final random = SeededRandom(
      SeedDerivation.derive(
        worldSeed: scenario.seed,
        generationVersion: generationVersion,
        path: 'term:${scenario.city.term}:world-conditions',
      ),
    );
    const pool = <WorldConditionType>[
      WorldConditionType.sunnyStretch,
      WorldConditionType.heavyRain,
      WorldConditionType.heavyRain,
      WorldConditionType.severeThunderstorms,
      WorldConditionType.heatWave,
      WorldConditionType.strongTyphoon,
      WorldConditionType.monsoonPeriod,
      WorldConditionType.oilPriceCrisis,
      WorldConditionType.fuelPriceDrop,
      WorldConditionType.supplyShortage,
      WorldConditionType.regionalEconomicSlowdown,
      WorldConditionType.businessExpansion,
      WorldConditionType.constructionMaterialIncrease,
      WorldConditionType.regionalPowerInstability,
      WorldConditionType.waterSupplyPressure,
      WorldConditionType.telecommunicationsOutage,
      WorldConditionType.logisticsDisruption,
      WorldConditionType.festivalWeek,
      WorldConditionType.schoolOpening,
      WorldConditionType.holidayRush,
      WorldConditionType.fluDengueSeason,
      WorldConditionType.graduationPeriod,
    ];
    final conditions = <WorldCondition>[];
    WorldConditionType? previous;
    for (var index = 0; index < 8; index++) {
      var type = pool[random.nextInt(pool.length)];
      if (type == previous) type = pool[(pool.indexOf(type) + 5) % pool.length];
      previous = type;
      final duration = switch (type) {
        WorldConditionType.strongTyphoon => 3 + random.nextInt(4),
        WorldConditionType.severeThunderstorms ||
        WorldConditionType.festivalWeek ||
        WorldConditionType.telecommunicationsOutage => 4 + random.nextInt(5),
        WorldConditionType.heavyRain ||
        WorldConditionType.sunnyStretch ||
        WorldConditionType.heatWave ||
        WorldConditionType.schoolOpening ||
        WorldConditionType.graduationPeriod => 7 + random.nextInt(10),
        _ => 18 + random.nextInt(24),
      };
      final segmentStart = 1 + index * 45;
      conditions.add(
        WorldCondition(
          id: 'world_condition_t${scenario.city.term}_${index}_${type.name}',
          type: type,
          source: WorldConditionSource.natural,
          startDay: (segmentStart + random.nextInt(26)).clamp(1, totalDays),
          durationDays: duration,
          intensity: 45 + random.nextInt(51),
        ),
      );
    }
    return List.unmodifiable(conditions);
  }

  WorldCondition sandboxCondition({
    required WorldConditionType type,
    required int startDay,
    required int durationDays,
    int intensity = 75,
    String id = 'sandbox_condition',
  }) => WorldCondition(
    id: id,
    type: type,
    source: WorldConditionSource.sandbox,
    startDay: startDay.clamp(1, totalDays),
    durationDays: durationDays.clamp(1, totalDays),
    intensity: intensity.clamp(1, 100),
  );

  List<AdministrationProject> _createProjects({
    required Scenario scenario,
    required Candidate candidate,
    required List<CandidatePromise> promises,
    required CandidateTruthSnapshot truth,
  }) {
    final relevantPromises = promises
        .where((promise) => promise.candidateId == candidate.id)
        .take(3)
        .toList(growable: false);
    if (relevantPromises.isEmpty) {
      final rankedProblems = scenario.city.problems.toList(growable: false)
        ..sort((left, right) {
          final leftFit =
              left.issueWeight * truth.policyFor(left.primaryIndicator);
          final rightFit =
              right.issueWeight * truth.policyFor(right.primaryIndicator);
          return rightFit.compareTo(leftFit);
        });
      return rankedProblems
          .take(2)
          .map(
            (problem) => _projectFor(
              candidate: candidate,
              promiseId: 'platform_${problem.id}',
              title: '${problem.title} response program',
              family: problem.family,
              problem: problem,
              difficulty: 55,
              truth: truth,
            ),
          )
          .toList(growable: false);
    }
    return relevantPromises
        .map((promise) {
          final matches = scenario.city.problems
              .where(
                (problem) =>
                    promise.relatedIssueFamilies.contains(problem.family),
              )
              .toList(growable: false);
          final problem = matches.isEmpty
              ? scenario.city.problems.first
              : matches.reduce(
                  (left, right) =>
                      truth.policyFor(left.primaryIndicator) >=
                          truth.policyFor(right.primaryIndicator)
                      ? left
                      : right,
                );
          final difficulty = switch (promise.complexity) {
            CandidatePromiseComplexity.focusedProgram => 42,
            CandidatePromiseComplexity.multiAgency => 58,
            CandidatePromiseComplexity.capitalProject => 70,
            CandidatePromiseComplexity.structuralReform => 76,
          };
          return _projectFor(
            candidate: candidate,
            promiseId: promise.id,
            title: promise.title,
            family: problem.family,
            problem: problem,
            difficulty: difficulty,
            truth: truth,
          );
        })
        .toList(growable: false);
  }

  AdministrationProject _projectFor({
    required Candidate candidate,
    required String promiseId,
    required String title,
    required CityIssueFamily family,
    required CityProblem problem,
    required int difficulty,
    required CandidateTruthSnapshot truth,
  }) => AdministrationProject(
    id: 'project_${candidate.id}_$promiseId',
    candidateId: candidate.id,
    promiseId: promiseId,
    title: title,
    relatedIssueFamily: family,
    relatedProblemId: problem.id,
    relevantIndicator: problem.primaryIndicator,
    cost: (difficulty * (110 - truth.budgetDiscipline) / 35).round().clamp(
      30,
      180,
    ),
    estimatedPhases: difficulty >= 70 ? 4 : 3,
    priority: (problem.severity + problem.urgency) ~/ 2,
    difficulty: difficulty,
    corruptionExposure: (difficulty + truth.corruptionRisk) ~/ 2,
    publicVisibility: (problem.urgency + 55) ~/ 2,
    progress: 0,
    state: AdministrationProjectState.proposed,
    promiseStatus: PromiseProgressStatus.announced,
    outcomeEffects: {problem.primaryIndicator: difficulty >= 70 ? 5 : 4},
    milestones: const [],
  );

  List<int> _projectReviewDays(
    Scenario scenario,
    AdministrationProject project,
  ) {
    const starts = [1, 92, 183, 274];
    const lengths = [91, 91, 91, 92];
    return List.generate(4, (index) {
      final random = SeededRandom(
        SeedDerivation.derive(
          worldSeed: scenario.seed,
          generationVersion: generationVersion,
          path:
              'term:${scenario.city.term}:project:${project.id}:quarter:${index + 1}:review-day',
        ),
      );
      return starts[index] + 20 + random.nextInt(lengths[index] - 40);
    }, growable: false);
  }

  _ProjectAdvance _advanceProject({
    required Scenario scenario,
    required CandidateTruthSnapshot truth,
    required AdministrationProject project,
    required int day,
    required int phase,
    required CityIndicatorSet indicators,
    required List<WorldCondition> worldConditions,
  }) {
    final random = SeededRandom(
      SeedDerivation.derive(
        worldSeed: scenario.seed,
        generationVersion: generationVersion,
        path: 'term:${scenario.city.term}:day:$day:project:${project.id}',
      ),
    );
    final policy = truth.policyFor(project.relevantIndicator);
    final capacity =
        truth.implementationSkill * .30 +
        truth.generalCompetence * .17 +
        truth.coalitionSkill * .16 +
        truth.budgetDiscipline * .17 +
        policy * .14 +
        truth.experience * .06;
    final fiscalPenalty = indicators.valueOf(CityIndicator.budgetHealth) < 35
        ? 7
        : 0;
    final integrityPenalty =
        project.corruptionExposure * truth.corruptionRisk / 650;
    final externalProgressModifier = worldConditions
        .fold<int>(
          0,
          (sum, condition) => sum + condition.projectProgressModifier,
        )
        .clamp(-6, 4);
    final progressDelta =
        (14 +
                capacity / 6 -
                project.difficulty / 8 -
                fiscalPenalty -
                integrityPenalty +
                externalProgressModifier +
                random.between(-5, 6))
            .round()
            .clamp(3, 34);
    final nextProgress = (project.progress + progressDelta).clamp(0, 100);
    final delayed = progressDelta <= 8;
    final complete = nextProgress >= 92 || (phase == 4 && nextProgress >= 74);
    final nextState = complete
        ? AdministrationProjectState.completed
        : delayed
        ? AdministrationProjectState.delayed
        : nextProgress >= 68
        ? AdministrationProjectState.underConstruction
        : nextProgress >= 42
        ? AdministrationProjectState.implementation
        : nextProgress >= 18
        ? AdministrationProjectState.procurement
        : AdministrationProjectState.planning;
    final promiseStatus = complete
        ? PromiseProgressStatus.completed
        : delayed
        ? PromiseProgressStatus.delayed
        : PromiseProgressStatus.progressing;
    final effects = <CityIndicator, int>{
      CityIndicator.budgetHealth: truth.budgetDiscipline >= 68 ? -1 : -2,
    };
    final issueEffects = <String, int>{};
    if (progressDelta >= 11) {
      effects[project.relevantIndicator] = policy >= 78 ? 2 : 1;
      issueEffects[project.relatedProblemId] = -1;
    }
    if (complete && project.state != AdministrationProjectState.completed) {
      for (final effect in project.outcomeEffects.entries) {
        effects.update(
          effect.key,
          (value) => value + effect.value,
          ifAbsent: () => effect.value,
        );
      }
      issueEffects.update(
        project.relatedProblemId,
        (value) => value - 6,
        ifAbsent: () => -6,
      );
      effects[CityIndicator.publicTrust] = project.publicVisibility >= 65
          ? 2
          : 1;
    } else if (delayed) {
      effects[CityIndicator.publicTrust] = -1;
    }
    final milestone = ProjectMilestone(
      id: 'milestone_${project.id}_q$phase',
      projectId: project.id,
      day: day,
      phase: phase,
      fromState: project.state,
      toState: nextState,
      progressDelta: nextProgress - project.progress,
      summary: complete
          ? '${project.title} reaches operational completion.'
          : delayed
          ? '${project.title} loses time to funding or coordination problems.'
          : '${project.title} advances to ${_projectStateLabel(nextState)}.',
      indicatorEffects: Map.unmodifiable(effects),
      issueSeverityEffects: Map.unmodifiable(issueEffects),
    );
    return _ProjectAdvance(
      project.copyWith(
        progress: nextProgress,
        state: nextState,
        promiseStatus: promiseStatus,
        milestones: [...project.milestones, milestone],
      ),
      milestone,
    );
  }

  CityEvent _projectEvent({
    required Scenario scenario,
    required Candidate candidate,
    required AdministrationProject project,
    required ProjectMilestone milestone,
    required int day,
    required int phase,
    required int step,
  }) {
    final anchor = _anchorForIssue(project.relatedIssueFamily);
    final important =
        milestone.toState == AdministrationProjectState.completed ||
        milestone.toState == AdministrationProjectState.delayed ||
        milestone.toState == AdministrationProjectState.stalled ||
        milestone.toState == AdministrationProjectState.underInvestigation;
    return CityEvent(
      id: 'city_event_t${scenario.city.term}_d${day}_project_${project.id}',
      templateId: 'project_milestone_${project.id}_q$phase',
      chainFamily: project.id,
      category: CityEventCategory.administration,
      severity: important
          ? CityEventSeverity.moderate
          : CityEventSeverity.minor,
      importance: important
          ? CityEventImportance.important
          : CityEventImportance.minor,
      day: day,
      phase: phase,
      step: step,
      title: milestone.toState == AdministrationProjectState.completed
          ? 'Project reaches completion'
          : milestone.toState == AdministrationProjectState.delayed
          ? 'Project schedule slips'
          : 'Project work advances',
      factualSummary: milestone.summary,
      explanation:
          'Project progress reflects policy fit, implementation, coalition support, fiscal room, integrity risk, difficulty, and seeded variation.',
      fictionalDate: _fictionalDate(day, scenario.city.term),
      district: anchor.district,
      locationId: anchor.id,
      relatedIssueIds: [project.relatedProblemId],
      relatedProjectIds: [project.id],
      relatedCandidateIds: [candidate.id],
      indicatorEffects: const {},
      issueSeverityEffects: const {},
      requiredHooks: const [],
      followUpHooks: const [],
      chronicleEligible: true,
      newsEligible: important,
      tvEligible: milestone.toState == AdministrationProjectState.completed,
      cityBookEligible: important,
      markerType: CityMapMarkerType.roadworks,
      markerX: anchor.x,
      markerY: anchor.y,
      markerLifetimeDays: important ? 28 : 12,
    );
  }

  LivingEventTemplate? _selectDailyEvent({
    required Scenario scenario,
    required CandidateTruthSnapshot truth,
    required int day,
    required int phase,
    required CityIndicatorSet indicators,
    required Map<String, CityIssueState> issues,
    required List<AdministrationProject> projects,
    required List<CityEvent> history,
    required Map<String, _PendingHook> pendingHooks,
    required Set<String> usedTemplateIds,
    required Map<String, int> lastTemplateDay,
    required Map<String, int> lastChainDay,
    required Map<String, int> lastLocationDay,
    required Map<CityIssueFamily, int> lastIssueDay,
    required List<WorldCondition> worldConditions,
  }) {
    final random = SeededRandom(
      SeedDerivation.derive(
        worldSeed: scenario.seed,
        generationVersion: generationVersion,
        path: 'term:${scenario.city.term}:day:$day:event-selection',
      ),
    );
    final recentCategories = history.reversed
        .take(5)
        .map((event) => event.category)
        .toSet();
    final hasPositive = history.any(
      (event) => event.category == CityEventCategory.positiveOpportunity,
    );
    final hasCityLife = history.any(
      (event) => event.category == CityEventCategory.cityLife,
    );
    final recentMajorDay = history.reversed
        .where(
          (event) =>
              event.importance == CityEventImportance.critical ||
              event.importance == CityEventImportance.rare ||
              event.severity == CityEventSeverity.major,
        )
        .map((event) => event.day)
        .firstOrNull;
    final candidates = <({LivingEventTemplate template, double weight})>[];
    for (final template in livingCityEventLibrary) {
      if (template.minimumPhase > phase || template.maximumPhase < phase) {
        continue;
      }
      if (!template.repeatable && usedTemplateIds.contains(template.id)) {
        continue;
      }
      final previousTemplate = lastTemplateDay[template.id];
      if (previousTemplate != null &&
          day - previousTemplate < template.cooldownDays) {
        continue;
      }
      final previousChain = lastChainDay[template.effectiveChainFamily];
      if (previousChain != null && day - previousChain < 18) continue;
      if ((template.severity == CityEventSeverity.major ||
              template.severity == CityEventSeverity.critical ||
              template.severity == CityEventSeverity.rare) &&
          recentMajorDay != null &&
          day - recentMajorDay < 28) {
        continue;
      }
      if (template.severity == CityEventSeverity.rare &&
          history
                  .where((event) => event.severity == CityEventSeverity.rare)
                  .length >=
              2) {
        continue;
      }
      if (template.requiredHook case final required?) {
        final hook = pendingHooks[required];
        if (hook == null || day < hook.eligibleDay || day > hook.expiresDay) {
          continue;
        }
      }
      final condition = template.conditionIndicator;
      if (condition != null) {
        final value = indicators.valueOf(condition);
        if (template.conditionBelow != null &&
            value > template.conditionBelow!) {
          continue;
        }
        if (template.conditionAbove != null &&
            value < template.conditionAbove!) {
          continue;
        }
      }
      var issueSeverity = 50;
      if (template.issueFamily case final family?) {
        final matching = issues.values
            .where((state) => state.family == family)
            .toList(growable: false);
        if (matching.isEmpty) continue;
        issueSeverity = matching
            .map((state) => state.severity)
            .reduce((left, right) => left > right ? left : right);
        final lastIssue = lastIssueDay[family];
        if (lastIssue != null && day - lastIssue < 16) continue;
      }
      final possibleAnchors = _anchorsForTemplate(template);
      if (possibleAnchors.every(
        (anchor) =>
            lastLocationDay[anchor.id] != null &&
            day - lastLocationDay[anchor.id]! < 7,
      )) {
        continue;
      }

      var weight = template.baseWeight;
      if (template.issueFamily != null) {
        weight *= .55 + issueSeverity / 58;
      }
      if (template.requiredHook != null) weight *= 3.1;
      if (recentCategories.contains(template.category)) weight *= .58;
      if (!hasPositive &&
          day >= 120 &&
          template.category == CityEventCategory.positiveOpportunity) {
        weight *= 5.5;
      }
      if (!hasCityLife &&
          day >= 90 &&
          template.category == CityEventCategory.cityLife) {
        weight *= 6.0;
      }
      if (template.category == CityEventCategory.positiveOpportunity) {
        weight *= .72 + _averageHealthyCondition(indicators) / 85;
      }
      if (template.category == CityEventCategory.political) {
        weight *=
            .65 +
            (100 - indicators.valueOf(CityIndicator.publicTrust)) / 100 +
            truth.corruptionRisk / 260;
      }
      if (template.category == CityEventCategory.administration) {
        weight *= .70 + truth.generalCompetence / 140;
        if (projects.any(
          (project) => project.relatedIssueFamily == template.issueFamily,
        )) {
          weight *= 1.3;
        }
      }
      for (final condition in worldConditions) {
        weight *= condition.eventWeightMultiplier(
          template.markerType,
          template.category,
        );
      }
      weight *= .88 + random.nextDouble() * .24;
      if (weight > 0) candidates.add((template: template, weight: weight));
    }
    if (candidates.isEmpty) return null;
    final total = candidates.fold<double>(0, (sum, item) => sum + item.weight);
    var roll = random.nextDouble() * total;
    for (final candidate in candidates) {
      roll -= candidate.weight;
      if (roll <= 0) return candidate.template;
    }
    return candidates.last.template;
  }

  CityEvent _materializeEvent({
    required Scenario scenario,
    required Candidate candidate,
    required CandidateTruthSnapshot truth,
    required List<AdministrationProject> projects,
    required LivingEventTemplate template,
    required int day,
    required int phase,
    required int step,
    required String? parentEventId,
  }) {
    final random = SeededRandom(
      SeedDerivation.derive(
        worldSeed: scenario.seed,
        generationVersion: generationVersion,
        path:
            'term:${scenario.city.term}:day:$day:event:${template.id}:effects',
      ),
    );
    final relatedProblems = scenario.city.problems
        .where((problem) => problem.family == template.issueFamily)
        .toList(growable: false);
    final relatedProjects = projects
        .where((project) => project.relatedIssueFamily == template.issueFamily)
        .map((project) => project.id)
        .toList(growable: false);
    final effects = <CityIndicator, int>{};
    for (final entry in template.indicatorEffects.entries) {
      final base = entry.value;
      final capability =
          (truth.policyFor(entry.key) +
              truth.crisisResponse +
              truth.implementationSkill) /
          3;
      final factor = entry.key == CityIndicator.corruptionPressure
          ? base > 0
                ? .35 + truth.corruptionRisk / 95
                : .50 + truth.integrity / 125
          : base < 0
          ? (1.22 - capability / 285)
          : (.72 + capability / 245);
      final adjusted = (base * factor + random.between(-.45, .45)).round();
      effects[entry.key] = adjusted == 0
          ? (base.isNegative ? -1 : 1)
          : adjusted;
    }
    final netEffect = effects.values.fold<int>(0, (sum, value) => sum + value);
    final issueEffects = <String, int>{
      for (final problem in relatedProblems)
        problem.id: netEffect < 0
            ? 2 + random.nextInt(3)
            : -2 - random.nextInt(2),
    };
    final anchor = _selectAnchorForTemplate(template, random);
    final importance = _importanceFor(template.severity);
    final x = anchor.x + random.between(-.018, .018);
    final y = anchor.y + random.between(-.014, .014);
    return CityEvent(
      id: 'city_event_t${scenario.city.term}_d${day}_${template.id}',
      templateId: template.id,
      chainFamily: template.effectiveChainFamily,
      category: template.category,
      severity: template.severity,
      importance: importance,
      day: day,
      phase: phase,
      step: step,
      title: template.title,
      factualSummary: template.summary,
      explanation:
          '${template.explanation} The saved result reflects city conditions and the administration response on this date.',
      fictionalDate: _fictionalDate(day, scenario.city.term),
      district: anchor.district,
      locationId: anchor.id,
      relatedIssueIds: relatedProblems
          .map((problem) => problem.id)
          .toList(growable: false),
      relatedProjectIds: relatedProjects,
      relatedCandidateIds: [candidate.id],
      indicatorEffects: Map.unmodifiable(effects),
      issueSeverityEffects: Map.unmodifiable(issueEffects),
      requiredHooks: template.requiredHook == null
          ? const []
          : [template.requiredHook!],
      followUpHooks: template.followUpHooks,
      chronicleEligible: true,
      newsEligible:
          importance == CityEventImportance.important ||
          importance == CityEventImportance.critical ||
          importance == CityEventImportance.rare,
      tvEligible:
          importance == CityEventImportance.critical ||
          importance == CityEventImportance.rare ||
          template.severity == CityEventSeverity.major,
      cityBookEligible: importance != CityEventImportance.ambient,
      markerType: template.markerType,
      markerX: x.clamp(.04, .96),
      markerY: y.clamp(.08, .92),
      markerLifetimeDays: switch (importance) {
        CityEventImportance.ambient => 0,
        CityEventImportance.minor => 9,
        CityEventImportance.important => 24,
        CityEventImportance.critical => 50,
        CityEventImportance.rare => 36,
      },
      parentEventId: parentEventId,
      visualAssetKey: template.visualAssetKey,
    );
  }

  List<CityMapAnchor> _anchorsForTemplate(LivingEventTemplate template) {
    return _weightedAnchorsForTemplate(
      template,
    ).map((choice) => choice.anchor).toList(growable: false);
  }

  CityMapAnchor _selectAnchorForTemplate(
    LivingEventTemplate template,
    SeededRandom random,
  ) {
    final choices = _weightedAnchorsForTemplate(template);
    final total = choices.fold<double>(0, (sum, choice) => sum + choice.weight);
    var roll = random.nextDouble() * total;
    for (final choice in choices) {
      roll -= choice.weight;
      if (roll <= 0) return choice.anchor;
    }
    return choices.last.anchor;
  }

  List<({CityMapAnchor anchor, double weight})> _weightedAnchorsForTemplate(
    LivingEventTemplate template,
  ) {
    final weights = <String, double>{};

    void add(String id, double weight) {
      final existing = weights[id] ?? 0;
      if (weight > existing) weights[id] = weight;
    }

    for (var index = 0; index < template.preferredLocationIds.length; index++) {
      add(template.preferredLocationIds[index], index == 0 ? 2.6 : 2.2);
    }
    for (final id in _issueLocationIds(template.issueFamily)) {
      add(id, template.preferredLocationIds.isEmpty ? 2.0 : 1.35);
    }
    for (final id in _markerLocationIds(template.markerType)) {
      add(id, template.preferredLocationIds.isEmpty ? 1.8 : 1.15);
    }
    if (weights.isEmpty) {
      for (final anchor in cityMapAnchors.where(
        (anchor) => anchor.district == template.district,
      )) {
        add(anchor.id, 1);
      }
    }
    if (weights.isEmpty) add(BayhavenMapAnchors.cityHall.id, 1);
    return [
      for (final entry in weights.entries)
        (anchor: cityMapAnchorById(entry.key), weight: entry.value),
    ];
  }

  List<String> _issueLocationIds(CityIssueFamily? family) => switch (family) {
    CityIssueFamily.floodingDrainage => const [
      'riverside_community',
      'riverside',
      'water_facility',
      'west_residential',
    ],
    CityIssueFamily.waterSupply => const [
      'water_facility',
      'riverside_community',
      'south_residential',
    ],
    CityIssueFamily.healthcareCapacity => const ['hospital'],
    CityIssueFamily.educationCapacity => const [
      'school_district',
      'university',
    ],
    CityIssueFamily.trafficTransport || CityIssueFamily.unfinishedRoads =>
      const ['transport_terminal', 'central_avenue', 'warehouse_logistics'],
    CityIssueFamily.employmentQuality => const [
      'industrial_zone',
      'shopping_mall',
      'warehouse_logistics',
      'commercial_center',
    ],
    CityIssueFamily.costOfLiving => const [
      'public_market',
      'shopping_mall',
      'commercial_center',
    ],
    CityIssueFamily.garbageCleanliness => const [
      'waste_segregation_center',
      'public_market',
      'south_residential',
      'east_residential',
    ],
    CityIssueFamily.drugsCommunitySafety => const [
      'police_hq',
      'subdivision_area',
      'south_residential',
      'east_residential',
    ],
    CityIssueFamily.corruptionPublicFunds ||
    CityIssueFamily.governmentServices => const [
      'government_services_center',
      'city_hall',
      'city_plaza',
    ],
    null => const [],
  };

  List<String> _markerLocationIds(CityMapMarkerType type) => switch (type) {
    CityMapMarkerType.flood || CityMapMarkerType.weather => const [
      'riverside_community',
      'riverside',
      'water_facility',
      'west_residential',
    ],
    CityMapMarkerType.clinic => const ['hospital'],
    CityMapMarkerType.water => const [
      'water_facility',
      'riverside_community',
      'south_residential',
    ],
    CityMapMarkerType.school => const ['school_district', 'university'],
    CityMapMarkerType.market => const [
      'public_market',
      'shopping_mall',
      'commercial_center',
    ],
    CityMapMarkerType.waste => const [
      'waste_segregation_center',
      'public_market',
      'south_residential',
    ],
    CityMapMarkerType.publicSafety => const [
      'police_hq',
      'subdivision_area',
      'south_residential',
      'east_residential',
    ],
    CityMapMarkerType.government => const [
      'government_services_center',
      'city_hall',
      'city_plaza',
    ],
    CityMapMarkerType.audit => const [
      'city_hall',
      'government_services_center',
      'news_headquarters',
    ],
    CityMapMarkerType.protest => const [
      'city_plaza',
      'city_hall',
      'government_services_center',
    ],
    CityMapMarkerType.news => const ['news_headquarters', 'city_hall'],
    CityMapMarkerType.jobs => const [
      'industrial_zone',
      'shopping_mall',
      'warehouse_logistics',
      'commercial_center',
    ],
    CityMapMarkerType.transport || CityMapMarkerType.roadworks => const [
      'transport_terminal',
      'central_avenue',
      'warehouse_logistics',
    ],
    CityMapMarkerType.power => const [
      'industrial_zone',
      'warehouse_logistics',
      'water_facility',
    ],
    CityMapMarkerType.festival || CityMapMarkerType.community => const [
      'city_plaza',
      'community_sports_area',
      'riverside',
      'university',
    ],
    CityMapMarkerType.opportunity => const [
      'university',
      'shopping_mall',
      'city_plaza',
      'commercial_center',
    ],
  };

  CityMapAnchor _anchorForIssue(CityIssueFamily family) => switch (family) {
    CityIssueFamily.floodingDrainage => cityMapAnchorById(
      'riverside_community',
    ),
    CityIssueFamily.waterSupply => cityMapAnchorById('water_facility'),
    CityIssueFamily.healthcareCapacity => cityMapAnchorById('hospital'),
    CityIssueFamily.educationCapacity => cityMapAnchorById('school_district'),
    CityIssueFamily.trafficTransport ||
    CityIssueFamily.unfinishedRoads => cityMapAnchorById('central_avenue'),
    CityIssueFamily.employmentQuality => cityMapAnchorById('industrial_zone'),
    CityIssueFamily.costOfLiving => cityMapAnchorById('public_market'),
    CityIssueFamily.garbageCleanliness => cityMapAnchorById(
      'waste_segregation_center',
    ),
    CityIssueFamily.drugsCommunitySafety => cityMapAnchorById('police_hq'),
    CityIssueFamily.corruptionPublicFunds => cityMapAnchorById('city_hall'),
    CityIssueFamily.governmentServices => cityMapAnchorById(
      'government_services_center',
    ),
  };

  Map<String, CityIssueState> _applyIssueEffects(
    Map<String, CityIssueState> current,
    Map<String, int> effects,
  ) => {
    for (final entry in current.entries)
      entry.key: entry.value.apply(effects[entry.key] ?? 0),
  };

  List<LivingChronicleEntry> _chronicleEntries(List<CityEvent> events) => events
      .where((event) => event.chronicleEligible)
      .map(
        (event) => LivingChronicleEntry(
          id: 'chronicle_${event.id}',
          eventId: event.id,
          headline: event.title,
          summary: event.factualSummary,
          sourceLabel: event.category == CityEventCategory.cityLife
              ? 'Community desk'
              : event.category == CityEventCategory.administration
              ? 'Administration tracker'
              : 'City desk',
          fictionalDate: event.fictionalDate,
          communityVoice:
              event.indicatorEffects.values.any((value) => value < 0)
              ? 'Residents ask what happens next and how the response will be measured.'
              : 'Residents welcome the change while watching whether it lasts.',
        ),
      )
      .toList(growable: false);

  List<NewsCoverage> _newsCoverages(List<CityEvent> events) {
    final coverages = <NewsCoverage>[];
    for (final event in events.where((event) => event.newsEligible)) {
      for (final outlet in const [
        ('outlet_daily', 'City record and public consequence'),
        ('outlet_wire', 'Immediate disruption and public reaction'),
        ('outlet_lantern', 'Systems, records, and longer-term context'),
      ]) {
        coverages.add(
          NewsCoverage(
            id: '${event.id}_${outlet.$1}',
            eventId: event.id,
            outletId: outlet.$1,
            category: _categoryName(event.category),
            publicationTime: '${event.fictionalDate} · 8:15 AM',
            headline: event.title,
            subheadline:
                'The verified city record is shared; this report emphasizes ${outlet.$2.toLowerCase()}.',
            articleSummary: event.factualSummary,
            framingAngle: outlet.$2,
            articleBody: [
              event.factualSummary,
              event.explanation,
              if (event.parentEventId != null)
                'This development follows an earlier recorded city event in the same causal chain.',
              'The map, Event History, Chronicle, news coverage, television reference, and CityBook discussion all point to the same saved event.',
            ],
          ),
        );
      }
    }
    return coverages;
  }

  (List<CityBookPost>, Map<String, CityBookCommentThread>) _cityBookArtifacts(
    Candidate candidate,
    List<CityEvent> events,
    List<AdministrationProject> projects,
  ) {
    final posts = <CityBookPost>[];
    final threads = <String, CityBookCommentThread>{};
    for (final event in events.where(
      (item) =>
          item.cityBookEligible &&
          (item.importance == CityEventImportance.important ||
              item.importance == CityEventImportance.critical ||
              item.importance == CityEventImportance.rare ||
              item.category == CityEventCategory.administration),
    )) {
      if (posts.length >= 12) break;
      final postId = 'term_post_${event.id}';
      final threadId = 'thread_$postId';
      final post = CityBookPost(
        id: postId,
        candidateId: candidate.id,
        fictionalDate: event.fictionalDate,
        type: CityBookPostType.publicServiceAnnouncement,
        text: '${event.title}: ${event.factualSummary}',
        reactions: CityBookReactionDistribution({
          CityBookReaction.like: 36 + event.phase * 9,
          CityBookReaction.receipt: 12 + event.step * 2,
          CityBookReaction.angry:
              event.indicatorEffects.values.any((value) => value < 0) ? 28 : 6,
        }),
        commentThreadId: threadId,
        visibility: CityBookVisibility.public,
        sourceTruthRelation: CityBookSourceTruthRelation.publicClaim,
        relatedIssueFamilies: event.relatedIssueIds.isEmpty
            ? const []
            : [
                projects
                        .where(
                          (project) =>
                              event.relatedProjectIds.contains(project.id),
                        )
                        .firstOrNull
                        ?.relatedIssueFamily ??
                    CityIssueFamily.governmentServices,
              ],
        relatedNewsEventIds: [event.id],
      );
      posts.add(post);
      threads[threadId] = CityBookCommentThread(
        id: threadId,
        comments: _commentsFor(event, post.reactions),
      );
    }
    return (posts, threads);
  }

  List<CityBookComment> _commentsFor(
    CityEvent event,
    CityBookReactionDistribution parentReactions,
  ) {
    final negative = event.indicatorEffects.values.any((value) => value < 0);
    final texts = negative
        ? const [
            'We need a real timeline, not another slogan.',
            'Our block felt this before the announcement.',
            'Where can we see the spending record?',
            'I hope the response reaches the side streets.',
            'Please post a verified service schedule.',
            'Whose office is responsible for the follow-up?',
            'This is worse during the morning commute.',
            'The headline is loud. Show us the actual record.',
            'Some neighborhoods are still waiting for help.',
            'Not everything is City Hall\'s fault, but the response matters.',
          ]
        : const [
            'Good start. Please publish the progress numbers.',
            'This helped our area today.',
            'Credit where it is due—but keep the records open.',
            'Can this reach the other districts too?',
            'Hope this lasts beyond one photo.',
            'The workers on the ground deserve credit too.',
            'We noticed the change near the market.',
            'Useful result. What is the next milestone?',
            'I was skeptical, but this part worked.',
            'Please keep the public dashboard updated.',
          ];
    const names = [
      'Mara D.',
      'Jun Reyes',
      'Tess L.',
      'Nico P.',
      'Ana Cruz',
      'Benjie S.',
      'Liza M.',
      'Paolo G.',
      'Cora V.',
      'Iking R.',
    ];
    return List.generate(
      texts.length,
      (index) => CityBookComment(
        id: 'comment_${event.id}_$index',
        authorName: names[index],
        authorHandle: '@resident_${event.day}_$index',
        archetype: CityBookCommentArchetype
            .values[index % CityBookCommentArchetype.values.length],
        text: texts[index],
        reactions: const CityBookCommentReactionEngine().generate(
          parentReactions: parentReactions,
          archetype: CityBookCommentArchetype
              .values[index % CityBookCommentArchetype.values.length],
          seed: cityBookReactionSeed('${event.id}:term-comment:$index'),
          commentIndex: index,
        ),
      ),
    );
  }

  CityEventImportance _importanceFor(CityEventSeverity severity) =>
      switch (severity) {
        CityEventSeverity.ambient => CityEventImportance.ambient,
        CityEventSeverity.minor => CityEventImportance.minor,
        CityEventSeverity.moderate ||
        CityEventSeverity.major => CityEventImportance.important,
        CityEventSeverity.critical => CityEventImportance.critical,
        CityEventSeverity.rare => CityEventImportance.rare,
      };

  String _phaseTitle(int phase) => const [
    'First Quarter · First 100 Days',
    'Second Quarter · Pressure and Response',
    'Third Quarter · Midyear Record',
    'Fourth Quarter · Year-End Reckoning',
  ][phase - 1];

  String _fictionalDate(int day, int term) {
    final date = DateTime(2026, 1, 1).add(Duration(days: day - 1));
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day} — Year $term';
  }

  String _categoryName(CityEventCategory category) => switch (category) {
    CityEventCategory.issueDriven => 'City issue',
    CityEventCategory.indicatorDriven => 'Indicators',
    CityEventCategory.administration => 'Administration',
    CityEventCategory.externalShock => 'Breaking',
    CityEventCategory.positiveOpportunity => 'Opportunity',
    CityEventCategory.political => 'Government',
    CityEventCategory.cityLife => 'City life',
    CityEventCategory.rare => 'Special report',
  };

  String _projectStateLabel(AdministrationProjectState state) => state.name
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .toLowerCase();

  double _averageHealthyCondition(CityIndicatorSet indicators) {
    var total = 0;
    for (final indicator in CityIndicator.values) {
      final value = indicators.valueOf(indicator);
      total += indicator == CityIndicator.corruptionPressure
          ? 100 - value
          : value;
    }
    return total / CityIndicator.values.length;
  }

  String _termSummary(
    Candidate candidate,
    CityIndicatorSet indicators,
    List<AdministrationProject> projects,
  ) {
    final complete = projects
        .where(
          (project) => project.state == AdministrationProjectState.completed,
        )
        .length;
    return '${candidate.name}\'s first simulated year ends with $complete of ${projects.length} tracked commitments completed and the city classified as ${overallCityCondition(indicators).name}. The record separates administration decisions from events outside City Hall\'s control.';
  }
}

class _PendingHook {
  const _PendingHook({
    required this.sourceEventId,
    required this.eligibleDay,
    required this.expiresDay,
  });

  final String sourceEventId;
  final int eligibleDay;
  final int expiresDay;
}

class _ProjectAdvance {
  const _ProjectAdvance(this.project, this.milestone);

  final AdministrationProject project;
  final ProjectMilestone milestone;
}
