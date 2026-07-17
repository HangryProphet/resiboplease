import 'candidate.dart';
import 'city_indicator.dart';
import 'city_indicator_set.dart';

class TermPhase {
  const TermPhase({
    required this.number,
    required this.title,
    required this.narrative,
    required this.explanation,
    required this.changes,
  });

  final int number;
  final String title;
  final String narrative;
  final String explanation;
  final Map<CityIndicator, int> changes;
}

class TermResult {
  const TermResult({
    required this.seed,
    required this.candidate,
    required this.before,
    required this.after,
    required this.phases,
    required this.summary,
  });

  final int seed;
  final Candidate candidate;
  final CityIndicatorSet before;
  final CityIndicatorSet after;
  final List<TermPhase> phases;
  final String summary;

  Map<CityIndicator, int> get totalChanges => {
    for (final indicator in CityIndicator.values)
      indicator: after.valueOf(indicator) - before.valueOf(indicator),
  };
}
