import '../../data/seed_content/living_city_event_library.dart';
import '../models/candidate.dart';
import '../models/candidate_biography.dart';
import '../models/city_indicator.dart';
import '../models/city_problem.dart';
import '../models/citybook.dart';
import '../models/living_city_simulation.dart';
import '../models/news_media.dart';
import '../models/scenario.dart';
import 'seed_derivation.dart';
import 'seeded_random.dart';

class LivingCityEngine {
  const LivingCityEngine();

  static const generationVersion = 1;

  LivingTermSimulation simulate({
    required Scenario scenario,
    required Candidate candidate,
    CandidateTruthSnapshot? truth,
    List<CandidatePromise> promises = const [],
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
    var projects = _createProjects(
      scenario: scenario,
      candidate: candidate,
      promises: promises,
      truth: candidateTruth,
    );
    final phases = <LivingCityPhase>[];
    final history = <CityEvent>[];
    final hooks = <String>{};
    final lastUsedPhase = <String, int>{};

    for (var phase = 1; phase <= 4; phase++) {
      final phaseStart = indicators;
      final projectUpdate = _advanceProjects(
        scenario: scenario,
        candidate: candidate,
        truth: candidateTruth,
        projects: projects,
        phase: phase,
        indicators: indicators,
      );
      projects = projectUpdate.projects;
      indicators = indicators.apply(projectUpdate.indicatorEffects);
      issues = _applyIssueEffects(issues, projectUpdate.issueEffects);

      final selected = _selectPhaseEvents(
        scenario: scenario,
        phase: phase,
        indicators: indicators,
        issues: issues,
        hooks: hooks,
        lastUsedPhase: lastUsedPhase,
      );
      final phaseEvents = <CityEvent>[];
      for (var step = 0; step < selected.length; step++) {
        final template = selected[step];
        final event = _materializeEvent(
          scenario: scenario,
          candidate: candidate,
          truth: candidateTruth,
          projects: projects,
          issues: issues,
          template: template,
          phase: phase,
          step: step + 1,
        );
        phaseEvents.add(event);
        history.add(event);
        indicators = indicators.apply(event.indicatorEffects);
        issues = _applyIssueEffects(issues, event.issueSeverityEffects);
        hooks.addAll(event.followUpHooks);
        for (final required in event.requiredHooks) {
          hooks.remove(required);
        }
        lastUsedPhase[event.chainFamily] = phase;
      }
      phases.add(
        LivingCityPhase(
          number: phase,
          title: _phaseTitle(phase),
          events: List.unmodifiable(phaseEvents),
          projectMilestones: List.unmodifiable(projectUpdate.milestones),
          indicatorsAfter: indicators,
          issueStatesAfter: Map.unmodifiable(issues),
        ),
      );
      // Enforce the broad fiscal envelope after a phase, rather than modeling
      // every peso. This prevents one event chain from creating impossible data.
      final budgetDrift =
          indicators.valueOf(CityIndicator.budgetHealth) -
          phaseStart.valueOf(CityIndicator.budgetHealth);
      if (budgetDrift < -10) {
        indicators = indicators.apply({
          CityIndicator.budgetHealth: -10 - budgetDrift,
        });
      }
    }

    final chronicle = _chronicleEntries(history);
    final news = _newsCoverages(history);
    final cityBook = _cityBookArtifacts(candidate, history, projects);
    final tvEvents = history
        .where((event) => event.tvEligible && event.isMajor)
        .map((event) => event.id)
        .take(5)
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
      eventHistory: List.unmodifiable(history),
      chronicleEntries: List.unmodifiable(chronicle),
      newsCoverages: List.unmodifiable(news),
      tvReportEventIds: List.unmodifiable(tvEvents),
      cityBookPosts: List.unmodifiable(cityBook.$1),
      cityBookCommentThreads: Map.unmodifiable(cityBook.$2),
      summary: _termSummary(candidate, indicators, projects),
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
          final leftPolicy = truth.policyFor(left.primaryIndicator);
          final rightPolicy = truth.policyFor(right.primaryIndicator);
          final leftFit = leftPolicy * leftPolicy * (.65 + left.issueWeight);
          final rightFit = rightPolicy * rightPolicy * (.65 + right.issueWeight);
          return rightFit.compareTo(leftFit);
        });
      return rankedProblems
          .take(2)
          .map((problem) {
            return _projectFor(
              candidate: candidate,
              promiseId: 'platform_${problem.id}',
              title: '${problem.title} response program',
              family: problem.family,
              problem: problem,
              difficulty: 55,
              truth: truth,
            );
          })
          .toList(growable: false);
    }
    return relevantPromises
        .map((promise) {
          final matchingProblems = scenario.city.problems
              .where(
                (item) => promise.relatedIssueFamilies.contains(item.family),
              )
              .toList(growable: false);
          final problem = matchingProblems.isEmpty
              ? scenario.city.problems.first
              : matchingProblems.reduce(
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

  _ProjectAdvance _advanceProjects({
    required Scenario scenario,
    required Candidate candidate,
    required CandidateTruthSnapshot truth,
    required List<AdministrationProject> projects,
    required int phase,
    required dynamic indicators,
  }) {
    final updated = <AdministrationProject>[];
    final milestones = <ProjectMilestone>[];
    final indicatorEffects = <CityIndicator, int>{};
    final issueEffects = <String, int>{};
    for (final project in projects) {
      final random = SeededRandom(
        SeedDerivation.derive(
          worldSeed: scenario.seed,
          generationVersion: generationVersion,
          path: 'term:${scenario.city.term}:phase:$phase:project:${project.id}',
        ),
      );
      final policy = truth.policyFor(project.relevantIndicator);
      final capacity =
          truth.implementationSkill * .32 +
          truth.generalCompetence * .18 +
          truth.coalitionSkill * .17 +
          truth.budgetDiscipline * .18 +
          policy * .15;
      final fiscalPenalty = indicators.valueOf(CityIndicator.budgetHealth) < 35
          ? 8
          : 0;
      final integrityPenalty =
          project.corruptionExposure * truth.corruptionRisk / 600;
      final progress =
          (12 +
                  capacity / 6 -
                  project.difficulty / 8 -
                  fiscalPenalty -
                  integrityPenalty +
                  random.between(-4, 5))
              .round()
              .clamp(3, 34);
      final nextProgress = (project.progress + progress).clamp(0, 100);
      final delayed = progress <= 8;
      final complete = nextProgress >= 92 || (phase == 4 && nextProgress >= 76);
      final nextState = complete
          ? AdministrationProjectState.completed
          : delayed
          ? AdministrationProjectState.delayed
          : nextProgress >= 55
          ? AdministrationProjectState.underConstruction
          : nextProgress >= 20
          ? AdministrationProjectState.implementation
          : AdministrationProjectState.planning;
      final promiseStatus = complete
          ? PromiseProgressStatus.completed
          : delayed
          ? PromiseProgressStatus.delayed
          : PromiseProgressStatus.progressing;
      final milestone = ProjectMilestone(
        id: 'milestone_${project.id}_p$phase',
        projectId: project.id,
        phase: phase,
        fromState: project.state,
        toState: nextState,
        progressDelta: nextProgress - project.progress,
        summary: complete
            ? '${project.title} reaches operational completion.'
            : delayed
            ? '${project.title} loses time to funding or coordination problems.'
            : '${project.title} advances to ${nextState.name}.',
      );
      milestones.add(milestone);
      if (complete && project.state != AdministrationProjectState.completed) {
        for (final effect in project.outcomeEffects.entries) {
          indicatorEffects.update(
            effect.key,
            (value) => value + effect.value,
            ifAbsent: () => effect.value,
          );
        }
        issueEffects[project.relatedProblemId] = -7;
      }
      if (progress >= 8) {
        final incrementalGain = policy >= 85
            ? 4
            : policy >= 70
            ? 2
            : policy >= 60
            ? 1
            : 0;
        if (incrementalGain > 0) {
          indicatorEffects.update(
            project.relevantIndicator,
            (value) => value + incrementalGain,
            ifAbsent: () => incrementalGain,
          );
        }
        issueEffects.update(
          project.relatedProblemId,
          (value) => value - 1,
          ifAbsent: () => -1,
        );
      }
      indicatorEffects.update(
        CityIndicator.budgetHealth,
        (value) => value - (truth.budgetDiscipline >= 68 ? 1 : 2),
        ifAbsent: () => -(truth.budgetDiscipline >= 68 ? 1 : 2),
      );
      updated.add(
        project.copyWith(
          progress: nextProgress,
          state: nextState,
          promiseStatus: promiseStatus,
          milestones: [...project.milestones, milestone],
        ),
      );
    }
    return _ProjectAdvance(updated, milestones, indicatorEffects, issueEffects);
  }

  List<LivingEventTemplate> _selectPhaseEvents({
    required Scenario scenario,
    required int phase,
    required dynamic indicators,
    required Map<String, CityIssueState> issues,
    required Set<String> hooks,
    required Map<String, int> lastUsedPhase,
  }) {
    final selected = <LivingEventTemplate>[];
    final selectedCategories = <CityEventCategory>{};
    final desired = phase == 4 ? 5 : 4;
    for (var slot = 0; slot < desired; slot++) {
      final random = SeededRandom(
        SeedDerivation.derive(
          worldSeed: scenario.seed,
          generationVersion: generationVersion,
          path: 'term:${scenario.city.term}:phase:$phase:event:$slot',
        ),
      );
      final candidates = <({LivingEventTemplate template, double weight})>[];
      for (final template in livingCityEventLibrary) {
        if (slot == 0 &&
            (phase == 2 || phase == 4) &&
            template.severity != CityEventSeverity.major &&
            template.severity != CityEventSeverity.critical &&
            template.severity != CityEventSeverity.rare) {
          continue;
        }
        if (template.minimumPhase > phase || template.maximumPhase < phase) {
          continue;
        }
        if (selected.any((item) => item.id == template.id)) continue;
        if (template.requiredHook != null &&
            !hooks.contains(template.requiredHook)) {
          continue;
        }
        final last = lastUsedPhase[template.id];
        if (last != null && phase - last <= template.cooldownPhases) continue;
        final condition = template.conditionIndicator;
        if (condition != null &&
            indicators.valueOf(condition) >
                (template.conditionBelow ?? 100)) {
          continue;
        }
        var weight = template.baseWeight;
        if (template.issueFamily case final family?) {
          final matching = issues.values.where(
            (state) => state.family == family,
          );
          if (matching.isEmpty) continue;
          weight *=
              .45 +
              matching
                      .map((state) => state.severity)
                      .reduce((a, b) => a > b ? a : b) /
                  65;
        }
        if (selectedCategories.contains(template.category)) weight *= .28;
        if (slot == 0 &&
            (template.category == CityEventCategory.cityLife ||
                template.severity == CityEventSeverity.ambient)) {
          weight *= .2;
        }
        if (slot == desired - 1 &&
            (template.category == CityEventCategory.cityLife ||
                template.category == CityEventCategory.positiveOpportunity)) {
          weight *= 2.4;
        }
        candidates.add((template: template, weight: weight));
      }
      if (candidates.isEmpty) break;
      final total = candidates.fold<double>(
        0,
        (sum, item) => sum + item.weight,
      );
      var roll = random.nextDouble() * total;
      var chosen = candidates.last.template;
      for (final item in candidates) {
        roll -= item.weight;
        if (roll <= 0) {
          chosen = item.template;
          break;
        }
      }
      selected.add(chosen);
      selectedCategories.add(chosen.category);
    }
    return selected;
  }

  CityEvent _materializeEvent({
    required Scenario scenario,
    required Candidate candidate,
    required CandidateTruthSnapshot truth,
    required List<AdministrationProject> projects,
    required Map<String, CityIssueState> issues,
    required LivingEventTemplate template,
    required int phase,
    required int step,
  }) {
    final random = SeededRandom(
      SeedDerivation.derive(
        worldSeed: scenario.seed,
        generationVersion: generationVersion,
        path:
            'term:${scenario.city.term}:phase:$phase:event:$step:${template.id}:effects',
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
                ? .18 + truth.corruptionRisk / 75
                : .45 + truth.integrity / 115
          : base < 0
          ? (1.28 - capability / 250)
          : (.72 + capability / 240);
      final adjusted = (base * factor + random.between(-.45, .45)).round();
      effects[entry.key] = adjusted == 0
          ? (base.isNegative ? -1 : 1)
          : adjusted;
    }
    final issueEffects = <String, int>{
      for (final problem in relatedProblems)
        problem.id: effects.values.any((value) => value < 0) ? 4 : -3,
    };
    final x =
        _districtCoordinates(template.district).$1 +
        random.between(-.035, .035);
    final y =
        _districtCoordinates(template.district).$2 +
        random.between(-.025, .025);
    return CityEvent(
      id: 'city_event_t${scenario.city.term}_p${phase}_s${step}_${template.id}',
      templateId: template.id,
      chainFamily: template.id,
      category: template.category,
      severity: template.severity,
      phase: phase,
      step: step,
      title: template.title,
      factualSummary: template.summary,
      explanation:
          '${template.explanation} The exact result is seeded and adjusted by the administration record.',
      fictionalDate: _fictionalDate(phase, step),
      district: template.district,
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
      newsEligible: template.severity != CityEventSeverity.ambient,
      tvEligible: template.isMajorForTv,
      cityBookEligible: true,
      markerType: template.markerType,
      markerX: x.clamp(.05, .95),
      markerY: y.clamp(.08, .92),
      visualAssetKey: template.visualAssetKey,
    );
  }

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
              : 'City desk',
          fictionalDate: event.fictionalDate,
          communityVoice:
              event.indicatorEffects.values.any((value) => value < 0)
              ? 'Residents ask what happens next and how the response will be measured.'
              : 'Residents welcome the change while watching whether it lasts.',
        ),
      )
      .toList(growable: false);

  List<NewsCoverage> _newsCoverages(List<CityEvent> events) => events
      .where((event) => event.newsEligible)
      .map(
        (event) => NewsCoverage(
          id: '${event.id}_outlet_daily',
          eventId: event.id,
          outletId: 'outlet_daily',
          category: _categoryName(event.category),
          publicationTime: '${event.fictionalDate} · 8:15 AM',
          headline: event.title,
          subheadline:
              'The Chronicle record shows what happened; the administration response remains under review.',
          articleSummary: event.factualSummary,
          framingAngle: 'City record and public consequence',
          articleBody: [
            event.factualSummary,
            event.explanation,
            'The event, Chronicle entry, news coverage, television reference, and CityBook discussion all point to the same saved city event ID.',
          ],
        ),
      )
      .toList(growable: false);

  (List<CityBookPost>, Map<String, CityBookCommentThread>) _cityBookArtifacts(
    Candidate candidate,
    List<CityEvent> events,
    List<AdministrationProject> projects,
  ) {
    final posts = <CityBookPost>[];
    final threads = <String, CityBookCommentThread>{};
    for (final event
        in events
            .where(
              (item) =>
                  item.cityBookEligible &&
                  (item.isMajor ||
                      item.category == CityEventCategory.administration),
            )
            .take(8)) {
      final postId = 'term_post_${event.id}';
      final threadId = 'thread_$postId';
      posts.add(
        CityBookPost(
          id: postId,
          candidateId: candidate.id,
          fictionalDate: event.fictionalDate,
          type: CityBookPostType.publicServiceAnnouncement,
          text: '${event.title}: ${event.factualSummary}',
          reactions: CityBookReactionDistribution({
            CityBookReaction.like: 36 + event.phase * 9,
            CityBookReaction.receipt: 12 + event.step * 4,
            CityBookReaction.angry:
                event.indicatorEffects.values.any((v) => v < 0) ? 28 : 6,
          }),
          commentThreadId: threadId,
          visibility: CityBookVisibility.public,
          sourceTruthRelation: CityBookSourceTruthRelation.publicClaim,
          relatedIssueFamilies: event.relatedIssueIds.isEmpty
              ? const []
              : [
                  projects
                          .where((p) => event.relatedProjectIds.contains(p.id))
                          .firstOrNull
                          ?.relatedIssueFamily ??
                      CityIssueFamily.governmentServices,
                ],
          relatedNewsEventIds: [event.id],
        ),
      );
      threads[threadId] = CityBookCommentThread(
        id: threadId,
        comments: _commentsFor(event),
      );
    }
    return (posts, threads);
  }

  List<CityBookComment> _commentsFor(CityEvent event) {
    final negative = event.indicatorEffects.values.any((value) => value < 0);
    final texts = negative
        ? [
            'We need a real timeline, not another slogan.',
            'Our block felt this before the announcement.',
            'Where can we see the spending record?',
            'I hope the response reaches the side streets.',
            'Please post a verified service schedule.',
          ]
        : [
            'Good start. Please publish the progress numbers.',
            'This helped our area today.',
            'Credit where it is due—but keep the records open.',
            'Can this reach the other districts too?',
            'Hope this lasts beyond one photo.',
          ];
    return List.generate(
      texts.length,
      (index) => CityBookComment(
        id: 'comment_${event.id}_$index',
        authorName: [
          'Mara D.',
          'Jun Reyes',
          'Tess L.',
          'Nico P.',
          'Ana Cruz',
        ][index],
        authorHandle: '@resident_${event.phase}${event.step}$index',
        archetype: [
          CityBookCommentArchetype.skepticalCitizen,
          CityBookCommentArchetype.affectedResident,
          CityBookCommentArchetype.policyFocusedCitizen,
          CityBookCommentArchetype.habitualCritic,
          CityBookCommentArchetype.confusedCommenter,
        ][index],
        text: texts[index],
        reactionCount: 3 + index * 4,
      ),
    );
  }

  String _phaseTitle(int phase) => const [
    'First 100 Days',
    'Pressure and Response',
    'Midterm Record',
    'Final-Year Reckoning',
  ][phase - 1];
  String _fictionalDate(int phase, int step) =>
      '${const ['January', 'April', 'July', 'October'][phase - 1]} ${5 + step * 4}, ${2026 + phase - 1}';
  (double, double) _districtCoordinates(CitySimulationDistrict district) =>
      switch (district) {
        CitySimulationDistrict.civicCenter => (.52, .36),
        CitySimulationDistrict.riverside => (.18, .62),
        CitySimulationDistrict.oldMarket => (.38, .70),
        CitySimulationDistrict.northWard => (.30, .28),
        CitySimulationDistrict.southPoint => (.68, .75),
        CitySimulationDistrict.harborDistrict => (.82, .58),
        CitySimulationDistrict.hillview => (.70, .25),
        CitySimulationDistrict.industrialBelt => (.86, .78),
      };
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
  String _termSummary(
    Candidate candidate,
    dynamic indicators,
    List<AdministrationProject> projects,
  ) {
    final complete = projects
        .where((p) => p.state == AdministrationProjectState.completed)
        .length;
    return '${candidate.name}\'s term ends with $complete of ${projects.length} tracked commitments completed and the city classified as ${overallCityCondition(indicators).name}. The record contains both administration decisions and events outside city hall\'s control.';
  }
}

extension on LivingEventTemplate {
  bool get isMajorForTv =>
      severity == CityEventSeverity.major ||
      severity == CityEventSeverity.critical ||
      severity == CityEventSeverity.rare;
}

class _ProjectAdvance {
  const _ProjectAdvance(
    this.projects,
    this.milestones,
    this.indicatorEffects,
    this.issueEffects,
  );
  final List<AdministrationProject> projects;
  final List<ProjectMilestone> milestones;
  final Map<CityIndicator, int> indicatorEffects;
  final Map<String, int> issueEffects;
}
