import 'package:flutter/foundation.dart';

import '../../data/seed_content/bayhaven_scenario.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/term_result.dart';
import '../../domain/simulation/term_engine.dart';

class CitySaveSlot {
  const CitySaveSlot({
    required this.slotIndex,
    required this.cityName,
    required this.scenarioName,
    required this.term,
    required this.progressLabel,
  });

  final int slotIndex;
  final String cityName;
  final String scenarioName;
  final int term;
  final String progressLabel;
}

class GameController extends ChangeNotifier {
  GameController({
    Scenario? scenario,
    bool activeRun = false,
    this._engine = const TermEngine(),
  }) : _baseScenario = scenario ?? buildBayhavenScenario() {
    if (activeRun) {
      _runs[0] = _RunSession(
        cityName: _baseScenario.city.name,
        scenario: _baseScenario,
      );
      _activeSlotIndex = 0;
    }
  }

  static const saveSlotCount = 5;

  final TermEngine _engine;
  final Scenario _baseScenario;
  final List<_RunSession?> _runs = List<_RunSession?>.filled(
    saveSlotCount,
    null,
  );
  int? _activeSlotIndex;

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
  String get activeCityName => _activeRun?.cityName ?? scenario.city.name;
  int get viewedEvidenceCount => _activeRun?.viewedEvidenceIds.length ?? 0;
  Set<String> get bookmarkedEvidenceIds =>
      Set.unmodifiable(_activeRun?.bookmarkedEvidenceIds ?? const <String>{});

  List<CitySaveSlot?> get saveSlots => List<CitySaveSlot?>.unmodifiable(
    List<CitySaveSlot?>.generate(saveSlotCount, (index) {
      final run = _runs[index];
      if (run == null) return null;
      return CitySaveSlot(
        slotIndex: index,
        cityName: run.cityName,
        scenarioName: run.scenario.city.name,
        term: run.scenario.city.term,
        progressLabel: run.termResult != null
            ? 'Term report ready'
            : run.selectedCandidate != null
            ? 'Term in progress'
            : 'Election brief',
      );
    }),
  );

  Candidate candidateById(String id) =>
      scenario.candidates.firstWhere((candidate) => candidate.id == id);

  void markEvidenceViewed(String id) {
    final run = _ensureActiveRun();
    if (run.viewedEvidenceIds.add(id)) notifyListeners();
  }

  void toggleBookmark(String id) {
    final run = _ensureActiveRun();
    if (!run.bookmarkedEvidenceIds.remove(id)) {
      run.bookmarkedEvidenceIds.add(id);
    }
    notifyListeners();
  }

  bool isBookmarked(String id) =>
      _activeRun?.bookmarkedEvidenceIds.contains(id) ?? false;

  void createCity({required int slotIndex, required String cityName}) {
    _validateSlotIndex(slotIndex);
    if (_runs[slotIndex] != null) {
      throw StateError('Save slot ${slotIndex + 1} is already occupied.');
    }
    final cleanedName = cityName.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError.value(cityName, 'cityName', 'Cannot be empty.');
    }
    _runs[slotIndex] = _RunSession(
      cityName: cleanedName,
      scenario: _baseScenario,
    );
    _activeSlotIndex = slotIndex;
    notifyListeners();
  }

  void continueCity(int slotIndex) {
    _validateSlotIndex(slotIndex);
    if (_runs[slotIndex] == null) {
      throw StateError('Save slot ${slotIndex + 1} is empty.');
    }
    _activeSlotIndex = slotIndex;
    notifyListeners();
  }

  void deleteCity(int slotIndex) {
    _validateSlotIndex(slotIndex);
    if (_runs[slotIndex] == null) return;
    _runs[slotIndex] = null;
    if (_activeSlotIndex == slotIndex) {
      _activeSlotIndex = _firstOccupiedSlot();
    }
    notifyListeners();
  }

  void startNewRun() {
    final active = _activeRun;
    if (active == null) {
      final index = _firstEmptySlot() ?? 0;
      _runs[index] = _RunSession(
        cityName: _baseScenario.city.name,
        scenario: _baseScenario,
      );
      _activeSlotIndex = index;
    } else {
      active.reset(scenario: _freshScenario(active.scenario.seed));
    }
    notifyListeners();
  }

  void castVote({
    required Candidate candidate,
    required String topIssue,
    required double confidence,
  }) {
    final run = _ensureActiveRun();
    run.selectedCandidate = candidate;
    run.topIssue = topIssue;
    run.confidence = confidence;
    run.termResult = _engine.simulate(
      scenario: run.scenario,
      candidate: candidate,
    );
    notifyListeners();
  }

  void restartSameSeed() {
    final run = _ensureActiveRun();
    run.reset(scenario: _freshScenario(run.scenario.seed));
    notifyListeners();
  }

  _RunSession _ensureActiveRun() {
    final active = _activeRun;
    if (active != null) return active;
    final index = _firstEmptySlot() ?? 0;
    final run = _RunSession(
      cityName: _baseScenario.city.name,
      scenario: _baseScenario,
    );
    _runs[index] = run;
    _activeSlotIndex = index;
    return run;
  }

  Scenario _freshScenario(int seed) {
    if (_baseScenario.id.startsWith('bayhaven')) {
      return buildBayhavenScenario(seed: seed);
    }
    return _baseScenario;
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
}

class _RunSession {
  _RunSession({required this.cityName, required this.scenario});

  final String cityName;
  Scenario scenario;
  final Set<String> bookmarkedEvidenceIds = {};
  final Set<String> viewedEvidenceIds = {};
  Candidate? selectedCandidate;
  TermResult? termResult;
  String? topIssue;
  double confidence = 0.5;

  void reset({required Scenario scenario}) {
    this.scenario = scenario;
    selectedCandidate = null;
    termResult = null;
    topIssue = null;
    confidence = 0.5;
    bookmarkedEvidenceIds.clear();
    viewedEvidenceIds.clear();
  }
}
