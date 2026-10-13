import '../../data/seed_content/procedural_candidate_library.dart';
import '../models/candidate.dart';
import '../models/candidate_biography.dart';
import '../models/candidate_experience.dart';
import '../models/candidate_generation.dart';
import '../models/candidate_name_registry.dart';
import '../models/candidate_portrait.dart';
import '../models/city.dart';
import '../models/city_indicator.dart';
import '../models/city_problem.dart';
import '../models/city_run_configuration.dart';
import '../models/citybook.dart';
import '../models/evidence_item.dart';
import '../models/news_media.dart';
import '../models/procedural_election.dart';
import 'seed_derivation.dart';
import 'seeded_random.dart';
import 'citybook_comment_reaction_engine.dart';

/// Stable identity supplied by the political timeline when a previously seen
/// politician is eligible to contest a later election.
class ReturningCandidateIdentity {
  const ReturningCandidateIdentity({
    required this.candidate,
    required this.truth,
    required this.portraitId,
    this.priorOffice,
    this.priorCampaign,
  });

  final Candidate candidate;
  final CandidateTruthProfile truth;
  final String portraitId;
  final ReturningCandidateOfficeRecord? priorOffice;
  final ReturningCandidateCampaignRecord? priorCampaign;
}

/// Public memory for a returning candidate who appeared in an earlier ballot.
/// It records participation only and never invents a moral or performance score.
class ReturningCandidateCampaignRecord {
  const ReturningCandidateCampaignRecord({
    required this.electionsContested,
    required this.lastElectionTerm,
    required this.yearsAway,
  });

  final int electionsContested;
  final int lastElectionTerm;
  final int yearsAway;
}

/// A compact, immutable account of what a returning politician did in office.
///
/// This is deliberately composed from an archived administration rather than
/// regenerated scores. The next campaign may frame the record, but cannot
/// rewrite it.
class ReturningCandidateOfficeRecord {
  const ReturningCandidateOfficeRecord({
    required this.termsServed,
    required this.latestTermNumber,
    required this.finalCondition,
    required this.summary,
    required this.completedProjectTitles,
    required this.unresolvedProjectTitles,
    required this.majorEventTitles,
    this.careerEvolutionReasons = const [],
  });

  final int termsServed;
  final int latestTermNumber;
  final String finalCondition;
  final String summary;
  final List<String> completedProjectTitles;
  final List<String> unresolvedProjectTitles;
  final List<String> majorEventTitles;
  final List<String> careerEvolutionReasons;
}

class ProceduralCandidateGenerator {
  const ProceduralCandidateGenerator();

  static const generationVersion = 1;
  static const candidateCount = 5;

  /// Exposed for generation invariants and save-audit tests. The generator
  /// still stores only the resulting name; it never derives identity from it.
  static bool isNameCompatibleWithGender(
    String fullName,
    CandidateGender gender,
  ) {
    final firstName = fullName.trim().split(RegExp(r'\s+')).first;
    final pool = gender == CandidateGender.female
        ? _femaleFirstNames
        : _maleFirstNames;
    return pool.contains(firstName);
  }

  ProceduralElection generate({
    required int worldSeed,
    required City city,
    required CandidateField candidateField,
    CampaignNoise campaignNoise = CampaignNoise.typical,
    Iterable<String> previouslyUsedNames = const [],
    List<ReturningCandidateIdentity> returningCandidates = const [],
  }) {
    if (returningCandidates.length > candidateCount ||
        returningCandidates.map((item) => item.candidate.id).toSet().length !=
            returningCandidates.length ||
        returningCandidates.map((item) => item.portraitId).toSet().length !=
            returningCandidates.length) {
      throw ArgumentError(
        'Returning candidates must contain at most five unique identities.',
      );
    }
    final returningNames = returningCandidates
        .map((item) => item.candidate.name.toLowerCase())
        .toSet();
    final portraits = _selectPortraits(worldSeed, returningCandidates);
    final registry = CandidateNameRegistry(
      previouslyUsedNames.where(
        (name) => !returningNames.contains(name.toLowerCase()),
      ),
    );
    final usedParties = <String>{};
    final usedSlogans = <String>{};
    final usedBackgrounds = <String>{};
    final usedOrigins = <CandidateCareerOrigin, int>{};
    final builds = <_CandidateBuild>[];

    for (var index = 0; index < candidateCount; index++) {
      builds.add(
        _generateCandidate(
          worldSeed: worldSeed,
          index: index,
          portrait: portraits[index],
          city: city,
          candidateField: candidateField,
          campaignNoise: campaignNoise,
          registry: registry,
          usedParties: usedParties,
          usedSlogans: usedSlogans,
          usedBackgrounds: usedBackgrounds,
          usedOrigins: usedOrigins,
          returning: index < returningCandidates.length
              ? returningCandidates[index]
              : null,
        ),
      );
    }

    final debate = _generateDebate(worldSeed, city, builds);
    final profiles = <String, CandidateExperienceProfile>{};
    final biographies = <String, CandidateBiography>{};
    final promises = <CandidatePromise>[];
    final comparisons = <CandidateStatementComparison>[];
    final informationRelations = <CandidateInformationRelation>[];
    final cityBookProfiles = <String, CityBookProfile>{};
    final cityBookPosts = <CityBookPost>[];
    final commentThreads = <String, CityBookCommentThread>{};
    final newsEvents = <UnderlyingNewsEvent>[];
    final newsCoverages = <NewsCoverage>[];

    for (final build in builds) {
      profiles[build.candidate.id] = build.profile;
      biographies[build.candidate.id] = build.biography;
      promises.addAll(build.promises);
      comparisons.add(build.comparison);
      informationRelations.addAll(build.informationRelations);
      cityBookProfiles[build.candidate.id] = build.cityBookProfile;
      cityBookPosts.addAll(build.cityBookPosts);
      commentThreads.addAll(build.commentThreads);
      newsEvents.add(build.newsEvent);
      newsCoverages.addAll(build.newsCoverages);
    }

    final election = ProceduralElection(
      generationVersion: generationVersion,
      portraitIds: List.unmodifiable(portraits.map((portrait) => portrait.id)),
      candidates: List.unmodifiable(builds.map((build) => build.candidate)),
      truthProfiles: Map.unmodifiable({
        for (final build in builds) build.candidate.id: build.truth,
      }),
      candidateExperience: CandidateExperienceCatalog(
        profiles: Map.unmodifiable(profiles),
        debateTopics: List.unmodifiable(debate),
        biographies: Map.unmodifiable(biographies),
        promises: List.unmodifiable(promises),
        comparisons: List.unmodifiable(comparisons),
        informationRelations: List.unmodifiable(informationRelations),
      ),
      cityBook: CityBookCatalog(
        profiles: Map.unmodifiable(cityBookProfiles),
        posts: List.unmodifiable(cityBookPosts),
        commentThreads: Map.unmodifiable(commentThreads),
      ),
      candidateNewsEvents: List.unmodifiable(newsEvents),
      candidateNewsCoverages: List.unmodifiable(newsCoverages),
    );
    final errors = election.validate();
    if (errors.isNotEmpty) {
      throw StateError('Invalid procedural election: ${errors.join(' | ')}');
    }
    return election;
  }

  List<CandidatePortrait> _selectPortraits(
    int worldSeed,
    List<ReturningCandidateIdentity> returningCandidates,
  ) {
    final random = _random(worldSeed, 'portraitSelection');
    final reserved = <CandidatePortrait>[];
    for (final returning in returningCandidates) {
      final portrait = candidatePortraitById(returning.portraitId);
      if (portrait == null) {
        throw ArgumentError(
          'Unknown returning portrait ${returning.portraitId}.',
        );
      }
      reserved.add(portrait);
    }
    final reservedIds = reserved.map((item) => item.id).toSet();
    final portraits = candidatePortraitPool
        .where((portrait) => !reservedIds.contains(portrait.id))
        .toList();
    for (var index = portraits.length - 1; index > 0; index--) {
      final swap = random.nextInt(index + 1);
      final value = portraits[index];
      portraits[index] = portraits[swap];
      portraits[swap] = value;
    }
    return List.unmodifiable([
      ...reserved,
      ...portraits.take(candidateCount - reserved.length),
    ]);
  }

  _CandidateBuild _generateCandidate({
    required int worldSeed,
    required int index,
    required CandidatePortrait portrait,
    required City city,
    required CandidateField candidateField,
    required CampaignNoise campaignNoise,
    required CandidateNameRegistry registry,
    required Set<String> usedParties,
    required Set<String> usedSlogans,
    required Set<String> usedBackgrounds,
    required Map<CandidateCareerOrigin, int> usedOrigins,
    ReturningCandidateIdentity? returning,
  }) {
    final identityRandom = _random(worldSeed, 'candidate:$index:identity');
    final truthRandom = _random(worldSeed, 'candidate:$index:truth');
    final historyRandom = _random(worldSeed, 'candidate:$index:history');
    final contentRandom = _random(worldSeed, 'candidate:$index:content');
    final firstNames = portrait.gender == CandidateGender.female
        ? _femaleFirstNames
        : _maleFirstNames;
    final name =
        returning?.candidate.name ??
        registry.generate(
          firstNames: firstNames,
          surnames: _surnames,
          seed: _seed(worldSeed, 'candidate:$index:name'),
        );
    if (returning != null && !registry.reserve(name)) {
      throw StateError('Returning candidate name is already reserved: $name.');
    }
    final candidateId =
        returning?.candidate.id ??
        'candidate_${_seed(worldSeed, 'candidate:$index:id').toRadixString(16).padLeft(8, '0')}';
    final background = returning == null
        ? _selectBackground(
            random: identityRandom,
            city: city,
            usedBackgrounds: usedBackgrounds,
            usedOrigins: usedOrigins,
            index: index,
          )
        : _backgroundForReturning(
            returning,
            usedBackgrounds: usedBackgrounds,
            usedOrigins: usedOrigins,
          );
    final party =
        returning?.candidate.party ??
        _takeUnique(
          _partyNames,
          usedParties,
          identityRandom,
          fallbackPrefix: 'Civic Coalition',
        );
    usedParties.add(party);
    final leadProblem = _leadProblemFor(background, city, identityRandom);
    final slogan = _takeUnique(
      _slogansFor(leadProblem),
      usedSlogans,
      identityRandom,
      fallbackPrefix: 'Proof before promises',
    );
    final style =
        background.rhetoricalStyles[identityRandom.nextInt(
          background.rhetoricalStyles.length,
        )];
    final band = returning?.truth.qualityBand ?? _qualityBand(truthRandom);
    final age = _ageFor(portrait.ageGroup, identityRandom);
    final truth =
        returning?.truth ??
        _generateTruth(
          id: candidateId,
          band: band,
          background: background,
          city: city,
          candidateField: candidateField,
          random: truthRandom,
        );
    final evidenceIds = _EvidenceIds(candidateId);
    final history = _generateHistory(
      candidateId: candidateId,
      name: name,
      age: age,
      background: background,
      leadProblem: leadProblem,
      truth: truth,
      evidenceIds: evidenceIds,
      random: historyRandom,
    );
    final priorOffice = returning?.priorOffice;
    final priorCampaign = returning?.priorCampaign;
    final promises = _generatePromises(
      candidateId: candidateId,
      city: city,
      background: background,
      truth: truth,
      history: history,
      evidenceIds: evidenceIds,
      random: _random(worldSeed, 'candidate:$index:platform'),
      priorOffice: priorOffice,
    );
    final evidence = _generateEvidence(
      candidateId: candidateId,
      name: name,
      city: city,
      background: background,
      truth: truth,
      history: history,
      promises: promises,
      evidenceIds: evidenceIds,
      priorOffice: returning?.priorOffice,
      priorCampaign: returning?.priorCampaign,
    );
    final quickBiography = _quickBiography(
      name,
      age,
      background,
      truth,
      history,
    );
    final candidate = Candidate(
      id: candidateId,
      name: name,
      party: party,
      archetype: returning?.candidate.archetype ?? background.archetype,
      slogan: slogan,
      biography: priorOffice != null
          ? '$quickBiography $name previously governed ${city.name} through Administration ${priorOffice.latestTermNumber}; the archived term ended ${priorOffice.finalCondition.toLowerCase()} and remains available as a public receipt.'
          : priorCampaign != null
          ? '$quickBiography $name last appeared on the Election ${priorCampaign.lastElectionTerm} ballot and returns after ${priorCampaign.yearsAway} election cycle(s) away.'
          : quickBiography,
      visibleStrengths: _visibleStrengths(background, truth),
      visibleConcerns: _visibleConcerns(truth, history),
      platform: List.unmodifiable(
        promises.map((promise) => promise.candidateWording),
      ),
      evidence: List.unmodifiable(evidence),
      capabilities: CandidateCapabilities(
        policyScores: Map.unmodifiable({
          for (final entry in truth.policyScores.entries)
            CityIndicator.values.firstWhere(
              (indicator) => indicator.name == entry.key,
            ): entry.value,
        }),
        implementationSkill: truth.implementationSkill,
        integrity: truth.integrity,
        coalitionSkill: truth.coalitionSkill,
        crisisResponse: truth.crisisResponse,
        budgetDiscipline: truth.budgetDiscipline,
        corruptionRisk: truth.corruptionRisk,
      ),
      colorValue:
          returning?.candidate.colorValue ??
          _candidateColors[index % _candidateColors.length],
    );
    final biography = _generateBiography(
      candidate: candidate,
      age: age,
      background: background,
      truth: truth,
      history: history,
      evidenceIds: evidenceIds,
      priorOffice: priorOffice,
      priorCampaign: priorCampaign,
    );
    final comparison = _generateComparison(
      candidate: candidate,
      leadProblem: leadProblem,
      promise: promises.first,
      history: history,
      evidenceIds: evidenceIds,
    );
    final profile = _generateExperienceProfile(
      candidate: candidate,
      portrait: portrait,
      background: background,
      rhetoricalStyle: style,
      truth: truth,
      leadProblem: leadProblem,
      history: history,
      promises: promises,
      comparison: comparison,
      evidenceIds: evidenceIds,
      random: contentRandom,
      campaignNoise: campaignNoise,
      priorOffice: priorOffice,
      priorCampaign: priorCampaign,
    );
    final cityBook = _generateCityBook(
      candidate: candidate,
      portrait: portrait,
      background: background,
      truth: truth,
      city: city,
      leadProblem: leadProblem,
      history: history,
      promises: promises,
      comparison: comparison,
      evidenceIds: evidenceIds,
      random: _random(worldSeed, 'candidate:$index:citybook'),
      campaignNoise: campaignNoise,
      priorOffice: priorOffice,
      priorCampaign: priorCampaign,
    );
    final news = _generateCandidateNews(
      candidate: candidate,
      leadProblem: leadProblem,
      history: history,
      truth: truth,
      evidenceIds: evidenceIds,
      priorOffice: priorOffice,
    );
    return _CandidateBuild(
      portrait: portrait,
      background: background,
      candidate: candidate,
      truth: truth,
      biography: biography,
      promises: promises,
      comparison: comparison,
      profile: profile,
      informationRelations: _informationRelations(
        candidateId,
        promises,
        history,
      ),
      cityBookProfile: cityBook.$1,
      cityBookPosts: cityBook.$2,
      commentThreads: cityBook.$3,
      newsEvent: news.$1,
      newsCoverages: news.$2,
      priorOffice: priorOffice,
    );
  }

  CandidateBackgroundTemplate _backgroundForReturning(
    ReturningCandidateIdentity returning, {
    required Set<String> usedBackgrounds,
    required Map<CandidateCareerOrigin, int> usedOrigins,
  }) {
    final exact = proceduralCandidateBackgrounds
        .where(
          (item) =>
              item.archetype == returning.candidate.archetype &&
              !usedBackgrounds.contains(item.id),
        )
        .firstOrNull;
    final sameOrigin = proceduralCandidateBackgrounds
        .where(
          (item) =>
              item.careerOrigin == returning.truth.careerOrigin &&
              !usedBackgrounds.contains(item.id),
        )
        .firstOrNull;
    final selected =
        exact ?? sameOrigin ?? proceduralCandidateBackgrounds.first;
    usedBackgrounds.add(selected.id);
    usedOrigins.update(
      selected.careerOrigin,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    return selected;
  }

  CandidateBackgroundTemplate _selectBackground({
    required SeededRandom random,
    required City city,
    required Set<String> usedBackgrounds,
    required Map<CandidateCareerOrigin, int> usedOrigins,
    required int index,
  }) {
    final available = proceduralCandidateBackgrounds
        .where((background) => !usedBackgrounds.contains(background.id))
        .toList(growable: false);
    final weighted = <CandidateBackgroundTemplate>[];
    for (final background in available) {
      var weight = background.weight;
      for (final problem in city.problems) {
        if (background.primaryIndicators.contains(problem.primaryIndicator)) {
          weight += index < 3 ? 7 : 3;
        }
      }
      final sameOriginCount = usedOrigins[background.careerOrigin] ?? 0;
      if (sameOriginCount >= 2) {
        // A third similar origin remains possible, but should be unusual.
        weight = 1;
      } else if (sameOriginCount == 1) {
        weight = (weight * .55).round().clamp(1, weight);
      }
      weighted.addAll(List.filled(weight, background));
    }
    final selected = weighted[random.nextInt(weighted.length)];
    usedBackgrounds.add(selected.id);
    usedOrigins.update(
      selected.careerOrigin,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    return selected;
  }

  CityProblem _leadProblemFor(
    CandidateBackgroundTemplate background,
    City city,
    SeededRandom random,
  ) {
    final matching = city.problems
        .where(
          (problem) =>
              background.primaryIndicators.contains(problem.primaryIndicator),
        )
        .toList(growable: false);
    if (matching.isNotEmpty && random.nextInt(100) < 72) {
      return matching[random.nextInt(matching.length)];
    }
    return city.problems[random.nextInt(city.problems.length)];
  }

  CandidateTruthProfile _generateTruth({
    required String id,
    required CandidateQualityBand band,
    required CandidateBackgroundTemplate background,
    required City city,
    required CandidateField candidateField,
    required SeededRandom random,
  }) {
    final (competenceBase, integrityBase, riskBase) = switch (band) {
      CandidateQualityBand.strong => (79, 80, 22),
      CandidateQualityBand.compromised => (72, 44, 68),
      CandidateQualityBand.mixed => (57, 57, 46),
      CandidateQualityBand.weak => (35, 50, 51),
      CandidateQualityBand.dangerous => (63, 20, 87),
    };
    int vary(int base, [int spread = 14]) =>
        (base + random.nextInt(spread * 2 + 1) - spread).clamp(5, 95);
    final fieldDelta = switch (candidateField) {
      CandidateField.unproven => -12,
      CandidateField.mixed => 0,
      CandidateField.seasoned => 12,
    };
    final experience =
        (background.baseExperience + fieldDelta + random.nextInt(17) - 8).clamp(
          8,
          94,
        );
    final policyScores = <String, int>{};
    for (final indicator in CityIndicator.values) {
      var base = competenceBase + random.nextInt(31) - 15;
      if (background.primaryIndicators.contains(indicator)) base += 19;
      if (city.problems.any(
        (problem) => problem.primaryIndicator == indicator,
      )) {
        base += random.nextInt(9) - 2;
      }
      policyScores[indicator.name] = base.clamp(8, 96);
    }
    final controversy = _controversyFor(id, band, city, random);
    final relationship = _relationshipFor(id, band, random);
    final footprint = _footprintFor(background, experience, random);
    return CandidateTruthProfile(
      qualityBand: band,
      generalCompetence: vary(competenceBase),
      implementationSkill: vary(competenceBase),
      integrity: vary(integrityBase),
      corruptionRisk: vary(riskBase),
      coalitionSkill: vary((competenceBase + experience) ~/ 2),
      communication: vary(
        background.id == 'media_personality' ? 88 : competenceBase,
      ),
      budgetDiscipline: vary(
        background.id == 'accountant' ? 88 : competenceBase,
      ),
      crisisResponse: vary(
        background.id == 'public_safety_official' ? 86 : competenceBase,
      ),
      adaptability: vary(competenceBase),
      experience: experience,
      populism: vary(background.id == 'media_personality' ? 83 : 52, 22),
      ambition: vary(band == CandidateQualityBand.dangerous ? 88 : 62, 20),
      reformCredibility: ((integrityBase * 2 + competenceBase) ~/ 3).clamp(
        8,
        94,
      ),
      politicalFatigue: (6 + experience ~/ 5).clamp(5, 38),
      institutionalStanding: ((competenceBase + experience) ~/ 2).clamp(8, 94),
      policyScores: Map.unmodifiable(policyScores),
      motivations: List.unmodifiable([
        if (band != CandidateQualityBand.dangerous) 'public_service',
        background.id,
        band == CandidateQualityBand.dangerous
            ? 'personal_power'
            : 'political_advancement',
      ]),
      hiddenRisks: List.unmodifiable([
        switch (band) {
          CandidateQualityBand.strong => 'overconfidence',
          CandidateQualityBand.compromised => 'donor_dependency',
          CandidateQualityBand.mixed => 'uneven_execution',
          CandidateQualityBand.weak => 'administrative_failure',
          CandidateQualityBand.dangerous => 'institutional_capture',
        },
      ]),
      informationFootprint: footprint,
      careerOrigin: background.careerOrigin,
      personalityTags: List.unmodifiable([
        background
            .rhetoricalStyles[random.nextInt(
              background.rhetoricalStyles.length,
            )]
            .name,
        random.nextInt(2) == 0 ? 'patient' : 'competitive',
      ]),
      controversies: [controversy],
      relationships: [relationship],
    );
  }

  CandidateControversyTruth _controversyFor(
    String candidateId,
    CandidateQualityBand band,
    City city,
    SeededRandom random,
  ) {
    final problem = city.problems[random.nextInt(city.problems.length)];
    final kind = _controversyKinds[random.nextInt(_controversyKinds.length)];
    final status = switch (band) {
      CandidateQualityBand.strong => [
        CandidateControversyStatus.disputed,
        CandidateControversyStatus.misleading,
        CandidateControversyStatus.falseAccusation,
      ][random.nextInt(3)],
      CandidateQualityBand.compromised => [
        CandidateControversyStatus.verified,
        CandidateControversyStatus.stronglySupported,
        CandidateControversyStatus.partiallySupported,
      ][random.nextInt(3)],
      CandidateQualityBand.mixed => [
        CandidateControversyStatus.partiallySupported,
        CandidateControversyStatus.disputed,
        CandidateControversyStatus.unresolved,
      ][random.nextInt(3)],
      CandidateQualityBand.weak => [
        CandidateControversyStatus.verified,
        CandidateControversyStatus.partiallySupported,
        CandidateControversyStatus.unresolved,
      ][random.nextInt(3)],
      CandidateQualityBand.dangerous => [
        CandidateControversyStatus.verified,
        CandidateControversyStatus.stronglySupported,
      ][random.nextInt(2)],
    };
    return CandidateControversyTruth(
      id: '${candidateId}_controversy_truth',
      kind: kind,
      summary:
          'Questions about $kind emerged from an earlier project connected to ${problem.title.toLowerCase()}.',
      status: status,
      relatedIssueKeys: [problem.family.name],
    );
  }

  CandidateRelationshipTruth _relationshipFor(
    String candidateId,
    CandidateQualityBand band,
    SeededRandom random,
  ) {
    final type = CandidateRelationshipType
        .values[random.nextInt(CandidateRelationshipType.values.length)];
    final conflict = switch (band) {
      CandidateQualityBand.strong => random.nextInt(100) < 18,
      CandidateQualityBand.compromised => true,
      CandidateQualityBand.mixed => random.nextInt(100) < 45,
      CandidateQualityBand.weak => random.nextInt(100) < 50,
      CandidateQualityBand.dangerous => true,
    };
    return CandidateRelationshipTruth(
      id: '${candidateId}_relationship_0',
      name: _organizationNames[random.nextInt(_organizationNames.length)],
      type: type,
      summary: conflict
          ? 'A documented relationship creates a possible conflict that requires safeguards.'
          : 'The relationship is documented, but the connection alone does not prove wrongdoing.',
      isPotentialConflict: conflict,
    );
  }

  CandidateInformationFootprint _footprintFor(
    CandidateBackgroundTemplate background,
    int experience,
    SeededRandom random,
  ) {
    if (background.careerOrigin == CandidateCareerOrigin.celebrityMedia) {
      return CandidateInformationFootprint.overexposed;
    }
    final originOffset = switch (background.careerOrigin) {
      CandidateCareerOrigin.careerPolitician => 14,
      CandidateCareerOrigin.publicAdministrator => 8,
      CandidateCareerOrigin.business => 3,
      CandidateCareerOrigin.community || CandidateCareerOrigin.advocacy => -8,
      CandidateCareerOrigin.professional ||
      CandidateCareerOrigin.publicSafety => 0,
      CandidateCareerOrigin.celebrityMedia => 25,
    };
    final score = experience + originOffset + random.nextInt(31) - 15;
    return switch (score) {
      < 25 => CandidateInformationFootprint.minimal,
      < 43 => CandidateInformationFootprint.limited,
      < 67 => CandidateInformationFootprint.normal,
      < 84 => CandidateInformationFootprint.extensive,
      _ => CandidateInformationFootprint.overexposed,
    };
  }

  List<CandidateLifeEvent> _generateHistory({
    required String candidateId,
    required String name,
    required int age,
    required CandidateBackgroundTemplate background,
    required CityProblem leadProblem,
    required CandidateTruthProfile truth,
    required _EvidenceIds evidenceIds,
    required SeededRandom random,
  }) {
    final birthYear = 2026 - age;
    final graduationYear = birthYear + 21 + random.nextInt(5);
    final projectYear = 2017 + random.nextInt(6);
    final failureYear = (projectYear + 1 + random.nextInt(3)).clamp(2018, 2024);
    final publicStart = graduationYear + 2 + random.nextInt(8);
    final accomplishment = _accomplishmentFor(leadProblem, truth);
    final failure = _failureFor(leadProblem, truth);
    return List.unmodifiable([
      CandidateLifeEvent(
        id: '${candidateId}_history_education',
        year: graduationYear,
        type: CandidateHistoryEventType.education,
        title: 'Completed professional studies',
        summary: '$name completed ${background.education.first}.',
        details:
            'Archive records place the qualification before the candidate\'s main professional career.',
        publicVisibility: CandidatePublicVisibility.local,
        evidenceIds: [evidenceIds.profile],
      ),
      CandidateLifeEvent(
        id: '${candidateId}_history_career',
        year: publicStart,
        type: CandidateHistoryEventType.employment,
        title: 'Entered ${background.occupation.toLowerCase()} work',
        summary:
            '$name began building a documented career as a ${background.occupation.toLowerCase()}.',
        details:
            'The role explains the candidate\'s strongest policy familiarity but does not prove executive ability.',
        publicVisibility: CandidatePublicVisibility.citywide,
        evidenceIds: [evidenceIds.profile],
        relatedIssueFamilies: [leadProblem.family],
      ),
      CandidateLifeEvent(
        id: '${candidateId}_history_accomplishment',
        year: projectYear,
        type: CandidateHistoryEventType.accomplishment,
        title: accomplishment.$1,
        summary: accomplishment.$2,
        details:
            '${accomplishment.$2} Independent records confirm an outcome while noting limits in scale and follow-through.',
        publicVisibility: CandidatePublicVisibility.prominent,
        evidenceIds: [evidenceIds.publicRecord, evidenceIds.campaign],
        relatedIssueFamilies: [leadProblem.family],
      ),
      CandidateLifeEvent(
        id: '${candidateId}_history_failure',
        year: failureYear,
        type: CandidateHistoryEventType.failure,
        title: failure.$1,
        summary: failure.$2,
        details:
            '${failure.$2} Available records do not show that one person controlled every contributing factor.',
        publicVisibility: CandidatePublicVisibility.citywide,
        evidenceIds: [evidenceIds.publicRecord, evidenceIds.budget],
        relatedIssueFamilies: [leadProblem.family],
      ),
      CandidateLifeEvent(
        id: '${candidateId}_history_controversy',
        year: 2024,
        type: CandidateHistoryEventType.controversy,
        title: 'Public questions about ${truth.controversies.last.kind}',
        summary: truth.controversies.last.summary,
        details:
            '${truth.controversies.last.summary} The available truth status is ${_controversyStatusText(truth.controversies.last.status)}.',
        publicVisibility: CandidatePublicVisibility.prominent,
        evidenceIds: [evidenceIds.controversy, evidenceIds.factCheck],
        relatedIssueFamilies: [leadProblem.family],
      ),
    ]);
  }

  (String, String) _accomplishmentFor(
    CityProblem problem,
    CandidateTruthProfile truth,
  ) {
    final strong = truth.generalCompetence >= 60;
    return switch (problem.family) {
      CityIssueFamily.waterSupply => (
        'Expanded water testing',
        strong
            ? 'A pilot testing program found damaged lines earlier and shortened response time.'
            : 'A small testing pilot opened, but coverage remained limited to two districts.',
      ),
      CityIssueFamily.healthcareCapacity => (
        'Extended neighborhood clinic access',
        strong
            ? 'A clinic partnership reduced waiting time in participating neighborhoods.'
            : 'A clinic partnership added hours but relied heavily on temporary funding.',
      ),
      CityIssueFamily.employmentQuality => (
        'Created a local apprenticeship program',
        strong
            ? 'The program placed residents into paid training with documented retention.'
            : 'The program placed residents into short training, with mixed long-term retention.',
      ),
      CityIssueFamily.floodingDrainage => (
        'Improved flood-response coordination',
        strong
            ? 'Response teams reached exposed neighborhoods faster during the next severe storm.'
            : 'A response protocol improved dispatch but did not address the largest drainage bottlenecks.',
      ),
      _ => (
        'Delivered a visible city-service pilot',
        strong
            ? 'The pilot met its main public target and produced a documented service improvement.'
            : 'The pilot opened on time, although its benefits remained narrow and uneven.',
      ),
    };
  }

  (String, String) _failureFor(
    CityProblem problem,
    CandidateTruthProfile truth,
  ) {
    final budgetWeak = truth.budgetDiscipline < 55;
    return (
      budgetWeak
          ? 'Project exceeded its budget'
          : 'Project missed its schedule',
      budgetWeak
          ? 'A related ${problem.title.toLowerCase()} initiative required additional funding after launch.'
          : 'A related ${problem.title.toLowerCase()} initiative finished later than announced.',
    );
  }

  List<CandidatePromise> _generatePromises({
    required String candidateId,
    required City city,
    required CandidateBackgroundTemplate background,
    required CandidateTruthProfile truth,
    required List<CandidateLifeEvent> history,
    required _EvidenceIds evidenceIds,
    required SeededRandom random,
    ReturningCandidateOfficeRecord? priorOffice,
  }) {
    final families = <CityIssueFamily>[];
    final ranked = [...city.problems]
      ..sort((a, b) => b.issueWeight.compareTo(a.issueWeight));
    families.addAll(ranked.take(3).map((problem) => problem.family));
    final backgroundFamily = city.problems
        .where(
          (problem) =>
              background.primaryIndicators.contains(problem.primaryIndicator),
        )
        .map((problem) => problem.family)
        .firstOrNull;
    if (backgroundFamily != null && !families.contains(backgroundFamily)) {
      families.add(backgroundFamily);
    }
    while (families.length < 4) {
      final family = city.problems[random.nextInt(city.problems.length)].family;
      if (!families.contains(family)) families.add(family);
    }
    return List.unmodifiable([
      for (var index = 0; index < 4; index++)
        _promiseFromTemplate(
          candidateId,
          index,
          families[index],
          truth,
          history,
          evidenceIds,
          priorOffice,
        ),
    ]);
  }

  CandidatePromise _promiseFromTemplate(
    String candidateId,
    int index,
    CityIssueFamily family,
    CandidateTruthProfile truth,
    List<CandidateLifeEvent> history,
    _EvidenceIds evidenceIds,
    ReturningCandidateOfficeRecord? priorOffice,
  ) {
    final template = proceduralPromiseLibrary.firstWhere(
      (item) => item.family == family,
    );
    final indicator = indicatorForIssueFamily(family);
    final fit = truth.policyScores[indicator.name] ?? 50;
    final baseWording = fit >= 70
        ? template.wording
        : fit < 40
        ? '${template.wording} The campaign has not yet released a detailed sequence.'
        : template.wording;
    final wording = index == 0 && priorOffice != null
        ? '$baseWording The Administration ${priorOffice.latestTermNumber} receipt is part of the record voters should use to judge this renewed commitment.'
        : baseWording;
    return CandidatePromise(
      id: '${candidateId}_promise_$index',
      candidateId: candidateId,
      title: template.title,
      candidateWording: wording,
      approach: template.approach,
      complexity: template.complexity,
      relatedIssueFamilies: [family],
      evidenceIds: [evidenceIds.platform, if (index == 0) evidenceIds.budget],
      relatedHistoryEventIds: [
        if (index == 0 && priorOffice != null)
          '${candidateId}_administration_${priorOffice.latestTermNumber}'
        else
          index.isEven ? history[2].id : history[3].id,
      ],
    );
  }

  List<EvidenceItem> _generateEvidence({
    required String candidateId,
    required String name,
    required City city,
    required CandidateBackgroundTemplate background,
    required CandidateTruthProfile truth,
    required List<CandidateLifeEvent> history,
    required List<CandidatePromise> promises,
    required _EvidenceIds evidenceIds,
    ReturningCandidateOfficeRecord? priorOffice,
    ReturningCandidateCampaignRecord? priorCampaign,
  }) {
    final controversy = truth.controversies.last;
    final accomplishment = history[2];
    final failure = history[3];
    final truthStatus = _evidenceStatus(controversy.status);
    final recordSource = priorOffice != null
        ? '${city.name} Administration Archive'
        : priorCampaign != null
        ? '${city.name} Election Archive'
        : _recordSource(background.careerOrigin, city.name);
    final recordTitle = priorOffice != null
        ? 'Administration ${priorOffice.latestTermNumber} performance record'
        : priorCampaign != null
        ? 'Election ${priorCampaign.lastElectionTerm} ballot record'
        : _recordTitle(background.careerOrigin);
    return List.unmodifiable([
      EvidenceItem(
        id: evidenceIds.profile,
        type: EvidenceType.profile,
        title: '$name: civic profile',
        source: '${city.name} Civic Archive',
        summary:
            '${background.occupation}, education, career history, and public roles.',
        details:
            '$name is a ${background.occupation.toLowerCase()} currently serving as ${background.currentPosition.toLowerCase()}. The archive cross-checks education and employment records.',
        truthStatus: TruthStatus.verifiedTrue,
        reliability: 90,
      ),
      EvidenceItem(
        id: evidenceIds.platform,
        type: EvidenceType.platform,
        title: 'Four promises for ${city.name}',
        source: '$name campaign',
        summary: promises.map((promise) => promise.title).join(', '),
        details:
            'The platform describes intended actions. It does not itself prove funding, authority, or delivery capacity.',
        truthStatus: TruthStatus.unverified,
        reliability: 46,
      ),
      EvidenceItem(
        id: evidenceIds.campaign,
        type: EvidenceType.campaignAd,
        title: 'A record ready for city hall',
        source: '$name campaign',
        summary: priorOffice == null
            ? 'The campaign highlights ${accomplishment.title.toLowerCase()}.'
            : 'The campaign highlights ${priorOffice.completedProjectTitles.isEmpty ? 'its governing experience' : priorOffice.completedProjectTitles.first.toLowerCase()} from Administration ${priorOffice.latestTermNumber}.',
        details: priorOffice == null
            ? '${accomplishment.summary} The advertisement does not emphasize ${failure.title.toLowerCase()}.'
            : '${priorOffice.summary} The advertisement emphasizes completed work but does not lead with ${priorOffice.unresolvedProjectTitles.isEmpty ? 'the administration\'s unresolved trade-offs' : priorOffice.unresolvedProjectTitles.first.toLowerCase()}.',
        truthStatus: TruthStatus.missingContext,
        reliability: 35,
      ),
      EvidenceItem(
        id: evidenceIds.publicRecord,
        type: EvidenceType.publicRecord,
        title: recordTitle,
        source: recordSource,
        summary: priorOffice != null
            ? priorOffice.summary
            : priorCampaign != null
            ? 'The archive confirms ${priorCampaign.electionsContested} prior ballot appearance(s), most recently Election ${priorCampaign.lastElectionTerm}.'
            : '${accomplishment.summary} ${failure.summary}',
        details: priorOffice != null
            ? 'The sealed Administration ${priorOffice.latestTermNumber} receipt records ${priorOffice.completedProjectTitles.length} completed project(s), ${priorOffice.unresolvedProjectTitles.length} unresolved project(s), and ${priorOffice.majorEventTitles.length} major event(s). ${priorOffice.careerEvolutionReasons.join(' ')} The record is evidence of actual governing consequences, not proof that a new promise will succeed.'
            : priorCampaign != null
            ? 'The public ballot establishes that the candidate previously ran and later spent ${priorCampaign.yearsAway} cycle(s) away. It does not turn an earlier loss into evidence of competence, weakness, honesty, or wrongdoing.'
            : 'The relevant archive confirms both the documented result and the documented limit. This is a career record, not proof of mayoral ability or personal integrity.',
        truthStatus: TruthStatus.verifiedTrue,
        reliability: 92,
      ),
      EvidenceItem(
        id: evidenceIds.budget,
        type: EvidenceType.budgetDocument,
        title: 'Independent platform cost review',
        source: 'Civic Ledger Institute',
        summary: truth.budgetDiscipline >= 68
            ? 'Major costs are identified, but later-year operating funds still require council approval.'
            : 'Several first-year promises depend on optimistic revenue or unspecified savings.',
        details:
            'Reviewers compared the campaign sequence with available city revenue, staffing, maintenance, and procurement timelines.',
        truthStatus: truth.budgetDiscipline >= 68
            ? TruthStatus.mostlyTrue
            : TruthStatus.partiallyTrue,
        reliability: 86,
      ),
      EvidenceItem(
        id: evidenceIds.social,
        type: EvidenceType.socialPost,
        title: 'A campaign claim spreads quickly',
        source: 'CityBook public post',
        summary:
            'Supporters describe ${accomplishment.title.toLowerCase()} as a complete solution for the whole city.',
        details:
            'The underlying accomplishment is real, but the post expands a limited project into a citywide claim.',
        truthStatus: TruthStatus.misleading,
        reliability: 22,
      ),
      EvidenceItem(
        id: evidenceIds.factCheck,
        type: EvidenceType.factCheck,
        title: 'Claim review: record, scale, and missing context',
        source: '${city.name} Fact Desk',
        summary:
            'The project existed, but public claims overstate its scale and omit a recorded setback.',
        details:
            '${accomplishment.summary} ${failure.summary} The fact-check does not erase the accomplishment; it corrects the scale.',
        truthStatus: TruthStatus.verifiedTrue,
        reliability: 94,
      ),
      EvidenceItem(
        id: evidenceIds.controversy,
        type: EvidenceType.controversy,
        title: 'Questions about ${controversy.kind}',
        source: 'The Public Eye',
        summary: controversy.summary,
        details:
            '${controversy.summary} Records currently classify the allegation as ${_controversyStatusText(controversy.status)}. That status is not the same as an automatic guilt finding.',
        truthStatus: truthStatus,
        reliability: 78,
      ),
      EvidenceItem(
        id: evidenceIds.debate,
        type: EvidenceType.debateAnswer,
        title: 'Mayoral debate answer and record check',
        source: '${city.name} Public Media',
        summary:
            '$name connects the platform to past work but avoids part of the implementation tradeoff.',
        details:
            'The answer is consistent with the written platform. Its feasibility depends on budget discipline, coalition support, and the limits shown in the public record.',
        truthStatus: TruthStatus.mostlyTrue,
        reliability: 81,
      ),
    ]);
  }

  CandidateBiography _generateBiography({
    required Candidate candidate,
    required int age,
    required CandidateBackgroundTemplate background,
    required CandidateTruthProfile truth,
    required List<CandidateLifeEvent> history,
    required _EvidenceIds evidenceIds,
    ReturningCandidateOfficeRecord? priorOffice,
    ReturningCandidateCampaignRecord? priorCampaign,
  }) {
    final birthYear = 2026 - age;
    final sections = <CandidateBiographySection>[
      CandidateBiographySection(
        id: '${candidate.id}_bio_early',
        title: 'Early Life and Education',
        statements: [
          CandidateBiographyStatement(
            id: '${candidate.id}_bio_early_0',
            text:
                '${candidate.name} was born in $birthYear and completed ${background.education.join(' and ')}.',
            evidenceIds: [evidenceIds.profile],
          ),
        ],
      ),
      CandidateBiographySection(
        id: '${candidate.id}_bio_career',
        title: 'Career',
        statements: [
          CandidateBiographyStatement(
            id: '${candidate.id}_bio_career_0',
            text:
                '${candidate.name} built a career as a ${background.occupation.toLowerCase()} before the current mayoral campaign.',
            evidenceIds: [evidenceIds.profile, evidenceIds.publicRecord],
          ),
        ],
      ),
      CandidateBiographySection(
        id: '${candidate.id}_bio_record',
        title: _recordSectionTitle(background.careerOrigin),
        statements: [
          CandidateBiographyStatement(
            id: '${candidate.id}_bio_record_0',
            text: history[2].summary,
            evidenceIds: [evidenceIds.publicRecord, evidenceIds.campaign],
          ),
          CandidateBiographyStatement(
            id: '${candidate.id}_bio_record_1',
            text: history[3].summary,
            evidenceIds: [evidenceIds.publicRecord, evidenceIds.budget],
          ),
        ],
      ),
      CandidateBiographySection(
        id: '${candidate.id}_bio_positions',
        title: 'Political Positions',
        statements: [
          CandidateBiographyStatement(
            id: '${candidate.id}_bio_positions_0',
            text:
                'The campaign emphasizes ${candidate.platform.take(2).join(' and ')}.',
            evidenceIds: [evidenceIds.platform, evidenceIds.budget],
          ),
        ],
      ),
      CandidateBiographySection(
        id: '${candidate.id}_bio_controversy',
        title: 'Controversies',
        statements: [
          CandidateBiographyStatement(
            id: '${candidate.id}_bio_controversy_0',
            text: truth.controversies.last.summary,
            evidenceIds: [evidenceIds.controversy, evidenceIds.factCheck],
          ),
        ],
      ),
    ];
    if (truth.informationFootprint == CandidateInformationFootprint.minimal) {
      sections.removeAt(3);
    }
    if (priorOffice != null) {
      sections.insert(
        2,
        CandidateBiographySection(
          id: '${candidate.id}_bio_administration_${priorOffice.latestTermNumber}',
          title: 'Administration ${priorOffice.latestTermNumber}',
          statements: [
            CandidateBiographyStatement(
              id: '${candidate.id}_bio_administration_${priorOffice.latestTermNumber}_0',
              text: priorOffice.summary,
              evidenceIds: [evidenceIds.publicRecord],
            ),
            CandidateBiographyStatement(
              id: '${candidate.id}_bio_administration_${priorOffice.latestTermNumber}_1',
              text:
                  'The archived receipt records ${priorOffice.completedProjectTitles.length} completed and ${priorOffice.unresolvedProjectTitles.length} unresolved project(s).',
              evidenceIds: [evidenceIds.publicRecord, evidenceIds.budget],
            ),
          ],
        ),
      );
    } else if (priorCampaign != null) {
      sections.insert(
        2,
        CandidateBiographySection(
          id: '${candidate.id}_bio_campaign_return',
          title: 'Previous Campaigns',
          statements: [
            CandidateBiographyStatement(
              id: '${candidate.id}_bio_campaign_return_0',
              text:
                  '${candidate.name} previously contested ${priorCampaign.electionsContested} election(s), most recently Election ${priorCampaign.lastElectionTerm}, and then spent ${priorCampaign.yearsAway} cycle(s) outside the mayoral ballot.',
              evidenceIds: [evidenceIds.publicRecord],
            ),
          ],
        ),
      );
    }
    final timeline = List<CandidateLifeEvent>.of(history);
    if (priorOffice != null) {
      timeline.add(
        CandidateLifeEvent(
          id: '${candidate.id}_administration_${priorOffice.latestTermNumber}',
          year: 2025 + priorOffice.latestTermNumber,
          type: CandidateHistoryEventType.publicService,
          title:
              'Served as mayor in Administration ${priorOffice.latestTermNumber}',
          summary: priorOffice.summary,
          details:
              'The final city condition was ${priorOffice.finalCondition.toLowerCase()}. The public receipt preserves completed work, unresolved projects, and major events from the term.',
          publicVisibility: CandidatePublicVisibility.citywide,
          evidenceIds: [evidenceIds.publicRecord],
        ),
      );
    } else if (priorCampaign != null) {
      timeline.add(
        CandidateLifeEvent(
          id: '${candidate.id}_election_${priorCampaign.lastElectionTerm}',
          year: 2025 + priorCampaign.lastElectionTerm,
          type: CandidateHistoryEventType.publicService,
          title: 'Contested Election ${priorCampaign.lastElectionTerm}',
          summary:
              'The archived ballot records a previous campaign without treating defeat as proof of competence or failure.',
          details:
              'This return follows ${priorCampaign.yearsAway} election cycle(s) away. The current campaign remains a new decision with a newly generated public record.',
          publicVisibility: CandidatePublicVisibility.citywide,
          evidenceIds: [evidenceIds.publicRecord],
        ),
      );
    }
    return CandidateBiography(
      candidateId: candidate.id,
      birthYear: birthYear,
      occupation: background.occupation,
      education: List.unmodifiable(background.education),
      currentPosition: priorOffice == null
          ? background.currentPosition
          : 'Former Mayor of the city',
      publicServiceStartYear: history[1].year,
      hometown: _hometowns[_stableIndex(candidate.id, _hometowns.length)],
      previousPositions: [
        background.currentPosition,
        if (priorOffice != null)
          'Mayor, Administration ${priorOffice.latestTermNumber}',
        if (priorOffice == null && priorCampaign != null)
          'Mayoral candidate, Election ${priorCampaign.lastElectionTerm}',
      ],
      summary: candidate.biography,
      informationFootprint: truth.informationFootprint,
      sections: List.unmodifiable(sections),
      timeline: List.unmodifiable(timeline),
    );
  }

  CandidateStatementComparison _generateComparison({
    required Candidate candidate,
    required CityProblem leadProblem,
    required CandidatePromise promise,
    required List<CandidateLifeEvent> history,
    required _EvidenceIds evidenceIds,
  }) => CandidateStatementComparison(
    id: '${candidate.id}_comparison_0',
    candidateId: candidate.id,
    thenYear: history[3].year,
    thenStatement:
        'Large ${leadProblem.title.toLowerCase()} programs should begin only after stable funding is secured.',
    nowYear: 2026,
    nowStatement: promise.candidateWording,
    context:
        'The statements may reflect changed conditions, political convenience, or an evolved position. The records show the change but do not decide the interpretation for the player.',
    evidenceIds: [
      evidenceIds.platform,
      evidenceIds.budget,
      evidenceIds.publicRecord,
    ],
    relatedPromiseId: promise.id,
  );

  CandidateExperienceProfile _generateExperienceProfile({
    required Candidate candidate,
    required CandidatePortrait portrait,
    required CandidateBackgroundTemplate background,
    required CandidateRhetoricalStyle rhetoricalStyle,
    required CandidateTruthProfile truth,
    required CityProblem leadProblem,
    required List<CandidateLifeEvent> history,
    required List<CandidatePromise> promises,
    required CandidateStatementComparison comparison,
    required _EvidenceIds evidenceIds,
    required SeededRandom random,
    required CampaignNoise campaignNoise,
    ReturningCandidateOfficeRecord? priorOffice,
    ReturningCandidateCampaignRecord? priorCampaign,
  }) {
    final questions = [
      CandidateQuestion(
        id: '${candidate.id}_question_budget',
        text: truth.budgetDiscipline < 58
            ? 'Which promises would be delayed if projected revenue falls short?'
            : 'Can the council sustain the plan after its first funded year?',
        cityIssueId: leadProblem.id,
        relatedEvidenceIds: [evidenceIds.platform, evidenceIds.budget],
      ),
      CandidateQuestion(
        id: '${candidate.id}_question_relationship',
        text: truth.relationships.first.isPotentialConflict
            ? 'What safeguards separate campaign relationships from future city contracts?'
            : 'How much influence will established allies have over appointments?',
        cityIssueId: leadProblem.id,
        relatedEvidenceIds: [evidenceIds.controversy, evidenceIds.publicRecord],
      ),
    ];
    final pulse = _generatePulse(
      candidate: candidate,
      truth: truth,
      leadProblem: leadProblem,
      history: history,
      promises: promises,
      comparison: comparison,
      evidenceIds: evidenceIds,
      random: random,
      campaignNoise: campaignNoise,
    );
    return CandidateExperienceProfile(
      candidateId: candidate.id,
      identityKey: portrait.id,
      portraitAssetKey: portrait.id,
      publicIdentity: priorOffice != null
          ? 'Former mayor with ${priorOffice.termsServed} archived term(s); ${background.publicIdentity.toLowerCase()}'
          : priorCampaign != null
          ? 'Returning candidate last seen in Election ${priorCampaign.lastElectionTerm}; ${background.publicIdentity.toLowerCase()}'
          : background.publicIdentity,
      position: 'Mayor',
      rhetoricalStyle: rhetoricalStyle,
      qualityBand: truth.qualityBand,
      questions: List.unmodifiable(questions),
      pulse: List.unmodifiable(pulse),
      relations: [
        EvidenceRelation(
          fromEvidenceId: evidenceIds.social,
          toEvidenceId: evidenceIds.factCheck,
          type: EvidenceRelationType.corrects,
          explanation:
              'The fact-check verifies the project while correcting its exaggerated scale.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: evidenceIds.platform,
          toEvidenceId: evidenceIds.budget,
          type: EvidenceRelationType.exposesMissingInformation,
          explanation:
              'The independent review examines costs omitted from the campaign platform.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: evidenceIds.campaign,
          toEvidenceId: evidenceIds.publicRecord,
          type: EvidenceRelationType.addsContext,
          explanation:
              'The public record shows both the advertised result and its documented limit.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: evidenceIds.controversy,
          toEvidenceId: evidenceIds.publicRecord,
          type: EvidenceRelationType.references,
          explanation:
              'The controversy concerns a relationship documented alongside the earlier project.',
        ),
      ],
      evidenceCosts: {
        evidenceIds.profile: 0,
        evidenceIds.platform: 0,
        evidenceIds.campaign: 0,
        evidenceIds.social: 0,
        evidenceIds.publicRecord: 1,
        evidenceIds.budget: 1,
        evidenceIds.factCheck: 1,
        evidenceIds.controversy: 2,
        evidenceIds.debate: 1,
      },
    );
  }

  List<CandidateContentItem> _generatePulse({
    required Candidate candidate,
    required CandidateTruthProfile truth,
    required CityProblem leadProblem,
    required List<CandidateLifeEvent> history,
    required List<CandidatePromise> promises,
    required CandidateStatementComparison comparison,
    required _EvidenceIds evidenceIds,
    required SeededRandom random,
    required CampaignNoise campaignNoise,
  }) {
    final attentionBase = (truth.communication * 900 + random.nextInt(18000));
    final items = <CandidateContentItem>[
      CandidateContentItem(
        id: '${candidate.id}_pulse_launch',
        candidateId: candidate.id,
        type: CandidateContentType.publicEvent,
        headline: '${candidate.name} opens the mayoral campaign',
        summary:
            'The launch turns ${leadProblem.title.toLowerCase()} into the campaign\'s first major theme.',
        inspectBody:
            'The event presents ${promises.first.title.toLowerCase()} as an urgent first-term priority. Crowd enthusiasm shows attention, not feasibility.',
        deepDivePrompt:
            'Compare the campaign presentation with the platform and budget review.',
        source: '${candidate.name} campaign',
        fictionalDate: 'September 8, 2026',
        cityIssueId: leadProblem.id,
        relatedEvidenceIds: [evidenceIds.campaign, evidenceIds.platform],
        receiptKind: ReceiptKind.partiallySupported,
        media: CandidateMedia(
          assetKey: 'news_${leadProblem.visualKey}',
          aspectRatio: 16 / 9,
          altText: 'Campaign gathering about ${leadProblem.title}',
          caption: 'Campaign image released during the opening week.',
          type: CandidateMediaType.image,
          isAvailable: true,
        ),
        publicAttention: attentionBase,
      ),
      CandidateContentItem(
        id: '${candidate.id}_pulse_human',
        candidateId: candidate.id,
        type: CandidateContentType.residentReaction,
        headline: 'Former colleagues describe a demanding public servant',
        summary: history[2].summary,
        inspectBody:
            '${history[2].details} Supporters emphasize the outcome; critics emphasize its limited scale.',
        deepDivePrompt:
            'Open the public record to separate personal testimony from documented results.',
        source: 'Neighborhood Voices Desk',
        fictionalDate: 'September 13, 2026',
        cityIssueId: leadProblem.id,
        relatedEvidenceIds: [evidenceIds.profile, evidenceIds.publicRecord],
        receiptKind: ReceiptKind.accomplishmentWithCost,
        publicAttention: (attentionBase * .72).round(),
      ),
      CandidateContentItem(
        id: '${candidate.id}_pulse_promise',
        candidateId: candidate.id,
        type: CandidateContentType.campaignAd,
        headline: promises.first.title,
        summary: promises.first.candidateWording,
        inspectBody:
            '${promises.first.approach} The campaign has authority to propose the plan, but implementation still depends on funding and council support.',
        deepDivePrompt:
            'Compare the platform, cost review, and related earlier project.',
        source: '${candidate.name} campaign',
        fictionalDate: 'September 18, 2026',
        cityIssueId: leadProblem.id,
        relatedEvidenceIds: [evidenceIds.platform, evidenceIds.budget],
        receiptKind: truth.budgetDiscipline < 58
            ? ReceiptKind.promiseWithoutFunding
            : ReceiptKind.partiallySupported,
        candidateResponse:
            'The campaign says detailed sequencing will be published after the transition audit.',
        missingContext:
            'Council votes and recurring operating costs are not controlled by the mayor alone.',
        publicAttention: (attentionBase * 1.12).round(),
      ),
      CandidateContentItem(
        id: '${candidate.id}_pulse_controversy',
        candidateId: candidate.id,
        type: CandidateContentType.scandal,
        headline: 'Questions surface about ${truth.controversies.last.kind}',
        summary: truth.controversies.last.summary,
        inspectBody:
            'The relationship or event is documented. Its current status is ${_controversyStatusText(truth.controversies.last.status)}, which may leave guilt, context, or scale unresolved.',
        deepDivePrompt:
            'Open the controversy file and related public record before deciding what the relationship proves.',
        source: 'The Public Eye',
        fictionalDate: 'September 24, 2026',
        cityIssueId: leadProblem.id,
        relatedEvidenceIds: [evidenceIds.controversy, evidenceIds.publicRecord],
        receiptKind: ReceiptKind.unresolvedAllegation,
        candidateResponse:
            'The campaign says all future contracts would follow published competitive rules.',
        publicAttention: (attentionBase * 1.28).round(),
      ),
      CandidateContentItem(
        id: '${candidate.id}_pulse_correction',
        candidateId: candidate.id,
        type: CandidateContentType.factCheckAlert,
        headline: 'Fact-check: a real result becomes a much larger claim',
        summary:
            'The advertised project existed, but viral posts exaggerate its citywide reach.',
        inspectBody:
            '${history[2].summary} ${history[3].summary} Both details belong to the same record.',
        deepDivePrompt:
            'Read the original post and independent claim review together.',
        source: 'City Fact Desk',
        fictionalDate: 'October 1, 2026',
        cityIssueId: leadProblem.id,
        relatedEvidenceIds: [evidenceIds.social, evidenceIds.factCheck],
        receiptKind: ReceiptKind.missingContext,
        missingContext: comparison.context,
        publicAttention: (attentionBase * .91).round(),
      ),
    ];
    final includeHistoricalPulse = switch (campaignNoise) {
      CampaignNoise.clear =>
        truth.informationFootprint == CandidateInformationFootprint.overexposed,
      CampaignNoise.typical =>
        truth.informationFootprint.index >=
            CandidateInformationFootprint.extensive.index,
      CampaignNoise.noisy =>
        truth.informationFootprint.index >=
            CandidateInformationFootprint.normal.index,
    };
    if (includeHistoricalPulse) {
      items.add(
        CandidateContentItem(
          id: '${candidate.id}_pulse_history',
          candidateId: candidate.id,
          type: CandidateContentType.correction,
          headline: 'An older statement returns to the campaign',
          summary:
              'A previous caution about funding differs from the campaign\'s current urgency.',
          inspectBody:
              'The two statements are both authentic. Changed conditions, strategy, or inconsistency may explain the difference.',
          deepDivePrompt:
              'Review the Then vs Now context without treating change as an automatic verdict.',
          source: 'Civic Archive Monitor',
          fictionalDate: 'October 4, 2026',
          cityIssueId: leadProblem.id,
          relatedEvidenceIds: [evidenceIds.platform, evidenceIds.publicRecord],
          receiptKind: ReceiptKind.statementVersusRecord,
          publicAttention: (attentionBase * .67).round(),
        ),
      );
    }
    return List.unmodifiable(items);
  }

  (CityBookProfile, List<CityBookPost>, Map<String, CityBookCommentThread>)
  _generateCityBook({
    required Candidate candidate,
    required CandidatePortrait portrait,
    required CandidateBackgroundTemplate background,
    required CandidateTruthProfile truth,
    required City city,
    required CityProblem leadProblem,
    required List<CandidateLifeEvent> history,
    required List<CandidatePromise> promises,
    required CandidateStatementComparison comparison,
    required _EvidenceIds evidenceIds,
    required SeededRandom random,
    required CampaignNoise campaignNoise,
    ReturningCandidateOfficeRecord? priorOffice,
    ReturningCandidateCampaignRecord? priorCampaign,
  }) {
    final handle = '@${candidate.name.toLowerCase().replaceAll(' ', '.')}';
    final profile = CityBookProfile(
      candidateId: candidate.id,
      handle: handle,
      shortBio: priorOffice != null
          ? 'Former mayor · Administration ${priorOffice.latestTermNumber} record on file'
          : priorCampaign != null
          ? 'Returning candidate · Election ${priorCampaign.lastElectionTerm} ballot record'
          : background.publicIdentity,
      affiliation: candidate.party,
      publicAttention:
          ((truth.communication * 1180 + random.nextInt(18000)) *
                  _attentionMultiplier(background.careerOrigin))
              .round(),
      profileAssetKey: portrait.id,
      bannerAssetKey: 'news_${leadProblem.visualKey}',
    );
    final footprintCount = switch (truth.informationFootprint) {
      CandidateInformationFootprint.minimal => 4,
      CandidateInformationFootprint.limited => 4,
      CandidateInformationFootprint.normal => 5,
      CandidateInformationFootprint.extensive => 6,
      CandidateInformationFootprint.overexposed => 7,
    };
    final noiseDelta = switch (campaignNoise) {
      CampaignNoise.clear => -1,
      CampaignNoise.typical => 0,
      CampaignNoise.noisy => 1,
    };
    final desiredCount = (footprintCount + noiseDelta).clamp(4, 7);
    final blueprints =
        <
          ({
            CityBookPostType type,
            String text,
            List<String> evidence,
            bool historical,
            CityBookSourceTruthRelation relation,
          })
        >[
          (
            type: CityBookPostType.campaignAnnouncement,
            text:
                'Today we begin a campaign for ${city.name} that puts ${leadProblem.title.toLowerCase()} on the public record. ${candidate.slogan}',
            evidence: [evidenceIds.platform],
            historical: false,
            relation: CityBookSourceTruthRelation.candidateOpinion,
          ),
          (
            type: CityBookPostType.policyStatement,
            text: promises.first.candidateWording,
            evidence: [evidenceIds.platform, evidenceIds.budget],
            historical: false,
            relation: CityBookSourceTruthRelation.publicClaim,
          ),
          (
            type: CityBookPostType.accomplishmentClaim,
            text:
                '${history[2].summary} We can bring that same focus to city hall.',
            evidence: [evidenceIds.campaign, evidenceIds.publicRecord],
            historical: false,
            relation: CityBookSourceTruthRelation.documentedClaim,
          ),
          (
            type: CityBookPostType.criticismResponse,
            text:
                'Questions about ${truth.controversies.last.kind} deserve records, not rumors. We will publish safeguards and answer with documents.',
            evidence: [evidenceIds.controversy],
            historical: false,
            relation: CityBookSourceTruthRelation.disputedClaim,
          ),
          (
            type: CityBookPostType.historical,
            text: priorOffice == null
                ? comparison.thenStatement
                : 'Administration ${priorOffice.latestTermNumber} ended with the city rated ${priorOffice.finalCondition.toLowerCase()}. ${priorOffice.summary} Read the full public receipt, including what remained unfinished.',
            evidence: [evidenceIds.publicRecord],
            historical: true,
            relation: CityBookSourceTruthRelation.documentedClaim,
          ),
          (
            type: CityBookPostType.clarification,
            text:
                'A real pilot is being described online as a complete citywide fix. The project helped, but the larger claim needs correction.',
            evidence: [evidenceIds.social, evidenceIds.factCheck],
            historical: false,
            relation: CityBookSourceTruthRelation.correction,
          ),
          (
            type: CityBookPostType.opponentAttack,
            text:
                'Other campaigns keep announcing totals without showing retention, maintenance, or contract details. Ask for the complete receipt.',
            evidence: [evidenceIds.debate],
            historical: false,
            relation: CityBookSourceTruthRelation.candidateOpinion,
          ),
        ];
    final posts = <CityBookPost>[];
    final threads = <String, CityBookCommentThread>{};
    for (var index = 0; index < desiredCount; index++) {
      final blueprint = blueprints[index];
      final postId = '${candidate.id}_citybook_$index';
      final threadId = '${postId}_comments';
      final post = CityBookPost(
        id: postId,
        candidateId: candidate.id,
        fictionalDate: 'October ${2 + index * 3}, 2026',
        type: blueprint.type,
        text: blueprint.text,
        imageAssetKey: index < 3 ? 'news_${leadProblem.visualKey}' : null,
        imageAspectRatio: index == 0 ? 16 / 9 : 1,
        relatedIssueFamilies: [leadProblem.family],
        relatedEvidenceIds: blueprint.evidence,
        reactions: _reactions(truth, random, index),
        commentThreadId: threadId,
        historical: blueprint.historical,
        visibility: blueprint.historical
            ? CityBookVisibility.resurfaced
            : CityBookVisibility.public,
        sourceTruthRelation: blueprint.relation,
        comparisonId: blueprint.historical ? comparison.id : null,
      );
      posts.add(post);
      threads[threadId] = _commentsFor(
        post: post,
        candidate: candidate,
        leadProblem: leadProblem,
        random: random,
      );
    }
    return (profile, List.unmodifiable(posts), Map.unmodifiable(threads));
  }

  CityBookReactionDistribution _reactions(
    CandidateTruthProfile truth,
    SeededRandom random,
    int index,
  ) {
    final base = 40 + truth.communication * 2 + random.nextInt(160);
    return CityBookReactionDistribution({
      CityBookReaction.like: base + random.nextInt(base + 1),
      CityBookReaction.love: (base * .35).round() + random.nextInt(50),
      CityBookReaction.laugh: index == 3
          ? random.nextInt(base)
          : random.nextInt(30),
      CityBookReaction.shock: index == 3 ? base ~/ 2 : random.nextInt(24),
      CityBookReaction.sad: random.nextInt(26),
      CityBookReaction.angry: index == 3 ? base : random.nextInt(base ~/ 2 + 1),
      CityBookReaction.receipt: 8 + random.nextInt(70),
    });
  }

  CityBookCommentThread _commentsFor({
    required CityBookPost post,
    required Candidate candidate,
    required CityProblem leadProblem,
    required SeededRandom random,
  }) {
    const reactionEngine = CityBookCommentReactionEngine();
    final comments = <CityBookComment>[];
    for (var index = 0; index < 10; index++) {
      final archetype =
          CityBookCommentArchetype.values[(index + random.nextInt(4)) %
              CityBookCommentArchetype.values.length];
      final author =
          _commentNames[(index + random.nextInt(_commentNames.length)) %
              _commentNames.length];
      comments.add(
        CityBookComment(
          id: '${post.id}_comment_$index',
          authorName: author,
          authorHandle:
              '@${author.toLowerCase().replaceAll(' ', '')}${10 + random.nextInt(89)}',
          archetype: archetype,
          text: _commentText(
            archetype,
            candidate.name.split(' ').first,
            leadProblem.title,
            post.type,
          ),
          reactions: reactionEngine.generate(
            parentReactions: post.reactions,
            archetype: archetype,
            seed: cityBookReactionSeed('${post.id}:comment:$index:reactions'),
            commentIndex: index,
          ),
          accountClues: archetype == CityBookCommentArchetype.suspiciousAccount
              ? const ['New account', 'Repeated campaign wording']
              : const [],
        ),
      );
    }
    return CityBookCommentThread(
      id: post.commentThreadId,
      comments: List.unmodifiable(comments),
    );
  }

  String _commentText(
    CityBookCommentArchetype archetype,
    String firstName,
    String issue,
    CityBookPostType postType,
  ) => switch (archetype) {
    CityBookCommentArchetype.supporter =>
      '$firstName is finally speaking directly about ${issue.toLowerCase()}.',
    CityBookCommentArchetype.skepticalCitizen =>
      'The proposal sounds clear, but where is the complete funding schedule?',
    CityBookCommentArchetype.angryResident =>
      'Residents have waited too long for another announcement without dates.',
    CityBookCommentArchetype.sarcasticCommenter =>
      'Great caption. Does the city accept captions as project payments now?',
    CityBookCommentArchetype.oppositionSupporter =>
      'The other candidates have records too. This post leaves out the comparison.',
    CityBookCommentArchetype.campaignVolunteer =>
      'The full platform and neighborhood schedule are available through the campaign page.',
    CityBookCommentArchetype.suspiciousAccount =>
      '$firstName has already solved this. Everyone else is hiding the truth!',
    CityBookCommentArchetype.affectedResident =>
      '${issue.toLowerCase()} affects our block every week. We need a measurable first step.',
    CityBookCommentArchetype.confusedCommenter =>
      'Is this a completed project, a promise, or a proposal? The post mixes them together.',
    CityBookCommentArchetype.jokeCommenter =>
      postType == CityBookPostType.historical
          ? 'Old post, new campaign, same comment section.'
          : 'I will believe the timeline when the traffic also believes it.',
    CityBookCommentArchetype.policyFocusedCitizen =>
      'Publish staffing, recurring costs, procurement dates, and the responsible offices.',
    CityBookCommentArchetype.habitualCritic =>
      'Every campaign says this until the council meeting starts.',
  };

  (UnderlyingNewsEvent, List<NewsCoverage>) _generateCandidateNews({
    required Candidate candidate,
    required CityProblem leadProblem,
    required List<CandidateLifeEvent> history,
    required CandidateTruthProfile truth,
    required _EvidenceIds evidenceIds,
    ReturningCandidateOfficeRecord? priorOffice,
  }) {
    final eventId = '${candidate.id}_news_record';
    final controversy = truth.controversies.last;
    final event = UnderlyingNewsEvent(
      id: eventId,
      fictionalDate: 'October 12, 2026',
      title: priorOffice == null
          ? '${candidate.name}\'s earlier project returns to campaign debate'
          : '${candidate.name}\'s Administration ${priorOffice.latestTermNumber} record returns to campaign debate',
      eventType: 'candidate_record',
      relatedIssueFamily: leadProblem.family,
      relatedCandidateIds: [candidate.id],
      factualSummary: priorOffice == null
          ? '${history[2].summary} ${history[3].summary} Questions about ${controversy.kind} remain ${_controversyStatusText(controversy.status)}.'
          : '${priorOffice.summary} The archived receipt lists ${priorOffice.completedProjectTitles.length} completed and ${priorOffice.unresolvedProjectTitles.length} unresolved project(s). Questions about ${controversy.kind} remain ${_controversyStatusText(controversy.status)}.',
      knownFacts: priorOffice == null
          ? [history[2].summary, history[3].summary]
          : [
              priorOffice.summary,
              ...priorOffice.completedProjectTitles.map(
                (title) => 'Completed project: $title',
              ),
              ...priorOffice.unresolvedProjectTitles.map(
                (title) => 'Unresolved project: $title',
              ),
            ],
      disputedFacts: [controversy.summary],
      evidenceIds: [
        evidenceIds.publicRecord,
        evidenceIds.controversy,
        evidenceIds.factCheck,
      ],
      publicImpact: 45 + truth.communication ~/ 2,
      importance: 48 + truth.experience ~/ 2,
      imageAssetKey: 'news_${leadProblem.visualKey}',
      chronicleVisibility: false,
    );
    final coverages = <NewsCoverage>[
      NewsCoverage(
        id: '${eventId}_outlet_daily',
        eventId: eventId,
        outletId: 'outlet_daily',
        category: 'Election Record',
        publicationTime: 'October 12, 2026 · 8:15 AM',
        headline: priorOffice == null
            ? '${candidate.name} record shows result and delayed follow-through'
            : '${candidate.name} asks voters to weigh archived City Hall record',
        subheadline:
            'Public documents confirm an achievement alongside a documented limit.',
        articleSummary: event.factualSummary,
        framingAngle: 'Public record and chronology',
        articleBody: [
          if (priorOffice != null) priorOffice.summary else history[2].summary,
          if (priorOffice != null)
            'The receipt records ${priorOffice.completedProjectTitles.length} completed and ${priorOffice.unresolvedProjectTitles.length} unresolved project(s).'
          else
            history[3].summary,
          'The available record supports both facts. The controversy remains ${_controversyStatusText(controversy.status)}.',
        ],
      ),
      NewsCoverage(
        id: '${eventId}_outlet_wire',
        eventId: eventId,
        outletId: 'outlet_wire',
        category: 'Campaign Watch',
        publicationTime: 'October 12, 2026 · 9:40 AM',
        headline: priorOffice == null
            ? 'QUESTIONS FOLLOW ${candidate.name.toUpperCase()} PROJECT CLAIM'
            : 'QUESTIONS FOLLOW ${candidate.name.toUpperCase()} CITY HALL RECORD',
        subheadline:
            'A campaign achievement faces renewed scrutiny over cost, timing, and relationships.',
        articleSummary:
            'The project delivered a result, but critics say the campaign omits its setback and unresolved questions.',
        framingAngle: 'Conflict, omissions, and political pressure',
        articleBody: [
          controversy.summary,
          if (priorOffice != null) priorOffice.summary else history[3].summary,
          'The sharper framing does not change the underlying project record or controversy status.',
        ],
      ),
      NewsCoverage(
        id: '${eventId}_outlet_lantern',
        eventId: eventId,
        outletId: 'outlet_lantern',
        category: 'Election Context',
        publicationTime: 'October 12, 2026 · 11:10 AM',
        headline: priorOffice == null
            ? 'What ${candidate.name}\'s mixed project record can—and cannot—prove'
            : 'What ${candidate.name}\'s governing record can—and cannot—prove',
        subheadline:
            'One earlier project offers evidence of capacity, limits, and unanswered safeguards.',
        articleSummary:
            'The same record contains a genuine accomplishment, a documented failure, and a controversy with a specific truth status.',
        framingAngle: 'Context, trade-offs, and limits of inference',
        articleBody: [
          if (priorOffice != null) priorOffice.summary else history[2].summary,
          if (priorOffice != null)
            'The archived term is direct evidence of outcomes under one set of city conditions, not a guarantee of the next term.'
          else
            history[3].summary,
          'A past project can inform judgment without perfectly predicting a future administration.',
        ],
      ),
    ];
    final ids = coverages.map((coverage) => coverage.id).toList();
    return (
      event,
      List.unmodifiable([
        for (final coverage in coverages)
          NewsCoverage(
            id: coverage.id,
            eventId: coverage.eventId,
            outletId: coverage.outletId,
            category: coverage.category,
            publicationTime: coverage.publicationTime,
            headline: coverage.headline,
            subheadline: coverage.subheadline,
            articleSummary: coverage.articleSummary,
            framingAngle: coverage.framingAngle,
            articleBody: coverage.articleBody,
            relatedCoverageIds: ids
                .where((id) => id != coverage.id)
                .toList(growable: false),
          ),
      ]),
    );
  }

  List<DebateTopic> _generateDebate(
    int worldSeed,
    City city,
    List<_CandidateBuild> builds,
  ) {
    final ranked = [...city.problems]
      ..sort((a, b) => b.issueWeight.compareTo(a.issueWeight));
    return List.unmodifiable([
      for (var topicIndex = 0; topicIndex < 3; topicIndex++)
        _debateTopic(
          worldSeed,
          topicIndex,
          ranked[topicIndex % ranked.length],
          builds,
        ),
    ]);
  }

  DebateTopic _debateTopic(
    int worldSeed,
    int topicIndex,
    CityProblem problem,
    List<_CandidateBuild> builds,
  ) {
    final random = _random(worldSeed, 'electionMedia:debate:$topicIndex');
    final messages = <DebateMessage>[
      DebateMessage(
        id: 'debate_${topicIndex}_moderator',
        topicId: 'debate_topic_$topicIndex',
        speakerId: 'moderator',
        type: DebateMessageType.moderator,
        text:
            '${problem.description} What is your first measurable action, and what tradeoff should residents expect?',
        sequence: 0,
        publicReaction: PublicReaction.mixed,
        bookmarkable: false,
      ),
    ];
    for (var index = 0; index < builds.length; index++) {
      final build = builds[index];
      final promise = build.promises.firstWhere(
        (item) => item.relatedIssueFamilies.contains(problem.family),
        orElse: () => build.promises.first,
      );
      final style = build.profile.rhetoricalStyle;
      messages.add(
        DebateMessage(
          id: 'debate_${topicIndex}_${build.candidate.id}_claim',
          topicId: 'debate_topic_$topicIndex',
          speakerId: build.candidate.id,
          type: DebateMessageType.claim,
          text: _debateAnswer(
            build.candidate.name,
            promise,
            style,
            build.priorOffice,
          ),
          sequence: messages.length,
          publicReaction: PublicReaction
              .values[random.nextInt(PublicReaction.values.length)],
          referencedEvidenceIds: [
            '${build.candidate.id}_evidence_platform',
            '${build.candidate.id}_evidence_debate',
          ],
          relatedPromiseIds: [promise.id],
          relatedHistoryEventIds: promise.relatedHistoryEventIds,
        ),
      );
    }
    final attacker = builds[(topicIndex + 1) % builds.length];
    final target = builds[(topicIndex + 3) % builds.length];
    final targetClaim = 'debate_${topicIndex}_${target.candidate.id}_claim';
    messages.add(
      DebateMessage(
        id: 'debate_${topicIndex}_${attacker.candidate.id}_rebuttal',
        topicId: 'debate_topic_$topicIndex',
        speakerId: attacker.candidate.id,
        type: DebateMessageType.rebuttal,
        text:
            '${target.candidate.name} is describing an announcement. The record still needs a funding schedule and named responsible offices.',
        sequence: messages.length,
        publicReaction: PublicReaction.surprised,
        referencedEvidenceIds: [
          '${target.candidate.id}_evidence_budget',
          '${attacker.candidate.id}_evidence_debate',
        ],
        contradictedByIds: ['${target.candidate.id}_evidence_platform'],
        relatedMessageIds: [targetClaim],
      ),
    );
    messages.add(
      DebateMessage(
        id: 'debate_${topicIndex}_${target.candidate.id}_response',
        topicId: 'debate_topic_$topicIndex',
        speakerId: target.candidate.id,
        type: DebateMessageType.response,
        text:
            'The cost review identifies real limits. It does not erase the first action or the earlier documented result.',
        sequence: messages.length,
        publicReaction: PublicReaction.mixed,
        referencedEvidenceIds: [
          '${target.candidate.id}_evidence_budget',
          '${target.candidate.id}_evidence_public_record',
        ],
        relatedMessageIds: [targetClaim],
      ),
    );
    messages.add(
      DebateMessage(
        id: 'debate_${topicIndex}_record_desk',
        topicId: 'debate_topic_$topicIndex',
        speakerId: 'record_desk',
        type: DebateMessageType.recordCheck,
        text:
            'Record Desk: every answer links to a saved platform, budget, debate, or project record. Public reaction is not a truth finding.',
        sequence: messages.length,
        publicReaction: PublicReaction.mixed,
        referencedEvidenceIds: [
          for (final build in builds) '${build.candidate.id}_evidence_debate',
        ],
        bookmarkable: false,
      ),
    );
    return DebateTopic(
      id: 'debate_topic_$topicIndex',
      title: problem.title,
      cityProblemId: problem.id,
      messages: List.unmodifiable(messages),
      issueFamilies: [problem.family],
    );
  }

  String _debateAnswer(
    String name,
    CandidatePromise promise,
    CandidateRhetoricalStyle style,
    ReturningCandidateOfficeRecord? priorOffice,
  ) {
    final answer = switch (style) {
      CandidateRhetoricalStyle.technical ||
      CandidateRhetoricalStyle.statisticHeavy =>
        '${promise.approach} I will publish the first benchmark and responsible office, not just a launch date.',
      CandidateRhetoricalStyle.charismatic ||
      CandidateRhetoricalStyle.emotional ||
      CandidateRhetoricalStyle.storyDriven =>
        '${promise.candidateWording} Residents have waited long enough to see the first visible step.',
      CandidateRhetoricalStyle.aggressive ||
      CandidateRhetoricalStyle.attackFocused ||
      CandidateRhetoricalStyle.sarcastic =>
        '${promise.candidateWording} Unlike the old promises, this one will have a public deadline.',
      CandidateRhetoricalStyle.evasive =>
        '$name will bring every responsible office to the table. The final sequence will follow the transition audit.',
      CandidateRhetoricalStyle.calm || CandidateRhetoricalStyle.conciliatory =>
        '${promise.approach} The first step must work with the council and affected communities.',
    };
    if (priorOffice == null) return answer;
    return '$answer Voters can compare this promise with the sealed Administration ${priorOffice.latestTermNumber} receipt, including ${priorOffice.unresolvedProjectTitles.length} project(s) that remained unresolved.';
  }

  List<CandidateInformationRelation> _informationRelations(
    String candidateId,
    List<CandidatePromise> promises,
    List<CandidateLifeEvent> history,
  ) => [
    for (var index = 0; index < promises.length; index++)
      CandidateInformationRelation(
        from: CandidateInformationReference(
          kind: CandidateInformationKind.promise,
          id: promises[index].id,
        ),
        to: CandidateInformationReference(
          kind: CandidateInformationKind.historyEvent,
          id: promises[index].relatedHistoryEventIds.first,
        ),
        type: CandidateRelationType.references,
        explanation:
            'The promise invokes an earlier project outcome from the same candidate history.',
      ),
  ];

  String _quickBiography(
    String name,
    int age,
    CandidateBackgroundTemplate background,
    CandidateTruthProfile truth,
    List<CandidateLifeEvent> history,
  ) =>
      '$name, $age, is a ${background.occupation.toLowerCase()} and ${background.currentPosition.toLowerCase()}. ${history[2].summary} ${history[3].summary} The available record also contains ${truth.controversies.last.kind} questions that require context.';

  String _recordSectionTitle(CandidateCareerOrigin origin) => switch (origin) {
    CandidateCareerOrigin.careerPolitician ||
    CandidateCareerOrigin.publicAdministrator => 'Public Service Record',
    CandidateCareerOrigin.business => 'Business and Management Record',
    CandidateCareerOrigin.celebrityMedia => 'Media and Public Work',
    CandidateCareerOrigin.community ||
    CandidateCareerOrigin.advocacy => 'Community and Advocacy Record',
    CandidateCareerOrigin.publicSafety => 'Public Safety Record',
    CandidateCareerOrigin.professional => 'Professional Record',
  };

  String _recordTitle(CandidateCareerOrigin origin) => switch (origin) {
    CandidateCareerOrigin.careerPolitician ||
    CandidateCareerOrigin.publicAdministrator =>
      'Projects and public-service record',
    CandidateCareerOrigin.business =>
      'Company, employment, and management record',
    CandidateCareerOrigin.celebrityMedia =>
      'Broadcast, endorsement, and charity archive',
    CandidateCareerOrigin.community || CandidateCareerOrigin.advocacy =>
      'Community programs and organization record',
    CandidateCareerOrigin.publicSafety =>
      'Service, training, and response record',
    CandidateCareerOrigin.professional =>
      'Professional license and project record',
  };

  String _recordSource(CandidateCareerOrigin origin, String cityName) =>
      switch (origin) {
        CandidateCareerOrigin.careerPolitician ||
        CandidateCareerOrigin.publicAdministrator =>
          '$cityName Transparency Portal',
        CandidateCareerOrigin.business =>
          '$cityName Corporate Registry and Labor Desk',
        CandidateCareerOrigin.celebrityMedia =>
          'Fictional Broadcast and Charity Archive',
        CandidateCareerOrigin.community || CandidateCareerOrigin.advocacy =>
          '$cityName Civic Organization Archive',
        CandidateCareerOrigin.publicSafety =>
          '$cityName Service and Training Archive',
        CandidateCareerOrigin.professional => '$cityName Professional Registry',
      };

  double _attentionMultiplier(CandidateCareerOrigin origin) => switch (origin) {
    CandidateCareerOrigin.celebrityMedia => 3.2,
    CandidateCareerOrigin.careerPolitician => 1.25,
    CandidateCareerOrigin.business => 1.15,
    CandidateCareerOrigin.publicAdministrator ||
    CandidateCareerOrigin.publicSafety => .9,
    CandidateCareerOrigin.community || CandidateCareerOrigin.advocacy => .78,
    CandidateCareerOrigin.professional => .85,
  };

  List<String> _visibleStrengths(
    CandidateBackgroundTemplate background,
    CandidateTruthProfile truth,
  ) {
    final strongest = truth.policyScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return List.unmodifiable([
      'Documented ${background.occupation.toLowerCase()} experience',
      'Strongest public record in ${_indicatorLabel(strongest.first.key)}',
    ]);
  }

  List<String> _visibleConcerns(
    CandidateTruthProfile truth,
    List<CandidateLifeEvent> history,
  ) {
    final weakest = truth.policyScores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return List.unmodifiable([
      history[3].title,
      'Limited record in ${_indicatorLabel(weakest.first.key)}',
      'Questions about ${truth.controversies.last.kind}',
    ]);
  }

  String _indicatorLabel(String name) {
    final spaced = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)!.toLowerCase()}',
    );
    return spaced;
  }

  CandidateQualityBand _qualityBand(SeededRandom random) {
    final roll = random.nextInt(100);
    return switch (roll) {
      < 18 => CandidateQualityBand.strong,
      < 40 => CandidateQualityBand.compromised,
      < 66 => CandidateQualityBand.mixed,
      < 86 => CandidateQualityBand.weak,
      _ => CandidateQualityBand.dangerous,
    };
  }

  int _ageFor(CandidateAgeGroup group, SeededRandom random) => switch (group) {
    CandidateAgeGroup.youngAdult => 32 + random.nextInt(11),
    CandidateAgeGroup.middleAged => 43 + random.nextInt(15),
    CandidateAgeGroup.olderAdult => 58 + random.nextInt(12),
  };

  String _takeUnique(
    List<String> pool,
    Set<String> used,
    SeededRandom random, {
    required String fallbackPrefix,
  }) {
    for (var attempt = 0; attempt < pool.length * 2; attempt++) {
      final value = pool[random.nextInt(pool.length)];
      if (used.add(value)) return value;
    }
    var suffix = 2;
    while (!used.add('$fallbackPrefix $suffix')) {
      suffix++;
    }
    return '$fallbackPrefix $suffix';
  }

  List<String> _slogansFor(CityProblem problem) => [
    ..._slogans,
    'A real plan for ${problem.title.toLowerCase()}.',
    'Fix the record. Build the future.',
    'Every district deserves proof.',
  ];

  String _controversyStatusText(CandidateControversyStatus status) =>
      switch (status) {
        CandidateControversyStatus.verified => 'verified',
        CandidateControversyStatus.stronglySupported => 'strongly supported',
        CandidateControversyStatus.partiallySupported => 'partially supported',
        CandidateControversyStatus.disputed => 'disputed',
        CandidateControversyStatus.unresolved => 'unresolved',
        CandidateControversyStatus.misleading => 'misleading',
        CandidateControversyStatus.falseAccusation => 'a false accusation',
      };

  TruthStatus _evidenceStatus(CandidateControversyStatus status) =>
      switch (status) {
        CandidateControversyStatus.verified => TruthStatus.verifiedTrue,
        CandidateControversyStatus.stronglySupported => TruthStatus.mostlyTrue,
        CandidateControversyStatus.partiallySupported =>
          TruthStatus.partiallyTrue,
        CandidateControversyStatus.disputed ||
        CandidateControversyStatus.unresolved => TruthStatus.unverified,
        CandidateControversyStatus.misleading => TruthStatus.misleading,
        CandidateControversyStatus.falseAccusation => TruthStatus.falseClaim,
      };

  int _seed(int worldSeed, String path) => SeedDerivation.derive(
    worldSeed: worldSeed,
    generationVersion: generationVersion,
    path: path,
  );

  SeededRandom _random(int worldSeed, String path) =>
      SeededRandom(_seed(worldSeed, path));

  int _stableIndex(String value, int length) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = ((hash * 31) + unit) & 0x7fffffff;
    }
    return hash % length;
  }
}

class _EvidenceIds {
  const _EvidenceIds(this.candidateId);
  final String candidateId;
  String get profile => '${candidateId}_evidence_profile';
  String get platform => '${candidateId}_evidence_platform';
  String get campaign => '${candidateId}_evidence_campaign';
  String get publicRecord => '${candidateId}_evidence_public_record';
  String get budget => '${candidateId}_evidence_budget';
  String get social => '${candidateId}_evidence_social';
  String get factCheck => '${candidateId}_evidence_fact_check';
  String get controversy => '${candidateId}_evidence_controversy';
  String get debate => '${candidateId}_evidence_debate';
}

class _CandidateBuild {
  const _CandidateBuild({
    required this.portrait,
    required this.background,
    required this.candidate,
    required this.truth,
    required this.biography,
    required this.promises,
    required this.comparison,
    required this.profile,
    required this.informationRelations,
    required this.cityBookProfile,
    required this.cityBookPosts,
    required this.commentThreads,
    required this.newsEvent,
    required this.newsCoverages,
    this.priorOffice,
  });
  final CandidatePortrait portrait;
  final CandidateBackgroundTemplate background;
  final Candidate candidate;
  final CandidateTruthProfile truth;
  final CandidateBiography biography;
  final List<CandidatePromise> promises;
  final CandidateStatementComparison comparison;
  final CandidateExperienceProfile profile;
  final List<CandidateInformationRelation> informationRelations;
  final CityBookProfile cityBookProfile;
  final List<CityBookPost> cityBookPosts;
  final Map<String, CityBookCommentThread> commentThreads;
  final UnderlyingNewsEvent newsEvent;
  final List<NewsCoverage> newsCoverages;
  final ReturningCandidateOfficeRecord? priorOffice;
}

const _femaleFirstNames = <String>[
  'Andrea',
  'Bianca',
  'Carla',
  'Danica',
  'Elena',
  'Farah',
  'Gabriela',
  'Inez',
  'Joanna',
  'Katrina',
  'Lara',
  'Marisol',
  'Nadia',
  'Patricia',
  'Rina',
  'Samira',
  'Teresa',
  'Valerie',
  'Yasmin',
  'Amihan',
];
const _maleFirstNames = <String>[
  'Adrian',
  'Benedicto',
  'Carlo',
  'Dante',
  'Emilio',
  'Felix',
  'Gabriel',
  'Hector',
  'Isaac',
  'Jonas',
  'Luis',
  'Marco',
  'Nicolas',
  'Paolo',
  'Rafael',
  'Samuel',
  'Tomas',
  'Vicente',
  'Warren',
  'Xavier',
];
const _surnames = <String>[
  'Alcantara',
  'Bautista',
  'Castillo',
  'Dela Cruz',
  'Espino',
  'Flores',
  'Garcia',
  'Herrera',
  'Ignacio',
  'Jimenez',
  'Lazaro',
  'Mendoza',
  'Navarro',
  'Ocampo',
  'Pascual',
  'Quinto',
  'Ramos',
  'Salonga',
  'Tolentino',
  'Villanueva',
  'Yu',
];
const _partyNames = <String>[
  'Bayanihan Coalition',
  'Harbor Reform League',
  'People First Movement',
  'Civic Renewal Party',
  'Common Future Alliance',
  'Neighborhood Action Bloc',
  'Public Trust Movement',
  'Forward Together Party',
  'City Service Alliance',
  'Bagong Bay Civic Union',
  'Independent Citizens League',
  'Progress and Proof Coalition',
];
const _slogans = <String>[
  'A city that works for every street.',
  'Repair today. Prepare tomorrow.',
  'Public money, public proof.',
  'Work with dignity, services with care.',
  'Steady hands for a changing city.',
  'Services first, slogans second.',
  'A plan residents can inspect.',
  'Build trust through visible work.',
  'One city, every neighborhood.',
  'Practical work. Public receipts.',
];
const _candidateColors = <int>[
  0xFF9B4D72,
  0xFFCC6B32,
  0xFF397D75,
  0xFF3F6FA5,
  0xFF8B5A3C,
];
const _controversyKinds = <String>[
  'contractor relationships',
  'questionable procurement',
  'campaign donations',
  'a conflict of interest',
  'project cost overruns',
  'party switching',
  'an inconsistent policy position',
  'a misleading public statistic',
  'a family appointment',
];
const _organizationNames = <String>[
  'North Harbor Builders',
  'Bayline Medical Supply Cooperative',
  'United Market Vendors Association',
  'Civic Transport Operators Council',
  'Green Shore Foundation',
  'Metro Small Business Federation',
  'Public Workers Alliance',
  'Safe Water Partnership',
];
const _hometowns = <String>[
  'North Harbor',
  'San Isidro District',
  'Old Market Ward',
  'Riverside East',
  'South Bay',
  'Hillcrest',
  'Portside',
  'Central Commons',
];
const _commentNames = <String>[
  'Ana Cruz',
  'Ben Reyes',
  'Cora Lim',
  'Dino Flores',
  'Ella Santos',
  'Francis Yu',
  'Grace Ramos',
  'Hugo Pascual',
  'Ivy Navarro',
  'Jomar Castillo',
  'Kai Mendoza',
  'Luz Herrera',
  'Mina Garcia',
  'Noel Bautista',
];
