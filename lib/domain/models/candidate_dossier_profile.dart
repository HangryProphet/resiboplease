import 'candidate.dart';
import 'city_run_configuration.dart';
import 'evidence_item.dart';

/// A coarse, player-facing description of public-service experience.
///
/// These bands are intentionally qualitative. They must never be converted
/// into a recommendation, match percentage, or overall candidate grade.
enum DossierExperienceBand { emerging, practiced, established }

enum DossierEvidenceDepth { limited, mixed, documented }

class CandidateEvidenceSummary {
  const CandidateEvidenceSummary({
    required this.totalItems,
    required this.distinctSources,
    required this.accountableRecords,
    required this.campaignClaims,
    required this.unresolvedItems,
    required this.depth,
  });

  final int totalItems;
  final int distinctSources;
  final int accountableRecords;
  final int campaignClaims;
  final int unresolvedItems;
  final DossierEvidenceDepth depth;
}

/// The only synthesized candidate profile intended for pre-election widgets.
///
/// It carries disclosed dossier statements and evidence-ledger facts, but no
/// hidden capability values and no aggregate suitability result.
class CandidateDossierProfile {
  const CandidateDossierProfile({
    required this.candidateId,
    required this.experienceBand,
    required this.strengths,
    required this.concerns,
    required this.uncertaintyEvidenceIds,
    required this.evidenceSummary,
  });

  final String candidateId;
  final DossierExperienceBand experienceBand;
  final List<String> strengths;
  final List<String> concerns;
  final List<String> uncertaintyEvidenceIds;
  final CandidateEvidenceSummary evidenceSummary;

  bool get hasRequiredTradeoffs =>
      strengths.length >= 2 &&
      concerns.length >= 2 &&
      uncertaintyEvidenceIds.isNotEmpty;
}

CandidateDossierProfile buildCandidateDossierProfile({
  required Candidate candidate,
  required CandidateField candidateField,
  required int seed,
}) {
  final uncertaintyIds = candidate.evidence
      .where(_containsUncertainty)
      .map((item) => item.id)
      .toSet()
      .toList(growable: false);
  final accountableRecords = candidate.evidence.where(_isAccountableRecord);
  final campaignClaims = candidate.evidence.where(
    (item) => switch (item.type) {
      EvidenceType.platform ||
      EvidenceType.campaignAd ||
      EvidenceType.socialPost => true,
      _ => false,
    },
  );
  final distinctSources = candidate.evidence
      .map((item) => item.source.trim().toLowerCase())
      .where((source) => source.isNotEmpty)
      .toSet()
      .length;
  final accountableCount = accountableRecords.length;
  final depth = switch (accountableCount) {
    <= 1 => DossierEvidenceDepth.limited,
    <= 3 => DossierEvidenceDepth.mixed,
    _ => DossierEvidenceDepth.documented,
  };

  final profile = CandidateDossierProfile(
    candidateId: candidate.id,
    experienceBand: _experienceBandFor(
      candidateId: candidate.id,
      candidateField: candidateField,
      seed: seed,
    ),
    strengths: List.unmodifiable(candidate.visibleStrengths),
    concerns: List.unmodifiable(candidate.visibleConcerns),
    uncertaintyEvidenceIds: List.unmodifiable(uncertaintyIds),
    evidenceSummary: CandidateEvidenceSummary(
      totalItems: candidate.evidence.length,
      distinctSources: distinctSources,
      accountableRecords: accountableCount,
      campaignClaims: campaignClaims.length,
      unresolvedItems: uncertaintyIds.length,
      depth: depth,
    ),
  );
  if (!profile.hasRequiredTradeoffs) {
    throw StateError(
      'Candidate ${candidate.id} does not meet the dossier tradeoff rules.',
    );
  }
  return profile;
}

DossierExperienceBand _experienceBandFor({
  required String candidateId,
  required CandidateField candidateField,
  required int seed,
}) {
  final slot = (seed ^ _stableHash(candidateId)) % 3;
  return switch (candidateField) {
    CandidateField.unproven =>
      slot == 0
          ? DossierExperienceBand.practiced
          : DossierExperienceBand.emerging,
    CandidateField.mixed => DossierExperienceBand.values[slot],
    CandidateField.seasoned =>
      slot == 0
          ? DossierExperienceBand.practiced
          : DossierExperienceBand.established,
  };
}

bool _isAccountableRecord(EvidenceItem item) {
  if (item.reliability < 70) return false;
  return switch (item.type) {
    EvidenceType.profile ||
    EvidenceType.publicRecord ||
    EvidenceType.budgetDocument ||
    EvidenceType.factCheck ||
    EvidenceType.controversy ||
    EvidenceType.debateAnswer => true,
    EvidenceType.platform ||
    EvidenceType.campaignAd ||
    EvidenceType.socialPost => false,
  };
}

bool _containsUncertainty(EvidenceItem item) =>
    item.type == EvidenceType.controversy ||
    switch (item.truthStatus) {
      TruthStatus.partiallyTrue ||
      TruthStatus.misleading ||
      TruthStatus.unverified ||
      TruthStatus.falseClaim ||
      TruthStatus.missingContext => true,
      TruthStatus.verifiedTrue || TruthStatus.mostlyTrue => false,
    };

int _stableHash(String value) => value.codeUnits.fold(
  0,
  (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
);
