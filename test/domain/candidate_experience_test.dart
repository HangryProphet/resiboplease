import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/seed_content/bayhaven_candidate_experience.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/candidate_experience.dart';

void main() {
  test('authored candidate experience has valid evidence relationships', () {
    final scenario = buildBayhavenScenario(seed: 5839201);
    final evidenceIds = {
      for (final candidate in scenario.candidates)
        for (final evidence in candidate.evidence) evidence.id,
    };

    expect(bayhavenCandidateExperience.validateRelations(evidenceIds), isEmpty);
    for (final topic in bayhavenCandidateExperience.debateTopics) {
      for (final message in topic.messages) {
        expect(
          message.referencedEvidenceIds.every(evidenceIds.contains),
          isTrue,
          reason: 'Broken debate evidence link in ${message.id}',
        );
        expect(
          message.contradictedByIds.every(evidenceIds.contains),
          isTrue,
          reason: 'Broken contradiction link in ${message.id}',
        );
      }
    }
  });

  test(
    'each candidate has a paced authored Pulse and unresolved questions',
    () {
      for (final profile in bayhavenCandidateExperience.profiles.values) {
        expect(profile.pulse.length, inInclusiveRange(5, 7));
        expect(profile.questions, isNotEmpty);
        expect(
          profile.pulse.any((item) => item.candidateResponse != null),
          isTrue,
        );
        expect(
          profile.pulse.any((item) => item.missingContext != null),
          isTrue,
        );
        expect(
          profile.evidenceCosts.values,
          everyElement(inInclusiveRange(0, 2)),
        );
      }
    },
  );

  test('authored biographies and promises vary while remaining connected', () {
    expect(bayhavenCandidateExperience.biographies, hasLength(3));
    expect(bayhavenCandidateExperience.promises, hasLength(9));
    expect(bayhavenCandidateExperience.comparisons, hasLength(3));

    final sectionCounts = bayhavenCandidateExperience.biographies.values
        .map((biography) => biography.sections.length)
        .toSet();
    expect(sectionCounts.length, greaterThan(1));

    for (final profile in bayhavenCandidateExperience.profiles.values) {
      final biography = bayhavenCandidateExperience.biographyFor(
        profile.candidateId,
      );
      expect(biography, isNotNull);
      expect(biography!.timeline.length, greaterThanOrEqualTo(6));
      expect(
        bayhavenCandidateExperience.promisesFor(profile.candidateId),
        hasLength(3),
      );
    }
  });

  test('debate contains three substantial authored topic histories', () {
    expect(bayhavenCandidateExperience.debateTopics, hasLength(3));
    for (final topic in bayhavenCandidateExperience.debateTopics) {
      expect(topic.messages.length, inInclusiveRange(8, 15));
      expect(
        topic.messages.any(
          (message) => message.type == DebateMessageType.moderator,
        ),
        isTrue,
      );
      expect(
        topic.messages.any(
          (message) => message.type == DebateMessageType.rebuttal,
        ),
        isTrue,
      );
      expect(
        topic.messages.any(
          (message) => message.referencedEvidenceIds.isNotEmpty,
        ),
        isTrue,
      );
    }
  });

  test('hidden quality allows genuinely different candidate quality bands', () {
    final bands = bayhavenCandidateExperience.profiles.values
        .map((profile) => profile.qualityBand)
        .toSet();

    expect(bands, contains(CandidateQualityBand.strong));
    expect(bands, contains(CandidateQualityBand.compromised));
    expect(bands, contains(CandidateQualityBand.dangerous));
  });
}
