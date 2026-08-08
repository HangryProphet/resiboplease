enum TvBroadcastType { breakingNews, specialReport, communityFeature }

enum TvReporterEmotion { neutral, concerned, emphatic, signOff }

class TvLocalizedText {
  const TvLocalizedText({required this.english, required this.filipino});

  final String english;
  final String filipino;

  String resolve(String languageCode) =>
      languageCode == 'fil' ? filipino : english;
}

class TvDialoguePage {
  const TvDialoguePage({
    required this.id,
    required this.speakerId,
    required this.text,
    required this.emotion,
    this.visualAssetKey,
    this.relatedEvidenceId,
  });

  final String id;
  final String speakerId;
  final TvLocalizedText text;
  final TvReporterEmotion emotion;
  final String? visualAssetKey;
  final String? relatedEvidenceId;
}

class TvBroadcast {
  const TvBroadcast({
    required this.id,
    required this.underlyingEventId,
    required this.channelId,
    required this.headline,
    required this.category,
    required this.broadcastType,
    required this.reporterId,
    required this.dialoguePages,
    required this.relatedArticleIds,
    required this.relatedCandidateIds,
    required this.relatedIssueIds,
    required this.date,
    required this.priority,
    this.visualAssetKey,
  });

  final String id;
  final String underlyingEventId;
  final String channelId;
  final TvLocalizedText headline;
  final TvLocalizedText category;
  final TvBroadcastType broadcastType;
  final String reporterId;
  final String? visualAssetKey;
  final List<TvDialoguePage> dialoguePages;
  final List<String> relatedArticleIds;
  final List<String> relatedCandidateIds;
  final List<String> relatedIssueIds;
  final String date;
  final int priority;
}

class TvBroadcastCatalog {
  const TvBroadcastCatalog({required this.broadcasts});

  final List<TvBroadcast> broadcasts;

  TvBroadcast? byId(String id) {
    for (final broadcast in broadcasts) {
      if (broadcast.id == id) return broadcast;
    }
    return null;
  }

  TvBroadcast? forEvent(String eventId) {
    for (final broadcast in broadcasts) {
      if (broadcast.underlyingEventId == eventId) return broadcast;
    }
    return null;
  }
}
