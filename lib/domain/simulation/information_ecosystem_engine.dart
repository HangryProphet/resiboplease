import '../../data/seed_content/bayhaven_citybook.dart';
import '../models/candidate_experience.dart';
import '../models/city_problem.dart';
import '../models/citybook.dart';
import '../models/information_ecosystem.dart';
import '../models/information_reference.dart';
import '../models/news_media.dart';
import '../models/pre_election_city_brief.dart';
import '../models/scenario.dart';
import 'tv_broadcast_engine.dart';
import 'seeded_random.dart';

class InformationEcosystemEngine {
  const InformationEcosystemEngine();

  InformationEcosystem build({
    required Scenario scenario,
    required PreElectionCityBrief brief,
    required CandidateExperienceCatalog candidateExperience,
  }) {
    final outlets = _buildOutlets(scenario.seed);
    final events = <UnderlyingNewsEvent>[];
    final coverages = <NewsCoverage>[];

    for (var index = 0; index < brief.news.length; index++) {
      final chronicle = brief.news[index];
      if (chronicle.kind != ChronicleStoryKind.issue ||
          chronicle.problemId == null) {
        continue;
      }
      final problem = scenario.city.problems.firstWhere(
        (item) => item.id == chronicle.problemId,
      );
      final candidateIds = <String>{
        for (final promise in candidateExperience.promises)
          if (promise.relatedIssueFamilies.contains(problem.family))
            promise.candidateId,
      };
      final evidenceIds = <String>{
        for (final promise in candidateExperience.promises)
          if (promise.relatedIssueFamilies.contains(problem.family))
            ...promise.evidenceIds,
      };
      final event = UnderlyingNewsEvent(
        id: 'news_${chronicle.id}',
        fictionalDate: 'October ${6 + index}, 2025',
        title: problem.title,
        eventType: problem.family.name,
        chronicleItemId: chronicle.id,
        relatedProblemId: problem.id,
        relatedIssueFamily: problem.family,
        relatedCandidateIds: candidateIds.toList(growable: false),
        factualSummary: problem.description,
        knownFacts: [
          'The current public severity reading is ${problem.severity} out of 100.',
          'Urgency is measured at ${problem.urgency} out of 100 and the recorded trend is ${problem.trend.label.toLowerCase()}.',
          if (problem.affectedGroups.isNotEmpty)
            'Affected groups include ${problem.affectedGroups.join(', ')}.',
        ],
        disputedFacts: const [],
        evidenceIds: evidenceIds.toList(growable: false),
        publicImpact: ((problem.severity + problem.urgency) / 2).round(),
        importance: (problem.issueWeight * 100).round().clamp(1, 100),
        imageAssetKey: 'news_${problem.visualKey}',
        chronicleVisibility: true,
      );
      events.add(event);
      for (var outletIndex = 0; outletIndex < outlets.length; outletIndex++) {
        coverages.add(
          _coverageFor(
            event: event,
            problem: problem,
            outlet: outlets[outletIndex],
            outletIndex: outletIndex,
          ),
        );
      }
    }

    final rawCityBook = buildBayhavenCityBook();
    final posts = [
      for (final post in rawCityBook.posts)
        post.copyWith(
          relatedNewsEventIds: events
              .where(
                (event) =>
                    event.relatedIssueFamily != null &&
                    post.relatedIssueFamilies.contains(
                      event.relatedIssueFamily,
                    ),
              )
              .map((event) => event.id)
              .take(1)
              .toList(growable: false),
        ),
    ];
    final cityBook = CityBookCatalog(
      profiles: rawCityBook.profiles,
      posts: List.unmodifiable(posts),
      commentThreads: rawCityBook.commentThreads,
    );
    final news = NewsCatalog(
      outlets: List.unmodifiable(outlets),
      events: List.unmodifiable(events),
      coverages: List.unmodifiable(coverages),
    );

    return InformationEcosystem(
      cityBook: cityBook,
      news: news,
      tvBroadcasts: const TvBroadcastEngine().build(news),
      relationships: List.unmodifiable(
        _relationships(
          scenario: scenario,
          candidateExperience: candidateExperience,
          cityBook: cityBook,
          news: news,
        ),
      ),
    );
  }
}

List<NewsOutlet> _buildOutlets(int seed) {
  const reserved = [
    'Bayhaven Daily',
    'City Herald',
    'Morning Beacon',
    'Bayview Report',
  ];
  const fast = ['MetroWire', 'CityLine Now', 'The Street Desk', 'Harbor Flash'];
  const deep = [
    'The Lantern',
    'Civic Ledger',
    'North Coast Review',
    'The Public Eye',
  ];
  final random = SeededRandom(seed ^ _stableHash('news-outlets'));
  return [
    NewsOutlet(
      id: 'outlet_daily',
      name: reserved[random.nextInt(reserved.length)],
      tagline: 'The city, on the record.',
      sensationalism: NewsSensationalism.low,
      depth: NewsDepth.standard,
      speed: NewsSpeed.balanced,
      tone: NewsTone.formal,
      aggression: NewsAggression.reserved,
      headlineStyle: NewsHeadlineStyle.descriptive,
      colorValue: 0xFF285E78,
    ),
    NewsOutlet(
      id: 'outlet_wire',
      name: fast[random.nextInt(fast.length)],
      tagline: 'Fast updates. Hard questions.',
      sensationalism: NewsSensationalism.high,
      depth: NewsDepth.shallow,
      speed: NewsSpeed.breakingFirst,
      tone: NewsTone.provocative,
      aggression: NewsAggression.confrontational,
      headlineStyle: NewsHeadlineStyle.dramatic,
      colorValue: 0xFFA43D3D,
    ),
    NewsOutlet(
      id: 'outlet_lantern',
      name: deep[random.nextInt(deep.length)],
      tagline: 'Context beyond the headline.',
      sensationalism: NewsSensationalism.medium,
      depth: NewsDepth.investigative,
      speed: NewsSpeed.careful,
      tone: NewsTone.conversational,
      aggression: NewsAggression.critical,
      headlineStyle: NewsHeadlineStyle.outcomeFocused,
      colorValue: 0xFF397458,
    ),
  ];
}

NewsCoverage _coverageFor({
  required UnderlyingNewsEvent event,
  required CityProblem problem,
  required NewsOutlet outlet,
  required int outletIndex,
}) {
  final affected = problem.affectedGroups.isEmpty
      ? 'residents'
      : problem.affectedGroups.first;
  final policy = problem.policyHooks.isEmpty
      ? 'a public response'
      : problem.policyHooks.first;
  final cause = problem.possibleCauses.isEmpty
      ? 'multiple pressures'
      : problem.possibleCauses.first;
  final (headline, subheadline, angle) = switch (outletIndex) {
    0 => (
      '${problem.title}: city records show ${problem.trend.label.toLowerCase()} pressure',
      'The latest condition snapshot outlines severity, urgency, and affected communities.',
      'Public record and present condition',
    ),
    1 => (
      '${problem.title.toUpperCase()}: urgency reaches ${problem.urgency}',
      'Residents face mounting pressure while officials debate how quickly to act.',
      'Urgency, delay, and political pressure',
    ),
    _ => (
      'What ${problem.title.toLowerCase()} means for $affected',
      'The numbers matter, but causes, trade-offs, and implementation decide what comes next.',
      'Human impact, causes, and policy trade-offs',
    ),
  };
  return NewsCoverage(
    id: '${event.id}_${outlet.id}',
    eventId: event.id,
    outletId: outlet.id,
    category: _categoryFor(problem.family),
    publicationTime: '${event.fictionalDate} · ${8 + outletIndex * 2}:15 AM',
    headline: headline,
    subheadline: subheadline,
    articleSummary: switch (outletIndex) {
      0 => event.factualSummary,
      1 =>
        'The city snapshot places the issue at ${problem.severity}/100 severity and ${problem.urgency}/100 urgency.',
      _ =>
        '$affected are among those most exposed as the city weighs $policy and other responses.',
    },
    framingAngle: angle,
    articleBody: [
      event.factualSummary,
      'The shared city record places severity at ${problem.severity} and urgency at ${problem.urgency}. Its trend is ${problem.trend.label.toLowerCase()}. These values are the same across all coverage of this event.',
      switch (outletIndex) {
        0 =>
          'Records identify $cause among the possible causes. Officials and candidates have discussed $policy, but a policy proposal is not the same as completed implementation.',
        1 =>
          'The immediate political question is whether leaders can respond before the trend worsens. The urgency reading is real; claims about who alone can fix it still require evidence.',
        _ =>
          'For $affected, the issue is experienced through daily services rather than one headline. Options such as $policy involve funding, sequencing, and institutional capacity.',
      },
      'This report describes the same underlying event as the other listed outlets. Differences in emphasis should not be mistaken for different city truth.',
    ],
  );
}

List<InformationRelationship> _relationships({
  required Scenario scenario,
  required CandidateExperienceCatalog candidateExperience,
  required CityBookCatalog cityBook,
  required NewsCatalog news,
}) {
  final relationships = <InformationRelationship>[];
  for (final event in news.events) {
    final chronicleId = event.chronicleItemId;
    if (chronicleId != null) {
      relationships.add(
        InformationRelationship(
          id: 'rel_${event.id}_chronicle',
          from: InformationReference(
            kind: InformationArtifactKind.newsEvent,
            id: event.id,
          ),
          to: InformationReference(
            kind: InformationArtifactKind.chronicleEntry,
            id: chronicleId,
          ),
          type: InformationRelationshipType.originatesFrom,
          explanation: 'The coverage begins with this Chronicle event.',
        ),
      );
    }
    for (final coverage in news.coverageForEvent(event.id)) {
      relationships.add(
        InformationRelationship(
          id: 'rel_${coverage.id}_event',
          from: InformationReference(
            kind: InformationArtifactKind.newsCoverage,
            id: coverage.id,
          ),
          to: InformationReference(
            kind: InformationArtifactKind.newsEvent,
            id: event.id,
          ),
          type: InformationRelationshipType.reportsOn,
          explanation: 'This article frames the shared underlying event.',
        ),
      );
    }
  }
  for (final post in cityBook.posts) {
    for (final evidenceId in post.relatedEvidenceIds) {
      relationships.add(
        InformationRelationship(
          id: 'rel_${post.id}_$evidenceId',
          from: InformationReference(
            kind: InformationArtifactKind.cityBookPost,
            id: post.id,
          ),
          to: InformationReference(
            kind: InformationArtifactKind.evidence,
            id: evidenceId,
          ),
          type: InformationRelationshipType.references,
          explanation: 'This public claim has a related record to inspect.',
        ),
      );
    }
    for (final eventId in post.relatedNewsEventIds) {
      relationships.add(
        InformationRelationship(
          id: 'rel_${post.id}_$eventId',
          from: InformationReference(
            kind: InformationArtifactKind.cityBookPost,
            id: post.id,
          ),
          to: InformationReference(
            kind: InformationArtifactKind.newsEvent,
            id: eventId,
          ),
          type: InformationRelationshipType.respondsTo,
          explanation: 'The candidate post addresses the same city issue.',
        ),
      );
    }
  }
  for (final promise in candidateExperience.promises) {
    for (final problem in scenario.city.problems) {
      if (!promise.relatedIssueFamilies.contains(problem.family)) continue;
      relationships.add(
        InformationRelationship(
          id: 'rel_${promise.id}_${problem.id}',
          from: InformationReference(
            kind: InformationArtifactKind.candidatePromise,
            id: promise.id,
          ),
          to: InformationReference(
            kind: InformationArtifactKind.cityProblem,
            id: problem.id,
          ),
          type: InformationRelationshipType.respondsTo,
          explanation:
              'This promise is presented as a response to the active city problem.',
        ),
      );
    }
  }
  return relationships;
}

String _categoryFor(CityIssueFamily family) => switch (family) {
  CityIssueFamily.corruptionPublicFunds ||
  CityIssueFamily.governmentServices => 'Government',
  CityIssueFamily.healthcareCapacity ||
  CityIssueFamily.drugsCommunitySafety => 'Health & Safety',
  CityIssueFamily.employmentQuality ||
  CityIssueFamily.costOfLiving => 'Economy',
  CityIssueFamily.floodingDrainage ||
  CityIssueFamily.waterSupply ||
  CityIssueFamily.garbageCleanliness => 'Environment',
  CityIssueFamily.trafficTransport ||
  CityIssueFamily.unfinishedRoads => 'Infrastructure',
  CityIssueFamily.educationCapacity => 'Education',
};

int _stableHash(String value) => value.codeUnits.fold(
  0,
  (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
);
