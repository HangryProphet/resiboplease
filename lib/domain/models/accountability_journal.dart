import 'living_city_simulation.dart';
import 'political_timeline.dart';

enum AccountabilityOutcome {
  notStarted,
  inProgress,
  partiallyDelivered,
  delivered,
  delayed,
  abandoned,
  blocked,
}

class AccountabilityPromiseRecord {
  const AccountabilityPromiseRecord({
    required this.id,
    required this.termNumber,
    required this.candidateId,
    required this.candidateName,
    required this.party,
    required this.portraitAssetKey,
    required this.promiseId,
    required this.promiseTitle,
    required this.campaignWording,
    required this.outcome,
    required this.outcomeExplanation,
    required this.evidenceIds,
    this.projectTitle,
    this.projectProgress = 0,
  });

  final String id;
  final int termNumber;
  final String candidateId;
  final String candidateName;
  final String party;
  final String portraitAssetKey;
  final String promiseId;
  final String promiseTitle;
  final String campaignWording;
  final AccountabilityOutcome outcome;
  final String outcomeExplanation;
  final List<String> evidenceIds;
  final String? projectTitle;
  final int projectProgress;
}

class AccountabilityJournal {
  const AccountabilityJournal({
    required this.promises,
    this.recurringPromises = const [],
    this.recurringControversies = const [],
  });

  factory AccountabilityJournal.fromAdministrations(
    Iterable<AdministrationRecord> administrations,
  ) {
    final entries = <AccountabilityPromiseRecord>[];
    final promiseGroups = <String, List<AccountabilityPromiseRecord>>{};
    final controversyGroups = <String, _ControversyAccumulator>{};
    for (final administration in administrations) {
      final election = administration.election;
      if (election == null) continue;
      final promises = election.candidateExperience.promisesFor(
        administration.electedCandidateId,
      );
      for (final promise in promises) {
        final project = administration.livingCity.projects
            .where((item) => item.promiseId == promise.id)
            .firstOrNull;
        final outcome = _outcomeFor(project);
        final entry = AccountabilityPromiseRecord(
          id: '${administration.id}_${promise.id}',
          termNumber: administration.termNumber,
          candidateId: administration.electedCandidateId,
          candidateName: administration.electedCandidateName,
          party: administration.electedParty,
          portraitAssetKey: administration.electedPortraitAssetKey,
          promiseId: promise.id,
          promiseTitle: promise.title,
          campaignWording: promise.candidateWording,
          outcome: outcome,
          outcomeExplanation: _explanationFor(project, outcome),
          evidenceIds: List.unmodifiable(promise.evidenceIds),
          projectTitle: project?.title,
          projectProgress: project?.progress ?? 0,
        );
        entries.add(entry);
        final family =
            promise.relatedIssueFamilies.firstOrNull?.name ??
            promise.title.toLowerCase();
        promiseGroups
            .putIfAbsent(
              '${administration.electedCandidateId}:$family',
              () => [],
            )
            .add(entry);
      }
      final truth = election.truthProfiles[administration.electedCandidateId];
      if (truth != null) {
        for (final controversy in truth.controversies) {
          final key =
              '${administration.electedCandidateId}:${controversy.kind.toLowerCase()}';
          final accumulator = controversyGroups.putIfAbsent(
            key,
            () => _ControversyAccumulator(
              candidateId: administration.electedCandidateId,
              candidateName: administration.electedCandidateName,
              kind: controversy.kind,
            ),
          );
          accumulator.termNumbers.add(administration.termNumber);
          accumulator.statuses.add(controversy.status.name);
        }
      }
    }
    final recurringPromises = promiseGroups.values
        .where((group) => group.length >= 2)
        .map(
          (group) => RecurringPromisePattern(
            id: 'recurring_${group.first.candidateId}_${group.first.promiseTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
            candidateId: group.first.candidateId,
            candidateName: group.first.candidateName,
            promiseTitle: group.first.promiseTitle,
            termNumbers: List.unmodifiable(
              group.map((item) => item.termNumber).toSet().toList()..sort(),
            ),
            outcomes: List.unmodifiable(group.map((item) => item.outcome)),
          ),
        )
        .toList(growable: false);
    final recurringControversies = controversyGroups.values
        .where((item) => item.termNumbers.toSet().length >= 2)
        .map(
          (item) => RecurringControversyPattern(
            id: 'controversy_${item.candidateId}_${item.kind.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
            candidateId: item.candidateId,
            candidateName: item.candidateName,
            controversyKind: item.kind,
            termNumbers: List.unmodifiable(
              item.termNumbers.toSet().toList()..sort(),
            ),
            recordedStatuses: List.unmodifiable(item.statuses),
          ),
        )
        .toList(growable: false);
    return AccountabilityJournal(
      promises: List.unmodifiable(entries),
      recurringPromises: List.unmodifiable(recurringPromises),
      recurringControversies: List.unmodifiable(recurringControversies),
    );
  }

  final List<AccountabilityPromiseRecord> promises;
  final List<RecurringPromisePattern> recurringPromises;
  final List<RecurringControversyPattern> recurringControversies;

  List<AccountabilityPromiseRecord> forCandidate(String candidateId) => promises
      .where((promise) => promise.candidateId == candidateId)
      .toList(growable: false);

  List<AccountabilityPromiseRecord> forTerm(int termNumber) => promises
      .where((promise) => promise.termNumber == termNumber)
      .toList(growable: false);

  static AccountabilityOutcome _outcomeFor(AdministrationProject? project) {
    if (project == null ||
        (project.progress == 0 &&
            project.promiseStatus == PromiseProgressStatus.announced)) {
      return AccountabilityOutcome.notStarted;
    }
    if (project.promiseStatus == PromiseProgressStatus.abandoned ||
        project.state == AdministrationProjectState.cancelled) {
      return AccountabilityOutcome.abandoned;
    }
    if (project.state == AdministrationProjectState.underInvestigation) {
      return AccountabilityOutcome.blocked;
    }
    if (project.promiseStatus == PromiseProgressStatus.delayed ||
        project.state == AdministrationProjectState.delayed ||
        project.state == AdministrationProjectState.stalled) {
      return AccountabilityOutcome.delayed;
    }
    if (project.promiseStatus == PromiseProgressStatus.completed ||
        project.state == AdministrationProjectState.completed) {
      return AccountabilityOutcome.delivered;
    }
    if (project.promiseStatus == PromiseProgressStatus.compromised ||
        project.state == AdministrationProjectState.partiallyCompleted ||
        project.progress >= 50) {
      return AccountabilityOutcome.partiallyDelivered;
    }
    return AccountabilityOutcome.inProgress;
  }

  static String _explanationFor(
    AdministrationProject? project,
    AccountabilityOutcome outcome,
  ) {
    if (project == null) {
      return 'No administration project was linked to this campaign promise in the sealed term record.';
    }
    final milestoneCount = project.milestones.length;
    return switch (outcome) {
      AccountabilityOutcome.notStarted =>
        'The promise remained announced, with no recorded implementation progress.',
      AccountabilityOutcome.inProgress =>
        '${project.title} reached ${project.progress}% with $milestoneCount recorded milestone(s) before the term ended.',
      AccountabilityOutcome.partiallyDelivered =>
        '${project.title} delivered part of the promised work and ended at ${project.progress}%.',
      AccountabilityOutcome.delivered =>
        '${project.title} reached its recorded completion state with $milestoneCount milestone(s).',
      AccountabilityOutcome.delayed =>
        '${project.title} recorded progress but ended delayed or stalled at ${project.progress}%.',
      AccountabilityOutcome.abandoned =>
        '${project.title} was cancelled or abandoned before delivery.',
      AccountabilityOutcome.blocked =>
        '${project.title} ended under investigation; the record does not treat that as automatic proof of wrongdoing.',
    };
  }
}

class RecurringPromisePattern {
  const RecurringPromisePattern({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.promiseTitle,
    required this.termNumbers,
    required this.outcomes,
  });

  final String id;
  final String candidateId;
  final String candidateName;
  final String promiseTitle;
  final List<int> termNumbers;
  final List<AccountabilityOutcome> outcomes;
}

class RecurringControversyPattern {
  const RecurringControversyPattern({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.controversyKind,
    required this.termNumbers,
    required this.recordedStatuses,
  });

  final String id;
  final String candidateId;
  final String candidateName;
  final String controversyKind;
  final List<int> termNumbers;
  final List<String> recordedStatuses;
}

class _ControversyAccumulator {
  _ControversyAccumulator({
    required this.candidateId,
    required this.candidateName,
    required this.kind,
  });

  final String candidateId;
  final String candidateName;
  final String kind;
  final List<int> termNumbers = [];
  final List<String> statuses = [];
}
