import 'accountability_journal.dart';
import 'citizen_action.dart';
import 'living_city_simulation.dart';
import 'political_timeline.dart';

enum CivicProgressionTrack {
  research,
  publicAccountability,
  civicOrganizing,
  historicalAnalysis,
}

class CivicTrackProgress {
  const CivicTrackProgress({
    required this.track,
    required this.points,
    required this.level,
    required this.currentLevelFloor,
    this.nextLevelAt,
  });

  final CivicProgressionTrack track;
  final int points;
  final int level;
  final int currentLevelFloor;
  final int? nextLevelAt;

  double get fractionToNextLevel {
    final next = nextLevelAt;
    if (next == null) return 1;
    return ((points - currentLevelFloor) / (next - currentLevelFloor)).clamp(
      0,
      1,
    );
  }
}

class CivicAccomplishment {
  const CivicAccomplishment({
    required this.id,
    required this.achieved,
    required this.progress,
    required this.target,
  });

  final String id;
  final bool achieved;
  final int progress;
  final int target;
}

/// A derived, anti-farming civic profile.
///
/// Points come only from unique election-scoped activity, immutable
/// administration records, and once-per-term citizen actions. The profile is
/// rebuilt from saved truth rather than maintained as a second mutable ledger.
class CivicProgressionProfile {
  const CivicProgressionProfile({
    required this.tracks,
    required this.accomplishments,
  });

  factory CivicProgressionProfile.fromState({
    required List<AdministrationRecord> administrations,
    required Set<String> activeViewedEvidenceIds,
    required Set<String> activeBookmarkedEvidenceIds,
    required Map<String, String> activeReceiptNotes,
    LivingTermSimulation? activeLivingCity,
    int activeSimulationDay = 0,
  }) {
    final journal = AccountabilityJournal.fromAdministrations(administrations);
    final allSimulations = <LivingTermSimulation>[
      ...administrations.map((record) => record.livingCity),
      ?activeLivingCity,
    ];
    final activeTerm =
        activeLivingCity?.termNumber ??
        (administrations.isEmpty ? 1 : administrations.last.termNumber + 1);

    final reviewedEvidence = <String>{
      for (final record in administrations)
        for (final id in record.investigation.viewedEvidenceIds)
          '${record.termNumber}:$id',
      for (final id in activeViewedEvidenceIds) '$activeTerm:$id',
    };
    final organizedEvidence = <String>{
      for (final record in administrations)
        for (final id in record.investigation.bookmarkedEvidenceIds)
          '${record.termNumber}:$id',
      for (final id in activeBookmarkedEvidenceIds) '$activeTerm:$id',
    };
    final receiptNotes = <String>{
      for (final record in administrations)
        for (final id in record.investigation.receiptNotes.keys)
          '${record.termNumber}:$id',
      for (final id in activeReceiptNotes.keys) '$activeTerm:$id',
    };
    final actionByKey =
        <String, ({LivingTermSimulation simulation, CityEvent event})>{
          for (final simulation in allSimulations)
            for (final event in simulation.eventHistory)
              if (citizenActionTypeForTemplate(event.templateId) != null)
                '${simulation.termNumber}:${event.id}': (
                  simulation: simulation,
                  event: event,
                ),
        };
    final actions = actionByKey.values.toList(growable: false);
    final recordsActions = actions
        .where(
          (item) =>
              citizenActionTypeForTemplate(item.event.templateId) ==
              CitizenActionType.requestPublicRecords,
        )
        .length;
    final petitionActions = actions
        .where(
          (item) =>
              citizenActionTypeForTemplate(item.event.templateId) ==
              CitizenActionType.organizePetition,
        )
        .length;
    final challengeActions = actions
        .where(
          (item) =>
              citizenActionTypeForTemplate(item.event.templateId) ==
              CitizenActionType.challengeMisleadingClaim,
        )
        .length;

    final researchPoints = reviewedEvidence.length + organizedEvidence.length;
    final accountabilityPoints =
        administrations.length * 3 +
        receiptNotes.length +
        recordsActions * 3 +
        challengeActions * 4 +
        journal.recurringControversies.length * 2;
    final organizingPoints = administrations.length + petitionActions * 5;
    final historicalPoints =
        administrations.length * 5 +
        journal.recurringPromises.length * 3 +
        journal.recurringControversies.length * 3;

    final maxReviewedInElection = [
      ...administrations.map(
        (record) => record.investigation.viewedEvidenceIds.length,
      ),
      activeViewedEvidenceIds.length,
    ].fold<int>(0, (highest, value) => value > highest ? value : highest);
    final recoveredIssueCount = administrations.where((record) {
      for (final entry in record.livingCity.initialIssueStates.entries) {
        final after = record.livingCity.finalIssueStates[entry.key];
        if (after != null && entry.value.severity - after.severity >= 8) {
          return true;
        }
      }
      return false;
    }).length;
    final recordsObtained = actions.where((item) {
      final isActive = identical(item.simulation, activeLivingCity);
      if (isActive && item.event.day > activeSimulationDay) return false;
      return item.event.templateId ==
              CitizenActionType.requestPublicRecords.templateId &&
          (item.event.indicatorEffects.values.any((change) => change > 0) ||
              item.event.issueSeverityEffects.values.any(
                (change) => change < 0,
              ));
    }).length;
    final successfulPetitions = actions.where((item) {
      final isActive = identical(item.simulation, activeLivingCity);
      if (isActive && item.event.day > activeSimulationDay) return false;
      return item.event.templateId ==
              CitizenActionType.organizePetition.templateId &&
          item.event.issueSeverityEffects.values.any((change) => change < 0);
    }).length;
    final crossTermProjects = _crossTermProjectFamilies(administrations);
    final comebackCount = _politicalComebackCount(administrations);

    final accomplishments = <CivicAccomplishment>[
      _accomplishment('first_administration', administrations.length, 1),
      _accomplishment('three_administrations', administrations.length, 3),
      _accomplishment('five_administrations', administrations.length, 5),
      _accomplishment('multi_source_investigator', maxReviewedInElection, 5),
      _accomplishment(
        'recurring_promise_documented',
        journal.recurringPromises.length,
        1,
      ),
      _accomplishment('public_records_obtained', recordsObtained, 1),
      _accomplishment('successful_petition', successfulPetitions, 1),
      _accomplishment('major_issue_recovery', recoveredIssueCount, 1),
      _accomplishment('cross_term_project', crossTermProjects, 1),
      _accomplishment('political_comeback', comebackCount, 1),
    ];
    return CivicProgressionProfile(
      tracks: {
        CivicProgressionTrack.research: _track(
          CivicProgressionTrack.research,
          researchPoints,
        ),
        CivicProgressionTrack.publicAccountability: _track(
          CivicProgressionTrack.publicAccountability,
          accountabilityPoints,
        ),
        CivicProgressionTrack.civicOrganizing: _track(
          CivicProgressionTrack.civicOrganizing,
          organizingPoints,
        ),
        CivicProgressionTrack.historicalAnalysis: _track(
          CivicProgressionTrack.historicalAnalysis,
          historicalPoints,
        ),
      },
      accomplishments: List.unmodifiable(accomplishments),
    );
  }

  final Map<CivicProgressionTrack, CivicTrackProgress> tracks;
  final List<CivicAccomplishment> accomplishments;

  int get accomplishedCount =>
      accomplishments.where((item) => item.achieved).length;

  CivicTrackProgress progressFor(CivicProgressionTrack track) => tracks[track]!;

  /// An optional desk view that groups already visible evidence by review
  /// state and source type. It never unlocks files or exposes truth status.
  bool get evidenceOrganizerUnlocked =>
      progressFor(CivicProgressionTrack.research).level >= 2;

  int actionDelayReductionDays(CitizenActionType type) {
    final track = type == CitizenActionType.organizePetition
        ? CivicProgressionTrack.civicOrganizing
        : CivicProgressionTrack.publicAccountability;
    return switch (progressFor(track).level) {
      >= 3 => 5,
      2 => 3,
      _ => 0,
    };
  }

  static CivicTrackProgress _track(CivicProgressionTrack track, int points) {
    const thresholds = [0, 8, 20, 40];
    var level = 1;
    for (var index = 1; index < thresholds.length; index++) {
      if (points >= thresholds[index]) level = index + 1;
    }
    return CivicTrackProgress(
      track: track,
      points: points,
      level: level,
      currentLevelFloor: thresholds[level - 1],
      nextLevelAt: level < thresholds.length ? thresholds[level] : null,
    );
  }

  static CivicAccomplishment _accomplishment(
    String id,
    int progress,
    int target,
  ) => CivicAccomplishment(
    id: id,
    achieved: progress >= target,
    progress: progress.clamp(0, target),
    target: target,
  );

  static int _crossTermProjectFamilies(
    List<AdministrationRecord> administrations,
  ) {
    final termsByFamily = <String, Set<int>>{};
    for (final record in administrations) {
      for (final project in record.livingCity.projects) {
        termsByFamily
            .putIfAbsent(project.relatedIssueFamily.name, () => <int>{})
            .add(record.termNumber);
      }
    }
    return termsByFamily.values.where((terms) => terms.length >= 2).length;
  }

  static int _politicalComebackCount(
    List<AdministrationRecord> administrations,
  ) {
    final termsByCandidate = <String, List<int>>{};
    for (final record in administrations) {
      termsByCandidate
          .putIfAbsent(record.electedCandidateId, () => <int>[])
          .add(record.termNumber);
    }
    return termsByCandidate.values.where((terms) {
      terms.sort();
      for (var index = 1; index < terms.length; index++) {
        if (terms[index] - terms[index - 1] > 1) return true;
      }
      return false;
    }).length;
  }
}
