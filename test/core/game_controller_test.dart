import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/data/persistence/run_repository.dart';
import 'package:resiboplease/data/persistence/run_save_data.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';

void main() {
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

    controller.createCity(slotIndex: 1, configuration: configuration);

    expect(
      controller.activeConfiguration!.startingPressure,
      StartingPressure.crisis,
    );
    expect(controller.scenario.city.name, 'Harborlight');
    expect(controller.scenario.city.problems, hasLength(2));
    expect(controller.scenario.city.problems.first.id, 'food_costs');
    expect(controller.assistanceMode, AssistanceMode.standard);
    expect(controller.investigationPointLimit, 7);
    expect(controller.remainingInvestigationPoints, 7);
    expect(
      controller.scenario.candidates.first.evidence.length,
      greaterThan(5),
    );

    final savedConfiguration = controller.activeConfiguration;
    controller.restartSameSeed();

    expect(controller.activeConfiguration, same(savedConfiguration));
    expect(controller.scenario.city.name, 'Harborlight');
    expect(controller.scenario.city.problems, hasLength(2));
  });

  test('limited investigation prevents opening new paid evidence', () {
    final controller = GameController();
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(
        cityName: 'Seven Points',
      ).copyWith(investigationTime: InvestigationTime.limited),
    );

    final paidEvidence = controller.scenario.candidates
        .expand((candidate) => candidate.evidence)
        .where((item) => item.type.name != 'profile')
        .take(8)
        .toList(growable: false);
    final freeProfile = controller.scenario.candidates.first.evidence
        .firstWhere((item) => item.type.name == 'profile');

    for (final item in paidEvidence.take(7)) {
      expect(controller.markEvidenceViewed(item.id), isTrue);
    }
    expect(controller.remainingInvestigationPoints, 0);
    expect(controller.markEvidenceViewed(paidEvidence.last.id), isFalse);
    expect(controller.markEvidenceViewed(paidEvidence.first.id), isTrue);
    expect(controller.markEvidenceViewed(freeProfile.id), isTrue);
    expect(controller.markEvidenceViewed('missing_evidence'), isFalse);
    expect(controller.viewedEvidenceCount, 8);
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
    final candidate = controller.scenario.candidates.first;
    final evidence = candidate.evidence.firstWhere(
      (item) => item.type.name != 'profile',
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
      (item) => item.type.name != 'profile',
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
        'maya_publicRecord',
      },
      chargedEvidenceIds: {...clean.chargedEvidenceIds, 'stale_file'},
      selectedCandidateId: clean.selectedCandidateId,
      termResultReady: clean.termResultReady,
      revealedTermPhases: clean.revealedTermPhases,
      topIssue: clean.topIssue,
      confidence: clean.confidence,
      createdAt: clean.createdAt,
      updatedAt: clean.updatedAt,
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
