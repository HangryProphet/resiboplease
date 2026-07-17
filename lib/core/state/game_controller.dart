import 'package:flutter/foundation.dart';

import '../../data/seed_content/bayhaven_scenario.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/term_result.dart';
import '../../domain/simulation/term_engine.dart';

class GameController extends ChangeNotifier {
  GameController({
    Scenario? scenario,
    bool activeRun = false,
    this._engine = const TermEngine(),
  }) : _scenario = scenario ?? buildBayhavenScenario(),
       _hasActiveRun = activeRun;

  final TermEngine _engine;
  Scenario _scenario;
  final Set<String> _bookmarkedEvidenceIds = {};
  final Set<String> _viewedEvidenceIds = {};

  Candidate? _selectedCandidate;
  TermResult? _termResult;
  String? _topIssue;
  double _confidence = 0.5;
  bool _hasActiveRun;

  Scenario get scenario => _scenario;
  Candidate? get selectedCandidate => _selectedCandidate;
  TermResult? get termResult => _termResult;
  String? get topIssue => _topIssue;
  double get confidence => _confidence;
  bool get hasActiveRun => _hasActiveRun;
  int get viewedEvidenceCount => _viewedEvidenceIds.length;
  Set<String> get bookmarkedEvidenceIds =>
      Set.unmodifiable(_bookmarkedEvidenceIds);

  Candidate candidateById(String id) =>
      _scenario.candidates.firstWhere((candidate) => candidate.id == id);

  void markEvidenceViewed(String id) {
    if (_viewedEvidenceIds.add(id)) notifyListeners();
  }

  void toggleBookmark(String id) {
    if (!_bookmarkedEvidenceIds.remove(id)) _bookmarkedEvidenceIds.add(id);
    notifyListeners();
  }

  bool isBookmarked(String id) => _bookmarkedEvidenceIds.contains(id);

  void startNewRun() {
    _resetRunState();
    _hasActiveRun = true;
    notifyListeners();
  }

  void castVote({
    required Candidate candidate,
    required String topIssue,
    required double confidence,
  }) {
    _hasActiveRun = true;
    _selectedCandidate = candidate;
    _topIssue = topIssue;
    _confidence = confidence;
    _termResult = _engine.simulate(scenario: _scenario, candidate: candidate);
    notifyListeners();
  }

  void restartSameSeed() {
    _scenario = buildBayhavenScenario(seed: _scenario.seed);
    _resetRunState();
    _hasActiveRun = true;
    notifyListeners();
  }

  void _resetRunState() {
    _selectedCandidate = null;
    _termResult = null;
    _topIssue = null;
    _confidence = 0.5;
    _bookmarkedEvidenceIds.clear();
    _viewedEvidenceIds.clear();
  }
}
