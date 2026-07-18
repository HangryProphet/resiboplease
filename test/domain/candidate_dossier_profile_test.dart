import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/configuration/configured_scenario.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/candidate_dossier_profile.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';

void main() {
  group('candidate dossier profiles', () {
    test('contain evidence-facing tradeoffs without an aggregate score', () {
      final scenario = buildBayhavenScenario();

      for (final candidate in scenario.candidates) {
        final profile = buildCandidateDossierProfile(
          candidate: candidate,
          candidateField: CandidateField.mixed,
          seed: scenario.seed,
        );

        expect(profile.candidateId, candidate.id);
        expect(profile.strengths, hasLength(greaterThanOrEqualTo(2)));
        expect(profile.concerns, hasLength(greaterThanOrEqualTo(2)));
        expect(profile.uncertaintyEvidenceIds, isNotEmpty);
        expect(profile.hasRequiredTradeoffs, isTrue);
        expect(profile.evidenceSummary.totalItems, candidate.evidence.length);
        expect(profile.evidenceSummary.accountableRecords, greaterThan(0));
        expect(profile.evidenceSummary.campaignClaims, greaterThan(0));
        expect(profile.evidenceSummary.depth, DossierEvidenceDepth.documented);
      }
    });

    test('same run seed reproduces the same qualitative experience band', () {
      final scenario = buildBayhavenScenario(seed: 9001);
      final candidate = scenario.candidates.first;

      final first = buildCandidateDossierProfile(
        candidate: candidate,
        candidateField: CandidateField.mixed,
        seed: scenario.seed,
      );
      final second = buildCandidateDossierProfile(
        candidate: candidate,
        candidateField: CandidateField.mixed,
        seed: scenario.seed,
      );

      expect(second.experienceBand, first.experienceBand);
      expect(second.uncertaintyEvidenceIds, first.uncertaintyEvidenceIds);
    });

    test(
      'field choice constrains experience without implying a best choice',
      () {
        final scenario = buildBayhavenScenario(seed: 731);

        for (final candidate in scenario.candidates) {
          final unproven = buildCandidateDossierProfile(
            candidate: candidate,
            candidateField: CandidateField.unproven,
            seed: scenario.seed,
          );
          final seasoned = buildCandidateDossierProfile(
            candidate: candidate,
            candidateField: CandidateField.seasoned,
            seed: scenario.seed,
          );

          expect(
            unproven.experienceBand,
            isNot(DossierExperienceBand.established),
          );
          expect(
            seasoned.experienceBand,
            isNot(DossierExperienceBand.emerging),
          );
          expect(seasoned.strengths, unproven.strengths);
          expect(seasoned.concerns, unproven.concerns);
        }
      },
    );

    test(
      'campaign noise increases unresolved material, not suitability data',
      () {
        final base = buildBayhavenScenario();
        final typical = buildConfiguredScenario(
          base: base,
          configuration: CityRunConfiguration.defaults(),
        );
        final noisy = buildConfiguredScenario(
          base: base,
          configuration: CityRunConfiguration.defaults().copyWith(
            campaignNoise: CampaignNoise.noisy,
          ),
        );

        final typicalProfile = buildCandidateDossierProfile(
          candidate: typical.candidates.first,
          candidateField: CandidateField.mixed,
          seed: typical.seed,
        );
        final noisyProfile = buildCandidateDossierProfile(
          candidate: noisy.candidates.first,
          candidateField: CandidateField.mixed,
          seed: noisy.seed,
        );

        expect(
          noisyProfile.evidenceSummary.unresolvedItems,
          greaterThan(typicalProfile.evidenceSummary.unresolvedItems),
        );
        expect(noisyProfile.strengths, typicalProfile.strengths);
        expect(noisyProfile.concerns, typicalProfile.concerns);
      },
    );
  });
}
