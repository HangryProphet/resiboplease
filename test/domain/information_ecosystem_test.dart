import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/data/persistence/run_repository.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/models/information_reference.dart';
import 'package:resiboplease/domain/models/pre_election_city_brief.dart';

void main() {
  test('one Chronicle event receives three distinct outlet framings', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    final ecosystem = controller.informationEcosystem;

    expect(ecosystem.news.outlets, hasLength(3));
    expect(
      ecosystem.news.outlets.map((outlet) => outlet.name).toSet(),
      hasLength(3),
    );

    final chronicle = controller.preElectionBrief.news.firstWhere(
      (item) => item.kind == ChronicleStoryKind.issue,
    );
    final event = ecosystem.news.eventForChronicle(chronicle.id);
    expect(event, isNotNull);
    final coverage = ecosystem.news.coverageForEvent(event!.id);
    expect(coverage, hasLength(3));
    expect(coverage.map((article) => article.headline).toSet(), hasLength(3));
    expect(coverage.every((article) => article.eventId == event.id), isTrue);
  });

  test(
    'CityBook profiles, reactions, comments, and historical posts connect',
    () {
      final controller = GameController(activeRun: true);
      addTearDown(controller.dispose);
      final ecosystem = controller.informationEcosystem;
      final evidenceIds = {
        for (final candidate in controller.scenario.candidates)
          for (final evidence in candidate.evidence) evidence.id,
      };
      final commentThreadSignatures = <String>{};

      expect(ecosystem.cityBook.profiles, hasLength(3));
      for (final candidate in controller.scenario.candidates) {
        final posts = ecosystem.cityBook.postsFor(candidate.id);
        expect(posts, hasLength(4));
        expect(posts.any((post) => post.historical), isTrue);
        for (final post in posts) {
          expect(post.reactions.total, greaterThan(0));
          final comments = ecosystem.cityBook.commentsFor(post)!.comments;
          expect(comments, hasLength(10));
          expect(
            comments.map((comment) => comment.text).toSet(),
            hasLength(10),
          );
          expect(
            comments.map((comment) => comment.authorHandle).toSet(),
            hasLength(10),
          );
          commentThreadSignatures.add(
            comments.map((comment) => comment.text).join('|'),
          );
          expect(post.relatedEvidenceIds.every(evidenceIds.contains), isTrue);
        }
      }
      expect(
        commentThreadSignatures,
        hasLength(ecosystem.cityBook.posts.length),
      );
      expect(
        ecosystem.relationships.any(
          (relation) =>
              relation.from.kind == InformationArtifactKind.cityBookPost &&
              relation.to.kind == InformationArtifactKind.evidence,
        ),
        isTrue,
      );
    },
  );

  test('information ecosystem is stable for the same world seed', () {
    final firstController = GameController(activeRun: true);
    final secondController = GameController(activeRun: true);
    addTearDown(firstController.dispose);
    addTearDown(secondController.dispose);

    final first = firstController.informationEcosystem;
    final second = secondController.informationEcosystem;
    expect(
      first.news.outlets.map((outlet) => outlet.name),
      orderedEquals(second.news.outlets.map((outlet) => outlet.name)),
    );
    expect(
      first.news.coverages.map((coverage) => coverage.headline),
      orderedEquals(second.news.coverages.map((coverage) => coverage.headline)),
    );
    expect(
      first.cityBook.posts.map((post) => post.id),
      orderedEquals(second.cityBook.posts.map((post) => post.id)),
    );
    expect(
      first.tvBroadcasts.broadcasts.map((broadcast) => broadcast.id),
      orderedEquals(
        second.tvBroadcasts.broadcasts.map((broadcast) => broadcast.id),
      ),
    );
  });

  test('TV reports reuse underlying event truth and shared media', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    final ecosystem = controller.informationEcosystem;

    expect(ecosystem.tvBroadcasts.broadcasts.length, inInclusiveRange(2, 3));
    for (final broadcast in ecosystem.tvBroadcasts.broadcasts) {
      final event = ecosystem.news.eventById(broadcast.underlyingEventId);
      expect(event, isNotNull);
      expect(broadcast.visualAssetKey, event!.imageAssetKey);
      expect(broadcast.dialoguePages, hasLength(5));
      expect(
        broadcast.dialoguePages.every(
          (page) =>
              page.text.english.isNotEmpty && page.text.filipino.isNotEmpty,
        ),
        isTrue,
      );
      expect(
        broadcast.relatedArticleIds,
        orderedEquals(
          ecosystem.news
              .coverageForEvent(event.id)
              .map((coverage) => coverage.id),
        ),
      );
      expect(
        broadcast.dialoguePages[1].text.english,
        contains('${event.publicImpact}'),
      );
    }
  });

  test(
    'outlets, posts, and headlines remain stable after save restore',
    () async {
      final repository = MemoryRunRepository();
      final source = GameController(repository: repository);
      source.createCity(
        slotIndex: 0,
        configuration: CityRunConfiguration.defaults(
          cityName: 'Media Test City',
        ),
        worldSeed: 841902,
      );
      final before = source.informationEcosystem;
      await source.flushSaves();

      final restored = GameController(repository: repository);
      await restored.restore();
      final after = restored.informationEcosystem;

      expect(
        after.news.outlets.map((outlet) => outlet.name),
        orderedEquals(before.news.outlets.map((outlet) => outlet.name)),
      );
      expect(
        after.news.coverages.map((coverage) => coverage.headline),
        orderedEquals(
          before.news.coverages.map((coverage) => coverage.headline),
        ),
      );
      expect(
        after.cityBook.posts.map((post) => post.id),
        orderedEquals(before.cityBook.posts.map((post) => post.id)),
      );
      expect(
        after.tvBroadcasts.broadcasts.map((broadcast) => broadcast.id),
        orderedEquals(
          before.tvBroadcasts.broadcasts.map((broadcast) => broadcast.id),
        ),
      );

      source.dispose();
      restored.dispose();
    },
  );
}
