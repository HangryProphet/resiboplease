import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/configuration/configured_scenario.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/simulation/pre_election_brief_engine.dart';

void main() {
  const engine = PreElectionBriefEngine();

  CityRunConfiguration configuration({
    StartingPressure pressure = StartingPressure.strained,
    CampaignNoise noise = CampaignNoise.typical,
  }) => CityRunConfiguration(
    cityName: 'Harborlight',
    startingPressure: pressure,
    mainConcerns: const [
      CityConcern.water,
      CityConcern.health,
      CityConcern.cityServices,
    ],
    candidateField: CandidateField.mixed,
    assistanceMode: AssistanceMode.guided,
    campaignNoise: noise,
    investigationTime: InvestigationTime.standard,
  );

  test('same seed and setup produce the same frozen city brief', () {
    final config = configuration();
    final scenario = buildConfiguredScenario(
      base: buildBayhavenScenario(seed: 71821),
      configuration: config,
    );

    final first = engine.build(scenario: scenario, configuration: config);
    final second = engine.build(scenario: scenario, configuration: config);

    expect(
      first.concerns.map((item) => item.affectedResidentsPercent),
      second.concerns.map((item) => item.affectedResidentsPercent),
    );
    expect(
      first.metrics.map((item) => (item.kind, item.value)),
      second.metrics.map((item) => (item.kind, item.value)),
    );
    expect(
      first.news.map((item) => (item.id, item.templateVariant, item.source)),
      second.news.map((item) => (item.id, item.templateVariant, item.source)),
    );
    expect(
      first.voices.map(
        (item) => (item.id, item.district, item.role, item.templateVariant),
      ),
      second.voices.map(
        (item) => (item.id, item.district, item.role, item.templateVariant),
      ),
    );
  });

  test('starting pressure changes city condition and impact estimates', () {
    final stableConfig = configuration(pressure: StartingPressure.stable);
    final crisisConfig = configuration(pressure: StartingPressure.crisis);
    final base = buildBayhavenScenario(seed: 5839201);
    final stable = engine.build(
      scenario: buildConfiguredScenario(
        base: base,
        configuration: stableConfig,
      ),
      configuration: stableConfig,
    );
    final crisis = engine.build(
      scenario: buildConfiguredScenario(
        base: base,
        configuration: crisisConfig,
      ),
      configuration: crisisConfig,
    );

    expect(
      crisis.metrics.first.conditionScore,
      lessThan(stable.metrics.first.conditionScore),
    );
    expect(
      crisis.concerns.first.affectedResidentsPercent,
      greaterThan(stable.concerns.first.affectedResidentsPercent),
    );
  });

  test('campaign noise changes information quality, not city facts', () {
    final clearConfig = configuration(noise: CampaignNoise.clear);
    final noisyConfig = configuration(noise: CampaignNoise.noisy);
    final base = buildBayhavenScenario(seed: 30451);
    final clear = engine.build(
      scenario: buildConfiguredScenario(base: base, configuration: clearConfig),
      configuration: clearConfig,
    );
    final noisy = engine.build(
      scenario: buildConfiguredScenario(base: base, configuration: noisyConfig),
      configuration: noisyConfig,
    );

    expect(
      clear.concerns.map((item) => item.affectedResidentsPercent),
      noisy.concerns.map((item) => item.affectedResidentsPercent),
    );
    expect(
      clear.metrics.map((item) => (item.kind, item.value)),
      noisy.metrics.map((item) => (item.kind, item.value)),
    );
    expect(clear.news.any((item) => item.isUnverified), isFalse);
    expect(noisy.news.first.isUnverified, isTrue);
  });
}
