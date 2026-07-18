import '../../domain/models/candidate.dart';
import '../../domain/models/city.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_problem.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/models/evidence_item.dart';
import '../../domain/models/scenario.dart';

Scenario buildConfiguredScenario({
  required Scenario base,
  required CityRunConfiguration configuration,
  int? seed,
}) {
  final scenario = seed == null ? base : base.copyWith(seed: seed);
  final city = _configuredCity(scenario.city, configuration);
  final candidates = scenario.candidates
      .map(
        (candidate) => _configuredCandidate(
          candidate,
          configuration,
          baseCityName: scenario.city.name,
        ),
      )
      .toList(growable: false);
  return scenario.copyWith(city: city, candidates: candidates);
}

City _configuredCity(City base, CityRunConfiguration configuration) {
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

  final problems = configuration.mainConcerns
      .map(
        (concern) => _problemFor(
          concern,
          base: base,
          pressure: configuration.startingPressure,
          cityName: configuration.cityName,
        ),
      )
      .toList(growable: false);
  final concernNames = problems.map((problem) => problem.title.toLowerCase());
  return base.copyWith(
    name: configuration.cityName,
    summary:
        '${configuration.cityName} begins this election facing ${_naturalList(concernNames)}. The city charter marks overall conditions as ${configuration.startingPressure.label.toLowerCase()}.',
    indicators: base.indicators.apply(changes),
    problems: problems,
  );
}

CityProblem _problemFor(
  CityConcern concern, {
  required City base,
  required StartingPressure pressure,
  required String cityName,
}) {
  final matching = base.problems
      .where((problem) => problem.primaryIndicator == concern.indicator)
      .firstOrNull;
  final source = matching ?? _newProblem(concern, cityName);
  final severityDelta = switch (pressure) {
    StartingPressure.stable => -16,
    StartingPressure.strained => 0,
    StartingPressure.crisis => 10,
  };
  final urgencyDelta = switch (pressure) {
    StartingPressure.stable => -14,
    StartingPressure.strained => 0,
    StartingPressure.crisis => 8,
  };
  final trend = switch (pressure) {
    StartingPressure.stable => ProblemTrend.stable,
    StartingPressure.strained => matching?.trend ?? ProblemTrend.worsening,
    StartingPressure.crisis => ProblemTrend.rapidlyWorsening,
  };
  return source.copyWith(
    description: source.description.replaceAll('Bayhaven', cityName),
    severity: (source.severity + severityDelta).clamp(20, 100),
    urgency: (source.urgency + urgencyDelta).clamp(20, 100),
    trend: trend,
  );
}

CityProblem _newProblem(CityConcern concern, String cityName) => switch (concern) {
  CityConcern.food => CityProblem(
    id: 'food_costs',
    title: 'Food prices outpacing wages',
    description:
        'Families across $cityName are skipping meals as market prices rise faster than household income.',
    primaryIndicator: CityIndicator.foodSecurity,
    relatedIndicators: const [
      CityIndicator.povertyReduction,
      CityIndicator.employmentQuality,
    ],
    severity: 74,
    urgency: 80,
    trend: ProblemTrend.worsening,
    sdgTags: const ['SDG 2', 'SDG 1', 'SDG 8'],
  ),
  CityConcern.poverty => CityProblem(
    id: 'households_falling_behind',
    title: 'Families falling behind',
    description:
        'Rent, transport, and food costs are pushing more $cityName households into unstable living conditions.',
    primaryIndicator: CityIndicator.povertyReduction,
    relatedIndicators: const [
      CityIndicator.foodSecurity,
      CityIndicator.urbanResilience,
    ],
    severity: 76,
    urgency: 81,
    trend: ProblemTrend.worsening,
    sdgTags: const ['SDG 1', 'SDG 2', 'SDG 11'],
  ),
  CityConcern.health => CityProblem(
    id: 'clinic_overload',
    title: 'Overcrowded public clinics',
    description:
        'Patients wait most of a day as $cityName clinics share too few staff and supplies.',
    primaryIndicator: CityIndicator.publicHealth,
    relatedIndicators: const [CityIndicator.povertyReduction],
    severity: 79,
    urgency: 86,
    trend: ProblemTrend.worsening,
    sdgTags: const ['SDG 3', 'SDG 1'],
  ),
  CityConcern.education => CityProblem(
    id: 'schools_stretched_thin',
    title: 'Schools stretched thin',
    description:
        'Crowded classrooms and uneven resources are widening learning gaps across $cityName.',
    primaryIndicator: CityIndicator.educationQuality,
    relatedIndicators: const [
      CityIndicator.povertyReduction,
      CityIndicator.employmentQuality,
    ],
    severity: 72,
    urgency: 77,
    trend: ProblemTrend.worsening,
    sdgTags: const ['SDG 4', 'SDG 1', 'SDG 8'],
  ),
  CityConcern.water => CityProblem(
    id: 'water_contamination',
    title: 'Unsafe water after heavy rain',
    description:
        'Several $cityName districts report unsafe tap water when heavy rain overwhelms damaged lines.',
    primaryIndicator: CityIndicator.waterSecurity,
    relatedIndicators: const [
      CityIndicator.publicHealth,
      CityIndicator.climateResilience,
    ],
    severity: 84,
    urgency: 90,
    trend: ProblemTrend.rapidlyWorsening,
    sdgTags: const ['SDG 6', 'SDG 3', 'SDG 13'],
  ),
  CityConcern.jobs => CityProblem(
    id: 'unemployment',
    title: 'Unstable jobs and layoffs',
    description:
        'Businesses in $cityName are closing while many new jobs remain short-term and low-paid.',
    primaryIndicator: CityIndicator.employmentQuality,
    relatedIndicators: const [
      CityIndicator.povertyReduction,
      CityIndicator.foodSecurity,
    ],
    severity: 76,
    urgency: 78,
    trend: ProblemTrend.worsening,
    sdgTags: const ['SDG 8', 'SDG 1'],
  ),
  CityConcern.cityServices => CityProblem(
    id: 'housing_transport_strain',
    title: 'Housing and transport under strain',
    description:
        'Long commutes, insecure housing, and delayed repairs are making daily life harder across $cityName.',
    primaryIndicator: CityIndicator.urbanResilience,
    relatedIndicators: const [
      CityIndicator.povertyReduction,
      CityIndicator.employmentQuality,
    ],
    severity: 73,
    urgency: 76,
    trend: ProblemTrend.worsening,
    sdgTags: const ['SDG 11', 'SDG 1', 'SDG 8'],
  ),
  CityConcern.climate => CityProblem(
    id: 'climate_readiness',
    title: 'Flood defenses falling behind',
    description:
        '$cityName drainage and emergency plans are not keeping pace with heavier rain and dangerous heat.',
    primaryIndicator: CityIndicator.climateResilience,
    relatedIndicators: const [
      CityIndicator.waterSecurity,
      CityIndicator.urbanResilience,
    ],
    severity: 78,
    urgency: 84,
    trend: ProblemTrend.worsening,
    sdgTags: const ['SDG 13', 'SDG 11', 'SDG 6'],
  ),
};

Candidate _configuredCandidate(
  Candidate candidate,
  CityRunConfiguration configuration, {
  required String baseCityName,
}) {
  final operationalDelta = switch (configuration.candidateField) {
    CandidateField.unproven => -8,
    CandidateField.mixed => 0,
    CandidateField.seasoned => 8,
  };
  int adjusted(int value) => (value + operationalDelta).clamp(10, 96);
  final capabilities = candidate.capabilities.copyWith(
    implementationSkill: adjusted(candidate.capabilities.implementationSkill),
    coalitionSkill: adjusted(candidate.capabilities.coalitionSkill),
    crisisResponse: adjusted(candidate.capabilities.crisisResponse),
    budgetDiscipline: adjusted(candidate.capabilities.budgetDiscipline),
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
    final sorted = [...evidence]..sort(
      (a, b) => _clearEvidenceRank(a.type).compareTo(
        _clearEvidenceRank(b.type),
      ),
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
