import 'city_indicator.dart';
import 'city_problem.dart';

enum CityBriefTopic {
  food,
  poverty,
  health,
  education,
  water,
  jobs,
  cityServices,
  climate,
}

enum CityMetricKind {
  reliableFoodAccess,
  financiallySecureHouseholds,
  clinicWaitTime,
  classroomSize,
  reliableWater,
  stableEmployment,
  commuteTime,
  floodReadiness,
  publicTrust,
  budgetRoom,
}

enum CityMetricUnit { percent, hours, people, minutes, condition }

enum CityNewsSource { cityDesk, recordsOffice, publicMedia, communityFeed }

enum CitizenDistrict {
  northWard,
  riverside,
  oldMarket,
  southPoint,
  harborDistrict,
  hillview,
}

enum CitizenRole {
  vendor,
  caregiver,
  clinicWorker,
  student,
  teacher,
  commuter,
  tradesWorker,
  resident,
}

class CityBriefMetric {
  const CityBriefMetric({
    required this.kind,
    required this.sourceIndicator,
    required this.value,
    required this.unit,
    required this.conditionScore,
  });

  final CityMetricKind kind;
  final CityIndicator sourceIndicator;
  final double value;
  final CityMetricUnit unit;

  /// Presentation-only condition from 0 (critical) to 100 (strong).
  /// It is derived from public city state and is never a candidate score.
  final int conditionScore;
}

class CityConcernSnapshot {
  const CityConcernSnapshot({
    required this.problem,
    required this.topic,
    required this.affectedResidentsPercent,
  });

  final CityProblem problem;
  final CityBriefTopic topic;
  final int affectedResidentsPercent;
}

class CityNewsItem {
  const CityNewsItem({
    required this.id,
    required this.topic,
    required this.source,
    required this.templateVariant,
    required this.isUnverified,
  });

  final String id;
  final CityBriefTopic topic;
  final CityNewsSource source;
  final int templateVariant;
  final bool isUnverified;
}

class CitizenVoice {
  const CitizenVoice({
    required this.id,
    required this.topic,
    required this.district,
    required this.role,
    required this.templateVariant,
  });

  final String id;
  final CityBriefTopic topic;
  final CitizenDistrict district;
  final CitizenRole role;
  final int templateVariant;
}

/// A reproducible, read-only description of the city before election day.
///
/// The brief contains no simulation steps and cannot mutate the city. News and
/// voices describe starting conditions only; consequential events begin after
/// a vote is confirmed.
class PreElectionCityBrief {
  const PreElectionCityBrief({
    required this.scenarioSeed,
    required this.metrics,
    required this.concerns,
    required this.news,
    required this.voices,
  });

  final int scenarioSeed;
  final List<CityBriefMetric> metrics;
  final List<CityConcernSnapshot> concerns;
  final List<CityNewsItem> news;
  final List<CitizenVoice> voices;
}
