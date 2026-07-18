import '../models/candidate.dart';
import '../models/evidence_item.dart';

/// Internal content validation for the "no perfect candidate" rule.
///
/// Counts based on hidden capabilities stay in the simulation layer. Player
/// widgets should use [CandidateDossierProfile] instead of this audit.
class CandidateTradeoffAudit {
  const CandidateTradeoffAudit({
    required this.visibleStrengthCount,
    required this.visibleConcernCount,
    required this.hiddenStrengthCount,
    required this.hiddenLiabilityCount,
    required this.uncertaintyCount,
    required this.violations,
  });

  final int visibleStrengthCount;
  final int visibleConcernCount;
  final int hiddenStrengthCount;
  final int hiddenLiabilityCount;
  final int uncertaintyCount;
  final List<String> violations;

  bool get passes => violations.isEmpty;
}

CandidateTradeoffAudit auditCandidateTradeoffs(Candidate candidate) {
  final capabilities = candidate.capabilities;
  final hiddenSignals = <int>[
    ...capabilities.policyScores.values,
    capabilities.implementationSkill,
    capabilities.integrity,
    capabilities.coalitionSkill,
    capabilities.crisisResponse,
    capabilities.budgetDiscipline,
    // Convert risk to a positive "safety" signal so low values are a liability.
    100 - capabilities.corruptionRisk,
  ];
  final hiddenStrengthCount = hiddenSignals
      .where((value) => value >= 75)
      .length;
  final hiddenLiabilityCount = hiddenSignals
      .where((value) => value <= 55)
      .length;
  final uncertaintyCount = candidate.evidence
      .where(_containsUncertainty)
      .length;
  final violations = <String>[
    if (candidate.visibleStrengths.length < 2)
      'needs at least two disclosed strengths',
    if (candidate.visibleConcerns.length < 2)
      'needs at least two disclosed concerns',
    if (hiddenStrengthCount < 2)
      'needs at least two meaningful simulation strengths',
    if (hiddenLiabilityCount < 2)
      'needs at least two meaningful simulation liabilities',
    if (uncertaintyCount < 1) 'needs at least one unresolved risk or claim',
  ];
  return CandidateTradeoffAudit(
    visibleStrengthCount: candidate.visibleStrengths.length,
    visibleConcernCount: candidate.visibleConcerns.length,
    hiddenStrengthCount: hiddenStrengthCount,
    hiddenLiabilityCount: hiddenLiabilityCount,
    uncertaintyCount: uncertaintyCount,
    violations: List.unmodifiable(violations),
  );
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
