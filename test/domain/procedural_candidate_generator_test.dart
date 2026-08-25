import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/configuration/configured_scenario.dart';
import 'package:resiboplease/data/persistence/procedural_election_codec.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/candidate_portrait.dart';
import 'package:resiboplease/domain/models/candidate_generation.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/models/procedural_election.dart';
import 'package:resiboplease/domain/simulation/procedural_candidate_generator.dart';
import 'package:resiboplease/domain/simulation/seed_derivation.dart';

void main() {
  const generator = ProceduralCandidateGenerator();

  ProceduralElection generate(int seed) {
    final configuration = CityRunConfiguration.defaults(
      cityName: 'Seed City $seed',
    );
    final scenario = buildConfiguredScenario(
      base: buildBayhavenScenario(seed: seed),
      configuration: configuration,
      seed: seed,
    );
    return generator.generate(
      worldSeed: seed,
      city: scenario.city,
      candidateField: configuration.candidateField,
    );
  }

  test(
    'same seed and generation version produce the same complete election',
    () {
      final first = generate(812345);
      final second = generate(812345);

      expect(
        jsonEncode(ProceduralElectionCodec.encode(first)),
        jsonEncode(ProceduralElectionCodec.encode(second)),
      );
      expect(
        first.generationVersion,
        ProceduralCandidateGenerator.generationVersion,
      );
    },
  );

  test('different seeds normally produce different candidate rosters', () {
    final first = generate(12001);
    final second = generate(12002);

    expect(
      first.candidates.map((candidate) => candidate.name).toList(),
      isNot(second.candidates.map((candidate) => candidate.name).toList()),
    );
  });

  test(
    'a roster has five unique IDs, names, and gender-compatible portraits',
    () {
      final election = generate(5839201);

      expect(election.candidates, hasLength(5));
      expect(election.portraitIds, hasLength(5));
      expect(election.portraitIds.toSet(), hasLength(5));
      expect(
        election.candidates.map((candidate) => candidate.id).toSet(),
        hasLength(5),
      );
      expect(
        election.candidates.map((candidate) => candidate.name).toSet(),
        hasLength(5),
      );

      for (final candidate in election.candidates) {
        final profile = election.candidateExperience.profileFor(candidate.id)!;
        final portrait = candidatePortraitById(profile.portraitAssetKey)!;
        expect(
          ProceduralCandidateGenerator.isNameCompatibleWithGender(
            candidate.name,
            portrait.gender,
          ),
          isTrue,
          reason: '${candidate.name} should match ${portrait.gender.name}',
        );
      }
    },
  );

  test('sub-seeds are stable, path-specific, and generation-versioned', () {
    final identity = SeedDerivation.derive(
      worldSeed: 42,
      generationVersion: 1,
      path: 'candidate:0:identity',
    );

    expect(
      identity,
      SeedDerivation.derive(
        worldSeed: 42,
        generationVersion: 1,
        path: 'candidate:0:identity',
      ),
    );
    expect(
      identity,
      isNot(
        SeedDerivation.derive(
          worldSeed: 42,
          generationVersion: 1,
          path: 'candidate:0:citybook',
        ),
      ),
    );
    expect(
      identity,
      isNot(
        SeedDerivation.derive(
          worldSeed: 42,
          generationVersion: 2,
          path: 'candidate:0:identity',
        ),
      ),
    );
  });

  test('candidate generation does not mutate or reroll city issues', () {
    const seed = 775533;
    final configuration = CityRunConfiguration.defaults(
      cityName: 'Isolated City',
    );
    final before = buildConfiguredScenario(
      base: buildBayhavenScenario(seed: seed),
      configuration: configuration,
      seed: seed,
    );

    generator.generate(
      worldSeed: seed,
      city: before.city,
      candidateField: configuration.candidateField,
    );
    final after = buildConfiguredScenario(
      base: buildBayhavenScenario(seed: seed),
      configuration: configuration,
      seed: seed,
    );

    expect(
      before.city.problems.map((problem) => problem.id).toList(),
      after.city.problems.map((problem) => problem.id).toList(),
    );
    expect(
      before.city.problems.map((problem) => problem.severity).toList(),
      after.city.problems.map((problem) => problem.severity).toList(),
    );
  });

  test('campaign noise changes public volume without rerolling identities', () {
    const seed = 334455;
    final configuration = CityRunConfiguration.defaults(
      cityName: 'Signal City',
    );
    final scenario = buildConfiguredScenario(
      base: buildBayhavenScenario(seed: seed),
      configuration: configuration,
      seed: seed,
    );
    final clear = generator.generate(
      worldSeed: seed,
      city: scenario.city,
      candidateField: configuration.candidateField,
      campaignNoise: CampaignNoise.clear,
    );
    final noisy = generator.generate(
      worldSeed: seed,
      city: scenario.city,
      candidateField: configuration.candidateField,
      campaignNoise: CampaignNoise.noisy,
    );

    expect(
      clear.candidates.map((candidate) => (candidate.id, candidate.name)),
      noisy.candidates.map((candidate) => (candidate.id, candidate.name)),
    );
    expect(clear.portraitIds, noisy.portraitIds);
    expect(
      noisy.cityBook.posts.length,
      greaterThanOrEqualTo(clear.cityBook.posts.length),
    );
  });

  test('all generated cross-system references resolve', () {
    final election = generate(991177);
    final issueFamilies = buildConfiguredScenario(
      base: buildBayhavenScenario(seed: 991177),
      configuration: CityRunConfiguration.defaults(
        cityName: 'Seed City 991177',
      ),
      seed: 991177,
    ).city.problems.map((problem) => problem.family).toSet();

    expect(election.validate(), isEmpty);
    for (final promise in election.candidateExperience.promises) {
      expect(promise.relatedIssueFamilies, everyElement(isIn(issueFamilies)));
    }
  });

  test('the full procedural election survives a codec round trip', () {
    final initial = generate(456789);
    final restored = ProceduralElectionCodec.decode(
      ProceduralElectionCodec.encode(initial),
    );

    expect(restored.validate(), isEmpty);
    expect(
      jsonEncode(ProceduralElectionCodec.encode(restored)),
      jsonEncode(ProceduralElectionCodec.encode(initial)),
    );
  });

  test('career origins vary by seed and are not assigned to fixed slots', () {
    final allOrigins = <CandidateCareerOrigin>{};
    final originsBySlot = <int, Set<CandidateCareerOrigin>>{};
    var rosterWithoutCelebrity = false;
    for (var seed = 61000; seed < 61060; seed++) {
      final election = generate(seed);
      final origins = election.candidates
          .map(
            (candidate) => election.truthProfiles[candidate.id]!.careerOrigin,
          )
          .toList();
      allOrigins.addAll(origins);
      rosterWithoutCelebrity |= !origins.contains(
        CandidateCareerOrigin.celebrityMedia,
      );
      for (var index = 0; index < origins.length; index++) {
        originsBySlot.putIfAbsent(index, () => {}).add(origins[index]);
      }
    }

    expect(allOrigins, contains(CandidateCareerOrigin.careerPolitician));
    expect(allOrigins, contains(CandidateCareerOrigin.professional));
    expect(allOrigins, contains(CandidateCareerOrigin.business));
    expect(allOrigins, contains(CandidateCareerOrigin.celebrityMedia));
    expect(allOrigins, contains(CandidateCareerOrigin.community));
    expect(rosterWithoutCelebrity, isTrue);
    expect(originsBySlot.values.every((origins) => origins.length > 2), isTrue);
  });

  test('origin changes the evidence footprint but does not define quality', () {
    final qualityByOrigin = <CandidateCareerOrigin, Set<Object>>{};
    ProceduralElection? withCelebrity;
    for (var seed = 72000; seed < 72080; seed++) {
      final election = generate(seed);
      for (final truth in election.truthProfiles.values) {
        qualityByOrigin
            .putIfAbsent(truth.careerOrigin, () => {})
            .add(truth.qualityBand);
        if (truth.careerOrigin == CandidateCareerOrigin.celebrityMedia) {
          withCelebrity ??= election;
        }
      }
    }

    expect(
      qualityByOrigin.values.any((qualities) => qualities.length > 1),
      isTrue,
    );
    final celebrity = withCelebrity!;
    final celebrityId = celebrity.truthProfiles.entries
        .firstWhere(
          (entry) =>
              entry.value.careerOrigin == CandidateCareerOrigin.celebrityMedia,
        )
        .key;
    final celebrityCandidate = celebrity.candidates.firstWhere(
      (candidate) => candidate.id == celebrityId,
    );
    expect(
      celebrityCandidate.evidence.map((item) => item.source),
      contains('Fictional Broadcast and Charity Archive'),
    );
  });
}
