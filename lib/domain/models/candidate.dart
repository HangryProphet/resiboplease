import 'city_indicator.dart';
import 'evidence_item.dart';

class CandidateCapabilities {
  const CandidateCapabilities({
    required this.policyScores,
    required this.implementationSkill,
    required this.integrity,
    required this.coalitionSkill,
    required this.crisisResponse,
    required this.budgetDiscipline,
    required this.corruptionRisk,
  });

  final Map<CityIndicator, int> policyScores;
  final int implementationSkill;
  final int integrity;
  final int coalitionSkill;
  final int crisisResponse;
  final int budgetDiscipline;
  final int corruptionRisk;

  int policyFor(CityIndicator indicator) => policyScores[indicator] ?? 50;

  CandidateCapabilities copyWith({
    Map<CityIndicator, int>? policyScores,
    int? implementationSkill,
    int? integrity,
    int? coalitionSkill,
    int? crisisResponse,
    int? budgetDiscipline,
    int? corruptionRisk,
  }) => CandidateCapabilities(
    policyScores: policyScores ?? this.policyScores,
    implementationSkill: implementationSkill ?? this.implementationSkill,
    integrity: integrity ?? this.integrity,
    coalitionSkill: coalitionSkill ?? this.coalitionSkill,
    crisisResponse: crisisResponse ?? this.crisisResponse,
    budgetDiscipline: budgetDiscipline ?? this.budgetDiscipline,
    corruptionRisk: corruptionRisk ?? this.corruptionRisk,
  );
}

class Candidate {
  const Candidate({
    required this.id,
    required this.name,
    required this.party,
    required this.archetype,
    required this.slogan,
    required this.biography,
    required this.visibleStrengths,
    required this.visibleConcerns,
    required this.platform,
    required this.evidence,
    required this.capabilities,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String party;
  final String archetype;
  final String slogan;
  final String biography;
  final List<String> visibleStrengths;
  final List<String> visibleConcerns;
  final List<String> platform;
  final List<EvidenceItem> evidence;

  // Simulation truth stays in the domain layer and is never rendered directly.
  final CandidateCapabilities capabilities;
  final int colorValue;

  Candidate copyWith({
    String? id,
    String? name,
    String? party,
    String? archetype,
    String? slogan,
    String? biography,
    List<String>? visibleStrengths,
    List<String>? visibleConcerns,
    List<String>? platform,
    List<EvidenceItem>? evidence,
    CandidateCapabilities? capabilities,
    int? colorValue,
  }) => Candidate(
    id: id ?? this.id,
    name: name ?? this.name,
    party: party ?? this.party,
    archetype: archetype ?? this.archetype,
    slogan: slogan ?? this.slogan,
    biography: biography ?? this.biography,
    visibleStrengths: visibleStrengths ?? this.visibleStrengths,
    visibleConcerns: visibleConcerns ?? this.visibleConcerns,
    platform: platform ?? this.platform,
    evidence: evidence ?? this.evidence,
    capabilities: capabilities ?? this.capabilities,
    colorValue: colorValue ?? this.colorValue,
  );
}
