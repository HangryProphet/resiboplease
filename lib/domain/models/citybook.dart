import 'city_problem.dart';

enum CityBookPostType {
  text,
  imageCaption,
  campaignAnnouncement,
  policyStatement,
  criticismResponse,
  accomplishmentClaim,
  eventAppearance,
  opponentAttack,
  clarification,
  apology,
  supportMessage,
  historical,
  slogan,
  publicServiceAnnouncement,
}

enum CityBookReaction { like, love, laugh, shock, sad, angry, receipt }

enum CityBookCommentArchetype {
  supporter,
  skepticalCitizen,
  angryResident,
  sarcasticCommenter,
  oppositionSupporter,
  campaignVolunteer,
  suspiciousAccount,
  affectedResident,
  confusedCommenter,
  jokeCommenter,
  policyFocusedCitizen,
  habitualCritic,
}

enum CityBookVisibility { public, resurfaced, archived }

enum CityBookSourceTruthRelation {
  publicClaim,
  candidateOpinion,
  documentedClaim,
  disputedClaim,
  correction,
}

class CityBookProfile {
  const CityBookProfile({
    required this.candidateId,
    required this.handle,
    required this.shortBio,
    required this.affiliation,
    required this.publicAttention,
    required this.profileAssetKey,
    required this.bannerAssetKey,
  });

  final String candidateId;
  final String handle;
  final String shortBio;
  final String affiliation;
  final int publicAttention;
  final String profileAssetKey;
  final String bannerAssetKey;
}

class CityBookReactionDistribution {
  const CityBookReactionDistribution(this.counts);

  final Map<CityBookReaction, int> counts;

  int countFor(CityBookReaction reaction) => counts[reaction] ?? 0;
  int get total => counts.values.fold(0, (sum, count) => sum + count);

  List<MapEntry<CityBookReaction, int>> get dominant =>
      counts.entries.where((entry) => entry.value > 0).toList(growable: false)
        ..sort((left, right) => right.value.compareTo(left.value));
}

class CityBookComment {
  const CityBookComment({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.archetype,
    required this.text,
    this.reactions = const CityBookReactionDistribution({}),
    this.accountClues = const [],
  });

  final String id;
  final String authorName;
  final String authorHandle;
  final CityBookCommentArchetype archetype;
  final String text;
  final CityBookReactionDistribution reactions;
  int get reactionCount => reactions.total;
  final List<String> accountClues;
}

class CityBookCommentThread {
  const CityBookCommentThread({required this.id, required this.comments});

  final String id;
  final List<CityBookComment> comments;
}

class CityBookPost {
  const CityBookPost({
    required this.id,
    required this.candidateId,
    required this.fictionalDate,
    required this.type,
    required this.text,
    required this.reactions,
    required this.commentThreadId,
    required this.visibility,
    required this.sourceTruthRelation,
    this.imageAssetKey,
    this.imageAspectRatio = 1,
    this.relatedIssueFamilies = const [],
    this.relatedEvidenceIds = const [],
    this.relatedNewsEventIds = const [],
    this.relatedDebateMessageIds = const [],
    this.comparisonId,
    this.historical = false,
  });

  final String id;
  final String candidateId;
  final String fictionalDate;
  final CityBookPostType type;
  final String text;
  final String? imageAssetKey;
  final double imageAspectRatio;
  final List<CityIssueFamily> relatedIssueFamilies;
  final List<String> relatedEvidenceIds;
  final List<String> relatedNewsEventIds;
  final List<String> relatedDebateMessageIds;
  final CityBookReactionDistribution reactions;
  final String commentThreadId;
  final bool historical;
  final CityBookVisibility visibility;
  final CityBookSourceTruthRelation sourceTruthRelation;
  final String? comparisonId;

  CityBookPost copyWith({List<String>? relatedNewsEventIds}) => CityBookPost(
    id: id,
    candidateId: candidateId,
    fictionalDate: fictionalDate,
    type: type,
    text: text,
    reactions: reactions,
    commentThreadId: commentThreadId,
    visibility: visibility,
    sourceTruthRelation: sourceTruthRelation,
    imageAssetKey: imageAssetKey,
    imageAspectRatio: imageAspectRatio,
    relatedIssueFamilies: relatedIssueFamilies,
    relatedEvidenceIds: relatedEvidenceIds,
    relatedNewsEventIds: relatedNewsEventIds ?? this.relatedNewsEventIds,
    relatedDebateMessageIds: relatedDebateMessageIds,
    comparisonId: comparisonId,
    historical: historical,
  );
}

class CityBookCatalog {
  const CityBookCatalog({
    required this.profiles,
    required this.posts,
    required this.commentThreads,
  });

  final Map<String, CityBookProfile> profiles;
  final List<CityBookPost> posts;
  final Map<String, CityBookCommentThread> commentThreads;

  CityBookProfile? profileFor(String candidateId) => profiles[candidateId];

  List<CityBookPost> postsFor(String candidateId) => posts
      .where((post) => post.candidateId == candidateId)
      .toList(growable: false);

  CityBookPost? postById(String id) {
    for (final post in posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  CityBookCommentThread? commentsFor(CityBookPost post) =>
      commentThreads[post.commentThreadId];
}
