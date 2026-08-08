import 'city_problem.dart';

enum NewsSensationalism { low, medium, high }

enum NewsDepth { shallow, standard, investigative }

enum NewsSpeed { careful, balanced, breakingFirst }

enum NewsTone { formal, conversational, provocative }

enum NewsAggression { reserved, critical, confrontational }

enum NewsHeadlineStyle {
  descriptive,
  dramatic,
  vague,
  questionBased,
  outcomeFocused,
}

class NewsOutlet {
  const NewsOutlet({
    required this.id,
    required this.name,
    required this.tagline,
    required this.sensationalism,
    required this.depth,
    required this.speed,
    required this.tone,
    required this.aggression,
    required this.headlineStyle,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String tagline;
  final NewsSensationalism sensationalism;
  final NewsDepth depth;
  final NewsSpeed speed;
  final NewsTone tone;
  final NewsAggression aggression;
  final NewsHeadlineStyle headlineStyle;
  final int colorValue;
}

class UnderlyingNewsEvent {
  const UnderlyingNewsEvent({
    required this.id,
    required this.fictionalDate,
    required this.title,
    required this.eventType,
    required this.factualSummary,
    required this.knownFacts,
    required this.publicImpact,
    required this.importance,
    required this.chronicleVisibility,
    this.chronicleItemId,
    this.relatedProblemId,
    this.relatedIssueFamily,
    this.relatedCandidateIds = const [],
    this.disputedFacts = const [],
    this.evidenceIds = const [],
    this.imageAssetKey,
  });

  final String id;
  final String fictionalDate;
  final String title;
  final String eventType;
  final String? chronicleItemId;
  final String? relatedProblemId;
  final CityIssueFamily? relatedIssueFamily;
  final List<String> relatedCandidateIds;
  final String factualSummary;
  final List<String> knownFacts;
  final List<String> disputedFacts;
  final List<String> evidenceIds;
  final int publicImpact;
  final int importance;
  final String? imageAssetKey;
  final bool chronicleVisibility;
}

class NewsCoverage {
  const NewsCoverage({
    required this.id,
    required this.eventId,
    required this.outletId,
    required this.category,
    required this.publicationTime,
    required this.headline,
    required this.subheadline,
    required this.articleSummary,
    required this.framingAngle,
    required this.articleBody,
    this.relatedCoverageIds = const [],
  });

  final String id;
  final String eventId;
  final String outletId;
  final String category;
  final String publicationTime;
  final String headline;
  final String subheadline;
  final String articleSummary;
  final String framingAngle;
  final List<String> articleBody;
  final List<String> relatedCoverageIds;
}

class NewsCatalog {
  const NewsCatalog({
    required this.outlets,
    required this.events,
    required this.coverages,
  });

  final List<NewsOutlet> outlets;
  final List<UnderlyingNewsEvent> events;
  final List<NewsCoverage> coverages;

  NewsOutlet? outletById(String id) {
    for (final outlet in outlets) {
      if (outlet.id == id) return outlet;
    }
    return null;
  }

  UnderlyingNewsEvent? eventById(String id) {
    for (final event in events) {
      if (event.id == id) return event;
    }
    return null;
  }

  NewsCoverage? coverageById(String id) {
    for (final coverage in coverages) {
      if (coverage.id == id) return coverage;
    }
    return null;
  }

  UnderlyingNewsEvent? eventForChronicle(String chronicleItemId) {
    for (final event in events) {
      if (event.chronicleItemId == chronicleItemId) return event;
    }
    return null;
  }

  List<NewsCoverage> coverageForEvent(String eventId) => coverages
      .where((coverage) => coverage.eventId == eventId)
      .toList(growable: false);

  List<NewsCoverage> coverageForCandidate(String candidateId) {
    final eventIds = events
        .where((event) => event.relatedCandidateIds.contains(candidateId))
        .map((event) => event.id)
        .toSet();
    return coverages
        .where((coverage) => eventIds.contains(coverage.eventId))
        .toList(growable: false);
  }
}
