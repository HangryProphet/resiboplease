import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/configuration/configured_scenario.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/city_indicator.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';

void main() {
  test('all scenario-changing setup choices affect generated content', () {
    final base = buildBayhavenScenario();
    final configuration = CityRunConfiguration(
      cityName: 'Bagong Pag-asa',
      startingPressure: StartingPressure.crisis,
      mainConcerns: [CityConcern.education, CityConcern.climate],
      candidateField: CandidateField.seasoned,
      assistanceMode: AssistanceMode.standard,
      campaignNoise: CampaignNoise.noisy,
      investigationTime: InvestigationTime.limited,
    );

    final configured = buildConfiguredScenario(
      base: base,
      configuration: configuration,
    );

    expect(configured.city.name, 'Bagong Pag-asa');
    expect(
      configured.city.problems.map((problem) => problem.primaryIndicator),
      [CityIndicator.educationQuality, CityIndicator.climateResilience],
    );
    expect(
      configured.city.indicators.valueOf(CityIndicator.publicTrust),
      lessThan(base.city.indicators.valueOf(CityIndicator.publicTrust)),
    );
    expect(
      configured.candidates.first.capabilities.implementationSkill,
      base.candidates.first.capabilities.implementationSkill + 8,
    );
    expect(
      configured.candidates.first.evidence.length,
      base.candidates.first.evidence.length + 2,
    );
    expect(
      configured.candidates.first.evidence.first.id,
      contains('forwarded_rumor'),
    );
  });
}
