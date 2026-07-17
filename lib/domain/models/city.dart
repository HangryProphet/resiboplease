import 'city_indicator_set.dart';
import 'city_problem.dart';

class City {
  const City({
    required this.name,
    required this.summary,
    required this.term,
    required this.indicators,
    required this.problems,
  });

  final String name;
  final String summary;
  final int term;
  final CityIndicatorSet indicators;
  final List<CityProblem> problems;

  City copyWith({CityIndicatorSet? indicators, int? term}) => City(
    name: name,
    summary: summary,
    term: term ?? this.term,
    indicators: indicators ?? this.indicators,
    problems: problems,
  );
}
