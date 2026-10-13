import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/configuration/configured_scenario.dart';
import '../../data/persistence/run_repository.dart';
import '../../data/persistence/run_save_data.dart';
import '../../data/seed_content/bayhaven_candidate_experience.dart';
import '../../data/seed_content/bayhaven_citybook.dart';
import '../../data/seed_content/bayhaven_scenario.dart';
import '../../data/seed_content/city_issue_library.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/city.dart';
import '../../domain/models/city_problem.dart';
import '../../domain/models/candidate_experience.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/models/evidence_item.dart';
import '../../domain/models/information_ecosystem.dart';
import '../../domain/models/citybook.dart';
import '../../domain/models/news_media.dart';
import '../../domain/models/pre_election_city_brief.dart';
import '../../domain/models/procedural_election.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/term_result.dart';
import '../../domain/models/living_city_simulation.dart';
import '../../domain/models/political_timeline.dart';
import '../../domain/models/accountability_journal.dart';
import '../../domain/models/citizen_action.dart';
import '../../domain/models/civic_progression.dart';
import '../settings/app_settings_controller.dart';
import '../../domain/simulation/candidate_career_evolution_engine.dart';
import '../../domain/simulation/citizen_action_engine.dart';
import '../../domain/simulation/emerging_issue_engine.dart';
import '../../domain/simulation/pre_election_brief_engine.dart';
import '../../domain/simulation/information_ecosystem_engine.dart';
import '../../domain/simulation/living_city_engine.dart';
import '../../domain/simulation/procedural_candidate_generator.dart';
import '../../domain/simulation/term_engine.dart';
import '../../domain/simulation/seed_derivation.dart';
import '../../domain/simulation/seeded_random.dart';

enum CityRunProgress { electionBrief, termInProgress, termReportReady }

class SimulationAdvanceResult {
  const SimulationAdvanceResult({
    required this.fromDay,
    required this.toDay,
    required this.paused,
    required this.yearCompletedNow,
    this.criticalEvent,
    this.shouldOpenEvent = false,
    this.shouldNotify = false,
  });

  final int fromDay;
  final int toDay;
  final bool paused;
  final bool yearCompletedNow;
  final CityEvent? criticalEvent;
  final bool shouldOpenEvent;
  final bool shouldNotify;
}

class CitySaveSlot {
  const CitySaveSlot({
    required this.slotIndex,
    required this.cityName,
    required this.scenarioName,
    required this.term,
    required this.progress,
    required this.configuration,
  });

  final int slotIndex;
  final String cityName;
  final String scenarioName;
  final int term;
  final CityRunProgress progress;
  final CityRunConfiguration configuration;
}

class GameController extends ChangeNotifier {
  GameController({
    Scenario? scenario,
    bool activeRun = false,
    this.repository,
    this._engine = const TermEngine(),
    this._briefEngine = const PreElectionBriefEngine(),
    this._informationEngine = const InformationEcosystemEngine(),
    this._candidateGenerator = const ProceduralCandidateGenerator(),
  }) : _baseScenario = scenario ?? buildBayhavenScenario() {
    if (activeRun) {
      final configuration = CityRunConfiguration.defaults(
        cityName: _baseScenario.city.name,
      );
      final scenario = buildConfiguredScenario(
        base: _baseScenario,
        configuration: configuration,
      );
      _runs[0] = _newRun(configuration: configuration, scenario: scenario);
      _activeSlotIndex = 0;
    }
  }

  static const saveSlotCount = 5;

  final TermEngine _engine;
  final PreElectionBriefEngine _briefEngine;
  static const _careerEvolutionEngine = CandidateCareerEvolutionEngine();
  static const _citizenActionEngine = CitizenActionEngine();
  static const _emergingIssueEngine = EmergingIssueEngine();
  final InformationEcosystemEngine _informationEngine;
  final ProceduralCandidateGenerator _candidateGenerator;
  final Scenario _baseScenario;
  final RunRepository? repository;
  final List<_RunSession?> _runs = List<_RunSession?>.filled(
    saveSlotCount,
    null,
  );
  int? _activeSlotIndex;
  Future<void> _pendingSave = Future<void>.value();
  int _saveGeneration = 0;
  bool _isSaving = false;
  String? _persistenceError;

  _RunSession? get _activeRun {
    final index = _activeSlotIndex;
    return index == null ? null : _runs[index];
  }

  Scenario get scenario => _activeRun?.scenario ?? _baseScenario;
  CandidateExperienceCatalog get candidateExperience =>
      _activeRun?.candidateExperience ?? bayhavenCandidateExperience;
  int? get generationVersion =>
      _activeRun?.proceduralElection?.generationVersion;
  InformationEcosystem get informationEcosystem => _informationEngine.build(
    scenario: scenario,
    brief: preElectionBrief,
    candidateExperience: candidateExperience,
    cityBookCatalog: _activeRun?.cityBook ?? buildBayhavenCityBook(),
    candidateNewsEvents:
        _activeRun?.candidateNewsEvents ?? const <UnderlyingNewsEvent>[],
    candidateNewsCoverages:
        _activeRun?.candidateNewsCoverages ?? const <NewsCoverage>[],
    livingCity: _activeRun?.termResult?.livingCity.visibleThroughDay(
      _activeRun?.simulationDay ?? 0,
    ),
  );
  Candidate? get selectedCandidate => _activeRun?.selectedCandidate;
  TermResult? get termResult => _activeRun?.termResult;
  String? get topIssue => _activeRun?.topIssue;
  double get confidence => _activeRun?.confidence ?? 0.5;
  bool get hasActiveRun => _runs.any((run) => run != null);
  int? get activeSlotIndex => _activeSlotIndex;
  bool get isSaving => _isSaving;
  bool get hasPersistentStorage => repository != null;
  String? get persistenceError => _persistenceError;
  String get activeResumeRoute => selectedCandidate == null
      ? '/city'
      : isTermReportReady
      ? '/report'
      : '/simulation';
  String get activeCityName => _activeRun?.cityName ?? scenario.city.name;
  CityRunConfiguration? get activeConfiguration => _activeRun?.configuration;
  AssistanceMode get assistanceMode =>
      activeConfiguration?.assistanceMode ?? AssistanceMode.guided;
  bool get isPreElection => selectedCandidate == null;
  int get revealedTermPhases => _activeRun?.revealedTermPhases ?? 0;
  int get simulationDay => _activeRun?.simulationDay ?? 0;
  SimulationSpeed get simulationSpeed =>
      _activeRun?.simulationSpeed ?? SimulationSpeed.day;
  bool get simulationPaused => _activeRun?.simulationPaused ?? true;
  List<ScheduledCitizenAction> get citizenActions {
    final living = termResult?.livingCity;
    return living == null
        ? const []
        : List.unmodifiable(scheduledCitizenActions(living));
  }

  List<EvidenceItem> get qualifyingChallengeEvidence {
    final run = _activeRun;
    if (run == null) return const [];
    final items = <EvidenceItem>[
      for (final candidate in run.scenario.candidates)
        for (final evidence in candidate.evidence)
          if (run.viewedEvidenceIds.contains(evidence.id) &&
              _citizenActionEngine.isQualifyingChallengeEvidence(evidence))
            evidence,
    ];
    items.sort((left, right) {
      final bookmarkOrder =
          (run.bookmarkedEvidenceIds.contains(right.id) ? 1 : 0).compareTo(
            run.bookmarkedEvidenceIds.contains(left.id) ? 1 : 0,
          );
      if (bookmarkOrder != 0) return bookmarkOrder;
      final reliabilityOrder = right.reliability.compareTo(left.reliability);
      return reliabilityOrder != 0
          ? reliabilityOrder
          : left.id.compareTo(right.id);
    });
    return List.unmodifiable(items);
  }

  EvidenceItem? get recommendedChallengeEvidence =>
      qualifyingChallengeEvidence.firstOrNull;

  Set<String> get inspectedCityEventIds =>
      Set.unmodifiable(_activeRun?.inspectedCityEventIds ?? const <String>{});
  int get unreadCityEventCount {
    final living = termResult?.livingCity;
    if (living == null) return 0;
    return living
        .eventsThroughDay(simulationDay)
        .where(
          (event) =>
              event.importance != CityEventImportance.ambient &&
              !inspectedCityEventIds.contains(event.id),
        )
        .length;
  }

  bool get isTermReportReady {
    return termResult != null && simulationDay >= 365;
  }

  PreElectionCityBrief get preElectionBrief =>
      _activeRun?.preElectionBrief ??
      _briefEngine.build(
        scenario: scenario,
        configuration: CityRunConfiguration.defaults(
          cityName: scenario.city.name,
        ),
      );
  int? get investigationPointLimit =>
      activeConfiguration?.investigationTime.pointLimit;
  int get investigationPointsUsed {
    final run = _activeRun;
    if (run == null) return 0;
    return run.evidencePointCosts.values.fold<int>(
      0,
      (total, cost) => total + cost,
    );
  }

  int? get remainingInvestigationPoints {
    final limit = investigationPointLimit;
    return limit == null
        ? null
        : (limit - investigationPointsUsed).clamp(0, limit);
  }

  int get viewedEvidenceCount => _activeRun?.viewedEvidenceIds.length ?? 0;
  Set<String> get viewedEvidenceIds =>
      Set.unmodifiable(_activeRun?.viewedEvidenceIds ?? const <String>{});
  Set<String> get bookmarkedEvidenceIds =>
      Set.unmodifiable(_activeRun?.bookmarkedEvidenceIds ?? const <String>{});
  Set<String> get unlockedEvidenceIds =>
      Set.unmodifiable(_activeRun?.unlockedEvidenceIds ?? const <String>{});
  Set<String> get pinnedCandidateIds =>
      Set.unmodifiable(_activeRun?.pinnedCandidateIds ?? const <String>{});
  Set<String> get pinnedContentIds =>
      Set.unmodifiable(_activeRun?.pinnedContentIds ?? const <String>{});
  Set<String> get pinnedQuestionIds =>
      Set.unmodifiable(_activeRun?.pinnedQuestionIds ?? const <String>{});
  Set<String> get bookmarkedDebateMessageIds => Set.unmodifiable(
    _activeRun?.bookmarkedDebateMessageIds ?? const <String>{},
  );
  Set<String> get pinnedDebateMessageIds =>
      Set.unmodifiable(_activeRun?.pinnedDebateMessageIds ?? const <String>{});
  Set<String> get suspiciousDebateMessageIds => Set.unmodifiable(
    _activeRun?.suspiciousDebateMessageIds ?? const <String>{},
  );
  Map<String, String> get receiptNotes =>
      Map.unmodifiable(_activeRun?.receiptNotes ?? const <String, String>{});
  Set<String> get predictionIds =>
      Set.unmodifiable(_activeRun?.predictionIds ?? const <String>{});
  Set<String> get usedCandidateNames =>
      Set.unmodifiable(_activeRun?.usedCandidateNames ?? const <String>{});
  List<AdministrationRecord> get administrationHistory => List.unmodifiable(
    _activeRun?.administrationHistory ?? const <AdministrationRecord>[],
  );
  AccountabilityJournal get accountabilityJournal =>
      AccountabilityJournal.fromAdministrations(administrationHistory);
  CivicProgressionProfile get civicProgression =>
      CivicProgressionProfile.fromState(
        administrations: administrationHistory,
        activeViewedEvidenceIds: viewedEvidenceIds,
        activeBookmarkedEvidenceIds: bookmarkedEvidenceIds,
        activeReceiptNotes: receiptNotes,
        activeLivingCity: termResult?.livingCity,
        activeSimulationDay: simulationDay,
      );
  int get currentElectionNumber => scenario.city.term;
  int get receiptCount =>
      pinnedContentIds.length +
      pinnedQuestionIds.length +
      pinnedDebateMessageIds.length +
      bookmarkedEvidenceIds.length;

  List<CitySaveSlot?> get saveSlots => List<CitySaveSlot?>.unmodifiable(
    List<CitySaveSlot?>.generate(saveSlotCount, (index) {
      final run = _runs[index];
      if (run == null) return null;
      return CitySaveSlot(
        slotIndex: index,
        cityName: run.cityName,
        scenarioName: _baseScenario.city.name,
        term: run.scenario.city.term,
        configuration: run.configuration,
        progress:
            run.termResult != null &&
                run.revealedTermPhases >= run.termResult!.phases.length
            ? CityRunProgress.termReportReady
            : run.selectedCandidate != null
            ? CityRunProgress.termInProgress
            : CityRunProgress.electionBrief,
      );
    }),
  );

  Candidate? candidateByIdOrNull(String id) {
    for (final candidate in scenario.candidates) {
      if (candidate.id == id) return candidate;
    }
    return null;
  }

  Candidate candidateById(String id) {
    final candidate = candidateByIdOrNull(id);
    if (candidate == null) {
      throw StateError('Candidate $id is unavailable in the active election.');
    }
    return candidate;
  }

  Future<void> restore() async {
    final repository = this.repository;
    if (repository == null) return;
    try {
      final saved = await repository.load();
      if (saved == null) return;
      if (saved.slots.length > saveSlotCount) {
        throw const FormatException('Save contains too many city slots.');
      }
      for (var index = 0; index < saveSlotCount; index++) {
        final slot = index < saved.slots.length ? saved.slots[index] : null;
        _runs[index] = slot == null ? null : _restoreRun(slot);
      }
      final requestedActive = saved.activeSlotIndex;
      _activeSlotIndex =
          requestedActive != null &&
              requestedActive >= 0 &&
              requestedActive < saveSlotCount &&
              _runs[requestedActive] != null
          ? requestedActive
          : _firstOccupiedSlot();
      _persistenceError = null;
    } catch (error) {
      for (var index = 0; index < saveSlotCount; index++) {
        _runs[index] = null;
      }
      _activeSlotIndex = null;
      _persistenceError = error.toString();
    }
    notifyListeners();
  }

  Future<void> flushSaves() => _pendingSave;

  void retryPersistence() {
    if (repository == null) return;
    _scheduleSave();
    notifyListeners();
  }

  EvidenceItem? evidenceByIdOrNull(String id) {
    final run = _activeRun;
    if (run == null) return null;
    return _evidenceById(run, id);
  }

  int evidenceInvestigationCost(String id) {
    final run = _activeRun;
    if (run == null || run.viewedEvidenceIds.contains(id)) return 0;
    final item = _evidenceById(run, id);
    if (item == null || item.type == EvidenceType.profile) return 0;
    if (run.unlockedEvidenceIds.contains(id)) return 0;
    return candidateExperience.investigationCostFor(id).clamp(0, 2);
  }

  bool canOpenEvidence(String id) {
    final cost = evidenceInvestigationCost(id);
    final remaining = remainingInvestigationPoints;
    return remaining == null || remaining >= cost;
  }

  bool markEvidenceViewed(String id) {
    final run = _ensureActiveRun();
    final item = _evidenceById(run, id);
    if (item == null) return false;
    if (run.viewedEvidenceIds.contains(id)) return true;
    final cost =
        item.type == EvidenceType.profile ||
            run.unlockedEvidenceIds.contains(id)
        ? 0
        : candidateExperience.investigationCostFor(id).clamp(0, 2);
    final pointLimit = run.configuration.investigationTime.pointLimit;
    if (pointLimit != null && investigationPointsUsed + cost > pointLimit) {
      return false;
    }
    run.viewedEvidenceIds.add(id);
    if (cost > 0) {
      run.chargedEvidenceIds.add(id);
      run.evidencePointCosts[id] = cost;
    }
    for (final relation in candidateExperience.relationsFrom(id)) {
      if (relation.unlocksTarget) {
        run.unlockedEvidenceIds.add(relation.toEvidenceId);
      }
    }
    run.touch();
    _commit();
    return true;
  }

  void toggleBookmark(String id) {
    final run = _ensureActiveRun();
    if (_evidenceById(run, id) == null) return;
    if (!run.bookmarkedEvidenceIds.remove(id)) {
      run.bookmarkedEvidenceIds.add(id);
    }
    run.touch();
    _commit();
  }

  bool isBookmarked(String id) =>
      _activeRun?.bookmarkedEvidenceIds.contains(id) ?? false;

  bool isEvidenceViewed(String id) =>
      _activeRun?.viewedEvidenceIds.contains(id) ?? false;

  bool isEvidenceUnlocked(String id) =>
      _activeRun?.unlockedEvidenceIds.contains(id) ?? false;

  void toggleCandidatePin(String candidateId) {
    final run = _ensureActiveRun();
    if (candidateByIdOrNull(candidateId) == null) return;
    _toggle(run.pinnedCandidateIds, candidateId);
    run.touch();
    _commit();
  }

  bool isCandidatePinned(String candidateId) =>
      _activeRun?.pinnedCandidateIds.contains(candidateId) ?? false;

  void toggleContentPin(String contentId) {
    final run = _ensureActiveRun();
    if (candidateExperience.contentById(contentId) == null) return;
    _toggle(run.pinnedContentIds, contentId);
    run.touch();
    _commit();
  }

  bool isContentPinned(String contentId) =>
      _activeRun?.pinnedContentIds.contains(contentId) ?? false;

  void toggleQuestionPin(String questionId) {
    final run = _ensureActiveRun();
    if (candidateExperience.questionById(questionId) == null) return;
    _toggle(run.pinnedQuestionIds, questionId);
    run.touch();
    _commit();
  }

  bool isQuestionPinned(String questionId) =>
      _activeRun?.pinnedQuestionIds.contains(questionId) ?? false;

  void toggleDebateBookmark(String messageId) {
    final run = _ensureActiveRun();
    if (candidateExperience.debateMessageById(messageId) == null) return;
    _toggle(run.bookmarkedDebateMessageIds, messageId);
    run.touch();
    _commit();
  }

  bool isDebateBookmarked(String messageId) =>
      _activeRun?.bookmarkedDebateMessageIds.contains(messageId) ?? false;

  void toggleDebatePin(String messageId) {
    final run = _ensureActiveRun();
    if (candidateExperience.debateMessageById(messageId) == null) return;
    _toggle(run.pinnedDebateMessageIds, messageId);
    run.touch();
    _commit();
  }

  bool isDebatePinned(String messageId) =>
      _activeRun?.pinnedDebateMessageIds.contains(messageId) ?? false;

  void toggleDebateSuspicious(String messageId) {
    final run = _ensureActiveRun();
    if (candidateExperience.debateMessageById(messageId) == null) return;
    _toggle(run.suspiciousDebateMessageIds, messageId);
    run.touch();
    _commit();
  }

  bool isDebateSuspicious(String messageId) =>
      _activeRun?.suspiciousDebateMessageIds.contains(messageId) ?? false;

  void setReceiptNote(String receiptId, String note) {
    final run = _ensureActiveRun();
    final cleaned = note.trim();
    if (cleaned.isEmpty) {
      run.receiptNotes.remove(receiptId);
    } else {
      run.receiptNotes[receiptId] = cleaned;
    }
    run.touch();
    _commit();
  }

  String receiptNote(String receiptId) =>
      _activeRun?.receiptNotes[receiptId] ?? '';

  bool togglePrediction(String predictionId) {
    final run = _ensureActiveRun();
    if (run.selectedCandidate != null) return false;
    if (run.predictionIds.remove(predictionId)) {
      run.touch();
      _commit();
      return true;
    }
    if (run.predictionIds.length >= 2) return false;
    run.predictionIds.add(predictionId);
    run.touch();
    _commit();
    return true;
  }

  bool reserveCandidateName(String fullName) {
    final run = _ensureActiveRun();
    final normalized = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty ||
        run.usedCandidateNames.any(
          (name) => name.toLowerCase() == normalized.toLowerCase(),
        )) {
      return false;
    }
    run.usedCandidateNames.add(normalized);
    run.touch();
    _commit();
    return true;
  }

  void createCity({
    required int slotIndex,
    required CityRunConfiguration configuration,
    int? worldSeed,
  }) {
    _validateSlotIndex(slotIndex);
    if (_runs[slotIndex] != null) {
      throw StateError('Save slot ${slotIndex + 1} is already occupied.');
    }
    final cleanedName = configuration.cityName.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError.value(
        configuration.cityName,
        'configuration.cityName',
        'Cannot be empty.',
      );
    }
    final normalizedConfiguration = configuration.copyWith(
      cityName: cleanedName,
      mainConcerns: List<CityConcern>.unmodifiable(configuration.mainConcerns),
    );
    final seed =
        worldSeed ??
        (DateTime.now().microsecondsSinceEpoch ^ (slotIndex + 1) * 0x45d9f3b)
            .abs();
    final freshBase = _baseScenario.id.startsWith('bayhaven')
        ? buildBayhavenScenario(seed: seed)
        : _baseScenario.copyWith(seed: seed);
    final configuredScenario = buildConfiguredScenario(
      base: freshBase,
      configuration: normalizedConfiguration,
    );
    final proceduralElection = _candidateGenerator.generate(
      worldSeed: seed,
      city: configuredScenario.city,
      candidateField: normalizedConfiguration.candidateField,
      campaignNoise: normalizedConfiguration.campaignNoise,
    );
    final proceduralScenario = configuredScenario.copyWith(
      candidates: proceduralElection.candidates,
    );
    _runs[slotIndex] = _newRun(
      configuration: normalizedConfiguration,
      scenario: proceduralScenario,
      proceduralElection: proceduralElection,
    );
    _activeSlotIndex = slotIndex;
    _commit();
  }

  void continueCity(int slotIndex) {
    _validateSlotIndex(slotIndex);
    if (_runs[slotIndex] == null) {
      throw StateError('Save slot ${slotIndex + 1} is empty.');
    }
    _activeSlotIndex = slotIndex;
    _commit();
  }

  void deleteCity(int slotIndex) {
    _validateSlotIndex(slotIndex);
    if (_runs[slotIndex] == null) return;
    _runs[slotIndex] = null;
    if (_activeSlotIndex == slotIndex) {
      _activeSlotIndex = _firstOccupiedSlot();
    }
    _commit();
  }

  void startNewRun() {
    final active = _activeRun;
    if (active == null) {
      final index = _firstEmptySlot() ?? 0;
      final configuration = CityRunConfiguration.defaults(
        cityName: _baseScenario.city.name,
      );
      final scenario = buildConfiguredScenario(
        base: _baseScenario,
        configuration: configuration,
      );
      _runs[index] = _newRun(configuration: configuration, scenario: scenario);
      _activeSlotIndex = index;
    } else {
      _resetRun(
        active,
        active.proceduralElection == null
            ? _freshScenario(
                active.scenario.seed,
                configuration: active.configuration,
              )
            : active.scenario,
      );
    }
    _commit();
  }

  void castVote({
    required Candidate candidate,
    required String topIssue,
    required double confidence,
  }) {
    final run = _ensureActiveRun();
    final activeCandidate = run.scenario.candidates
        .where((item) => item.id == candidate.id)
        .firstOrNull;
    if (activeCandidate == null) {
      throw StateError(
        'Candidate ${candidate.id} is unavailable in the active election.',
      );
    }
    run.selectedCandidate = activeCandidate;
    run.topIssue = topIssue;
    run.confidence = confidence;
    final generatedTruth =
        run.proceduralElection?.truthProfiles[activeCandidate.id];
    run.termResult = _engine.simulate(
      scenario: run.scenario,
      candidate: activeCandidate,
      promises: run.candidateExperience.promisesFor(activeCandidate.id),
      truth: generatedTruth == null
          ? null
          : truthSnapshotFromProfile(generatedTruth, activeCandidate),
      historicalTemplatePressure: _historicalTemplatePressure(
        run.administrationHistory,
      ),
      historicalVisualPressure: _historicalVisualPressure(
        run.administrationHistory,
      ),
      historicalNewsFramingPressure: _historicalNewsFramingPressure(
        run.administrationHistory,
      ),
    );
    run.revealedTermPhases = 0;
    run.simulationDay = 0;
    run.simulationSpeed = SimulationSpeed.day;
    run.simulationPaused = false;
    run.inspectedCityEventIds.clear();
    run.touch();
    _commit();
  }

  void setSimulationSpeed(SimulationSpeed speed) {
    final run = _ensureActiveRun();
    if (run.termResult == null || run.simulationDay >= 365) return;
    run.simulationSpeed = speed;
    run.simulationPaused = false;
    run.touch();
    _commit();
  }

  void pauseSimulation() {
    final run = _ensureActiveRun();
    if (run.termResult == null || run.simulationPaused) return;
    run.simulationPaused = true;
    run.touch();
    _commit();
  }

  bool canPerformCitizenAction(CitizenActionType type) {
    final living = termResult?.livingCity;
    return living != null &&
        _citizenActionEngine.canPerform(
          simulation: living,
          type: type,
          currentDay: simulationDay,
          supportingEvidence: type == CitizenActionType.challengeMisleadingClaim
              ? recommendedChallengeEvidence
              : null,
        );
  }

  CitizenActionResolution performCitizenAction(CitizenActionType type) {
    final run = _ensureActiveRun();
    final result = run.termResult;
    if (result == null) {
      throw StateError('A confirmed election is required for citizen actions.');
    }
    final resolution = _citizenActionEngine.apply(
      result: result,
      type: type,
      currentDay: run.simulationDay,
      problems: run.scenario.city.problems,
      responseDelayReductionDays: civicProgression.actionDelayReductionDays(
        type,
      ),
      supportingEvidence: type == CitizenActionType.challengeMisleadingClaim
          ? recommendedChallengeEvidence
          : null,
    );
    run.termResult = resolution.termResult;
    run.simulationPaused = true;
    run.touch();
    _commit();
    return resolution;
  }

  SimulationAdvanceResult? advanceSimulationDays(
    int requestedDays, {
    required CriticalEventInterruption interruptionPreference,
  }) {
    final run = _ensureActiveRun();
    final result = run.termResult;
    if (result == null ||
        run.simulationPaused ||
        requestedDays <= 0 ||
        run.simulationDay >= 365) {
      return null;
    }
    final fromDay = run.simulationDay;
    final target = (fromDay + requestedDays).clamp(0, 365);
    CityEvent? criticalEvent;
    if (interruptionPreference != CriticalEventInterruption.neverInterrupt) {
      criticalEvent = result.livingCity.eventHistory
          .where(
            (event) =>
                event.day > fromDay &&
                event.day <= target &&
                _isInterruptingCriticalEvent(event),
          )
          .firstOrNull;
    }
    final pausesForEvent =
        criticalEvent != null && interruptionPreference.pausesSimulation;
    run.simulationDay = pausesForEvent ? criticalEvent.day : target;
    run.revealedTermPhases = switch (run.simulationDay) {
      >= 365 => 4,
      >= 273 => 3,
      >= 182 => 2,
      >= 91 => 1,
      _ => 0,
    };
    if (pausesForEvent || run.simulationDay >= 365) {
      run.simulationPaused = true;
    }
    run.touch();
    _commit();
    return SimulationAdvanceResult(
      fromDay: fromDay,
      toDay: run.simulationDay,
      paused: run.simulationPaused,
      yearCompletedNow: fromDay < 365 && run.simulationDay >= 365,
      criticalEvent: criticalEvent,
      shouldOpenEvent:
          criticalEvent != null && interruptionPreference.opensEvent,
      shouldNotify:
          criticalEvent != null &&
          interruptionPreference.showsNotification &&
          !interruptionPreference.opensEvent,
    );
  }

  /// Treats YEAR as a bounded command to reveal the remaining deterministic
  /// simulation, stopping only when the configured critical-event preference
  /// requires it. Every batch uses [advanceSimulationDays], so boundaries do
  /// not rerun or duplicate events.
  SimulationAdvanceResult? fastForwardToYearEnd({
    required CriticalEventInterruption interruptionPreference,
    int batchSize = 30,
  }) {
    final run = _ensureActiveRun();
    if (run.termResult == null || run.simulationDay >= 365 || batchSize < 1) {
      return null;
    }
    final fromDay = run.simulationDay;
    run.simulationSpeed = SimulationSpeed.year;
    run.simulationPaused = false;
    CityEvent? firstCriticalEvent;
    var shouldOpen = false;
    var shouldNotify = false;
    while (!run.simulationPaused && run.simulationDay < 365) {
      final step = (365 - run.simulationDay).clamp(1, batchSize);
      final result = advanceSimulationDays(
        step,
        interruptionPreference: interruptionPreference,
      );
      if (result == null) break;
      firstCriticalEvent ??= result.criticalEvent;
      shouldOpen = shouldOpen || result.shouldOpenEvent;
      shouldNotify = shouldNotify || result.shouldNotify;
      if (result.paused) break;
    }
    return SimulationAdvanceResult(
      fromDay: fromDay,
      toDay: run.simulationDay,
      paused: run.simulationPaused,
      yearCompletedNow: fromDay < 365 && run.simulationDay >= 365,
      criticalEvent: firstCriticalEvent,
      shouldOpenEvent: shouldOpen,
      shouldNotify: shouldNotify,
    );
  }

  void markCityEventInspected(String eventId) {
    final run = _ensureActiveRun();
    final result = run.termResult;
    if (result == null ||
        !result.livingCity.eventHistory.any(
          (event) => event.id == eventId && event.day <= run.simulationDay,
        ) ||
        !run.inspectedCityEventIds.add(eventId)) {
      return;
    }
    run.touch();
    _commit();
  }

  void advanceTerm() {
    final run = _ensureActiveRun();
    final result = run.termResult;
    if (result == null || run.selectedCandidate == null) {
      throw StateError('A confirmed election is required to advance the term.');
    }
    if (run.simulationDay >= 365) return;
    final target = const [
      91,
      182,
      273,
      365,
    ][run.revealedTermPhases.clamp(0, 3)];
    run.simulationDay = target;
    run.revealedTermPhases = (run.revealedTermPhases + 1).clamp(0, 4);
    run.simulationPaused = true;
    run.touch();
    _commit();
  }

  void restartSameSeed() {
    final run = _ensureActiveRun();
    // A migrated completed single-term save may already contain the active
    // report in history. Replaying that election replaces only this active
    // term, never earlier administrations, and prevents a stale duplicate.
    run.administrationHistory.removeWhere(
      (record) => record.termNumber == run.scenario.city.term,
    );
    _resetRun(run, run.scenario);
    _commit();
  }

  /// Archives the completed administration and opens the next election while
  /// retaining the city's resulting indicators and issue conditions.
  void continueToNextElection() {
    final run = _ensureActiveRun();
    final result = run.termResult;
    final elected = run.selectedCandidate;
    if (result == null || elected == null || run.simulationDay < 365) {
      throw StateError(
        'The current administration must be completed before continuing.',
      );
    }

    final completedTerm = run.scenario.city.term;
    final administrationId = 'administration_$completedTerm';
    if (!run.administrationHistory.any(
      (record) => record.id == administrationId,
    )) {
      final portrait = run.candidateExperience
          .profileFor(elected.id)
          ?.portraitAssetKey;
      run.administrationHistory.add(
        AdministrationRecord(
          id: administrationId,
          termNumber: completedTerm,
          electionSeed: _electionSeedFor(run.scenario.seed, completedTerm),
          electedCandidateId: elected.id,
          electedCandidateName: elected.name,
          electedParty: elected.party,
          electedPortraitAssetKey:
              portrait ?? 'candidate_${elected.id}_neutral',
          topIssue: run.topIssue,
          confidence: run.confidence,
          election: run.proceduralElection,
          livingCity: result.livingCity,
          investigation: AdministrationInvestigationSnapshot(
            viewedEvidenceIds: Set.unmodifiable(run.viewedEvidenceIds),
            bookmarkedEvidenceIds: Set.unmodifiable(run.bookmarkedEvidenceIds),
            pinnedCandidateIds: Set.unmodifiable(run.pinnedCandidateIds),
            pinnedContentIds: Set.unmodifiable(run.pinnedContentIds),
            pinnedQuestionIds: Set.unmodifiable(run.pinnedQuestionIds),
            bookmarkedDebateMessageIds: Set.unmodifiable(
              run.bookmarkedDebateMessageIds,
            ),
            pinnedDebateMessageIds: Set.unmodifiable(
              run.pinnedDebateMessageIds,
            ),
            suspiciousDebateMessageIds: Set.unmodifiable(
              run.suspiciousDebateMessageIds,
            ),
            receiptNotes: Map.unmodifiable(run.receiptNotes),
            predictionIds: Set.unmodifiable(run.predictionIds),
          ),
          completedAt: run.updatedAt,
        ),
      );
    }

    final nextTerm = completedTerm + 1;
    final inheritedCity = _inheritedCityForNextElection(run, result, nextTerm);
    final electionSeed = _electionSeedFor(run.scenario.seed, nextTerm);
    final returningCandidates = _returningCandidatesFor(
      run,
      electionSeed: electionSeed,
      nextTerm: nextTerm,
    );
    final nextElection = _candidateGenerator.generate(
      worldSeed: electionSeed,
      city: inheritedCity,
      candidateField: run.configuration.candidateField,
      campaignNoise: run.configuration.campaignNoise,
      previouslyUsedNames: run.usedCandidateNames,
      returningCandidates: returningCandidates,
    );
    final nextScenario = run.scenario.copyWith(
      city: inheritedCity,
      candidates: nextElection.candidates,
    );
    final nextBrief = _briefEngine.build(
      scenario: nextScenario,
      configuration: run.configuration,
    );
    run.proceduralElection = nextElection;
    run.reset(scenario: nextScenario, preElectionBrief: nextBrief);
    _commit();
  }

  City _inheritedCityForNextElection(
    _RunSession run,
    TermResult result,
    int nextTerm,
  ) {
    final issueTransition = _emergingIssueEngine.transition(
      currentProblems: run.scenario.city.problems,
      finalIssueStates: result.livingCity.finalIssueStates,
      before: result.before,
      after: result.after,
      projects: result.livingCity.projects,
      worldSeed: run.scenario.seed,
      nextTerm: nextTerm,
      cityName: run.cityName,
    );
    final inheritedProblems = issueTransition.activeProblems;
    final unresolved = [...inheritedProblems]
      ..sort((left, right) => right.issueWeight.compareTo(left.issueWeight));
    final concernText = unresolved
        .take(3)
        .map((problem) => problem.title.toLowerCase())
        .join(', ');
    final developmentText = issueTransition.emergedProblem == null
        ? ''
        : ' ${issueTransition.emergedProblem!.title} has newly entered the active city agenda.';
    final resolutionText = issueTransition.resolvedProblem == null
        ? ''
        : ' ${issueTransition.resolvedProblem!.title} has left the active agenda after sustained improvement, while its historical record remains archived.';
    return run.scenario.city.copyWith(
      term: nextTerm,
      indicators: result.after,
      problems: inheritedProblems,
      summary:
          '${run.cityName} enters Election $nextTerm carrying the recorded results of Administration ${nextTerm - 1}. Current concerns include $concernText.$developmentText$resolutionText',
    );
  }

  List<ReturningCandidateIdentity> _returningCandidatesFor(
    _RunSession run, {
    required int electionSeed,
    required int nextTerm,
  }) {
    final election = run.proceduralElection;
    final incumbent = run.selectedCandidate;
    if (election == null || incumbent == null) return const [];

    ReturningCandidateIdentity? identityFor(
      Candidate candidate,
      ProceduralElection sourceElection, {
      ReturningCandidateCampaignRecord? priorCampaign,
    }) {
      final truth = sourceElection.truthProfiles[candidate.id];
      final portrait = sourceElection.candidateExperience
          .profileFor(candidate.id)
          ?.portraitAssetKey;
      if (truth == null || portrait == null) return null;
      final priorAdministrations = run.administrationHistory
          .where((record) => record.electedCandidateId == candidate.id)
          .toList(growable: false);
      final latestAdministration = priorAdministrations.lastOrNull;
      final careerEvolution = latestAdministration == null
          ? null
          : _careerEvolutionEngine.evolve(
              baseline: truth,
              administration: latestAdministration.livingCity,
            );
      return ReturningCandidateIdentity(
        candidate: candidate,
        truth: careerEvolution?.truth ?? truth,
        portraitId: portrait,
        priorOffice: latestAdministration == null
            ? null
            : ReturningCandidateOfficeRecord(
                termsServed: priorAdministrations.length,
                latestTermNumber: latestAdministration.termNumber,
                finalCondition:
                    latestAdministration.livingCity.finalCondition.name,
                summary: latestAdministration.livingCity.summary,
                completedProjectTitles: latestAdministration.livingCity.projects
                    .where(
                      (project) =>
                          project.state == AdministrationProjectState.completed,
                    )
                    .map((project) => project.title)
                    .toList(growable: false),
                unresolvedProjectTitles: latestAdministration
                    .livingCity
                    .projects
                    .where(
                      (project) =>
                          project.state != AdministrationProjectState.completed,
                    )
                    .map((project) => project.title)
                    .toList(growable: false),
                majorEventTitles: latestAdministration.livingCity.eventHistory
                    .where((event) => event.isMajor)
                    .map((event) => event.title)
                    .toList(growable: false),
                careerEvolutionReasons:
                    careerEvolution?.publicReasons ?? const [],
              ),
        priorCampaign: priorCampaign,
      );
    }

    var consecutiveTerms = 0;
    for (final record in run.administrationHistory.reversed) {
      if (record.electedCandidateId != incumbent.id) break;
      consecutiveTerms++;
    }
    final selected = <ReturningCandidateIdentity>[];
    if (consecutiveTerms < 2) {
      final incumbentIdentity = identityFor(incumbent, election);
      if (incumbentIdentity != null) selected.add(incumbentIdentity);
    }

    // Every third election can surface one politician who genuinely sat out
    // the immediately preceding ballot. Their archived identity and truth are
    // reused exactly; only their present-day public framing is regenerated.
    // This makes political memory visible without flooding every election with
    // familiar names.
    if (nextTerm >= 3 && nextTerm % 3 == 0) {
      final currentCandidateIds = election.candidates
          .map((candidate) => candidate.id)
          .toSet();
      final archivedCandidates = <String, Candidate>{};
      final archivedElections = <String, ProceduralElection>{};
      final lastElectionTerms = <String, int>{};
      final electionsContested = <String, int>{};
      for (final administration in run.administrationHistory) {
        final archivedElection = administration.election;
        if (archivedElection == null) continue;
        for (final candidate in archivedElection.candidates) {
          archivedCandidates[candidate.id] = candidate;
          archivedElections[candidate.id] = archivedElection;
          lastElectionTerms[candidate.id] = administration.termNumber;
          electionsContested.update(
            candidate.id,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }
      }
      final usedPortraits = selected
          .map((identity) => identity.portraitId)
          .toSet();
      final eligibleComebacks =
          archivedCandidates.keys
              .where((candidateId) {
                if (currentCandidateIds.contains(candidateId) ||
                    selected.any((item) => item.candidate.id == candidateId)) {
                  return false;
                }
                final archivedElection = archivedElections[candidateId];
                final portrait = archivedElection?.candidateExperience
                    .profileFor(candidateId)
                    ?.portraitAssetKey;
                return portrait != null && !usedPortraits.contains(portrait);
              })
              .toList(growable: false)
            ..sort();
      if (eligibleComebacks.isNotEmpty) {
        final random = SeededRandom(
          SeedDerivation.derive(
            worldSeed: electionSeed,
            generationVersion: ProceduralCandidateGenerator.generationVersion,
            path: 'returning-comeback',
          ),
        );
        final candidateId =
            eligibleComebacks[random.nextInt(eligibleComebacks.length)];
        final lastElectionTerm = lastElectionTerms[candidateId]!;
        final comeback = identityFor(
          archivedCandidates[candidateId]!,
          archivedElections[candidateId]!,
          priorCampaign: ReturningCandidateCampaignRecord(
            electionsContested: electionsContested[candidateId]!,
            lastElectionTerm: lastElectionTerm,
            yearsAway: (nextTerm - lastElectionTerm - 1).clamp(1, nextTerm),
          ),
        );
        if (comeback != null) selected.add(comeback);
      }
    }

    final reservedPortraits = selected
        .map((identity) => identity.portraitId)
        .toSet();
    final eligibleLosers = election.candidates
        .where(
          (candidate) =>
              candidate.id != incumbent.id &&
              !selected.any((item) => item.candidate.id == candidate.id) &&
              !reservedPortraits.contains(
                election.candidateExperience
                    .profileFor(candidate.id)
                    ?.portraitAssetKey,
              ),
        )
        .toList(growable: false);
    if (selected.length < 2 && eligibleLosers.isNotEmpty) {
      final random = SeededRandom(
        SeedDerivation.derive(
          worldSeed: electionSeed,
          generationVersion: ProceduralCandidateGenerator.generationVersion,
          path: 'returning-challenger',
        ),
      );
      final challenger = identityFor(
        eligibleLosers[random.nextInt(eligibleLosers.length)],
        election,
      );
      if (challenger != null &&
          !selected.any(
            (item) => item.candidate.id == challenger.candidate.id,
          )) {
        selected.add(challenger);
      }
    }
    return List.unmodifiable(selected);
  }

  int _electionSeedFor(int worldSeed, int termNumber) => termNumber <= 1
      ? worldSeed
      : SeedDerivation.derive(
          worldSeed: worldSeed,
          generationVersion: ProceduralCandidateGenerator.generationVersion,
          path: 'election:$termNumber',
        );

  _RunSession _restoreRun(RunSaveData saved) {
    final freshBase = _baseScenario.id.startsWith('bayhaven')
        ? buildBayhavenScenario(seed: saved.seed)
        : _baseScenario.copyWith(seed: saved.seed);
    var scenario = buildConfiguredScenario(
      base: freshBase,
      configuration: saved.configuration,
    );
    final proceduralElection = saved.proceduralElection;
    if (proceduralElection != null) {
      scenario = scenario.copyWith(candidates: proceduralElection.candidates);
    }
    final restoredProblems = _restoreCurrentProblems(
      scenario.city.problems,
      saved.currentIssueStates,
      cityName: saved.configuration.cityName,
    );
    scenario = scenario.copyWith(
      city: scenario.city.copyWith(
        indicators: saved.indicators,
        term: saved.term,
        problems: restoredProblems,
        summary: _restoredCitySummary(
          originalSummary: scenario.city.summary,
          cityName: saved.configuration.cityName,
          term: saved.term,
          problems: restoredProblems,
          history: saved.administrationHistory,
        ),
      ),
    );
    Candidate? candidate;
    final selectedId = saved.selectedCandidateId;
    if (selectedId != null) {
      final matches = scenario.candidates.where(
        (item) => item.id == selectedId,
      );
      if (matches.isEmpty) {
        throw FormatException('Saved candidate $selectedId is unavailable.');
      }
      candidate = matches.first;
    }
    if (saved.termResultReady && candidate == null) {
      throw const FormatException('Term result has no selected candidate.');
    }
    final availableEvidence = <String, EvidenceItem>{
      for (final candidate in scenario.candidates)
        for (final item in candidate.evidence) item.id: item,
    };
    final restoredExperience =
        proceduralElection?.candidateExperience ?? bayhavenCandidateExperience;
    final freeViews = saved.viewedEvidenceIds.where((id) {
      final item = availableEvidence[id];
      if (item == null) return false;
      return item.type == EvidenceType.profile ||
          restoredExperience.investigationCostFor(id) == 0 ||
          saved.unlockedEvidenceIds.contains(id);
    });
    final paidViews = saved.viewedEvidenceIds.where(
      (id) =>
          availableEvidence[id] != null &&
          saved.evidencePointCosts.containsKey(id),
    );
    final pointLimit = saved.configuration.investigationTime.pointLimit;
    var spent = 0;
    final allowedPaidViews = <String>[];
    for (final id in paidViews) {
      final cost = saved.evidencePointCosts[id]!.clamp(0, 2);
      if (pointLimit == null || spent + cost <= pointLimit) {
        allowedPaidViews.add(id);
        spent += cost;
      }
    }
    final sanitizedViews = <String>{...freeViews, ...allowedPaidViews};
    final sanitizedBookmarks = saved.bookmarkedEvidenceIds.where(
      availableEvidence.containsKey,
    );
    final sanitizedCosts = <String, int>{
      for (final id in allowedPaidViews)
        id: saved.evidencePointCosts[id]!.clamp(0, 2),
    };
    final validContentIds = <String>{
      for (final profile in restoredExperience.profiles.values)
        for (final item in profile.pulse) item.id,
    };
    final validDebateIds = <String>{
      for (final topic in restoredExperience.debateTopics)
        for (final message in topic.messages) message.id,
    };
    final validQuestionIds = <String>{
      for (final profile in restoredExperience.profiles.values)
        for (final question in profile.questions) question.id,
    };
    final validCandidateIds = scenario.candidates
        .map((item) => item.id)
        .toSet();
    final run = _newRun(
      configuration: saved.configuration,
      scenario: scenario,
      createdAt: saved.createdAt,
      updatedAt: saved.updatedAt,
      chronicleStoryIds: saved.chronicleStoryIds,
      chronicleVoiceIds: saved.chronicleVoiceIds,
      usedChronicleTemplateIds: saved.usedChronicleTemplateIds,
      proceduralElection: proceduralElection,
      administrationHistory: saved.administrationHistory,
    );
    final restoredTruth = candidate == null
        ? null
        : proceduralElection?.truthProfiles[candidate.id];
    return run
      ..bookmarkedEvidenceIds.addAll(sanitizedBookmarks)
      ..viewedEvidenceIds.addAll(sanitizedViews)
      ..chargedEvidenceIds.addAll(sanitizedCosts.keys)
      ..evidencePointCosts.addAll(sanitizedCosts)
      ..unlockedEvidenceIds.addAll(
        saved.unlockedEvidenceIds.where(availableEvidence.containsKey),
      )
      ..pinnedCandidateIds.addAll(
        saved.pinnedCandidateIds.where(validCandidateIds.contains),
      )
      ..pinnedContentIds.addAll(
        saved.pinnedContentIds.where(validContentIds.contains),
      )
      ..pinnedQuestionIds.addAll(
        saved.pinnedQuestionIds.where(validQuestionIds.contains),
      )
      ..bookmarkedDebateMessageIds.addAll(
        saved.bookmarkedDebateMessageIds.where(validDebateIds.contains),
      )
      ..pinnedDebateMessageIds.addAll(
        saved.pinnedDebateMessageIds.where(validDebateIds.contains),
      )
      ..suspiciousDebateMessageIds.addAll(
        saved.suspiciousDebateMessageIds.where(validDebateIds.contains),
      )
      ..receiptNotes.addAll(saved.receiptNotes)
      ..predictionIds.addAll(saved.predictionIds)
      ..usedCandidateNames.addAll({
        ...saved.usedCandidateNames,
        ...scenario.candidates.map((candidate) => candidate.name),
      })
      ..selectedCandidate = candidate
      ..termResult = saved.termResultReady && candidate != null
          ? _restoreTermResult(
              _engine.simulate(
                scenario: scenario,
                candidate: candidate,
                promises: restoredExperience.promisesFor(candidate.id),
                truth: restoredTruth == null
                    ? null
                    : truthSnapshotFromProfile(restoredTruth, candidate),
                historicalTemplatePressure: _historicalTemplatePressure(
                  saved.administrationHistory,
                ),
                historicalVisualPressure: _historicalVisualPressure(
                  saved.administrationHistory,
                ),
                historicalNewsFramingPressure: _historicalNewsFramingPressure(
                  saved.administrationHistory,
                ),
              ),
              saved.livingCity,
            )
          : null
      ..simulationDay = candidate == null
          ? 0
          : saved.simulationDay.clamp(0, 365)
      ..simulationSpeed = saved.simulationSpeed
      ..simulationPaused = candidate == null ? true : saved.simulationPaused
      ..inspectedCityEventIds.addAll(
        saved.inspectedCityEventIds.where(
          (id) =>
              saved.livingCity?.eventHistory.any(
                (event) => event.id == id && event.day <= saved.simulationDay,
              ) ??
              false,
        ),
      )
      ..revealedTermPhases = candidate == null
          ? 0
          : switch (saved.simulationDay) {
              >= 365 => 4,
              >= 273 => 3,
              >= 182 => 2,
              >= 91 => 1,
              _ => 0,
            }
      ..topIssue = saved.topIssue
      ..confidence = saved.confidence.clamp(0, 1);
  }

  List<CityProblem> _restoreCurrentProblems(
    List<CityProblem> configuredProblems,
    Map<String, CityIssueSaveState> savedStates, {
    required String cityName,
  }) {
    if (savedStates.isEmpty) return configuredProblems;
    final authoredById = <String, CityProblem>{
      for (final problem in cityIssueLibrary) problem.id: problem,
    };
    final configuredById = <String, CityProblem>{
      for (final problem in configuredProblems) problem.id: problem,
    };
    final restored = <CityProblem>[];
    for (final entry in savedStates.entries) {
      final source = configuredById[entry.key] ?? authoredById[entry.key];
      if (source == null) continue;
      restored.add(
        source.copyWith(
          description: source.description.replaceAll('the city', cityName),
          severity: entry.value.severity,
          urgency: entry.value.urgency,
          trend: entry.value.trend,
        ),
      );
    }
    restored.sort(
      (left, right) => right.issueWeight.compareTo(left.issueWeight),
    );
    return restored.isEmpty ? configuredProblems : List.unmodifiable(restored);
  }

  String _restoredCitySummary({
    required String originalSummary,
    required String cityName,
    required int term,
    required List<CityProblem> problems,
    required List<AdministrationRecord> history,
  }) {
    if (term <= 1 || history.isEmpty) return originalSummary;
    final concernText = problems
        .take(3)
        .map((problem) => problem.title.toLowerCase())
        .join(', ');
    final priorIds = history.last.livingCity.finalIssueStates.keys.toSet();
    final currentIds = problems.map((problem) => problem.id).toSet();
    final emergedIds = currentIds.difference(priorIds);
    final resolvedIds = priorIds.difference(currentIds);
    final emerged = problems
        .where((problem) => emergedIds.contains(problem.id))
        .firstOrNull;
    final resolved = cityIssueLibrary
        .where((problem) => resolvedIds.contains(problem.id))
        .firstOrNull;
    final developmentText = emerged == null
        ? ''
        : ' ${emerged.title} has newly entered the active city agenda.';
    final resolutionText = resolved == null
        ? ''
        : ' ${resolved.title} has left the active agenda after sustained improvement, while its historical record remains archived.';
    return '$cityName enters Election $term carrying the recorded results of Administration ${term - 1}. Current concerns include $concernText.$developmentText$resolutionText';
  }

  void _commit() {
    _scheduleSave();
    notifyListeners();
  }

  void _scheduleSave() {
    final repository = this.repository;
    if (repository == null) return;
    final generation = ++_saveGeneration;
    final snapshot = GameSaveData(
      activeSlotIndex: _activeSlotIndex,
      slots: _runs.map((run) => run?.toSaveData()).toList(growable: false),
    );
    _isSaving = true;
    _pendingSave = _pendingSave.then(
      (_) => _writeSave(repository, snapshot, generation),
    );
  }

  Future<void> _writeSave(
    RunRepository repository,
    GameSaveData snapshot,
    int generation,
  ) async {
    try {
      await repository.save(snapshot);
      if (generation == _saveGeneration) {
        _isSaving = false;
        _persistenceError = null;
        notifyListeners();
      }
    } catch (error) {
      if (generation == _saveGeneration) {
        _isSaving = false;
        _persistenceError = error.toString();
        notifyListeners();
      }
    }
  }

  _RunSession _newRun({
    required CityRunConfiguration configuration,
    required Scenario scenario,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String> chronicleStoryIds = const [],
    List<String> chronicleVoiceIds = const [],
    Set<String> usedChronicleTemplateIds = const {},
    ProceduralElection? proceduralElection,
    List<AdministrationRecord> administrationHistory = const [],
  }) {
    final generated = _briefEngine.build(
      scenario: scenario,
      configuration: configuration,
    );
    final news = _orderedById(
      generated.news,
      chronicleStoryIds,
      (item) => item.id,
    );
    final voices = _orderedById(
      generated.voices,
      chronicleVoiceIds,
      (item) => item.id,
    );
    final brief = PreElectionCityBrief(
      scenarioSeed: generated.scenarioSeed,
      metrics: generated.metrics,
      concerns: generated.concerns,
      news: List.unmodifiable(news),
      voices: List.unmodifiable(voices),
    );
    return _RunSession(
        configuration: configuration,
        scenario: scenario,
        preElectionBrief: brief,
        createdAt: createdAt,
        updatedAt: updatedAt,
        proceduralElection: proceduralElection,
        administrationHistory: administrationHistory,
      )
      ..chronicleStoryIds.addAll(brief.news.map((item) => item.id))
      ..chronicleVoiceIds.addAll(brief.voices.map((item) => item.id))
      ..usedChronicleTemplateIds.addAll({
        ...usedChronicleTemplateIds,
        ...brief.usedTemplateIds,
      });
  }

  void _resetRun(_RunSession run, Scenario scenario) {
    final fresh = _briefEngine.build(
      scenario: scenario,
      configuration: run.configuration,
    );
    run.reset(scenario: scenario, preElectionBrief: fresh);
  }

  _RunSession _ensureActiveRun() {
    final active = _activeRun;
    if (active != null) return active;
    final index = _firstEmptySlot() ?? 0;
    final configuration = CityRunConfiguration.defaults(
      cityName: _baseScenario.city.name,
    );
    final scenario = buildConfiguredScenario(
      base: _baseScenario,
      configuration: configuration,
    );
    final run = _newRun(configuration: configuration, scenario: scenario);
    _runs[index] = run;
    _activeSlotIndex = index;
    return run;
  }

  Scenario _freshScenario(
    int seed, {
    required CityRunConfiguration configuration,
  }) {
    final freshBase = _baseScenario.id.startsWith('bayhaven')
        ? buildBayhavenScenario(seed: seed)
        : _baseScenario.copyWith(seed: seed);
    return buildConfiguredScenario(
      base: freshBase,
      configuration: configuration,
    );
  }

  int? _firstEmptySlot() {
    final index = _runs.indexWhere((run) => run == null);
    return index == -1 ? null : index;
  }

  int? _firstOccupiedSlot() {
    final index = _runs.indexWhere((run) => run != null);
    return index == -1 ? null : index;
  }

  void _validateSlotIndex(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= saveSlotCount) {
      throw RangeError.range(slotIndex, 0, saveSlotCount - 1, 'slotIndex');
    }
  }

  EvidenceItem? _evidenceById(_RunSession run, String id) {
    for (final candidate in run.scenario.candidates) {
      for (final item in candidate.evidence) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  void _toggle(Set<String> values, String id) {
    if (!values.remove(id)) values.add(id);
  }

  @override
  void dispose() {
    final repository = this.repository;
    if (repository != null) {
      unawaited(_pendingSave.whenComplete(repository.close));
    }
    super.dispose();
  }
}

class _RunSession {
  _RunSession({
    required this.configuration,
    required this.scenario,
    required this.preElectionBrief,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.proceduralElection,
    List<AdministrationRecord> administrationHistory = const [],
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc(),
       administrationHistory = List.of(administrationHistory) {
    initializeCandidateNames();
  }

  final CityRunConfiguration configuration;
  String get cityName => configuration.cityName;
  Scenario scenario;
  PreElectionCityBrief preElectionBrief;
  ProceduralElection? proceduralElection;
  final List<AdministrationRecord> administrationHistory;
  CandidateExperienceCatalog get candidateExperience =>
      proceduralElection?.candidateExperience ?? bayhavenCandidateExperience;
  CityBookCatalog get cityBook =>
      proceduralElection?.cityBook ?? buildBayhavenCityBook();
  List<UnderlyingNewsEvent> get candidateNewsEvents =>
      proceduralElection?.candidateNewsEvents ?? const [];
  List<NewsCoverage> get candidateNewsCoverages =>
      proceduralElection?.candidateNewsCoverages ?? const [];
  final List<String> chronicleStoryIds = [];
  final List<String> chronicleVoiceIds = [];
  final Set<String> usedChronicleTemplateIds = {};
  final Set<String> bookmarkedEvidenceIds = {};
  final Set<String> viewedEvidenceIds = {};
  final Set<String> chargedEvidenceIds = {};
  final Map<String, int> evidencePointCosts = {};
  final Set<String> unlockedEvidenceIds = {};
  final Set<String> pinnedCandidateIds = {};
  final Set<String> pinnedContentIds = {};
  final Set<String> pinnedQuestionIds = {};
  final Set<String> bookmarkedDebateMessageIds = {};
  final Set<String> pinnedDebateMessageIds = {};
  final Set<String> suspiciousDebateMessageIds = {};
  final Map<String, String> receiptNotes = {};
  final Set<String> predictionIds = {};
  final Set<String> usedCandidateNames = {};
  Candidate? selectedCandidate;
  TermResult? termResult;
  String? topIssue;
  double confidence = 0.5;
  int revealedTermPhases = 0;
  int simulationDay = 0;
  SimulationSpeed simulationSpeed = SimulationSpeed.day;
  bool simulationPaused = true;
  final Set<String> inspectedCityEventIds = {};
  final DateTime createdAt;
  DateTime updatedAt;

  void initializeCandidateNames() {
    usedCandidateNames.addAll(
      scenario.candidates.map((candidate) => candidate.name),
    );
  }

  void reset({
    required Scenario scenario,
    required PreElectionCityBrief preElectionBrief,
  }) {
    this.scenario = scenario;
    this.preElectionBrief = preElectionBrief;
    chronicleStoryIds
      ..clear()
      ..addAll(preElectionBrief.news.map((item) => item.id));
    chronicleVoiceIds
      ..clear()
      ..addAll(preElectionBrief.voices.map((item) => item.id));
    usedChronicleTemplateIds
      ..clear()
      ..addAll(preElectionBrief.usedTemplateIds);
    selectedCandidate = null;
    termResult = null;
    topIssue = null;
    confidence = 0.5;
    revealedTermPhases = 0;
    simulationDay = 0;
    simulationSpeed = SimulationSpeed.day;
    simulationPaused = true;
    inspectedCityEventIds.clear();
    bookmarkedEvidenceIds.clear();
    viewedEvidenceIds.clear();
    chargedEvidenceIds.clear();
    evidencePointCosts.clear();
    unlockedEvidenceIds.clear();
    pinnedCandidateIds.clear();
    pinnedContentIds.clear();
    pinnedQuestionIds.clear();
    bookmarkedDebateMessageIds.clear();
    pinnedDebateMessageIds.clear();
    suspiciousDebateMessageIds.clear();
    receiptNotes.clear();
    predictionIds.clear();
    initializeCandidateNames();
    touch();
  }

  void touch() => updatedAt = DateTime.now().toUtc();

  RunSaveData toSaveData() => RunSaveData(
    seed: scenario.seed,
    configuration: configuration,
    indicators: scenario.city.indicators,
    term: scenario.city.term,
    bookmarkedEvidenceIds: bookmarkedEvidenceIds,
    viewedEvidenceIds: viewedEvidenceIds,
    chargedEvidenceIds: chargedEvidenceIds,
    evidencePointCosts: evidencePointCosts,
    unlockedEvidenceIds: unlockedEvidenceIds,
    pinnedCandidateIds: pinnedCandidateIds,
    pinnedContentIds: pinnedContentIds,
    pinnedQuestionIds: pinnedQuestionIds,
    bookmarkedDebateMessageIds: bookmarkedDebateMessageIds,
    pinnedDebateMessageIds: pinnedDebateMessageIds,
    suspiciousDebateMessageIds: suspiciousDebateMessageIds,
    receiptNotes: receiptNotes,
    predictionIds: predictionIds,
    usedCandidateNames: usedCandidateNames,
    chronicleStoryIds: chronicleStoryIds,
    chronicleVoiceIds: chronicleVoiceIds,
    usedChronicleTemplateIds: usedChronicleTemplateIds,
    selectedCandidateId: selectedCandidate?.id,
    termResultReady: termResult != null,
    revealedTermPhases: revealedTermPhases,
    topIssue: topIssue,
    confidence: confidence,
    createdAt: createdAt,
    updatedAt: updatedAt,
    proceduralElection: proceduralElection,
    livingCity: termResult?.livingCity,
    simulationDay: simulationDay,
    simulationSpeed: simulationSpeed,
    simulationPaused: simulationPaused,
    inspectedCityEventIds: inspectedCityEventIds,
    administrationHistory: administrationHistory,
    currentIssueStates: {
      for (final problem in scenario.city.problems)
        problem.id: CityIssueSaveState(
          severity: problem.severity,
          urgency: problem.urgency,
          trend: problem.trend,
        ),
    },
  );
}

bool _isInterruptingCriticalEvent(CityEvent event) =>
    event.importance == CityEventImportance.critical ||
    event.importance == CityEventImportance.rare;

Map<String, int> _historicalTemplatePressure(
  List<AdministrationRecord> administrations,
) {
  final pressure = <String, int>{};
  for (var index = 0; index < administrations.length; index++) {
    final record = administrations[index];
    final recencyWeight = index == administrations.length - 1 ? 2 : 1;
    final usedThisTerm = record.livingCity.eventHistory
        .where(
          (event) =>
              !event.templateId.startsWith('project_milestone_') &&
              citizenActionTypeForTemplate(event.templateId) == null,
        )
        .map((event) => event.templateId)
        .toSet();
    for (final templateId in usedThisTerm) {
      pressure.update(
        templateId,
        (value) => value + recencyWeight,
        ifAbsent: () => recencyWeight,
      );
    }
  }
  return Map.unmodifiable(pressure);
}

Map<String, int> _historicalVisualPressure(
  List<AdministrationRecord> administrations,
) {
  final pressure = <String, int>{};
  for (var index = 0; index < administrations.length; index++) {
    final record = administrations[index];
    final recencyWeight = index == administrations.length - 1 ? 2 : 1;
    final usedThisTerm = record.livingCity.eventHistory
        .where(
          (event) =>
              !event.templateId.startsWith('project_milestone_') &&
              citizenActionTypeForTemplate(event.templateId) == null,
        )
        .map(
          (event) =>
              livingEventVisualKeyForTemplateId(event.templateId) ??
              livingEventVisualKey(
                visualAssetKey: event.visualAssetKey,
                markerType: event.markerType,
                district: event.district,
              ),
        )
        .toSet();
    for (final visualKey in usedThisTerm) {
      pressure.update(
        visualKey,
        (value) => value + recencyWeight,
        ifAbsent: () => recencyWeight,
      );
    }
  }
  return Map.unmodifiable(pressure);
}

Map<String, int> _historicalNewsFramingPressure(
  List<AdministrationRecord> administrations,
) {
  final pressure = <String, int>{};
  for (var index = 0; index < administrations.length; index++) {
    final record = administrations[index];
    final recencyWeight = index == administrations.length - 1 ? 2 : 1;
    final countsByOutlet = <String, Map<String, int>>{};
    for (final coverage in record.livingCity.newsCoverages) {
      final framingKey = newsFramingKey(
        outletId: coverage.outletId,
        framingAngle: coverage.framingAngle,
      );
      final outletCounts = countsByOutlet.putIfAbsent(
        coverage.outletId,
        () => <String, int>{},
      );
      outletCounts.update(framingKey, (value) => value + 1, ifAbsent: () => 1);
    }
    for (final outletCounts in countsByOutlet.values) {
      final dominantUseCount = outletCounts.values.fold<int>(
        0,
        (highest, count) => count > highest ? count : highest,
      );
      final dominantKeys = outletCounts.entries
          .where((entry) => entry.value == dominantUseCount)
          .map((entry) => entry.key);
      for (final framingKey in dominantKeys) {
        pressure.update(
          framingKey,
          (value) => value + recencyWeight,
          ifAbsent: () => recencyWeight,
        );
      }
    }
  }
  return Map.unmodifiable(pressure);
}

TermResult _restoreTermResult(
  TermResult generated,
  LivingTermSimulation? persisted,
) => persisted == null
    ? generated
    : TermResult(
        seed: generated.seed,
        candidate: generated.candidate,
        before: persisted.initialIndicators,
        after: persisted.finalIndicators,
        phases: generated.phases,
        summary: persisted.summary,
        livingCity: persisted,
      );

List<T> _orderedById<T>(
  List<T> generated,
  List<String> savedIds,
  String Function(T item) idOf,
) {
  if (savedIds.isEmpty) return generated;
  final byId = {for (final item in generated) idOf(item): item};
  final ordered = <T>[];
  for (final id in savedIds) {
    final item = byId.remove(id);
    if (item != null) ordered.add(item);
  }
  ordered.addAll(byId.values);
  return ordered;
}
