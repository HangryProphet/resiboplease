import 'living_city_simulation.dart';
import 'term_result.dart';

enum CitizenActionType {
  requestPublicRecords,
  organizePetition,
  challengeMisleadingClaim,
}

enum CitizenActionOutcome { succeeded, partial, resisted }

extension CitizenActionTypeMetadata on CitizenActionType {
  String get templateId => switch (this) {
    CitizenActionType.requestPublicRecords =>
      'citizen_action_request_public_records',
    CitizenActionType.organizePetition => 'citizen_action_organize_petition',
    CitizenActionType.challengeMisleadingClaim =>
      'citizen_action_challenge_misleading_claim',
  };

  String get title => switch (this) {
    CitizenActionType.requestPublicRecords => 'Request Public Records',
    CitizenActionType.organizePetition => 'Organize a Petition',
    CitizenActionType.challengeMisleadingClaim =>
      'Challenge a Misleading Claim',
  };

  String get description => switch (this) {
    CitizenActionType.requestPublicRecords =>
      'Ask City Hall to release records relevant to public accountability.',
    CitizenActionType.organizePetition =>
      'Build public pressure around the city\'s most severe current concern.',
    CitizenActionType.challengeMisleadingClaim =>
      'Use reviewed evidence to challenge a misleading or false public claim.',
  };
}

CitizenActionType? citizenActionTypeForTemplate(String templateId) {
  for (final type in CitizenActionType.values) {
    if (type.templateId == templateId) return type;
  }
  return null;
}

class CitizenActionResolution {
  const CitizenActionResolution({
    required this.type,
    required this.outcome,
    required this.performedDay,
    required this.outcomeEvent,
    required this.termResult,
    required this.checkpoint,
  });

  final CitizenActionType type;
  final CitizenActionOutcome outcome;
  final int performedDay;
  final CityEvent outcomeEvent;
  final TermResult termResult;
  final SimulationDayCheckpoint checkpoint;
}

/// Immutable receipt of the observed simulation prefix at the moment a citizen
/// action is filed. Future action systems must preserve this fingerprint unless
/// a later, versioned suffix-regeneration migration explicitly replaces it.
class SimulationDayCheckpoint {
  const SimulationDayCheckpoint({
    required this.day,
    required this.observedEventIds,
    required this.observedMilestoneIds,
    required this.stateFingerprint,
  });

  final int day;
  final List<String> observedEventIds;
  final List<String> observedMilestoneIds;
  final String stateFingerprint;
}

class ScheduledCitizenAction {
  const ScheduledCitizenAction({required this.type, required this.event});

  final CitizenActionType type;
  final CityEvent event;

  bool isResolvedOn(int day) => event.day <= day;
}

List<ScheduledCitizenAction> scheduledCitizenActions(
  LivingTermSimulation simulation,
) => simulation.eventHistory
    .map((event) {
      final type = citizenActionTypeForTemplate(event.templateId);
      return type == null
          ? null
          : ScheduledCitizenAction(type: type, event: event);
    })
    .whereType<ScheduledCitizenAction>()
    .toList(growable: false);
