import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/configuration/configured_scenario.dart';
import '../../data/persistence/run_repository.dart';
import '../../data/persistence/run_save_data.dart';
import '../../data/seed_content/bayhaven_candidate_experience.dart';
import '../../data/seed_content/bayhaven_citybook.dart';
import '../../data/seed_content/bayhaven_scenario.dart';
import '../../domain/models/candidate.dart';
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
import '../settings/app_settings_controller.dart';
import '../../domain/simulation/pre_election_brief_engine.dart';
import '../../domain/simulation/information_ecosystem_engine.dart';
import '../../domain/simulation/procedural_candidate_generator.dart';
import '../../domain/simulation/term_engine.dart';

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
  Set<String> get usedCandidateNames =>
      Set.unmodifiable(_activeRun?.usedCandidateNames ?? const <String>{});
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
    _resetRun(run, run.scenario);
    _commit();
  }

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
    scenario = scenario.copyWith(
      city: scenario.city.copyWith(
        indicators: saved.indicators,
        term: saved.term,
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
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc() {
    initializeCandidateNames();
  }

  final CityRunConfiguration configuration;
  String get cityName => configuration.cityName;
  Scenario scenario;
  PreElectionCityBrief preElectionBrief;
  final ProceduralElection? proceduralElection;
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
  );
}

bool _isInterruptingCriticalEvent(CityEvent event) =>
    event.importance == CityEventImportance.critical ||
    event.importance == CityEventImportance.rare;

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
