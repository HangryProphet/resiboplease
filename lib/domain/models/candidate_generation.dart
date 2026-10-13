import 'dart:math';

import 'candidate_experience.dart';
import 'candidate_biography.dart';
import 'candidate_name_registry.dart';

enum CandidateControversyStatus {
  verified,
  stronglySupported,
  partiallySupported,
  disputed,
  unresolved,
  misleading,
  falseAccusation,
}

enum CandidateRelationshipType {
  donor,
  contractor,
  ally,
  rival,
  organization,
  formerEmployer,
  advocacyGroup,
}

enum CandidateCareerOrigin {
  careerPolitician,
  publicAdministrator,
  professional,
  business,
  celebrityMedia,
  community,
  advocacy,
  publicSafety,
}

class CandidateControversyTruth {
  const CandidateControversyTruth({
    required this.id,
    required this.kind,
    required this.summary,
    required this.status,
    required this.relatedIssueKeys,
  });

  final String id;
  final String kind;
  final String summary;
  final CandidateControversyStatus status;
  final List<String> relatedIssueKeys;
}

class CandidateRelationshipTruth {
  const CandidateRelationshipTruth({
    required this.id,
    required this.name,
    required this.type,
    required this.summary,
    required this.isPotentialConflict,
  });

  final String id;
  final String name;
  final CandidateRelationshipType type;
  final String summary;
  final bool isPotentialConflict;
}

/// Hidden, deterministic truth used to construct a future candidate.
/// This model must never be passed directly to player-facing widgets.
class CandidateTruthProfile {
  const CandidateTruthProfile({
    required this.qualityBand,
    required this.generalCompetence,
    required this.implementationSkill,
    required this.integrity,
    required this.corruptionRisk,
    required this.coalitionSkill,
    required this.communication,
    required this.budgetDiscipline,
    required this.policyScores,
    required this.motivations,
    required this.hiddenRisks,
    this.crisisResponse = 50,
    this.adaptability = 50,
    this.experience = 50,
    this.populism = 50,
    this.ambition = 50,
    this.reformCredibility = 50,
    this.politicalFatigue = 10,
    this.institutionalStanding = 50,
    this.informationFootprint = CandidateInformationFootprint.normal,
    this.careerOrigin = CandidateCareerOrigin.careerPolitician,
    this.personalityTags = const [],
    this.controversies = const [],
    this.relationships = const [],
  });

  final CandidateQualityBand qualityBand;
  final int generalCompetence;
  final int implementationSkill;
  final int integrity;
  final int corruptionRisk;
  final int coalitionSkill;
  final int communication;
  final int budgetDiscipline;
  final Map<String, int> policyScores;
  final List<String> motivations;
  final List<String> hiddenRisks;
  final int crisisResponse;
  final int adaptability;
  final int experience;
  final int populism;
  final int ambition;

  /// Dynamic career pressures. These remain simulation-only; player-facing
  /// screens explain their causes through the historical record instead of
  /// exposing raw scores.
  final int reformCredibility;
  final int politicalFatigue;
  final int institutionalStanding;
  final CandidateInformationFootprint informationFootprint;
  final CandidateCareerOrigin careerOrigin;
  final List<String> personalityTags;
  final List<CandidateControversyTruth> controversies;
  final List<CandidateRelationshipTruth> relationships;
}

/// A content-safe outline. Authored templates or a later narrative service may
/// turn these seeds into prose, but may not alter [truth].
class CandidateNarrativePlan {
  const CandidateNarrativePlan({
    required this.claimSeeds,
    required this.disputeSeeds,
    required this.evidenceRelations,
    required this.debateTopicIds,
  });

  final List<String> claimSeeds;
  final List<String> disputeSeeds;
  final List<EvidenceRelationType> evidenceRelations;
  final List<String> debateTopicIds;
}

class CandidateGenerationBlueprint {
  const CandidateGenerationBlueprint({
    required this.id,
    required this.displayName,
    required this.partyName,
    required this.slogan,
    required this.identityKey,
    required this.portraitAssetKey,
    required this.rhetoricalStyle,
    required this.truth,
    required this.narrativePlan,
  });

  final String id;
  final String displayName;
  final String partyName;
  final String slogan;
  final String identityKey;
  final String portraitAssetKey;
  final CandidateRhetoricalStyle rhetoricalStyle;
  final CandidateTruthProfile truth;
  final CandidateNarrativePlan narrativePlan;
}

class CandidateBlueprintGenerator {
  const CandidateBlueprintGenerator();

  static const _firstNames = [
    'Amihan',
    'Lina',
    'Tomas',
    'Rafael',
    'Nika',
    'Elena',
    'Paolo',
    'Samira',
  ];
  static const _surnames = [
    'Santos',
    'Reyes',
    'Cruz',
    'Navarro',
    'Lim',
    'Flores',
    'Aquino',
    'Mercado',
  ];
  static const _parties = [
    'Bayanihan Coalition',
    'Harbor Reform League',
    'People First Movement',
    'Civic Renewal Party',
    'Common Future Alliance',
  ];
  static const _slogans = [
    'A city that works for every street.',
    'Repair today. Prepare tomorrow.',
    'Public money, public proof.',
    'Work with dignity, services with care.',
    'Steady hands for a changing city.',
  ];
  static const _issues = ['water', 'health', 'employment'];

  List<CandidateGenerationBlueprint> generateRoster({
    required int seed,
    required int count,
    required CandidateNameRegistry nameRegistry,
  }) {
    if (count < 1) {
      throw ArgumentError.value(count, 'count', 'Must be positive.');
    }
    final random = Random(seed);
    final usedParties = <String>{};
    final usedSlogans = <String>{};
    final usedIdentities = <String>{};
    return List.generate(count, (index) {
      final id = CandidateNameRegistry.seededCandidateId(
        seed: seed,
        index: index,
      );
      final name = nameRegistry.generate(
        firstNames: _firstNames,
        surnames: _surnames,
        seed: seed ^ (index * 7919),
      );
      final party = _uniqueFromPool(_parties, usedParties, random, index);
      final slogan = _uniqueFromPool(_slogans, usedSlogans, random, index);
      final identity = 'identity_${id.substring('candidate_'.length)}';
      if (!usedIdentities.add(identity)) {
        throw StateError('Generated duplicate portrait identity: $identity');
      }
      final band = CandidateQualityBand
          .values[random.nextInt(CandidateQualityBand.values.length)];
      final style = CandidateRhetoricalStyle
          .values[random.nextInt(CandidateRhetoricalStyle.values.length)];
      final truth = _truthFor(band, random);
      return CandidateGenerationBlueprint(
        id: id,
        displayName: name,
        partyName: party,
        slogan: slogan,
        identityKey: identity,
        portraitAssetKey: '${id}_neutral',
        rhetoricalStyle: style,
        truth: truth,
        narrativePlan: CandidateNarrativePlan(
          claimSeeds: [
            'lead_issue_${_strongestIssue(truth.policyScores)}',
            'record_${style.name}',
          ],
          disputeSeeds: [
            'risk_${truth.hiddenRisks.first}',
            'tradeoff_${_weakestIssue(truth.policyScores)}',
          ],
          evidenceRelations: const [
            EvidenceRelationType.supports,
            EvidenceRelationType.addsContext,
            EvidenceRelationType.contradicts,
          ],
          debateTopicIds: const ['water', 'health', 'employment'],
        ),
      );
    }, growable: false);
  }

  CandidateTruthProfile _truthFor(CandidateQualityBand band, Random random) {
    final base = switch (band) {
      CandidateQualityBand.strong => (72, 78, 24),
      CandidateQualityBand.compromised => (66, 45, 63),
      CandidateQualityBand.mixed => (55, 56, 47),
      CandidateQualityBand.weak => (37, 52, 49),
      CandidateQualityBand.dangerous => (62, 20, 86),
    };
    int vary(int value) => (value + random.nextInt(17) - 8).clamp(5, 95);
    final policyScores = {for (final issue in _issues) issue: vary(base.$1)};
    return CandidateTruthProfile(
      qualityBand: band,
      generalCompetence: vary(base.$1),
      implementationSkill: vary(base.$1),
      integrity: vary(base.$2),
      corruptionRisk: vary(base.$3),
      coalitionSkill: vary(base.$1),
      communication: vary(base.$1),
      budgetDiscipline: vary(base.$1),
      policyScores: Map.unmodifiable(policyScores),
      motivations: List.unmodifiable([
        band == CandidateQualityBand.dangerous
            ? 'personal_power'
            : 'public_service',
        'political_advancement',
      ]),
      hiddenRisks: List.unmodifiable([
        switch (band) {
          CandidateQualityBand.strong => 'overconfidence',
          CandidateQualityBand.compromised => 'donor_dependency',
          CandidateQualityBand.mixed => 'uneven_execution',
          CandidateQualityBand.weak => 'administrative_failure',
          CandidateQualityBand.dangerous => 'institutional_capture',
        },
      ]),
    );
  }

  String _uniqueFromPool(
    List<String> pool,
    Set<String> used,
    Random random,
    int index,
  ) {
    for (var attempt = 0; attempt < pool.length; attempt++) {
      final value = pool[random.nextInt(pool.length)];
      if (used.add(value)) return value;
    }
    final fallback = '${pool[index % pool.length]} ${index + 1}';
    used.add(fallback);
    return fallback;
  }

  String _strongestIssue(Map<String, int> scores) => scores.entries
      .reduce((left, right) => left.value >= right.value ? left : right)
      .key;

  String _weakestIssue(Map<String, int> scores) => scores.entries
      .reduce((left, right) => left.value <= right.value ? left : right)
      .key;
}
