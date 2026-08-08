import '../../domain/models/candidate.dart';
import '../../domain/models/city.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/models/evidence_item.dart';
import '../../domain/models/scenario.dart';
import '../../domain/simulation/candidate_tradeoff_audit.dart';
import '../../domain/simulation/city_issue_generator.dart';
import 'candidate_field_adjustment.dart';

Scenario buildConfiguredScenario({
  required Scenario base,
  required CityRunConfiguration configuration,
  int? seed,
}) {
  final scenario = seed == null ? base : base.copyWith(seed: seed);
  final city = _configuredCity(
    scenario.city,
    configuration,
    seed: scenario.seed,
  );
  final candidates = scenario.candidates
      .map(
        (candidate) => _configuredCandidate(
          candidate,
          configuration,
          seed: scenario.seed,
          baseCityName: scenario.city.name,
        ),
      )
      .toList(growable: false);
  for (final candidate in candidates) {
    final audit = auditCandidateTradeoffs(candidate);
    if (!audit.passes) {
      throw StateError(
        'Candidate ${candidate.id} failed tradeoff validation: '
        '${audit.violations.join(', ')}.',
      );
    }
  }
  return scenario.copyWith(city: city, candidates: candidates);
}

City _configuredCity(
  City base,
  CityRunConfiguration configuration, {
  required int seed,
}) {
  final pressureDelta = switch (configuration.startingPressure) {
    StartingPressure.stable => 7,
    StartingPressure.strained => 0,
    StartingPressure.crisis => -9,
  };
  final targetConcernValue = switch (configuration.startingPressure) {
    StartingPressure.stable => 50,
    StartingPressure.strained => 42,
    StartingPressure.crisis => 27,
  };
  final changes = <CityIndicator, int>{};
  for (final indicator in _coreIndicators) {
    changes[indicator] = pressureDelta;
  }
  for (final concern in configuration.mainConcerns) {
    final currentAfterPressure =
        base.indicators.valueOf(concern.indicator) + pressureDelta;
    if (currentAfterPressure > targetConcernValue) {
      changes[concern.indicator] =
          pressureDelta + targetConcernValue - currentAfterPressure;
    }
  }
  final civicDelta = switch (configuration.startingPressure) {
    StartingPressure.stable => 5,
    StartingPressure.strained => 0,
    StartingPressure.crisis => -6,
  };
  changes[CityIndicator.budgetHealth] = civicDelta;
  changes[CityIndicator.publicTrust] = civicDelta;
  changes[CityIndicator.corruptionPressure] = -civicDelta;

  final problems = const CityIssueGenerator().generate(
    seed: seed,
    cityName: configuration.cityName,
    pressure: configuration.startingPressure,
    priorities: configuration.mainConcerns,
  );
  for (final problem in problems) {
    final penalty = ((problem.severity - 45) / 18).round().clamp(0, 4);
    changes.update(
      problem.primaryIndicator,
      (value) => value - penalty,
      ifAbsent: () => -penalty,
    );
    if (problem.relatedIndicators.contains(CityIndicator.publicTrust)) {
      changes.update(
        CityIndicator.publicTrust,
        (value) => value - 1,
        ifAbsent: () => -1,
      );
    }
    if (problem.relatedIndicators.contains(CityIndicator.corruptionPressure)) {
      changes.update(
        CityIndicator.corruptionPressure,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
  }
  final concernNames = problems.map((problem) => problem.title.toLowerCase());
  return base.copyWith(
    name: configuration.cityName,
    summary:
        '${configuration.cityName} begins this election facing ${_naturalList(concernNames)}. The city charter marks overall conditions as ${configuration.startingPressure.label.toLowerCase()}.',
    indicators: base.indicators.apply(changes),
    problems: problems,
  );
}

Candidate _configuredCandidate(
  Candidate candidate,
  CityRunConfiguration configuration, {
  required int seed,
  required String baseCityName,
}) {
  final adjustment = candidateFieldAdjustmentFor(
    candidate: candidate,
    field: configuration.candidateField,
    seed: seed,
  );
  int adjusted(int value, int delta) => (value + delta).clamp(10, 96);
  final capabilities = candidate.capabilities.copyWith(
    implementationSkill: adjusted(
      candidate.capabilities.implementationSkill,
      adjustment.implementation,
    ),
    coalitionSkill: adjusted(
      candidate.capabilities.coalitionSkill,
      adjustment.coalition,
    ),
    crisisResponse: adjusted(
      candidate.capabilities.crisisResponse,
      adjustment.crisis,
    ),
    budgetDiscipline: adjusted(
      candidate.capabilities.budgetDiscipline,
      adjustment.budget,
    ),
  );
  String renamed(String value) =>
      value.replaceAll(baseCityName, configuration.cityName);
  final renamedEvidence = candidate.evidence
      .map(
        (item) => item.copyWith(
          title: renamed(item.title),
          source: renamed(item.source),
          summary: renamed(item.summary),
          details: renamed(item.details),
        ),
      )
      .toList(growable: true);
  final evidence = _evidenceForNoise(
    renamedEvidence,
    candidateName: candidate.name,
    candidateId: candidate.id,
    cityName: configuration.cityName,
    noise: configuration.campaignNoise,
  );
  return candidate.copyWith(
    party: renamed(candidate.party),
    slogan: renamed(candidate.slogan),
    biography: renamed(candidate.biography),
    visibleStrengths: candidate.visibleStrengths.map(renamed).toList(),
    visibleConcerns: candidate.visibleConcerns.map(renamed).toList(),
    platform: candidate.platform.map(renamed).toList(),
    evidence: evidence,
    capabilities: capabilities,
  );
}

List<EvidenceItem> _evidenceForNoise(
  List<EvidenceItem> evidence, {
  required String candidateName,
  required String candidateId,
  required String cityName,
  required CampaignNoise noise,
}) {
  if (noise == CampaignNoise.clear) {
    final sorted = [...evidence]
      ..sort(
        (a, b) =>
            _clearEvidenceRank(a.type).compareTo(_clearEvidenceRank(b.type)),
      );
    return List.unmodifiable(sorted);
  }
  if (noise == CampaignNoise.typical) return List.unmodifiable(evidence);
  final rumor = EvidenceItem(
    id: '${candidateId}_forwarded_rumor',
    type: EvidenceType.socialPost,
    title: 'Forwarded claim about $candidateName',
    source: '$cityName Community Feed',
    summary:
        'An unsigned post claims insiders already know what $candidateName will do in office.',
    details:
        'The post names no source and supplies no document. Repetition and urgency do not make a claim verified.',
    truthStatus: TruthStatus.unverified,
    reliability: 10,
  );
  final clippedVideo = EvidenceItem(
    id: '${candidateId}_clipped_video',
    type: EvidenceType.campaignAd,
    title: 'A clip spreading without context',
    source: 'CityLoop video repost',
    summary:
        'A short edited clip makes $candidateName appear to promise an immediate solution to every major problem.',
    details:
        'The excerpt removes the question and most of the answer. Find a full record before assigning it weight.',
    truthStatus: TruthStatus.missingContext,
    reliability: 16,
  );
  return List.unmodifiable([
    rumor,
    evidence.first,
    clippedVideo,
    ...evidence.skip(1),
  ]);
}

int _clearEvidenceRank(EvidenceType type) => switch (type) {
  EvidenceType.publicRecord => 0,
  EvidenceType.budgetDocument => 1,
  EvidenceType.factCheck => 2,
  EvidenceType.profile => 3,
  EvidenceType.debateAnswer => 4,
  EvidenceType.controversy => 5,
  EvidenceType.platform => 6,
  EvidenceType.campaignAd => 7,
  EvidenceType.socialPost => 8,
};

String _naturalList(Iterable<String> values) {
  final items = values.toList(growable: false);
  if (items.length == 1) return items.single;
  if (items.length == 2) return '${items.first} and ${items.last}';
  return '${items.take(items.length - 1).join(', ')}, and ${items.last}';
}

const _coreIndicators = <CityIndicator>[
  CityIndicator.foodSecurity,
  CityIndicator.povertyReduction,
  CityIndicator.publicHealth,
  CityIndicator.educationQuality,
  CityIndicator.waterSecurity,
  CityIndicator.employmentQuality,
  CityIndicator.urbanResilience,
  CityIndicator.climateResilience,
];
