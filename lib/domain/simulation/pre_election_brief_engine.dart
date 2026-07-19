import '../models/city_indicator.dart';
import '../models/city_run_configuration.dart';
import '../models/pre_election_city_brief.dart';
import '../models/scenario.dart';
import 'seeded_random.dart';

class PreElectionBriefEngine {
  const PreElectionBriefEngine();

  PreElectionCityBrief build({
    required Scenario scenario,
    required CityRunConfiguration configuration,
  }) {
    final cityRandom = SeededRandom(
      scenario.seed ^
          _stableHash(scenario.city.name) ^
          _stableHash(scenario.city.problems.map((item) => item.id).join('|')),
    );
    final concerns = scenario.city.problems
        .map(
          (problem) => CityConcernSnapshot(
            problem: problem,
            topic: _topicFor(problem.primaryIndicator),
            affectedResidentsPercent: _affectedResidents(
              scenario: scenario,
              indicator: problem.primaryIndicator,
              severity: problem.severity,
              urgency: problem.urgency,
              random: cityRandom,
            ),
          ),
        )
        .toList(growable: false);

    final metrics = <CityBriefMetric>[];
    final usedKinds = <CityMetricKind>{};
    for (final concern in concerns) {
      final metric = _metricFor(
        concern.problem.primaryIndicator,
        scenario.city.indicators.valueOf(concern.problem.primaryIndicator),
      );
      if (usedKinds.add(metric.kind)) metrics.add(metric);
    }
    metrics.add(
      CityBriefMetric(
        kind: CityMetricKind.publicTrust,
        sourceIndicator: CityIndicator.publicTrust,
        value: scenario.city.indicators.publicTrust.toDouble(),
        unit: CityMetricUnit.percent,
        conditionScore: scenario.city.indicators.publicTrust,
      ),
    );
    metrics.add(
      CityBriefMetric(
        kind: CityMetricKind.budgetRoom,
        sourceIndicator: CityIndicator.budgetHealth,
        value: scenario.city.indicators.budgetHealth.toDouble(),
        unit: CityMetricUnit.condition,
        conditionScore: scenario.city.indicators.budgetHealth,
      ),
    );

    final news = _newsFor(
      concerns: concerns,
      noise: configuration.campaignNoise,
      random: SeededRandom(
        scenario.seed ^
            _stableHash('pre-election-news') ^
            configuration.campaignNoise.index * 0x45d9f3b,
      ),
    );
    final districts = CitizenDistrict.values.toList(growable: true);
    final voices = <CitizenVoice>[];
    for (var index = 0; index < concerns.length; index++) {
      final concern = concerns[index];
      final districtIndex = cityRandom.nextInt(districts.length);
      final district = districts.removeAt(districtIndex);
      voices.add(
        CitizenVoice(
          id: 'voice_${concern.problem.id}_$index',
          topic: concern.topic,
          district: district,
          role: _roleFor(concern.topic, cityRandom.nextInt(2)),
          templateVariant: cityRandom.nextInt(3),
        ),
      );
    }

    return PreElectionCityBrief(
      scenarioSeed: scenario.seed,
      metrics: List.unmodifiable(metrics),
      concerns: List.unmodifiable(concerns),
      news: List.unmodifiable(news),
      voices: List.unmodifiable(voices),
    );
  }

  int _affectedResidents({
    required Scenario scenario,
    required CityIndicator indicator,
    required int severity,
    required int urgency,
    required SeededRandom random,
  }) {
    final condition = scenario.city.indicators.valueOf(indicator);
    final estimate =
        severity * .50 +
        urgency * .25 +
        (100 - condition) * .25 +
        random.nextInt(7) -
        3;
    return estimate.round().clamp(18, 89);
  }

  List<CityNewsItem> _newsFor({
    required List<CityConcernSnapshot> concerns,
    required CampaignNoise noise,
    required SeededRandom random,
  }) {
    final items = <CityNewsItem>[];
    for (var index = 0; index < concerns.length; index++) {
      final concern = concerns[index];
      final source = switch (noise) {
        CampaignNoise.clear =>
          index.isEven
              ? CityNewsSource.recordsOffice
              : CityNewsSource.publicMedia,
        CampaignNoise.typical => switch (index % 3) {
          0 => CityNewsSource.publicMedia,
          1 => CityNewsSource.cityDesk,
          _ => CityNewsSource.recordsOffice,
        },
        CampaignNoise.noisy =>
          index.isEven ? CityNewsSource.cityDesk : CityNewsSource.publicMedia,
      };
      items.add(
        CityNewsItem(
          id: 'brief_${concern.problem.id}',
          topic: concern.topic,
          source: source,
          templateVariant: random.nextInt(2),
          isUnverified: false,
        ),
      );
    }
    if (noise == CampaignNoise.noisy && concerns.isNotEmpty) {
      final concern = concerns[random.nextInt(concerns.length)];
      items.insert(
        0,
        CityNewsItem(
          id: 'brief_unverified_${concern.problem.id}',
          topic: concern.topic,
          source: CityNewsSource.communityFeed,
          templateVariant: random.nextInt(2),
          isUnverified: true,
        ),
      );
    }
    return items;
  }
}

CityBriefTopic _topicFor(CityIndicator indicator) => switch (indicator) {
  CityIndicator.foodSecurity => CityBriefTopic.food,
  CityIndicator.povertyReduction => CityBriefTopic.poverty,
  CityIndicator.publicHealth => CityBriefTopic.health,
  CityIndicator.educationQuality => CityBriefTopic.education,
  CityIndicator.waterSecurity => CityBriefTopic.water,
  CityIndicator.employmentQuality => CityBriefTopic.jobs,
  CityIndicator.urbanResilience => CityBriefTopic.cityServices,
  CityIndicator.climateResilience => CityBriefTopic.climate,
  CityIndicator.budgetHealth ||
  CityIndicator.publicTrust ||
  CityIndicator.corruptionPressure => throw ArgumentError.value(
    indicator,
    'indicator',
    'Supporting indicators are not city-concern topics.',
  ),
};

CityBriefMetric _metricFor(CityIndicator indicator, int condition) =>
    switch (indicator) {
      CityIndicator.foodSecurity => CityBriefMetric(
        kind: CityMetricKind.reliableFoodAccess,
        sourceIndicator: indicator,
        value: (24 + condition * .72).clamp(18, 94),
        unit: CityMetricUnit.percent,
        conditionScore: condition,
      ),
      CityIndicator.povertyReduction => CityBriefMetric(
        kind: CityMetricKind.financiallySecureHouseholds,
        sourceIndicator: indicator,
        value: (18 + condition * .65).clamp(12, 88),
        unit: CityMetricUnit.percent,
        conditionScore: condition,
      ),
      CityIndicator.publicHealth => CityBriefMetric(
        kind: CityMetricKind.clinicWaitTime,
        sourceIndicator: indicator,
        value: (8.8 - condition * .075).clamp(.8, 8.5),
        unit: CityMetricUnit.hours,
        conditionScore: condition,
      ),
      CityIndicator.educationQuality => CityBriefMetric(
        kind: CityMetricKind.classroomSize,
        sourceIndicator: indicator,
        value: (63 - condition * .30).clamp(24, 58),
        unit: CityMetricUnit.people,
        conditionScore: condition,
      ),
      CityIndicator.waterSecurity => CityBriefMetric(
        kind: CityMetricKind.reliableWater,
        sourceIndicator: indicator,
        value: (18 + condition * .78).clamp(15, 96),
        unit: CityMetricUnit.percent,
        conditionScore: condition,
      ),
      CityIndicator.employmentQuality => CityBriefMetric(
        kind: CityMetricKind.stableEmployment,
        sourceIndicator: indicator,
        value: (24 + condition * .62).clamp(20, 88),
        unit: CityMetricUnit.percent,
        conditionScore: condition,
      ),
      CityIndicator.urbanResilience => CityBriefMetric(
        kind: CityMetricKind.commuteTime,
        sourceIndicator: indicator,
        value: (92 - condition * .55).clamp(30, 88),
        unit: CityMetricUnit.minutes,
        conditionScore: condition,
      ),
      CityIndicator.climateResilience => CityBriefMetric(
        kind: CityMetricKind.floodReadiness,
        sourceIndicator: indicator,
        value: (12 + condition * .78).clamp(10, 94),
        unit: CityMetricUnit.percent,
        conditionScore: condition,
      ),
      CityIndicator.budgetHealth ||
      CityIndicator.publicTrust ||
      CityIndicator.corruptionPressure => throw ArgumentError.value(
        indicator,
        'indicator',
        'Supporting indicators use dedicated metrics.',
      ),
    };

CitizenRole _roleFor(CityBriefTopic topic, int variant) => switch (topic) {
  CityBriefTopic.food =>
    variant == 0 ? CitizenRole.vendor : CitizenRole.caregiver,
  CityBriefTopic.poverty =>
    variant == 0 ? CitizenRole.caregiver : CitizenRole.resident,
  CityBriefTopic.health =>
    variant == 0 ? CitizenRole.clinicWorker : CitizenRole.caregiver,
  CityBriefTopic.education =>
    variant == 0 ? CitizenRole.teacher : CitizenRole.student,
  CityBriefTopic.water =>
    variant == 0 ? CitizenRole.resident : CitizenRole.tradesWorker,
  CityBriefTopic.jobs =>
    variant == 0 ? CitizenRole.tradesWorker : CitizenRole.vendor,
  CityBriefTopic.cityServices =>
    variant == 0 ? CitizenRole.commuter : CitizenRole.resident,
  CityBriefTopic.climate =>
    variant == 0 ? CitizenRole.tradesWorker : CitizenRole.resident,
};

int _stableHash(String value) => value.codeUnits.fold(
  0,
  (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
);
