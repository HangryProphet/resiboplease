import 'city.dart';
import 'city_indicator.dart';
import 'city_run_configuration.dart';
import 'term_result.dart';

/// Public, deliberately limited city data that is safe to send to the gallery.
///
/// This model is separate from save data so a world seed, investigation state,
/// hidden candidate capabilities, and other private simulation fields cannot be
/// uploaded accidentally.
class PublicCitySnapshot {
  const PublicCitySnapshot({
    this.id,
    required this.cityName,
    required this.termNumber,
    required this.startingPressure,
    required this.topIssue,
    required this.selectedCandidateName,
    required this.candidateParty,
    required this.finalCityCondition,
    required this.outcomeSummary,
    required this.majorIssues,
    required this.majorEvents,
    required this.createdAt,
  });

  final String? id;
  final String cityName;
  final int termNumber;
  final String startingPressure;
  final String topIssue;
  final String selectedCandidateName;
  final String candidateParty;
  final String finalCityCondition;
  final String outcomeSummary;
  final List<String> majorIssues;
  final List<String> majorEvents;
  final DateTime createdAt;

  /// JSON sent by POST. The database owns [id].
  Map<String, Object?> toPublishJson() => {
    'city_name': cityName,
    'term_number': termNumber,
    'starting_pressure': startingPressure,
    'top_issue': topIssue,
    'selected_candidate_name': selectedCandidateName,
    'candidate_party': candidateParty,
    'final_city_condition': finalCityCondition,
    'outcome_summary': outcomeSummary,
    'major_issues': majorIssues,
    'major_events': majorEvents,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  /// JSON used by the local public-gallery cache.
  Map<String, Object?> toJson() => {
    if (id != null) 'id': id,
    ...toPublishJson(),
  };

  factory PublicCitySnapshot.fromJson(
    Map<String, Object?> json,
  ) => PublicCitySnapshot(
    id: _optionalText(json['id']),
    cityName: _requiredText(json['city_name'], 'city_name'),
    termNumber: _requiredInt(json['term_number'], 'term_number'),
    startingPressure: _requiredText(
      json['starting_pressure'],
      'starting_pressure',
    ),
    topIssue: _requiredText(json['top_issue'], 'top_issue'),
    selectedCandidateName: _requiredText(
      json['selected_candidate_name'],
      'selected_candidate_name',
    ),
    candidateParty: _requiredText(json['candidate_party'], 'candidate_party'),
    finalCityCondition: _requiredText(
      json['final_city_condition'],
      'final_city_condition',
    ),
    outcomeSummary: _requiredText(json['outcome_summary'], 'outcome_summary'),
    majorIssues: _requiredTextList(json['major_issues'], 'major_issues'),
    majorEvents: _requiredTextList(json['major_events'], 'major_events'),
    createdAt: _requiredDate(json['created_at'], 'created_at'),
  );
}

/// Converts a completed local term into the only payload the API may receive.
PublicCitySnapshot buildPublicCitySnapshot({
  required City city,
  required CityRunConfiguration configuration,
  required TermResult result,
  required String? topIssueId,
  DateTime? createdAt,
}) {
  final rankedIssues = [...city.problems]
    ..sort((a, b) => b.issueWeight.compareTo(a.issueWeight));
  final topIssue = city.problems
      .where((problem) => problem.id == topIssueId)
      .map((problem) => problem.title)
      .firstOrNull;
  final events = <String>[];
  for (final phase in result.phases) {
    if (!events.contains(phase.title)) events.add(phase.title);
  }
  return PublicCitySnapshot(
    cityName: configuration.cityName.trim(),
    termNumber: city.term,
    startingPressure: configuration.startingPressure.name,
    topIssue: topIssue ?? 'Not recorded',
    selectedCandidateName: result.candidate.name,
    candidateParty: result.candidate.party,
    finalCityCondition: _conditionFromResult(result),
    outcomeSummary: result.summary,
    majorIssues: List.unmodifiable(
      rankedIssues.take(3).map((problem) => problem.title),
    ),
    majorEvents: List.unmodifiable(events.take(4)),
    createdAt: (createdAt ?? DateTime.now()).toUtc(),
  );
}

String _conditionFromResult(TermResult result) {
  var total = 0;
  for (final indicator in CityIndicator.values) {
    final raw = result.after.valueOf(indicator);
    total += indicator == CityIndicator.corruptionPressure ? 100 - raw : raw;
  }
  final average = total / CityIndicator.values.length;
  return switch (average) {
    >= 72 => 'strong',
    >= 60 => 'functional',
    >= 48 => 'mixed',
    >= 36 => 'strained',
    _ => 'critical',
  };
}

String _requiredText(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Invalid $field in city snapshot.');
  }
  return value.trim();
}

String? _optionalText(Object? value) {
  if (value == null) return null;
  return _requiredText(value, 'id');
}

int _requiredInt(Object? value, String field) {
  if (value is! num) throw FormatException('Invalid $field in city snapshot.');
  return value.toInt();
}

List<String> _requiredTextList(Object? value, String field) {
  if (value is! List) throw FormatException('Invalid $field in city snapshot.');
  return List.unmodifiable(
    value.map((item) => _requiredText(item, field)).take(8),
  );
}

DateTime _requiredDate(Object? value, String field) {
  final parsed = value is String ? DateTime.tryParse(value) : null;
  if (parsed == null) throw FormatException('Invalid $field in city snapshot.');
  return parsed.toUtc();
}
