import 'living_city_simulation.dart';
import 'procedural_election.dart';

/// Immutable receipt for one completed administration.
///
/// The active election continues to live in the run session. Once its full
/// 365-day term is completed, this snapshot is appended exactly once before the
/// next election is created. Historical records are never regenerated.
class AdministrationRecord {
  const AdministrationRecord({
    required this.id,
    required this.termNumber,
    required this.electionSeed,
    required this.electedCandidateId,
    required this.electedCandidateName,
    required this.electedParty,
    required this.electedPortraitAssetKey,
    required this.topIssue,
    required this.confidence,
    required this.livingCity,
    required this.investigation,
    required this.completedAt,
    this.election,
  });

  final String id;
  final int termNumber;
  final int electionSeed;
  final String electedCandidateId;
  final String electedCandidateName;
  final String electedParty;
  final String electedPortraitAssetKey;
  final String? topIssue;
  final double confidence;
  final ProceduralElection? election;
  final LivingTermSimulation livingCity;
  final AdministrationInvestigationSnapshot investigation;
  final DateTime completedAt;

  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Administration ID cannot be empty.');
    if (termNumber < 1) errors.add('Administration term must be positive.');
    if (livingCity.termNumber != termNumber) {
      errors.add('Administration term does not match its simulation.');
    }
    if (livingCity.candidateId != electedCandidateId) {
      errors.add('Administration mayor does not match its simulation.');
    }
    final election = this.election;
    if (election != null &&
        !election.candidates.any((item) => item.id == electedCandidateId)) {
      errors.add('Administration mayor is absent from its election.');
    }
    if (confidence < 0 || confidence > 1) {
      errors.add('Administration confidence must be between zero and one.');
    }
    return errors;
  }
}

class AdministrationInvestigationSnapshot {
  const AdministrationInvestigationSnapshot({
    this.viewedEvidenceIds = const {},
    this.bookmarkedEvidenceIds = const {},
    this.pinnedCandidateIds = const {},
    this.pinnedContentIds = const {},
    this.pinnedQuestionIds = const {},
    this.bookmarkedDebateMessageIds = const {},
    this.pinnedDebateMessageIds = const {},
    this.suspiciousDebateMessageIds = const {},
    this.receiptNotes = const {},
    this.predictionIds = const {},
  });

  final Set<String> viewedEvidenceIds;
  final Set<String> bookmarkedEvidenceIds;
  final Set<String> pinnedCandidateIds;
  final Set<String> pinnedContentIds;
  final Set<String> pinnedQuestionIds;
  final Set<String> bookmarkedDebateMessageIds;
  final Set<String> pinnedDebateMessageIds;
  final Set<String> suspiciousDebateMessageIds;
  final Map<String, String> receiptNotes;
  final Set<String> predictionIds;
}
