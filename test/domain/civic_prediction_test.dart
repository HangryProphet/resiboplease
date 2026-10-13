import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/civic_prediction.dart';
import 'package:resiboplease/domain/models/city_indicator.dart';

void main() {
  test('prediction assessment uses only observed indicator movement', () {
    final before = buildBayhavenScenario(seed: 42).city.indicators;
    final health = civicPredictionById('health_access')!;
    final improved = health.assess(
      before: before,
      after: before.apply({CityIndicator.publicHealth: 5}),
    );
    final declined = health.assess(
      before: before,
      after: before.apply({CityIndicator.publicHealth: -5}),
    );

    expect(improved.outcome, CivicPredictionOutcome.observed);
    expect(declined.outcome, CivicPredictionOutcome.notObserved);
    expect(improved.healthyChanges, {CityIndicator.publicHealth: 5});
  });

  test('lower corruption pressure is assessed as healthier movement', () {
    final before = buildBayhavenScenario(seed: 77).city.indicators;
    final prediction = civicPredictionById('corruption_pressure')!;
    final assessment = prediction.assess(
      before: before,
      after: before.apply({CityIndicator.corruptionPressure: -6}),
    );

    expect(assessment.outcome, CivicPredictionOutcome.observed);
    expect(assessment.healthyChanges[CityIndicator.corruptionPressure], 6);
  });
}
