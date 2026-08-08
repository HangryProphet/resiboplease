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

enum CityIssueFamily {
  floodingDrainage,
  corruptionPublicFunds,
  unfinishedRoads,
  drugsCommunitySafety,
  garbageCleanliness,
  trafficTransport,
  waterSupply,
  healthcareCapacity,
  employmentQuality,
  costOfLiving,
  governmentServices,
  educationCapacity,
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
    this.family = CityIssueFamily.governmentServices,
    this.affectedGroups = const [],
    this.possibleCauses = const [],
    this.policyHooks = const [],
    this.chronicleHooks = const [],
    this.communityVoiceHooks = const [],
    this.eventHooks = const [],
    this.visualKey = 'city_issue_generic',
    this.tags = const [],
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
  final CityIssueFamily family;
  final List<String> affectedGroups;
  final List<String> possibleCauses;
  final List<String> policyHooks;
  final List<String> chronicleHooks;
  final List<String> communityVoiceHooks;
  final List<String> eventHooks;
  final String visualKey;
  final List<String> tags;

  double get issueWeight =>
      (severity / 100) * (urgency / 100) * trend.multiplier;

  CityProblem copyWith({
    String? id,
    String? title,
    String? description,
    CityIndicator? primaryIndicator,
    List<CityIndicator>? relatedIndicators,
    int? severity,
    int? urgency,
    ProblemTrend? trend,
    List<String>? sdgTags,
    CityIssueFamily? family,
    List<String>? affectedGroups,
    List<String>? possibleCauses,
    List<String>? policyHooks,
    List<String>? chronicleHooks,
    List<String>? communityVoiceHooks,
    List<String>? eventHooks,
    String? visualKey,
    List<String>? tags,
  }) => CityProblem(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    primaryIndicator: primaryIndicator ?? this.primaryIndicator,
    relatedIndicators: relatedIndicators ?? this.relatedIndicators,
    severity: severity ?? this.severity,
    urgency: urgency ?? this.urgency,
    trend: trend ?? this.trend,
    sdgTags: sdgTags ?? this.sdgTags,
    family: family ?? this.family,
    affectedGroups: affectedGroups ?? this.affectedGroups,
    possibleCauses: possibleCauses ?? this.possibleCauses,
    policyHooks: policyHooks ?? this.policyHooks,
    chronicleHooks: chronicleHooks ?? this.chronicleHooks,
    communityVoiceHooks: communityVoiceHooks ?? this.communityVoiceHooks,
    eventHooks: eventHooks ?? this.eventHooks,
    visualKey: visualKey ?? this.visualKey,
    tags: tags ?? this.tags,
  );
}
