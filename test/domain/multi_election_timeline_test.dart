import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/data/persistence/run_repository.dart';
import 'package:resiboplease/data/persistence/run_save_data.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/models/evidence_item.dart';

void main() {
  test(
    'completed city continues through two administrations into election three',
    () async {
      final repository = MemoryRunRepository();
      final controller = GameController(repository: repository);
      addTearDown(controller.dispose);
      controller.createCity(
        slotIndex: 0,
        configuration: CityRunConfiguration.defaults(
          cityName: 'Continuity City',
        ),
        worldSeed: 8262026,
      );

      final firstElectionIds = controller.scenario.candidates
          .map((candidate) => candidate.id)
          .toSet();
      final firstElectionNames = {
        for (final candidate in controller.scenario.candidates)
          candidate.id: candidate.name,
      };
      final firstElectionPortraits = {
        for (final candidate in controller.scenario.candidates)
          candidate.id: controller.candidateExperience
              .profileFor(candidate.id)!
              .portraitAssetKey,
      };
      final firstMayor = controller.scenario.candidates.first;
      expect(controller.togglePrediction('health_access'), isTrue);
      expect(controller.togglePrediction('budget_protection'), isTrue);
      expect(controller.togglePrediction('public_trust'), isFalse);
      final firstMayorPortrait = controller.candidateExperience
          .profileFor(firstMayor.id)!
          .portraitAssetKey;
      controller.castVote(
        candidate: firstMayor,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .72,
      );
      _completeTerm(controller);
      final firstFinalIndicators = controller.termResult!.after;
      final firstFinalIssues =
          controller.termResult!.livingCity.finalIssueStates;

      controller.continueToNextElection();

      expect(controller.currentElectionNumber, 2);
      expect(controller.administrationHistory, hasLength(1));
      expect(
        controller.administrationHistory.single.electedCandidateId,
        firstMayor.id,
      );
      expect(
        controller.administrationHistory.single.investigation.predictionIds,
        {'health_access', 'budget_protection'},
      );
      expect(controller.predictionIds, isEmpty);
      expect(controller.scenario.city.indicators, firstFinalIndicators);
      for (final problem in controller.scenario.city.problems) {
        final inheritedState = firstFinalIssues[problem.id];
        if (inheritedState == null) {
          expect(problem.tags, contains('emerged'));
        } else {
          expect(problem.severity, inheritedState.severity);
          expect(problem.trend, inheritedState.trend);
        }
      }
      expect(controller.selectedCandidate, isNull);
      expect(controller.scenario.candidates, hasLength(5));
      final secondElectionIds = controller.scenario.candidates
          .map((candidate) => candidate.id)
          .toSet();
      final secondElectionProblemIds = controller.scenario.city.problems
          .map((problem) => problem.id)
          .toList(growable: false);
      final secondElectionCitySummary = controller.scenario.city.summary;
      expect(secondElectionIds, contains(firstMayor.id));
      expect(firstElectionIds.intersection(secondElectionIds), hasLength(2));
      final satOutElectionTwo = firstElectionIds.difference(secondElectionIds);
      expect(satOutElectionTwo, hasLength(3));
      expect(
        controller.candidateExperience
            .profileFor(firstMayor.id)!
            .portraitAssetKey,
        firstMayorPortrait,
      );
      final returningMayor = controller.candidateById(firstMayor.id);
      expect(returningMayor.biography, contains('Administration 1'));
      final governingRecord = returningMayor.evidence.singleWhere(
        (item) => item.type == EvidenceType.publicRecord,
      );
      expect(governingRecord.title, contains('Administration 1'));
      expect(governingRecord.details, contains('sealed Administration 1'));
      expect(
        controller.candidateExperience
            .profileFor(firstMayor.id)!
            .publicIdentity,
        contains('Former mayor'),
      );
      final returningBiography = controller.candidateExperience.biographyFor(
        firstMayor.id,
      )!;
      expect(
        returningBiography.sections.map((section) => section.title),
        contains('Administration 1'),
      );
      expect(
        returningBiography.timeline.map((event) => event.id),
        contains('${firstMayor.id}_administration_1'),
      );
      expect(
        controller.candidateExperience
            .promisesFor(firstMayor.id)
            .first
            .candidateWording,
        contains('Administration 1 receipt'),
      );
      final returningDebateAnswer = controller.candidateExperience.debateTopics
          .expand((topic) => topic.messages)
          .firstWhere((message) => message.speakerId == firstMayor.id);
      expect(returningDebateAnswer.text, contains('Administration 1 receipt'));
      expect(
        controller.informationEcosystem.cityBook
            .profileFor(firstMayor.id)!
            .shortBio,
        contains('Administration 1'),
      );
      expect(
        controller.informationEcosystem.cityBook
            .postsFor(firstMayor.id)
            .map((post) => post.text)
            .join(' '),
        contains('Administration 1'),
      );
      final recordNews = controller.informationEcosystem.news.events.firstWhere(
        (item) =>
            item.relatedCandidateIds.contains(firstMayor.id) &&
            item.title.contains('Administration 1'),
      );
      expect(recordNews.title, contains('Administration 1'));

      await controller.flushSaves();
      final restoredElectionTwo = GameController(repository: repository);
      addTearDown(restoredElectionTwo.dispose);
      await restoredElectionTwo.restore();
      expect(restoredElectionTwo.currentElectionNumber, 2);
      expect(restoredElectionTwo.administrationHistory, hasLength(1));
      expect(
        restoredElectionTwo.scenario.city.indicators,
        firstFinalIndicators,
      );
      expect(
        restoredElectionTwo.scenario.candidates.map((item) => item.id),
        orderedEquals(controller.scenario.candidates.map((item) => item.id)),
      );
      expect(
        restoredElectionTwo.scenario.city.problems.map((problem) => problem.id),
        orderedEquals(secondElectionProblemIds),
      );
      expect(
        restoredElectionTwo.scenario.city.summary,
        secondElectionCitySummary,
      );

      final returningIncumbent = restoredElectionTwo.candidateById(
        firstMayor.id,
      );
      restoredElectionTwo.castVote(
        candidate: returningIncumbent,
        topIssue: restoredElectionTwo.scenario.city.problems.first.id,
        confidence: .61,
      );
      await restoredElectionTwo.flushSaves();

      final restoredDuringSecondAdministration = GameController(
        repository: repository,
      );
      addTearDown(restoredDuringSecondAdministration.dispose);
      await restoredDuringSecondAdministration.restore();
      expect(restoredDuringSecondAdministration.currentElectionNumber, 2);
      expect(
        restoredDuringSecondAdministration.selectedCandidate?.id,
        firstMayor.id,
      );
      expect(
        restoredDuringSecondAdministration.administrationHistory,
        hasLength(1),
      );
      _completeTerm(restoredDuringSecondAdministration);
      restoredDuringSecondAdministration.continueToNextElection();

      expect(restoredDuringSecondAdministration.currentElectionNumber, 3);
      expect(
        restoredDuringSecondAdministration.administrationHistory,
        hasLength(2),
      );
      expect(
        restoredDuringSecondAdministration.administrationHistory.map(
          (record) => record.electedCandidateId,
        ),
        everyElement(firstMayor.id),
      );
      expect(
        restoredDuringSecondAdministration.scenario.candidates.map(
          (item) => item.id,
        ),
        isNot(contains(firstMayor.id)),
        reason:
            'The fictional charter limits a mayor to two consecutive terms.',
      );
      final electionThreeIds = restoredDuringSecondAdministration
          .scenario
          .candidates
          .map((candidate) => candidate.id)
          .toSet();
      final comebackIds = electionThreeIds.intersection(satOutElectionTwo);
      expect(
        comebackIds,
        hasLength(1),
        reason:
            'Election 3 should surface one archived candidate who sat out Election 2.',
      );
      final comebackId = comebackIds.single;
      final comeback = restoredDuringSecondAdministration.candidateById(
        comebackId,
      );
      expect(comeback.name, firstElectionNames[comebackId]);
      expect(
        restoredDuringSecondAdministration.candidateExperience
            .profileFor(comebackId)!
            .portraitAssetKey,
        firstElectionPortraits[comebackId],
      );
      expect(comeback.biography, contains('Election 1 ballot'));
      final comebackRecord = comeback.evidence.singleWhere(
        (item) => item.type == EvidenceType.publicRecord,
      );
      expect(comebackRecord.title, contains('Election 1 ballot record'));
      expect(comebackRecord.details, contains('earlier loss'));
      final comebackBiography = restoredDuringSecondAdministration
          .candidateExperience
          .biographyFor(comebackId)!;
      expect(
        comebackBiography.sections.map((section) => section.title),
        contains('Previous Campaigns'),
      );
      expect(
        comebackBiography.timeline.map((event) => event.id),
        contains('${comebackId}_election_1'),
      );
      expect(
        restoredDuringSecondAdministration.informationEcosystem.cityBook
            .profileFor(comebackId)!
            .shortBio,
        contains('Election 1 ballot record'),
      );

      await restoredDuringSecondAdministration.flushSaves();
      final restoredElectionThree = GameController(repository: repository);
      addTearDown(restoredElectionThree.dispose);
      await restoredElectionThree.restore();
      expect(restoredElectionThree.currentElectionNumber, 3);
      expect(restoredElectionThree.administrationHistory, hasLength(2));
      expect(restoredElectionThree.selectedCandidate, isNull);
      expect(
        restoredElectionThree.scenario.candidates
            .firstWhere((candidate) => candidate.id == comebackId)
            .name,
        firstElectionNames[comebackId],
      );
    },
  );

  test('a different winner can govern the second administration', () {
    final controller = GameController();
    addTearDown(controller.dispose);
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(cityName: 'Change City'),
      worldSeed: 13579,
    );
    final firstMayor = controller.scenario.candidates.first;
    controller.castVote(
      candidate: firstMayor,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .5,
    );
    _completeTerm(controller);
    controller.continueToNextElection();

    final challenger = controller.scenario.candidates.firstWhere(
      (candidate) => candidate.id != firstMayor.id,
    );
    controller.castVote(
      candidate: challenger,
      topIssue: controller.scenario.city.problems.last.id,
      confidence: .58,
    );
    _completeTerm(controller);
    controller.continueToNextElection();

    expect(controller.currentElectionNumber, 3);
    expect(
      controller.administrationHistory
          .map((record) => record.electedCandidateId)
          .toList(),
      [firstMayor.id, challenger.id],
    );
  });

  test(
    'a completed schema-eight save migrates into one administration',
    () async {
      final repository = MemoryRunRepository();
      final controller = GameController(repository: repository);
      addTearDown(controller.dispose);
      controller.createCity(
        slotIndex: 0,
        configuration: CityRunConfiguration.defaults(cityName: 'Legacy City'),
        worldSeed: 24680,
      );
      controller.castVote(
        candidate: controller.scenario.candidates.first,
        topIssue: controller.scenario.city.problems.first.id,
        confidence: .66,
      );
      _completeTerm(controller);
      await controller.flushSaves();

      final versionNine = (await repository.load())!;
      final legacyJson = versionNine.toJson()..['schema_version'] = 8;
      final slots = legacyJson['slots']! as List<Object?>;
      final legacySlot = Map<String, Object?>.from(slots.first! as Map)
        ..remove('administration_history')
        ..remove('current_issue_states');
      slots[0] = legacySlot;

      final migrated = GameSaveData.fromJson(legacyJson);
      final run = migrated.slots.first!;
      expect(run.administrationHistory, hasLength(1));
      expect(run.administrationHistory.single.termNumber, 1);
      expect(
        run.administrationHistory.single.electedCandidateId,
        controller.selectedCandidate!.id,
      );
      expect(run.currentIssueStates, isNotEmpty);

      final migratedRepository = MemoryRunRepository(initialValue: migrated);
      final restored = GameController(repository: migratedRepository);
      addTearDown(restored.dispose);
      await restored.restore();
      restored.continueToNextElection();
      expect(restored.currentElectionNumber, 2);
      expect(restored.administrationHistory, hasLength(1));
      await restored.flushSaves();
    },
  );
}

void _completeTerm(GameController controller) {
  while (!controller.isTermReportReady) {
    controller.advanceTerm();
  }
}
