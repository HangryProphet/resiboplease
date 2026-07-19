import 'candidate.dart';
import 'city_indicator.dart';
import 'city_indicator_set.dart';

enum TermEventKind {
  policyLaunch,
  typhoonResponse,
  clinicOutbreak,
  waterEmergency,
  jobsShock,
  transportDisruption,
  recordsReview,
  deliveryMilestone,
}

extension TermEventKindVisuals on TermEventKind {
  bool get hasArtwork => switch (this) {
    TermEventKind.typhoonResponse ||
    TermEventKind.clinicOutbreak ||
    TermEventKind.waterEmergency ||
    TermEventKind.jobsShock ||
    TermEventKind.transportDisruption => true,
    _ => false,
  };

  String? get assetPath => switch (this) {
    TermEventKind.typhoonResponse =>
      'assets/images/events/typhoon_response.jpg',
    TermEventKind.clinicOutbreak => 'assets/images/events/clinic_outbreak.jpg',
    TermEventKind.waterEmergency => 'assets/images/events/water_emergency.jpg',
    TermEventKind.jobsShock => 'assets/images/events/jobs_shock.jpg',
    TermEventKind.transportDisruption =>
      'assets/images/events/transport_disruption.jpg',
    _ => null,
  };
}

class TermPhase {
  const TermPhase({
    required this.number,
    required this.eventKind,
    required this.title,
    required this.narrative,
    required this.explanation,
    required this.changes,
  });

  final int number;
  final TermEventKind eventKind;
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
