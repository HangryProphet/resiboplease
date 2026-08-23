import 'candidate.dart';
import 'candidate_experience.dart';
import 'candidate_generation.dart';
import 'citybook.dart';
import 'news_media.dart';

/// Complete generated election snapshot. The seed creates this once; saves
/// persist it and restore these exact objects instead of rerolling them.
class ProceduralElection {
  const ProceduralElection({
    required this.generationVersion,
    required this.portraitIds,
    required this.candidates,
    required this.truthProfiles,
    required this.candidateExperience,
    required this.cityBook,
    required this.candidateNewsEvents,
    required this.candidateNewsCoverages,
  });

  final int generationVersion;
  final List<String> portraitIds;
  final List<Candidate> candidates;
  final Map<String, CandidateTruthProfile> truthProfiles;
  final CandidateExperienceCatalog candidateExperience;
  final CityBookCatalog cityBook;
  final List<UnderlyingNewsEvent> candidateNewsEvents;
  final List<NewsCoverage> candidateNewsCoverages;

  List<String> validate() {
    final errors = <String>[];
    final candidateIds = candidates.map((candidate) => candidate.id).toSet();
    final evidenceIds = candidates
        .expand((candidate) => candidate.evidence)
        .map((evidence) => evidence.id)
        .toSet();
    if (candidates.length != 5) {
      errors.add('A procedural mayoral election must contain five candidates.');
    }
    if (portraitIds.length != 5 || portraitIds.toSet().length != 5) {
      errors.add('Portrait assignments must contain five unique identities.');
    }
    if (candidateIds.length != candidates.length) {
      errors.add('Candidate IDs must be unique.');
    }
    if (candidates.map((item) => item.name.toLowerCase()).toSet().length !=
        candidates.length) {
      errors.add('Candidate full names must be unique.');
    }
    if (truthProfiles.keys.toSet().difference(candidateIds).isNotEmpty ||
        candidateIds.difference(truthProfiles.keys.toSet()).isNotEmpty) {
      errors.add('Truth profiles must exactly match the candidate roster.');
    }
    if (candidateExperience.profiles.keys
            .toSet()
            .difference(candidateIds)
            .isNotEmpty ||
        candidateIds
            .difference(candidateExperience.profiles.keys.toSet())
            .isNotEmpty) {
      errors.add(
        'Experience profiles must exactly match the candidate roster.',
      );
    }
    if (cityBook.profiles.keys.toSet().difference(candidateIds).isNotEmpty ||
        candidateIds.difference(cityBook.profiles.keys.toSet()).isNotEmpty) {
      errors.add('CityBook profiles must exactly match the candidate roster.');
    }
    if (candidateExperience.biographies.keys
            .toSet()
            .difference(candidateIds)
            .isNotEmpty ||
        candidateIds
            .difference(candidateExperience.biographies.keys.toSet())
            .isNotEmpty) {
      errors.add('Biographies must exactly match the candidate roster.');
    }
    final assignedPortraitIds = candidateExperience.profiles.values
        .map((profile) => profile.portraitAssetKey)
        .toList(growable: false);
    if (assignedPortraitIds.length != assignedPortraitIds.toSet().length ||
        assignedPortraitIds
            .toSet()
            .difference(portraitIds.toSet())
            .isNotEmpty ||
        portraitIds
            .toSet()
            .difference(assignedPortraitIds.toSet())
            .isNotEmpty) {
      errors.add('Profile portrait assignments must match the unique roster.');
    }
    for (final promise in candidateExperience.promises) {
      if (!candidateIds.contains(promise.candidateId)) {
        errors.add('Promise ${promise.id} has an unknown candidate.');
      }
    }
    for (final comparison in candidateExperience.comparisons) {
      if (!candidateIds.contains(comparison.candidateId)) {
        errors.add('Comparison ${comparison.id} has an unknown candidate.');
      }
    }
    errors.addAll(candidateExperience.validateRelations(evidenceIds));
    for (final post in cityBook.posts) {
      if (!candidateIds.contains(post.candidateId)) {
        errors.add('CityBook post ${post.id} has an unknown candidate.');
      }
      for (final evidenceId in post.relatedEvidenceIds) {
        if (!evidenceIds.contains(evidenceId)) {
          errors.add(
            'CityBook post ${post.id} has missing evidence $evidenceId.',
          );
        }
      }
      if (!cityBook.commentThreads.containsKey(post.commentThreadId)) {
        errors.add('CityBook post ${post.id} has no comment thread.');
      }
    }
    for (final event in candidateNewsEvents) {
      for (final candidateId in event.relatedCandidateIds) {
        if (!candidateIds.contains(candidateId)) {
          errors.add('News event ${event.id} has an unknown candidate.');
        }
      }
      for (final evidenceId in event.evidenceIds) {
        if (!evidenceIds.contains(evidenceId)) {
          errors.add(
            'News event ${event.id} has missing evidence $evidenceId.',
          );
        }
      }
    }
    final eventIds = candidateNewsEvents.map((event) => event.id).toSet();
    for (final coverage in candidateNewsCoverages) {
      if (!eventIds.contains(coverage.eventId)) {
        errors.add('Coverage ${coverage.id} has an unknown event.');
      }
    }
    return errors;
  }
}
