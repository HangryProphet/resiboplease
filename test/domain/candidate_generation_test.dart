import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/domain/models/candidate_experience.dart';
import 'package:resiboplease/domain/models/candidate_generation.dart';
import 'package:resiboplease/domain/models/candidate_name_registry.dart';

void main() {
  test('procedural blueprint roster is deterministic and unique', () {
    const generator = CandidateBlueprintGenerator();
    final first = generator.generateRoster(
      seed: 8102,
      count: 5,
      nameRegistry: CandidateNameRegistry(['Maya Vargas']),
    );
    final second = generator.generateRoster(
      seed: 8102,
      count: 5,
      nameRegistry: CandidateNameRegistry(['Maya Vargas']),
    );

    expect(first.map((item) => item.id), second.map((item) => item.id));
    expect(
      first.map((item) => item.displayName),
      second.map((item) => item.displayName),
    );
    expect(first.map((item) => item.displayName).toSet(), hasLength(5));
    expect(first.map((item) => item.partyName).toSet(), hasLength(5));
    expect(first.map((item) => item.slogan).toSet(), hasLength(5));
    expect(first.map((item) => item.identityKey).toSet(), hasLength(5));
  });

  test('generation permits a genuinely dangerous hidden candidate', () {
    const generator = CandidateBlueprintGenerator();
    CandidateGenerationBlueprint? dangerous;
    for (var seed = 1; seed < 100 && dangerous == null; seed++) {
      final roster = generator.generateRoster(
        seed: seed,
        count: 3,
        nameRegistry: CandidateNameRegistry(),
      );
      dangerous = roster
          .where(
            (item) => item.truth.qualityBand == CandidateQualityBand.dangerous,
          )
          .firstOrNull;
    }

    expect(dangerous, isNotNull);
    expect(
      dangerous!.truth.corruptionRisk,
      greaterThan(dangerous.truth.integrity),
    );
    expect(
      dangerous.narrativePlan.evidenceRelations,
      contains(EvidenceRelationType.contradicts),
    );
  });
}
