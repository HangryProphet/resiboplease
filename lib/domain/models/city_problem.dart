import 'city_indicator.dart';

enum ProblemTrend {
  improving('Improving', 0.8),
  stable('Stable', 1),
  worsening('Worsening', 1.2),
  rapidlyWorsening('Rapidly worsening', 1.4);

  const ProblemTrend(this.label, this.multiplier);

  final String label;
  final double multiplier;
}

class CityProblem {
  const CityProblem({
    required this.id,
    required this.title,
    required this.description,
    required this.primaryIndicator,
    required this.relatedIndicators,
    required this.severity,
    required this.urgency,
    required this.trend,
    required this.sdgTags,
  });

  final String id;
  final String title;
  final String description;
  final CityIndicator primaryIndicator;
  final List<CityIndicator> relatedIndicators;
  final int severity;
  final int urgency;
  final ProblemTrend trend;
  final List<String> sdgTags;

  double get issueWeight =>
      (severity / 100) * (urgency / 100) * trend.multiplier;
}
