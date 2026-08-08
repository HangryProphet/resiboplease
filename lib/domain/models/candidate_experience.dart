import 'candidate_biography.dart';
import 'city_problem.dart';

enum CandidateQualityBand { strong, compromised, mixed, weak, dangerous }

enum CandidateRhetoricalStyle {
  technical,
  charismatic,
  storyDriven,
  aggressive,
  calm,
  evasive,
  sarcastic,
  emotional,
  statisticHeavy,
  attackFocused,
  conciliatory,
}

enum CandidateContentType {
  campaignAd,
  news,
  speech,
  socialPost,
  poll,
  endorsement,
  residentReaction,
  protestReaction,
  scandal,
  correction,
  factCheckAlert,
  meme,
  publicEvent,
  statement,
}

enum EvidenceRelationType {
  supports,
  contradicts,
  addsContext,
  updates,
  corrects,
  disputes,
  references,
  revealsConsequence,
  exposesMissingInformation,
}

enum DebateMessageType {
  moderator,
  claim,
  response,
  rebuttal,
  interruption,
  clarification,
  recordCheck,
  reaction,
}

enum PublicReaction { positive, mixed, skeptical, negative, surprised }

enum ReceiptKind {
  supportedClaim,
  contradictedClaim,
  partiallySupported,
  missingContext,
  unresolvedAllegation,
  promiseWithoutFunding,
  accomplishmentWithCost,
  statementVersusRecord,
  debateVersusFactCheck,
}

enum CandidateMediaType { image, document, socialPost, videoStill }

class CandidateMedia {
  const CandidateMedia({
    required this.assetKey,
    required this.aspectRatio,
    required this.altText,
    required this.caption,
    required this.type,
    this.isAvailable = false,
    this.alignmentX = 0,
    this.alignmentY = 0,
  });

  final String assetKey;
  final double aspectRatio;
  final String altText;
  final String caption;
  final CandidateMediaType type;
  final bool isAvailable;
  final double alignmentX;
  final double alignmentY;
}

class CandidateContentItem {
  const CandidateContentItem({
    required this.id,
    required this.candidateId,
    required this.type,
    required this.headline,
    required this.summary,
    required this.inspectBody,
    required this.deepDivePrompt,
    required this.source,
    required this.fictionalDate,
    required this.cityIssueId,
    required this.relatedEvidenceIds,
    required this.receiptKind,
    this.candidateResponse,
    this.missingContext,
    this.keyFigures = const [],
    this.media,
    this.publicAttention = 0,
  });

  final String id;
  final String candidateId;
  final CandidateContentType type;
  final String headline;
  final String summary;
  final String inspectBody;
  final String deepDivePrompt;
  final String source;
  final String fictionalDate;
  final String cityIssueId;
  final List<String> relatedEvidenceIds;
  final ReceiptKind receiptKind;
  final String? candidateResponse;
  final String? missingContext;
  final List<String> keyFigures;
  final CandidateMedia? media;
  final int publicAttention;
}

class EvidenceRelation {
  const EvidenceRelation({
    required this.fromEvidenceId,
    required this.toEvidenceId,
    required this.type,
    required this.explanation,
    this.unlocksTarget = false,
  });

  final String fromEvidenceId;
  final String toEvidenceId;
  final EvidenceRelationType type;
  final String explanation;
  final bool unlocksTarget;
}

class CandidateQuestion {
  const CandidateQuestion({
    required this.id,
    required this.text,
    required this.cityIssueId,
    required this.relatedEvidenceIds,
  });

  final String id;
  final String text;
  final String cityIssueId;
  final List<String> relatedEvidenceIds;
}

class CandidateExperienceProfile {
  const CandidateExperienceProfile({
    required this.candidateId,
    required this.identityKey,
    required this.portraitAssetKey,
    required this.publicIdentity,
    required this.position,
    required this.rhetoricalStyle,
    required this.qualityBand,
    required this.questions,
    required this.pulse,
    required this.relations,
    required this.evidenceCosts,
  });

  final String candidateId;
  final String identityKey;
  final String portraitAssetKey;
  final String publicIdentity;
  final String position;
  final CandidateRhetoricalStyle rhetoricalStyle;

  /// Simulation-only generation metadata. Never render this value.
  final CandidateQualityBand qualityBand;
  final List<CandidateQuestion> questions;
  final List<CandidateContentItem> pulse;
  final List<EvidenceRelation> relations;
  final Map<String, int> evidenceCosts;
}

class DebateMessage {
  const DebateMessage({
    required this.id,
    required this.topicId,
    required this.speakerId,
    required this.type,
    required this.text,
    required this.sequence,
    required this.publicReaction,
    this.referencedEvidenceIds = const [],
    this.contradictedByIds = const [],
    this.relatedPromiseIds = const [],
    this.relatedHistoryEventIds = const [],
    this.relatedMessageIds = const [],
    this.comparisonId,
    this.bookmarkable = true,
  });

  final String id;
  final String topicId;
  final String speakerId;
  final DebateMessageType type;
  final String text;
  final int sequence;
  final PublicReaction publicReaction;
  final List<String> referencedEvidenceIds;
  final List<String> contradictedByIds;
  final List<String> relatedPromiseIds;
  final List<String> relatedHistoryEventIds;
  final List<String> relatedMessageIds;
  final String? comparisonId;
  final bool bookmarkable;
}

class DebateTopic {
  const DebateTopic({
    required this.id,
    required this.title,
    required this.cityProblemId,
    required this.messages,
    this.issueFamilies = const [],
  });

  final String id;
  final String title;
  final String cityProblemId;
  final List<DebateMessage> messages;
  final List<CityIssueFamily> issueFamilies;
}

class CandidateExperienceCatalog {
  const CandidateExperienceCatalog({
    required this.profiles,
    required this.debateTopics,
    this.biographies = const {},
    this.promises = const [],
    this.comparisons = const [],
    this.informationRelations = const [],
  });

  final Map<String, CandidateExperienceProfile> profiles;
  final List<DebateTopic> debateTopics;
  final Map<String, CandidateBiography> biographies;
  final List<CandidatePromise> promises;
  final List<CandidateStatementComparison> comparisons;
  final List<CandidateInformationRelation> informationRelations;

  CandidateBiography? biographyFor(String candidateId) =>
      biographies[candidateId];

  List<CandidatePromise> promisesFor(String candidateId) => promises
      .where((promise) => promise.candidateId == candidateId)
      .toList(growable: false);

  CandidatePromise? promiseById(String id) {
    for (final promise in promises) {
      if (promise.id == id) return promise;
    }
    return null;
  }

  CandidateStatementComparison? comparisonById(String id) {
    for (final comparison in comparisons) {
      if (comparison.id == id) return comparison;
    }
    return null;
  }

  List<CandidateStatementComparison> comparisonsFor(String candidateId) =>
      comparisons
          .where((comparison) => comparison.candidateId == candidateId)
          .toList(growable: false);

  CandidateExperienceProfile? profileFor(String candidateId) =>
      profiles[candidateId];

  CandidateContentItem? contentById(String id) {
    for (final profile in profiles.values) {
      for (final item in profile.pulse) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  DebateMessage? debateMessageById(String id) {
    for (final topic in debateTopics) {
      for (final message in topic.messages) {
        if (message.id == id) return message;
      }
    }
    return null;
  }

  CandidateQuestion? questionById(String id) {
    for (final profile in profiles.values) {
      for (final question in profile.questions) {
        if (question.id == id) return question;
      }
    }
    return null;
  }

  int investigationCostFor(String evidenceId) {
    for (final profile in profiles.values) {
      final cost = profile.evidenceCosts[evidenceId];
      if (cost != null) return cost;
    }
    return 1;
  }

  Iterable<EvidenceRelation> relationsFrom(String evidenceId) sync* {
    for (final profile in profiles.values) {
      yield* profile.relations.where(
        (relation) => relation.fromEvidenceId == evidenceId,
      );
    }
  }

  List<String> validateRelations(Set<String> availableEvidenceIds) {
    final errors = <String>[];
    for (final profile in profiles.values) {
      for (final relation in profile.relations) {
        if (!availableEvidenceIds.contains(relation.fromEvidenceId)) {
          errors.add('Missing relation source: ${relation.fromEvidenceId}');
        }
        if (!availableEvidenceIds.contains(relation.toEvidenceId)) {
          errors.add('Missing relation target: ${relation.toEvidenceId}');
        }
      }
      for (final item in profile.pulse) {
        for (final evidenceId in item.relatedEvidenceIds) {
          if (!availableEvidenceIds.contains(evidenceId)) {
            errors.add('Missing Pulse evidence: $evidenceId');
          }
        }
      }
    }
    for (final profile in profiles.values) {
      final biography = biographies[profile.candidateId];
      if (biography == null) {
        errors.add('Missing biography: ${profile.candidateId}');
        continue;
      }
      final historyIds = biography.timeline.map((event) => event.id).toSet();
      for (final section in biography.sections) {
        for (final statement in section.statements) {
          for (final evidenceId in statement.evidenceIds) {
            if (!availableEvidenceIds.contains(evidenceId)) {
              errors.add('Missing biography evidence: $evidenceId');
            }
          }
        }
      }
      for (final event in biography.timeline) {
        for (final evidenceId in event.evidenceIds) {
          if (!availableEvidenceIds.contains(evidenceId)) {
            errors.add('Missing history evidence: $evidenceId');
          }
        }
      }
      for (final promise in promisesFor(profile.candidateId)) {
        for (final evidenceId in promise.evidenceIds) {
          if (!availableEvidenceIds.contains(evidenceId)) {
            errors.add('Missing promise evidence: $evidenceId');
          }
        }
        for (final eventId in promise.relatedHistoryEventIds) {
          if (!historyIds.contains(eventId)) {
            errors.add('Missing promise history: $eventId');
          }
        }
      }
    }
    final promiseIds = promises.map((promise) => promise.id).toSet();
    final comparisonIds = comparisons
        .map((comparison) => comparison.id)
        .toSet();
    final allHistoryIds = biographies.values
        .expand((biography) => biography.timeline)
        .map((event) => event.id)
        .toSet();
    for (final comparison in comparisons) {
      if (comparison.relatedPromiseId case final promiseId?) {
        if (!promiseIds.contains(promiseId)) {
          errors.add('Missing comparison promise: $promiseId');
        }
      }
      for (final evidenceId in comparison.evidenceIds) {
        if (!availableEvidenceIds.contains(evidenceId)) {
          errors.add('Missing comparison evidence: $evidenceId');
        }
      }
    }
    final messageIds = debateTopics
        .expand((topic) => topic.messages)
        .map((message) => message.id)
        .toSet();
    for (final topic in debateTopics) {
      for (final message in topic.messages) {
        for (final promiseId in message.relatedPromiseIds) {
          if (!promiseIds.contains(promiseId)) {
            errors.add('Missing debate promise: $promiseId');
          }
        }
        for (final eventId in message.relatedHistoryEventIds) {
          if (!allHistoryIds.contains(eventId)) {
            errors.add('Missing debate history: $eventId');
          }
        }
        for (final messageId in message.relatedMessageIds) {
          if (!messageIds.contains(messageId)) {
            errors.add('Missing related debate message: $messageId');
          }
        }
        final comparisonId = message.comparisonId;
        if (comparisonId != null && !comparisonIds.contains(comparisonId)) {
          errors.add('Missing debate comparison: $comparisonId');
        }
      }
    }
    return errors;
  }
}
