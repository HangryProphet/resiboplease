import 'city_indicator.dart';
import 'city_indicator_set.dart';

enum CivicPredictionOutcome { observed, mixed, notObserved }

class CivicPrediction {
  const CivicPrediction({
    required this.id,
    required this.indicators,
    required this.inverseIndicators,
  });

  final String id;
  final List<CityIndicator> indicators;
  final List<CityIndicator> inverseIndicators;

  CivicPredictionAssessment assess({
    required CityIndicatorSet before,
    required CityIndicatorSet after,
  }) {
    final changes = <CityIndicator, int>{
      for (final indicator in indicators)
        indicator: after.valueOf(indicator) - before.valueOf(indicator),
      for (final indicator in inverseIndicators)
        indicator: before.valueOf(indicator) - after.valueOf(indicator),
    };
    final total = changes.values.fold<int>(0, (sum, value) => sum + value);
    final average = changes.isEmpty ? 0.0 : total / changes.length;
    final outcome = average >= 3
        ? CivicPredictionOutcome.observed
        : average <= -3
        ? CivicPredictionOutcome.notObserved
        : CivicPredictionOutcome.mixed;
    return CivicPredictionAssessment(
      predictionId: id,
      outcome: outcome,
      healthyChanges: Map.unmodifiable(changes),
      averageHealthyChange: average,
    );
  }
}

class CivicPredictionAssessment {
  const CivicPredictionAssessment({
    required this.predictionId,
    required this.outcome,
    required this.healthyChanges,
    required this.averageHealthyChange,
  });

  final String predictionId;
  final CivicPredictionOutcome outcome;
  final Map<CityIndicator, int> healthyChanges;
  final double averageHealthyChange;
}

const civicPredictions = <CivicPrediction>[
  CivicPrediction(
    id: 'health_access',
    indicators: [CityIndicator.publicHealth],
    inverseIndicators: [],
  ),
  CivicPrediction(
    id: 'infrastructure_resilience',
    indicators: [
      CityIndicator.waterSecurity,
      CityIndicator.urbanResilience,
      CityIndicator.climateResilience,
    ],
    inverseIndicators: [],
  ),
  CivicPrediction(
    id: 'livelihoods',
    indicators: [
      CityIndicator.employmentQuality,
      CityIndicator.povertyReduction,
    ],
    inverseIndicators: [],
  ),
  CivicPrediction(
    id: 'budget_protection',
    indicators: [CityIndicator.budgetHealth],
    inverseIndicators: [],
  ),
  CivicPrediction(
    id: 'public_trust',
    indicators: [CityIndicator.publicTrust],
    inverseIndicators: [],
  ),
  CivicPrediction(
    id: 'corruption_pressure',
    indicators: [],
    inverseIndicators: [CityIndicator.corruptionPressure],
  ),
];

CivicPrediction? civicPredictionById(String id) =>
    civicPredictions.where((item) => item.id == id).firstOrNull;
