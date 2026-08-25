import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';
import 'package:resiboplease/data/persistence/run_repository.dart';
import 'package:resiboplease/data/persistence/run_save_data.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/models/living_city_simulation.dart';

void main() {
  test(
    'simulation speeds process logical day batches and pause blocks ticks',
    () {
      final controller = GameController(activeRun: true);
      addTearDown(controller.dispose);
      controller.castVote(
        candidate: controller.scenario.candidates.first,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .7,
      );

      expect(controller.simulationDay, 0);
      controller.advanceSimulationDays(
        SimulationSpeed.day.daysPerPulse,
        interruptionPreference: CriticalEventInterruption.neverInterrupt,
      );
      expect(controller.simulationDay, 1);

      controller.setSimulationSpeed(SimulationSpeed.week);
      controller.advanceSimulationDays(
        controller.simulationSpeed.daysPerPulse,
        interruptionPreference: CriticalEventInterruption.neverInterrupt,
      );
      expect(controller.simulationDay, 8);

      controller.pauseSimulation();
      controller.advanceSimulationDays(
        30,
        interruptionPreference: CriticalEventInterruption.neverInterrupt,
      );
      expect(controller.simulationDay, 8);

      controller.setSimulationSpeed(SimulationSpeed.month);
      controller.advanceSimulationDays(
        controller.simulationSpeed.daysPerPulse,
        interruptionPreference: CriticalEventInterruption.neverInterrupt,
      );
      expect(controller.simulationDay, 38);
    },
  );

  test('year fast-forward preserves events and reaches day 365', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .6,
    );
    final expectedIds = controller.termResult!.livingCity.eventHistory
        .map((event) => event.id)
        .toList(growable: false);
    final result = controller.fastForwardToYearEnd(
      interruptionPreference: CriticalEventInterruption.neverInterrupt,
    );

    expect(result?.yearCompletedNow, isTrue);
    expect(controller.simulationDay, 365);
    expect(controller.simulationPaused, isTrue);
    expect(controller.isTermReportReady, isTrue);
    expect(
      controller.termResult!.livingCity.eventHistory.map((event) => event.id),
      orderedEquals(expectedIds),
    );
  });

  test('important auto-pause stops at the first qualifying event', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .6,
    );
    final firstImportant = controller.termResult!.livingCity.eventHistory
        .firstWhere(
          (event) =>
              event.importance == CityEventImportance.critical ||
              event.importance == CityEventImportance.rare,
        );
    controller.setSimulationSpeed(SimulationSpeed.year);
    final interruption = controller.advanceSimulationDays(
      365,
      interruptionPreference: CriticalEventInterruption.pauseAndNotify,
    );

    expect(interruption?.criticalEvent?.id, firstImportant.id);
    expect(interruption?.shouldNotify, isTrue);
    expect(interruption?.shouldOpenEvent, isFalse);
    expect(controller.simulationDay, firstImportant.day);
    expect(controller.simulationPaused, isTrue);
  });

  test('all critical-event interruption modes preserve event history', () {
    for (final mode in CriticalEventInterruption.values) {
      final controller = GameController(activeRun: true);
      addTearDown(controller.dispose);
      controller.castVote(
        candidate: controller.scenario.candidates.first,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .6,
      );
      final history = controller.termResult!.livingCity.eventHistory;
      final originalIds = history.map((event) => event.id).toList();
      final firstCritical = history.firstWhere(
        (event) =>
            event.day < 365 &&
            (event.importance == CityEventImportance.critical ||
                event.importance == CityEventImportance.rare),
      );
      final result = controller.advanceSimulationDays(
        firstCritical.day + 1,
        interruptionPreference: mode,
      )!;

      expect(
        controller.termResult!.livingCity.eventHistory.map((event) => event.id),
        orderedEquals(originalIds),
      );
      switch (mode) {
        case CriticalEventInterruption.autoOpen:
          expect(result.criticalEvent?.id, firstCritical.id);
          expect(result.shouldOpenEvent, isTrue);
          expect(result.shouldNotify, isFalse);
          expect(result.paused, isTrue);
          expect(result.toDay, firstCritical.day);
        case CriticalEventInterruption.pauseAndNotify:
          expect(result.criticalEvent?.id, firstCritical.id);
          expect(result.shouldOpenEvent, isFalse);
          expect(result.shouldNotify, isTrue);
          expect(result.paused, isTrue);
          expect(result.toDay, firstCritical.day);
        case CriticalEventInterruption.notifyOnly:
          expect(result.criticalEvent?.id, firstCritical.id);
          expect(result.shouldOpenEvent, isFalse);
          expect(result.shouldNotify, isTrue);
          expect(result.paused, isFalse);
          expect(result.toDay, firstCritical.day + 1);
        case CriticalEventInterruption.neverInterrupt:
          expect(result.criticalEvent, isNull);
          expect(result.shouldOpenEvent, isFalse);
          expect(result.shouldNotify, isFalse);
          expect(result.paused, isFalse);
          expect(result.toDay, firstCritical.day + 1);
      }
    }
  });

  test('YEAR reaches the exact finish from day and month positions', () {
    for (final startingDay in [11, 137]) {
      final controller = GameController(activeRun: true);
      addTearDown(controller.dispose);
      controller.castVote(
        candidate: controller.scenario.candidates.first,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .6,
      );
      controller.advanceSimulationDays(
        startingDay,
        interruptionPreference: CriticalEventInterruption.neverInterrupt,
      );

      final result = controller.fastForwardToYearEnd(
        interruptionPreference: CriticalEventInterruption.neverInterrupt,
      );

      expect(result?.fromDay, startingDay);
      expect(result?.toDay, 365);
      expect(result?.yearCompletedNow, isTrue);
      expect(controller.simulationDay, 365);
      expect(
        controller.fastForwardToYearEnd(
          interruptionPreference: CriticalEventInterruption.neverInterrupt,
        ),
        isNull,
      );
    }
  });

  test('a paused YEAR command can resume without rerolling events', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .6,
    );
    final originalIds = controller.termResult!.livingCity.eventHistory
        .map((event) => event.id)
        .toList();

    final interrupted = controller.fastForwardToYearEnd(
      interruptionPreference: CriticalEventInterruption.pauseAndNotify,
    )!;
    expect(interrupted.criticalEvent, isNotNull);
    expect(controller.simulationDay, lessThan(365));

    final resumed = controller.fastForwardToYearEnd(
      interruptionPreference: CriticalEventInterruption.neverInterrupt,
    )!;
    expect(resumed.toDay, 365);
    expect(
      controller.termResult!.livingCity.eventHistory.map((event) => event.id),
      orderedEquals(originalIds),
    );
  });

  test(
    'simulation date, speed, inspection, and history restore without reroll',
    () async {
      final repository = MemoryRunRepository();
      final controller = GameController(
        repository: repository,
        activeRun: true,
      );
      final candidate = controller.scenario.candidates.first;
      controller.castVote(
        candidate: candidate,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .7,
      );
      final originalHistory = controller.termResult!.livingCity.eventHistory
          .map((event) => event.id)
          .toList(growable: false);
      controller.setSimulationSpeed(SimulationSpeed.month);
      controller.advanceSimulationDays(
        120,
        interruptionPreference: CriticalEventInterruption.neverInterrupt,
      );
      final inspected = controller.termResult!.livingCity
          .eventsThroughDay(controller.simulationDay)
          .first;
      controller.markCityEventInspected(inspected.id);
      controller.pauseSimulation();
      await controller.flushSaves();

      final restored = GameController(repository: repository);
      addTearDown(restored.dispose);
      await restored.restore();

      expect(restored.simulationDay, 120);
      expect(restored.simulationSpeed, SimulationSpeed.month);
      expect(restored.simulationPaused, isTrue);
      expect(restored.inspectedCityEventIds, contains(inspected.id));
      expect(
        restored.termResult!.livingCity.eventHistory.map((event) => event.id),
        orderedEquals(originalHistory),
      );
    },
  );

  test('a new run becomes active and clears previous decisions', () {
    final controller = GameController();
    final candidate = controller.scenario.candidates.first;

    expect(controller.hasActiveRun, isFalse);
    controller.castVote(
      candidate: candidate,
      topIssue: 'flooding',
      confidence: .8,
    );
    controller.startNewRun();

    expect(controller.hasActiveRun, isTrue);
    expect(controller.selectedCandidate, isNull);
    expect(controller.termResult, isNull);
    expect(controller.topIssue, isNull);
    expect(controller.confidence, .5);
  });

  test('five city slots can be created, selected, and deleted', () {
    final controller = GameController();

    expect(controller.saveSlots, hasLength(GameController.saveSlotCount));
    expect(controller.saveSlots, everyElement(isNull));

    controller.createCity(
      slotIndex: 2,
      configuration: CityRunConfiguration.defaults(cityName: '  Harborlight  '),
    );
    expect(controller.hasActiveRun, isTrue);
    expect(controller.activeSlotIndex, 2);
    expect(controller.activeCityName, 'Harborlight');
    expect(controller.saveSlots[2]!.cityName, 'Harborlight');

    controller.createCity(
      slotIndex: 4,
      configuration: CityRunConfiguration.defaults(cityName: 'Mabuhay'),
    );
    expect(controller.activeSlotIndex, 4);
    controller.continueCity(2);
    expect(controller.activeCityName, 'Harborlight');

    controller.deleteCity(2);
    expect(controller.saveSlots[2], isNull);
    expect(controller.activeSlotIndex, 4);
    expect(controller.activeCityName, 'Mabuhay');
  });

  test('an occupied slot cannot be overwritten', () {
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'First City'),
    );

    expect(
      () => controller.createCity(
        slotIndex: 0,
        configuration: CityRunConfiguration.defaults(cityName: 'Replacement'),
      ),
      throwsStateError,
    );
    expect(controller.activeCityName, 'First City');
  });

  test('city configuration builds and survives a same-seed restart', () {
    final controller = GameController();
    final configuration = CityRunConfiguration(
      cityName: 'Harborlight',
      startingPressure: StartingPressure.crisis,
      mainConcerns: [CityConcern.food, CityConcern.climate],
      candidateField: CandidateField.seasoned,
      assistanceMode: AssistanceMode.standard,
      campaignNoise: CampaignNoise.noisy,
      investigationTime: InvestigationTime.limited,
    );

    controller.createCity(
      slotIndex: 1,
      configuration: configuration,
      worldSeed: 71821,
    );

    expect(
      controller.activeConfiguration!.startingPressure,
      StartingPressure.crisis,
    );
    expect(controller.scenario.city.name, 'Harborlight');
    expect(controller.scenario.city.problems.length, inInclusiveRange(4, 6));
    expect(
      controller.scenario.city.problems.map((problem) => problem.id),
      containsAll(['cost_of_living_pressure', 'flooding_drainage_backlog']),
    );
    expect(controller.assistanceMode, AssistanceMode.standard);
    expect(controller.investigationPointLimit, 7);
    expect(controller.remainingInvestigationPoints, 7);
    expect(
      controller.scenario.candidates.first.evidence.length,
      greaterThan(5),
    );

    final savedConfiguration = controller.activeConfiguration;
    final issueIds = controller.scenario.city.problems
        .map((problem) => problem.id)
        .toList();
    final storyIds = controller.preElectionBrief.news
        .map((story) => story.id)
        .toList();
    controller.restartSameSeed();

    expect(controller.activeConfiguration, same(savedConfiguration));
    expect(controller.scenario.city.name, 'Harborlight');
    expect(
      controller.scenario.city.problems.map((problem) => problem.id),
      issueIds,
    );
    expect(controller.preElectionBrief.news.map((story) => story.id), storyIds);
  });

  test('limited investigation prevents opening new paid evidence', () {
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(
        cityName: 'Seven Points',
      ).copyWith(investigationTime: InvestigationTime.limited),
    );

    final paidEvidenceIds = <String>[];
    var plannedSpend = 0;
    for (final candidate in controller.scenario.candidates) {
      for (final evidence in candidate.evidence) {
        final cost = controller.evidenceInvestigationCost(evidence.id);
        if (cost <= 0 || plannedSpend + cost > 7) continue;
        paidEvidenceIds.add(evidence.id);
        plannedSpend += cost;
        if (plannedSpend == 7) break;
      }
      if (plannedSpend == 7) break;
    }
    expect(plannedSpend, 7);
    final freeProfile = controller.scenario.candidates.first.evidence
        .firstWhere((item) => item.type.name == 'profile');

    for (final id in paidEvidenceIds) {
      expect(controller.markEvidenceViewed(id), isTrue);
    }
    expect(controller.remainingInvestigationPoints, 0);
    final blockedEvidence = controller.scenario.candidates
        .expand((candidate) => candidate.evidence)
        .firstWhere(
          (item) =>
              !paidEvidenceIds.contains(item.id) &&
              controller.evidenceInvestigationCost(item.id) > 0,
        );
    expect(controller.markEvidenceViewed(blockedEvidence.id), isFalse);
    expect(controller.markEvidenceViewed(paidEvidenceIds.first), isTrue);
    expect(controller.markEvidenceViewed(freeProfile.id), isTrue);
    expect(controller.markEvidenceViewed('missing_evidence'), isFalse);
    expect(controller.viewedEvidenceCount, paidEvidenceIds.length + 1);
    expect(controller.investigationPointsUsed, 7);
  });

  test('voting resolves candidate truth from the active configured ballot', () {
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults().copyWith(
        candidateField: CandidateField.seasoned,
      ),
    );
    final configuredCandidate = controller.scenario.candidates.first;
    final externalCopy = configuredCandidate.copyWith(
      capabilities: configuredCandidate.capabilities.copyWith(
        implementationSkill: 10,
      ),
    );

    controller.castVote(
      candidate: externalCopy,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .6,
    );

    expect(controller.selectedCandidate, same(configuredCandidate));
    expect(controller.termResult!.candidate, same(configuredCandidate));
  });

  test('a complete run restores from the local repository', () async {
    final repository = MemoryRunRepository();
    final controller = GameController(repository: repository);
    final configuration =
        CityRunConfiguration.defaults(cityName: 'Persistent Harbor').copyWith(
          startingPressure: StartingPressure.crisis,
          campaignNoise: CampaignNoise.noisy,
          investigationTime: InvestigationTime.limited,
        );
    controller.createCity(slotIndex: 3, configuration: configuration);
    final chronicleStoryIds = controller.preElectionBrief.news
        .map((item) => item.id)
        .toList();
    final chronicleVoiceIds = controller.preElectionBrief.voices
        .map((item) => item.id)
        .toList();
    String candidateSnapshot(GameController source) => jsonEncode([
      for (final item in source.scenario.candidates)
        {
          'id': item.id,
          'name': item.name,
          'evidence': item.evidence.map((evidence) => evidence.id).toList(),
          'portrait': source.candidateExperience
              .profileFor(item.id)!
              .portraitAssetKey,
          'pulse': source.candidateExperience
              .profileFor(item.id)!
              .pulse
              .map((content) => content.id)
              .toList(),
        },
    ]);
    final initialCandidateSnapshot = candidateSnapshot(controller);
    final candidate = controller.scenario.candidates.first;
    final evidence = candidate.evidence.firstWhere(
      (item) => controller.evidenceInvestigationCost(item.id) > 0,
    );
    expect(controller.markEvidenceViewed(evidence.id), isTrue);
    controller.toggleBookmark(evidence.id);
    controller.castVote(
      candidate: candidate,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );
    await controller.flushSaves();

    final restored = GameController(repository: repository);
    await restored.restore();

    expect(restored.activeSlotIndex, 3);
    expect(restored.activeCityName, 'Persistent Harbor');
    expect(
      restored.activeConfiguration!.startingPressure,
      StartingPressure.crisis,
    );
    expect(restored.selectedCandidate!.id, candidate.id);
    expect(restored.termResult, isNotNull);
    expect(restored.topIssue, controller.scenario.city.problems.first.id);
    expect(restored.confidence, .7);
    expect(restored.viewedEvidenceCount, 1);
    expect(restored.isBookmarked(evidence.id), isTrue);
    expect(restored.investigationPointsUsed, 1);
    expect(restored.activeResumeRoute, '/simulation');
    expect(candidateSnapshot(restored), initialCandidateSnapshot);
    expect(
      restored.preElectionBrief.news.map((item) => item.id),
      chronicleStoryIds,
    );
    expect(
      restored.preElectionBrief.voices.map((item) => item.id),
      chronicleVoiceIds,
    );
    for (var phase = 0; phase < 4; phase++) {
      restored.advanceTerm();
    }
    expect(restored.activeResumeRoute, '/report');
    await restored.flushSaves();

    controller.dispose();
    restored.dispose();
  });

  test('restore discards stale or uncharged evidence state', () async {
    final sourceRepository = MemoryRunRepository();
    final source = GameController(repository: sourceRepository);
    source.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults().copyWith(
        investigationTime: InvestigationTime.limited,
      ),
    );
    final profile = source.scenario.candidates.first.evidence.firstWhere(
      (item) => item.type.name == 'profile',
    );
    final paid = source.scenario.candidates.first.evidence.firstWhere(
      (item) => source.evidenceInvestigationCost(item.id) > 0,
    );
    final uncharged = source.scenario.candidates
        .expand((candidate) => candidate.evidence)
        .firstWhere(
          (item) =>
              item.id != paid.id &&
              source.evidenceInvestigationCost(item.id) > 0,
        );
    expect(source.markEvidenceViewed(profile.id), isTrue);
    expect(source.markEvidenceViewed(paid.id), isTrue);
    await source.flushSaves();
    final cleanRoot = (await sourceRepository.load())!;
    final clean = cleanRoot.slots.first!;
    final polluted = RunSaveData(
      seed: clean.seed,
      configuration: clean.configuration,
      indicators: clean.indicators,
      term: clean.term,
      bookmarkedEvidenceIds: {...clean.bookmarkedEvidenceIds, 'stale_file'},
      viewedEvidenceIds: {
        ...clean.viewedEvidenceIds,
        'stale_file',
        uncharged.id,
      },
      chargedEvidenceIds: {...clean.chargedEvidenceIds, 'stale_file'},
      evidencePointCosts: clean.evidencePointCosts,
      selectedCandidateId: clean.selectedCandidateId,
      termResultReady: clean.termResultReady,
      revealedTermPhases: clean.revealedTermPhases,
      topIssue: clean.topIssue,
      confidence: clean.confidence,
      createdAt: clean.createdAt,
      updatedAt: clean.updatedAt,
      proceduralElection: clean.proceduralElection,
    );
    final repository = MemoryRunRepository(
      initialValue: GameSaveData(
        activeSlotIndex: 0,
        slots: [polluted, null, null, null, null],
      ),
    );
    final restored = GameController(repository: repository);
    await restored.restore();

    expect(restored.viewedEvidenceIds, {profile.id, paid.id});
    expect(restored.bookmarkedEvidenceIds, isNot(contains('stale_file')));
    expect(restored.investigationPointsUsed, 1);

    source.dispose();
    restored.dispose();
  });

  test('evidence relationships unlock a free follow-up', () {
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults().copyWith(
        investigationTime: InvestigationTime.limited,
      ),
    );

    final unlockRelation = controller.candidateExperience.profiles.values
        .expand((profile) => profile.relations)
        .firstWhere(
          (relation) =>
              relation.unlocksTarget &&
              controller.candidateExperience.investigationCostFor(
                    relation.toEvidenceId,
                  ) >
                  0,
        );
    expect(
      controller.evidenceInvestigationCost(unlockRelation.toEvidenceId),
      greaterThan(0),
    );
    expect(
      controller.markEvidenceViewed(unlockRelation.fromEvidenceId),
      isTrue,
    );
    expect(
      controller.unlockedEvidenceIds,
      contains(unlockRelation.toEvidenceId),
    );
    expect(
      controller.evidenceInvestigationCost(unlockRelation.toEvidenceId),
      0,
    );
    expect(controller.markEvidenceViewed(unlockRelation.toEvidenceId), isTrue);
    expect(controller.investigationPointsUsed, 0);

    controller.dispose();
  });

  test('candidate receipts and world name registry persist', () async {
    final repository = MemoryRunRepository();
    final controller = GameController(repository: repository);
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Receipt City'),
    );

    final candidateId = controller.scenario.candidates.first.id;
    final profile = controller.candidateExperience.profileFor(candidateId)!;
    final contentId = profile.pulse.first.id;
    final questionId = profile.questions.first.id;
    final debateMessages = controller.candidateExperience.debateTopics
        .expand((topic) => topic.messages)
        .where((message) => message.bookmarkable)
        .take(3)
        .toList();
    controller.toggleCandidatePin(candidateId);
    controller.toggleContentPin(contentId);
    controller.toggleQuestionPin(questionId);
    controller.toggleDebateBookmark(debateMessages[0].id);
    controller.toggleDebatePin(debateMessages[1].id);
    controller.toggleDebateSuspicious(debateMessages[2].id);
    controller.setReceiptNote(
      'content:$contentId',
      'Compare this with the budget.',
    );
    expect(controller.reserveCandidateName('Ari Santos'), isTrue);
    expect(controller.reserveCandidateName('  ari   santos '), isFalse);
    await controller.flushSaves();

    final restored = GameController(repository: repository);
    await restored.restore();

    expect(restored.isCandidatePinned(candidateId), isTrue);
    expect(restored.isContentPinned(contentId), isTrue);
    expect(restored.isQuestionPinned(questionId), isTrue);
    expect(restored.isDebateBookmarked(debateMessages[0].id), isTrue);
    expect(restored.isDebatePinned(debateMessages[1].id), isTrue);
    expect(restored.isDebateSuspicious(debateMessages[2].id), isTrue);
    expect(
      restored.receiptNote('content:$contentId'),
      'Compare this with the budget.',
    );
    expect(restored.usedCandidateNames, contains('Ari Santos'));

    controller.dispose();
    restored.dispose();
  });

  test('slot deletion and active slot selection persist', () async {
    final repository = MemoryRunRepository();
    final controller = GameController(repository: repository);
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'First'),
    );
    controller.createCity(
      slotIndex: 1,
      configuration: CityRunConfiguration.defaults(cityName: 'Second'),
    );
    controller.continueCity(0);
    controller.deleteCity(0);
    await controller.flushSaves();

    final restored = GameController(repository: repository);
    await restored.restore();

    expect(restored.saveSlots[0], isNull);
    expect(restored.saveSlots[1]!.cityName, 'Second');
    expect(restored.activeSlotIndex, 1);

    controller.dispose();
    restored.dispose();
  });

  test('a failed local save can be retried without losing the run', () async {
    final repository = _FailOnceRunRepository();
    final controller = GameController(repository: repository);
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Retry City'),
    );
    await controller.flushSaves();

    expect(controller.persistenceError, isNotNull);
    expect(controller.isSaving, isFalse);
    expect(repository.value, isNull);

    controller.retryPersistence();
    await controller.flushSaves();

    expect(controller.persistenceError, isNull);
    expect(repository.value, isNotNull);
    expect(repository.value!.slots.first!.configuration.cityName, 'Retry City');
    controller.dispose();
  });
}

class _FailOnceRunRepository implements RunRepository {
  bool _shouldFail = true;
  GameSaveData? value;

  @override
  Future<GameSaveData?> load() async => value;

  @override
  Future<void> save(GameSaveData nextValue) async {
    if (_shouldFail) {
      _shouldFail = false;
      throw StateError('Simulated disk failure.');
    }
    value = GameSaveData.fromJson(nextValue.toJson());
  }

  @override
  Future<void> close() async {}
}
