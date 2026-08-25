import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/domain/models/citybook.dart';
import 'package:resiboplease/domain/simulation/citybook_comment_reaction_engine.dart';

void main() {
  const engine = CityBookCommentReactionEngine();
  const parent = CityBookReactionDistribution({
    CityBookReaction.like: 640,
    CityBookReaction.love: 180,
    CityBookReaction.angry: 80,
  });

  test('comment reactions are deterministic and bounded by parent reach', () {
    final first = engine.generate(
      parentReactions: parent,
      archetype: CityBookCommentArchetype.skepticalCitizen,
      seed: cityBookReactionSeed('post:comment:0'),
      commentIndex: 0,
    );
    final second = engine.generate(
      parentReactions: parent,
      archetype: CityBookCommentArchetype.skepticalCitizen,
      seed: cityBookReactionSeed('post:comment:0'),
      commentIndex: 0,
    );

    expect(first.counts, second.counts);
    expect(first.total, lessThanOrEqualTo(parent.total));
    expect(first.dominant, isNotNull);
  });

  test(
    'reaction tone follows the comment archetype without changing truth',
    () {
      final sarcastic = engine.generate(
        parentReactions: parent,
        archetype: CityBookCommentArchetype.sarcasticCommenter,
        seed: cityBookReactionSeed('sarcastic-standout'),
        commentIndex: 0,
      );
      final supporter = engine.generate(
        parentReactions: parent,
        archetype: CityBookCommentArchetype.supporter,
        seed: cityBookReactionSeed('supporter-standout'),
        commentIndex: 0,
      );

      if (sarcastic.total > 0) {
        expect(
          sarcastic.counts[CityBookReaction.laugh] ?? 0,
          greaterThan(sarcastic.counts[CityBookReaction.angry] ?? 0),
        );
      }
      if (supporter.total > 0) {
        expect(
          supporter.counts[CityBookReaction.like] ?? 0,
          greaterThan(supporter.counts[CityBookReaction.angry] ?? 0),
        );
      }
    },
  );

  test('low-engagement and zero-reaction comments occur naturally', () {
    final totals = <int>[
      for (var index = 0; index < 80; index++)
        engine
            .generate(
              parentReactions: parent,
              archetype: CityBookCommentArchetype.confusedCommenter,
              seed: cityBookReactionSeed('comment-$index'),
              commentIndex: index,
            )
            .total,
    ];

    expect(totals, contains(0));
    expect(totals.where((total) => total > 0), isNotEmpty);
    expect(totals.every((total) => total <= parent.total), isTrue);
  });
}
