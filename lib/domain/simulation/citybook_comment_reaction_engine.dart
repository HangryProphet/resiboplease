import '../models/citybook.dart';
import 'seeded_random.dart';

/// Generates a saved, deterministic social response from the comment's tone
/// and the parent post's actual reach. It never changes candidate truth.
class CityBookCommentReactionEngine {
  const CityBookCommentReactionEngine();

  CityBookReactionDistribution generate({
    required CityBookReactionDistribution parentReactions,
    required CityBookCommentArchetype archetype,
    required int seed,
    required int commentIndex,
  }) {
    final random = SeededRandom(seed);
    final parentTotal = parentReactions.total;
    if (parentTotal <= 0 || random.nextInt(100) < 18) {
      return const CityBookReactionDistribution({});
    }
    final standout = commentIndex < 3 && random.nextInt(100) < 16;
    final ratio = standout
        ? .28 + random.nextDouble() * .34
        : .015 + random.nextDouble() * (commentIndex < 4 ? .20 : .10);
    final total = (parentTotal * ratio).round().clamp(0, parentTotal);
    if (total < 2 && random.nextInt(2) == 0) {
      return const CityBookReactionDistribution({});
    }

    final weights = _weightsFor(archetype);
    final jittered = <CityBookReaction, double>{
      for (final entry in weights.entries)
        entry.key: entry.value * (.82 + random.nextDouble() * .36),
    };
    final weightTotal = jittered.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    var remaining = total;
    final counts = <CityBookReaction, int>{};
    final entries = jittered.entries.toList(growable: false);
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final count = index == entries.length - 1
          ? remaining
          : (total * entry.value / weightTotal).round().clamp(0, remaining);
      if (count > 0) counts[entry.key] = count;
      remaining -= count;
    }
    return CityBookReactionDistribution(Map.unmodifiable(counts));
  }

  Map<CityBookReaction, double> _weightsFor(
    CityBookCommentArchetype archetype,
  ) => switch (archetype) {
    CityBookCommentArchetype.sarcasticCommenter ||
    CityBookCommentArchetype.jokeCommenter => const {
      CityBookReaction.laugh: 5.4,
      CityBookReaction.like: 2.4,
      CityBookReaction.shock: 1.4,
      CityBookReaction.angry: .4,
    },
    CityBookCommentArchetype.angryResident ||
    CityBookCommentArchetype.habitualCritic ||
    CityBookCommentArchetype.oppositionSupporter => const {
      CityBookReaction.angry: 4.5,
      CityBookReaction.like: 2.4,
      CityBookReaction.sad: 1.6,
      CityBookReaction.laugh: .7,
    },
    CityBookCommentArchetype.affectedResident => const {
      CityBookReaction.love: 3.8,
      CityBookReaction.sad: 3.2,
      CityBookReaction.like: 2.5,
      CityBookReaction.angry: 1.0,
    },
    CityBookCommentArchetype.supporter ||
    CityBookCommentArchetype.campaignVolunteer => const {
      CityBookReaction.like: 5.0,
      CityBookReaction.love: 3.8,
      CityBookReaction.laugh: .6,
      CityBookReaction.receipt: .5,
    },
    CityBookCommentArchetype.suspiciousAccount => const {
      CityBookReaction.like: 3.2,
      CityBookReaction.laugh: 2.3,
      CityBookReaction.angry: 2.1,
      CityBookReaction.shock: 1.6,
    },
    CityBookCommentArchetype.confusedCommenter => const {
      CityBookReaction.shock: 3.0,
      CityBookReaction.like: 2.3,
      CityBookReaction.laugh: 1.7,
      CityBookReaction.sad: .8,
    },
    CityBookCommentArchetype.skepticalCitizen ||
    CityBookCommentArchetype.policyFocusedCitizen => const {
      CityBookReaction.like: 4.4,
      CityBookReaction.receipt: 2.6,
      CityBookReaction.shock: 1.1,
      CityBookReaction.angry: .7,
    },
  };
}

int cityBookReactionSeed(String value) {
  var hash = 0x811C9DC5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
