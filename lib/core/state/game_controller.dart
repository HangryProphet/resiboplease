import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/configuration/configured_scenario.dart';
import '../../data/persistence/run_repository.dart';
import '../../data/persistence/run_save_data.dart';
import '../../data/seed_content/bayhaven_scenario.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/models/evidence_item.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/term_result.dart';
import '../../domain/simulation/term_engine.dart';

enum CityRunProgress { electionBrief, termInProgress, termReportReady }

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
  }) : _baseScenario = scenario ?? buildBayhavenScenario() {
    if (activeRun) {
      final configuration = CityRunConfiguration.defaults(
        cityName: _baseScenario.city.name,
      );
      _runs[0] = _RunSession(
        configuration: configuration,
        scenario: buildConfiguredScenario(
          base: _baseScenario,
          configuration: configuration,
        ),
      );
      _activeSlotIndex = 0;
    }
  }

  static const saveSlotCount = 5;

  final TermEngine _engine;
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
  Candidate? get selectedCandidate => _activeRun?.selectedCandidate;
  TermResult? get termResult => _activeRun?.termResult;
  String? get topIssue => _activeRun?.topIssue;
  double get confidence => _activeRun?.confidence ?? 0.5;
  bool get hasActiveRun => _runs.any((run) => run != null);
  int? get activeSlotIndex => _activeSlotIndex;
  bool get isSaving => _isSaving;
  bool get hasPersistentStorage => repository != null;
  String? get persistenceError => _persistenceError;
  String get activeResumeRoute => termResult != null
      ? '/report'
      : selectedCandidate != null
      ? '/simulation'
      : '/city';
  String get activeCityName => _activeRun?.cityName ?? scenario.city.name;
  CityRunConfiguration? get activeConfiguration => _activeRun?.configuration;
  AssistanceMode get assistanceMode =>
      activeConfiguration?.assistanceMode ?? AssistanceMode.guided;
  int? get investigationPointLimit =>
      activeConfiguration?.investigationTime.pointLimit;
  int get investigationPointsUsed => _activeRun?.chargedEvidenceIds.length ?? 0;
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
        progress: run.termResult != null
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

  bool markEvidenceViewed(String id) {
    final run = _ensureActiveRun();
    final item = _evidenceById(run, id);
    if (item == null) return false;
    if (run.viewedEvidenceIds.contains(id)) return true;
    final costsPoint = item.type != EvidenceType.profile;
    final pointLimit = run.configuration.investigationTime.pointLimit;
    if (costsPoint &&
        pointLimit != null &&
        run.chargedEvidenceIds.length >= pointLimit) {
      return false;
    }
    run.viewedEvidenceIds.add(id);
    if (costsPoint) run.chargedEvidenceIds.add(id);
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

  void createCity({
    required int slotIndex,
    required CityRunConfiguration configuration,
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
    final configuredScenario = buildConfiguredScenario(
      base: _baseScenario,
      configuration: normalizedConfiguration,
    );
    _runs[slotIndex] = _RunSession(
      configuration: normalizedConfiguration,
      scenario: configuredScenario,
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
      _runs[index] = _RunSession(
        configuration: configuration,
        scenario: buildConfiguredScenario(
          base: _baseScenario,
          configuration: configuration,
        ),
      );
      _activeSlotIndex = index;
    } else {
      active.reset(
        scenario: _freshScenario(
          active.scenario.seed,
          configuration: active.configuration,
        ),
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
    run.termResult = _engine.simulate(
      scenario: run.scenario,
      candidate: activeCandidate,
    );
    run.touch();
    _commit();
  }

  void restartSameSeed() {
    final run = _ensureActiveRun();
    run.reset(
      scenario: _freshScenario(
        run.scenario.seed,
        configuration: run.configuration,
      ),
    );
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
    final profileViews = saved.viewedEvidenceIds.where(
      (id) => availableEvidence[id]?.type == EvidenceType.profile,
    );
    final paidViews = saved.viewedEvidenceIds.where(
      (id) =>
          availableEvidence[id] != null &&
          availableEvidence[id]!.type != EvidenceType.profile &&
          saved.chargedEvidenceIds.contains(id),
    );
    final pointLimit = saved.configuration.investigationTime.pointLimit;
    final allowedPaidViews = pointLimit == null
        ? paidViews
        : paidViews.take(pointLimit);
    final sanitizedViews = <String>{...profileViews, ...allowedPaidViews};
    final sanitizedBookmarks = saved.bookmarkedEvidenceIds.where(
      availableEvidence.containsKey,
    );
    final sanitizedCharges = sanitizedViews.where(
      (id) => availableEvidence[id]?.type != EvidenceType.profile,
    );
    return _RunSession(
        configuration: saved.configuration,
        scenario: scenario,
        createdAt: saved.createdAt,
        updatedAt: saved.updatedAt,
      )
      ..bookmarkedEvidenceIds.addAll(sanitizedBookmarks)
      ..viewedEvidenceIds.addAll(sanitizedViews)
      ..chargedEvidenceIds.addAll(sanitizedCharges)
      ..selectedCandidate = candidate
      ..termResult = saved.termResultReady && candidate != null
          ? _engine.simulate(scenario: scenario, candidate: candidate)
          : null
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

  _RunSession _ensureActiveRun() {
    final active = _activeRun;
    if (active != null) return active;
    final index = _firstEmptySlot() ?? 0;
    final configuration = CityRunConfiguration.defaults(
      cityName: _baseScenario.city.name,
    );
    final run = _RunSession(
      configuration: configuration,
      scenario: buildConfiguredScenario(
        base: _baseScenario,
        configuration: configuration,
      ),
    );
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc();

  final CityRunConfiguration configuration;
  String get cityName => configuration.cityName;
  Scenario scenario;
  final Set<String> bookmarkedEvidenceIds = {};
  final Set<String> viewedEvidenceIds = {};
  final Set<String> chargedEvidenceIds = {};
  Candidate? selectedCandidate;
  TermResult? termResult;
  String? topIssue;
  double confidence = 0.5;
  final DateTime createdAt;
  DateTime updatedAt;

  void reset({required Scenario scenario}) {
    this.scenario = scenario;
    selectedCandidate = null;
    termResult = null;
    topIssue = null;
    confidence = 0.5;
    bookmarkedEvidenceIds.clear();
    viewedEvidenceIds.clear();
    chargedEvidenceIds.clear();
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
    selectedCandidateId: selectedCandidate?.id,
    termResultReady: termResult != null,
    topIssue: topIssue,
    confidence: confidence,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
