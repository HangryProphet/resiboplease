import '../../domain/models/candidate.dart';
import '../../domain/models/candidate_biography.dart';
import '../../domain/models/candidate_experience.dart';
import '../../domain/models/candidate_generation.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_problem.dart';
import '../../domain/models/citybook.dart';
import '../../domain/models/evidence_item.dart';
import '../../domain/models/news_media.dart';
import '../../domain/models/procedural_election.dart';

abstract final class ProceduralElectionCodec {
  static Map<String, Object?> encode(ProceduralElection election) => {
    'generation_version': election.generationVersion,
    'portrait_ids': election.portraitIds,
    'candidates': election.candidates.map(_candidateToJson).toList(),
    'truth_profiles': {
      for (final entry in election.truthProfiles.entries)
        entry.key: _truthToJson(entry.value),
    },
    'candidate_experience': _experienceToJson(election.candidateExperience),
    'citybook': _cityBookToJson(election.cityBook),
    'candidate_news_events': election.candidateNewsEvents
        .map(_newsEventToJson)
        .toList(),
    'candidate_news_coverages': election.candidateNewsCoverages
        .map(_newsCoverageToJson)
        .toList(),
  };

  static ProceduralElection decode(Map<String, Object?> json) {
    final election = ProceduralElection(
      generationVersion: _int(json, 'generation_version'),
      portraitIds: _strings(json, 'portrait_ids'),
      candidates: _maps(json, 'candidates').map(_candidateFromJson).toList(),
      truthProfiles: _map(json['truth_profiles'], 'truth_profiles').map(
        (key, value) =>
            MapEntry(key, _truthFromJson(_map(value, 'truth_profiles.$key'))),
      ),
      candidateExperience: _experienceFromJson(
        _map(json['candidate_experience'], 'candidate_experience'),
      ),
      cityBook: _cityBookFromJson(_map(json['citybook'], 'citybook')),
      candidateNewsEvents: _maps(
        json,
        'candidate_news_events',
      ).map(_newsEventFromJson).toList(),
      candidateNewsCoverages: _maps(
        json,
        'candidate_news_coverages',
      ).map(_newsCoverageFromJson).toList(),
    );
    final errors = election.validate();
    if (errors.isNotEmpty) {
      throw FormatException(
        'Saved procedural election is inconsistent: ${errors.join(' | ')}',
      );
    }
    return election;
  }

  static Map<String, Object?> _candidateToJson(Candidate candidate) => {
    'id': candidate.id,
    'name': candidate.name,
    'party': candidate.party,
    'archetype': candidate.archetype,
    'slogan': candidate.slogan,
    'biography': candidate.biography,
    'visible_strengths': candidate.visibleStrengths,
    'visible_concerns': candidate.visibleConcerns,
    'platform': candidate.platform,
    'evidence': candidate.evidence.map(_evidenceToJson).toList(),
    'capabilities': {
      'policy_scores': {
        for (final entry in candidate.capabilities.policyScores.entries)
          entry.key.name: entry.value,
      },
      'implementation_skill': candidate.capabilities.implementationSkill,
      'integrity': candidate.capabilities.integrity,
      'coalition_skill': candidate.capabilities.coalitionSkill,
      'crisis_response': candidate.capabilities.crisisResponse,
      'budget_discipline': candidate.capabilities.budgetDiscipline,
      'corruption_risk': candidate.capabilities.corruptionRisk,
    },
    'color_value': candidate.colorValue,
  };

  static Candidate _candidateFromJson(Map<String, Object?> json) {
    final capabilities = _map(json['capabilities'], 'capabilities');
    final policyScores = _map(capabilities['policy_scores'], 'policy_scores')
        .map(
          (key, value) => MapEntry(
            _enum(CityIndicator.values, key, 'policy_scores.$key'),
            _number(value, 'policy_scores.$key').toInt(),
          ),
        );
    return Candidate(
      id: _text(json, 'id'),
      name: _text(json, 'name'),
      party: _text(json, 'party'),
      archetype: _text(json, 'archetype'),
      slogan: _text(json, 'slogan'),
      biography: _text(json, 'biography'),
      visibleStrengths: _strings(json, 'visible_strengths'),
      visibleConcerns: _strings(json, 'visible_concerns'),
      platform: _strings(json, 'platform'),
      evidence: _maps(json, 'evidence').map(_evidenceFromJson).toList(),
      capabilities: CandidateCapabilities(
        policyScores: policyScores,
        implementationSkill: _int(capabilities, 'implementation_skill'),
        integrity: _int(capabilities, 'integrity'),
        coalitionSkill: _int(capabilities, 'coalition_skill'),
        crisisResponse: _int(capabilities, 'crisis_response'),
        budgetDiscipline: _int(capabilities, 'budget_discipline'),
        corruptionRisk: _int(capabilities, 'corruption_risk'),
      ),
      colorValue: _int(json, 'color_value'),
    );
  }

  static Map<String, Object?> _evidenceToJson(EvidenceItem evidence) => {
    'id': evidence.id,
    'type': evidence.type.name,
    'title': evidence.title,
    'source': evidence.source,
    'summary': evidence.summary,
    'details': evidence.details,
    'truth_status': evidence.truthStatus.name,
    'reliability': evidence.reliability,
  };

  static EvidenceItem _evidenceFromJson(Map<String, Object?> json) =>
      EvidenceItem(
        id: _text(json, 'id'),
        type: _enum(EvidenceType.values, json['type'], 'type'),
        title: _text(json, 'title'),
        source: _text(json, 'source'),
        summary: _text(json, 'summary'),
        details: _text(json, 'details'),
        truthStatus: _enum(
          TruthStatus.values,
          json['truth_status'],
          'truth_status',
        ),
        reliability: _int(json, 'reliability'),
      );

  static Map<String, Object?> _truthToJson(CandidateTruthProfile truth) => {
    'quality_band': truth.qualityBand.name,
    'general_competence': truth.generalCompetence,
    'implementation_skill': truth.implementationSkill,
    'integrity': truth.integrity,
    'corruption_risk': truth.corruptionRisk,
    'coalition_skill': truth.coalitionSkill,
    'communication': truth.communication,
    'budget_discipline': truth.budgetDiscipline,
    'crisis_response': truth.crisisResponse,
    'adaptability': truth.adaptability,
    'experience': truth.experience,
    'populism': truth.populism,
    'ambition': truth.ambition,
    'policy_scores': truth.policyScores,
    'motivations': truth.motivations,
    'hidden_risks': truth.hiddenRisks,
    'information_footprint': truth.informationFootprint.name,
    'personality_tags': truth.personalityTags,
    'controversies': truth.controversies
        .map(
          (item) => {
            'id': item.id,
            'kind': item.kind,
            'summary': item.summary,
            'status': item.status.name,
            'related_issue_keys': item.relatedIssueKeys,
          },
        )
        .toList(),
    'relationships': truth.relationships
        .map(
          (item) => {
            'id': item.id,
            'name': item.name,
            'type': item.type.name,
            'summary': item.summary,
            'is_potential_conflict': item.isPotentialConflict,
          },
        )
        .toList(),
  };

  static CandidateTruthProfile _truthFromJson(Map<String, Object?> json) =>
      CandidateTruthProfile(
        qualityBand: _enum(
          CandidateQualityBand.values,
          json['quality_band'],
          'quality_band',
        ),
        generalCompetence: _int(json, 'general_competence'),
        implementationSkill: _int(json, 'implementation_skill'),
        integrity: _int(json, 'integrity'),
        corruptionRisk: _int(json, 'corruption_risk'),
        coalitionSkill: _int(json, 'coalition_skill'),
        communication: _int(json, 'communication'),
        budgetDiscipline: _int(json, 'budget_discipline'),
        crisisResponse: _int(json, 'crisis_response'),
        adaptability: _int(json, 'adaptability'),
        experience: _int(json, 'experience'),
        populism: _int(json, 'populism'),
        ambition: _int(json, 'ambition'),
        policyScores: _intMap(json['policy_scores'], 'policy_scores'),
        motivations: _strings(json, 'motivations'),
        hiddenRisks: _strings(json, 'hidden_risks'),
        informationFootprint: _enum(
          CandidateInformationFootprint.values,
          json['information_footprint'],
          'information_footprint',
        ),
        personalityTags: _strings(json, 'personality_tags'),
        controversies: _maps(json, 'controversies')
            .map(
              (item) => CandidateControversyTruth(
                id: _text(item, 'id'),
                kind: _text(item, 'kind'),
                summary: _text(item, 'summary'),
                status: _enum(
                  CandidateControversyStatus.values,
                  item['status'],
                  'status',
                ),
                relatedIssueKeys: _strings(item, 'related_issue_keys'),
              ),
            )
            .toList(),
        relationships: _maps(json, 'relationships')
            .map(
              (item) => CandidateRelationshipTruth(
                id: _text(item, 'id'),
                name: _text(item, 'name'),
                type: _enum(
                  CandidateRelationshipType.values,
                  item['type'],
                  'type',
                ),
                summary: _text(item, 'summary'),
                isPotentialConflict: _bool(item, 'is_potential_conflict'),
              ),
            )
            .toList(),
      );

  static Map<String, Object?> _experienceToJson(
    CandidateExperienceCatalog catalog,
  ) => {
    'profiles': {
      for (final entry in catalog.profiles.entries)
        entry.key: _profileToJson(entry.value),
    },
    'debate_topics': catalog.debateTopics.map(_debateTopicToJson).toList(),
    'biographies': {
      for (final entry in catalog.biographies.entries)
        entry.key: _biographyToJson(entry.value),
    },
    'promises': catalog.promises.map(_promiseToJson).toList(),
    'comparisons': catalog.comparisons.map(_comparisonToJson).toList(),
    'information_relations': catalog.informationRelations
        .map(_candidateInformationRelationToJson)
        .toList(),
  };

  static CandidateExperienceCatalog _experienceFromJson(
    Map<String, Object?> json,
  ) => CandidateExperienceCatalog(
    profiles: _map(json['profiles'], 'profiles').map(
      (key, value) =>
          MapEntry(key, _profileFromJson(_map(value, 'profiles.$key'))),
    ),
    debateTopics: _maps(
      json,
      'debate_topics',
    ).map(_debateTopicFromJson).toList(),
    biographies: _map(json['biographies'], 'biographies').map(
      (key, value) =>
          MapEntry(key, _biographyFromJson(_map(value, 'biographies.$key'))),
    ),
    promises: _maps(json, 'promises').map(_promiseFromJson).toList(),
    comparisons: _maps(json, 'comparisons').map(_comparisonFromJson).toList(),
    informationRelations: _maps(
      json,
      'information_relations',
    ).map(_candidateInformationRelationFromJson).toList(),
  );

  static Map<String, Object?> _profileToJson(
    CandidateExperienceProfile profile,
  ) => {
    'candidate_id': profile.candidateId,
    'identity_key': profile.identityKey,
    'portrait_asset_key': profile.portraitAssetKey,
    'public_identity': profile.publicIdentity,
    'position': profile.position,
    'rhetorical_style': profile.rhetoricalStyle.name,
    'quality_band': profile.qualityBand.name,
    'questions': profile.questions.map(_questionToJson).toList(),
    'pulse': profile.pulse.map(_contentToJson).toList(),
    'relations': profile.relations.map(_evidenceRelationToJson).toList(),
    'evidence_costs': profile.evidenceCosts,
  };

  static CandidateExperienceProfile _profileFromJson(
    Map<String, Object?> json,
  ) => CandidateExperienceProfile(
    candidateId: _text(json, 'candidate_id'),
    identityKey: _text(json, 'identity_key'),
    portraitAssetKey: _text(json, 'portrait_asset_key'),
    publicIdentity: _text(json, 'public_identity'),
    position: _text(json, 'position'),
    rhetoricalStyle: _enum(
      CandidateRhetoricalStyle.values,
      json['rhetorical_style'],
      'rhetorical_style',
    ),
    qualityBand: _enum(
      CandidateQualityBand.values,
      json['quality_band'],
      'quality_band',
    ),
    questions: _maps(json, 'questions').map(_questionFromJson).toList(),
    pulse: _maps(json, 'pulse').map(_contentFromJson).toList(),
    relations: _maps(json, 'relations').map(_evidenceRelationFromJson).toList(),
    evidenceCosts: _intMap(json['evidence_costs'], 'evidence_costs'),
  );

  static Map<String, Object?> _questionToJson(CandidateQuestion question) => {
    'id': question.id,
    'text': question.text,
    'city_issue_id': question.cityIssueId,
    'related_evidence_ids': question.relatedEvidenceIds,
  };

  static CandidateQuestion _questionFromJson(Map<String, Object?> json) =>
      CandidateQuestion(
        id: _text(json, 'id'),
        text: _text(json, 'text'),
        cityIssueId: _text(json, 'city_issue_id'),
        relatedEvidenceIds: _strings(json, 'related_evidence_ids'),
      );

  static Map<String, Object?> _contentToJson(CandidateContentItem item) => {
    'id': item.id,
    'candidate_id': item.candidateId,
    'type': item.type.name,
    'headline': item.headline,
    'summary': item.summary,
    'inspect_body': item.inspectBody,
    'deep_dive_prompt': item.deepDivePrompt,
    'source': item.source,
    'fictional_date': item.fictionalDate,
    'city_issue_id': item.cityIssueId,
    'related_evidence_ids': item.relatedEvidenceIds,
    'receipt_kind': item.receiptKind.name,
    'candidate_response': item.candidateResponse,
    'missing_context': item.missingContext,
    'key_figures': item.keyFigures,
    'media': item.media == null ? null : _mediaToJson(item.media!),
    'public_attention': item.publicAttention,
  };

  static CandidateContentItem _contentFromJson(Map<String, Object?> json) =>
      CandidateContentItem(
        id: _text(json, 'id'),
        candidateId: _text(json, 'candidate_id'),
        type: _enum(CandidateContentType.values, json['type'], 'type'),
        headline: _text(json, 'headline'),
        summary: _text(json, 'summary'),
        inspectBody: _text(json, 'inspect_body'),
        deepDivePrompt: _text(json, 'deep_dive_prompt'),
        source: _text(json, 'source'),
        fictionalDate: _text(json, 'fictional_date'),
        cityIssueId: _text(json, 'city_issue_id'),
        relatedEvidenceIds: _strings(json, 'related_evidence_ids'),
        receiptKind: _enum(
          ReceiptKind.values,
          json['receipt_kind'],
          'receipt_kind',
        ),
        candidateResponse: _optionalText(json['candidate_response']),
        missingContext: _optionalText(json['missing_context']),
        keyFigures: _strings(json, 'key_figures'),
        media: json['media'] == null
            ? null
            : _mediaFromJson(_map(json['media'], 'media')),
        publicAttention: _int(json, 'public_attention'),
      );

  static Map<String, Object?> _mediaToJson(CandidateMedia media) => {
    'asset_key': media.assetKey,
    'aspect_ratio': media.aspectRatio,
    'alt_text': media.altText,
    'caption': media.caption,
    'type': media.type.name,
    'is_available': media.isAvailable,
    'alignment_x': media.alignmentX,
    'alignment_y': media.alignmentY,
  };

  static CandidateMedia _mediaFromJson(Map<String, Object?> json) =>
      CandidateMedia(
        assetKey: _text(json, 'asset_key'),
        aspectRatio: _number(json['aspect_ratio'], 'aspect_ratio').toDouble(),
        altText: _text(json, 'alt_text'),
        caption: _text(json, 'caption'),
        type: _enum(CandidateMediaType.values, json['type'], 'type'),
        isAvailable: _bool(json, 'is_available'),
        alignmentX: _number(json['alignment_x'], 'alignment_x').toDouble(),
        alignmentY: _number(json['alignment_y'], 'alignment_y').toDouble(),
      );

  static Map<String, Object?> _evidenceRelationToJson(
    EvidenceRelation relation,
  ) => {
    'from_evidence_id': relation.fromEvidenceId,
    'to_evidence_id': relation.toEvidenceId,
    'type': relation.type.name,
    'explanation': relation.explanation,
    'unlocks_target': relation.unlocksTarget,
  };

  static EvidenceRelation _evidenceRelationFromJson(
    Map<String, Object?> json,
  ) => EvidenceRelation(
    fromEvidenceId: _text(json, 'from_evidence_id'),
    toEvidenceId: _text(json, 'to_evidence_id'),
    type: _enum(EvidenceRelationType.values, json['type'], 'type'),
    explanation: _text(json, 'explanation'),
    unlocksTarget: _bool(json, 'unlocks_target'),
  );

  static Map<String, Object?> _biographyToJson(CandidateBiography biography) =>
      {
        'candidate_id': biography.candidateId,
        'birth_year': biography.birthYear,
        'occupation': biography.occupation,
        'education': biography.education,
        'current_position': biography.currentPosition,
        'public_service_start_year': biography.publicServiceStartYear,
        'hometown': biography.hometown,
        'previous_positions': biography.previousPositions,
        'summary': biography.summary,
        'information_footprint': biography.informationFootprint.name,
        'sections': biography.sections.map(_biographySectionToJson).toList(),
        'timeline': biography.timeline.map(_lifeEventToJson).toList(),
      };

  static CandidateBiography _biographyFromJson(Map<String, Object?> json) =>
      CandidateBiography(
        candidateId: _text(json, 'candidate_id'),
        birthYear: _int(json, 'birth_year'),
        occupation: _text(json, 'occupation'),
        education: _strings(json, 'education'),
        currentPosition: _text(json, 'current_position'),
        publicServiceStartYear: _int(json, 'public_service_start_year'),
        hometown: _text(json, 'hometown'),
        previousPositions: _strings(json, 'previous_positions'),
        summary: _text(json, 'summary'),
        informationFootprint: _enum(
          CandidateInformationFootprint.values,
          json['information_footprint'],
          'information_footprint',
        ),
        sections: _maps(
          json,
          'sections',
        ).map(_biographySectionFromJson).toList(),
        timeline: _maps(json, 'timeline').map(_lifeEventFromJson).toList(),
      );

  static Map<String, Object?> _biographySectionToJson(
    CandidateBiographySection section,
  ) => {
    'id': section.id,
    'title': section.title,
    'statements': section.statements
        .map(
          (statement) => {
            'id': statement.id,
            'text': statement.text,
            'evidence_ids': statement.evidenceIds,
          },
        )
        .toList(),
  };

  static CandidateBiographySection _biographySectionFromJson(
    Map<String, Object?> json,
  ) => CandidateBiographySection(
    id: _text(json, 'id'),
    title: _text(json, 'title'),
    statements: _maps(json, 'statements')
        .map(
          (statement) => CandidateBiographyStatement(
            id: _text(statement, 'id'),
            text: _text(statement, 'text'),
            evidenceIds: _strings(statement, 'evidence_ids'),
          ),
        )
        .toList(),
  );

  static Map<String, Object?> _lifeEventToJson(CandidateLifeEvent event) => {
    'id': event.id,
    'year': event.year,
    'type': event.type.name,
    'title': event.title,
    'summary': event.summary,
    'details': event.details,
    'public_visibility': event.publicVisibility.name,
    'evidence_ids': event.evidenceIds,
    'related_issue_families': event.relatedIssueFamilies
        .map((family) => family.name)
        .toList(),
  };

  static CandidateLifeEvent _lifeEventFromJson(Map<String, Object?> json) =>
      CandidateLifeEvent(
        id: _text(json, 'id'),
        year: _int(json, 'year'),
        type: _enum(CandidateHistoryEventType.values, json['type'], 'type'),
        title: _text(json, 'title'),
        summary: _text(json, 'summary'),
        details: _text(json, 'details'),
        publicVisibility: _enum(
          CandidatePublicVisibility.values,
          json['public_visibility'],
          'public_visibility',
        ),
        evidenceIds: _strings(json, 'evidence_ids'),
        relatedIssueFamilies: _enumList(
          CityIssueFamily.values,
          json['related_issue_families'],
          'related_issue_families',
        ),
      );

  static Map<String, Object?> _promiseToJson(CandidatePromise promise) => {
    'id': promise.id,
    'candidate_id': promise.candidateId,
    'title': promise.title,
    'candidate_wording': promise.candidateWording,
    'approach': promise.approach,
    'complexity': promise.complexity.name,
    'related_issue_families': promise.relatedIssueFamilies
        .map((family) => family.name)
        .toList(),
    'evidence_ids': promise.evidenceIds,
    'related_history_event_ids': promise.relatedHistoryEventIds,
  };

  static CandidatePromise _promiseFromJson(Map<String, Object?> json) =>
      CandidatePromise(
        id: _text(json, 'id'),
        candidateId: _text(json, 'candidate_id'),
        title: _text(json, 'title'),
        candidateWording: _text(json, 'candidate_wording'),
        approach: _text(json, 'approach'),
        complexity: _enum(
          CandidatePromiseComplexity.values,
          json['complexity'],
          'complexity',
        ),
        relatedIssueFamilies: _enumList(
          CityIssueFamily.values,
          json['related_issue_families'],
          'related_issue_families',
        ),
        evidenceIds: _strings(json, 'evidence_ids'),
        relatedHistoryEventIds: _strings(json, 'related_history_event_ids'),
      );

  static Map<String, Object?> _comparisonToJson(
    CandidateStatementComparison comparison,
  ) => {
    'id': comparison.id,
    'candidate_id': comparison.candidateId,
    'then_year': comparison.thenYear,
    'then_statement': comparison.thenStatement,
    'now_year': comparison.nowYear,
    'now_statement': comparison.nowStatement,
    'context': comparison.context,
    'evidence_ids': comparison.evidenceIds,
    'related_promise_id': comparison.relatedPromiseId,
  };

  static CandidateStatementComparison _comparisonFromJson(
    Map<String, Object?> json,
  ) => CandidateStatementComparison(
    id: _text(json, 'id'),
    candidateId: _text(json, 'candidate_id'),
    thenYear: _int(json, 'then_year'),
    thenStatement: _text(json, 'then_statement'),
    nowYear: _int(json, 'now_year'),
    nowStatement: _text(json, 'now_statement'),
    context: _text(json, 'context'),
    evidenceIds: _strings(json, 'evidence_ids'),
    relatedPromiseId: _optionalText(json['related_promise_id']),
  );

  static Map<String, Object?> _debateTopicToJson(DebateTopic topic) => {
    'id': topic.id,
    'title': topic.title,
    'city_problem_id': topic.cityProblemId,
    'issue_families': topic.issueFamilies.map((family) => family.name).toList(),
    'messages': topic.messages.map(_debateMessageToJson).toList(),
  };

  static DebateTopic _debateTopicFromJson(Map<String, Object?> json) =>
      DebateTopic(
        id: _text(json, 'id'),
        title: _text(json, 'title'),
        cityProblemId: _text(json, 'city_problem_id'),
        issueFamilies: _enumList(
          CityIssueFamily.values,
          json['issue_families'],
          'issue_families',
        ),
        messages: _maps(json, 'messages').map(_debateMessageFromJson).toList(),
      );

  static Map<String, Object?> _debateMessageToJson(DebateMessage message) => {
    'id': message.id,
    'topic_id': message.topicId,
    'speaker_id': message.speakerId,
    'type': message.type.name,
    'text': message.text,
    'sequence': message.sequence,
    'public_reaction': message.publicReaction.name,
    'referenced_evidence_ids': message.referencedEvidenceIds,
    'contradicted_by_ids': message.contradictedByIds,
    'related_promise_ids': message.relatedPromiseIds,
    'related_history_event_ids': message.relatedHistoryEventIds,
    'related_message_ids': message.relatedMessageIds,
    'comparison_id': message.comparisonId,
    'bookmarkable': message.bookmarkable,
  };

  static DebateMessage _debateMessageFromJson(Map<String, Object?> json) =>
      DebateMessage(
        id: _text(json, 'id'),
        topicId: _text(json, 'topic_id'),
        speakerId: _text(json, 'speaker_id'),
        type: _enum(DebateMessageType.values, json['type'], 'type'),
        text: _text(json, 'text'),
        sequence: _int(json, 'sequence'),
        publicReaction: _enum(
          PublicReaction.values,
          json['public_reaction'],
          'public_reaction',
        ),
        referencedEvidenceIds: _strings(json, 'referenced_evidence_ids'),
        contradictedByIds: _strings(json, 'contradicted_by_ids'),
        relatedPromiseIds: _strings(json, 'related_promise_ids'),
        relatedHistoryEventIds: _strings(json, 'related_history_event_ids'),
        relatedMessageIds: _strings(json, 'related_message_ids'),
        comparisonId: _optionalText(json['comparison_id']),
        bookmarkable: _bool(json, 'bookmarkable'),
      );

  static Map<String, Object?> _candidateInformationRelationToJson(
    CandidateInformationRelation relation,
  ) => {
    'from': {'kind': relation.from.kind.name, 'id': relation.from.id},
    'to': {'kind': relation.to.kind.name, 'id': relation.to.id},
    'type': relation.type.name,
    'explanation': relation.explanation,
  };

  static CandidateInformationRelation _candidateInformationRelationFromJson(
    Map<String, Object?> json,
  ) {
    CandidateInformationReference reference(String key) {
      final value = _map(json[key], key);
      return CandidateInformationReference(
        kind: _enum(
          CandidateInformationKind.values,
          value['kind'],
          '$key.kind',
        ),
        id: _text(value, 'id'),
      );
    }

    return CandidateInformationRelation(
      from: reference('from'),
      to: reference('to'),
      type: _enum(CandidateRelationType.values, json['type'], 'type'),
      explanation: _text(json, 'explanation'),
    );
  }

  static Map<String, Object?> _cityBookToJson(CityBookCatalog catalog) => {
    'profiles': {
      for (final entry in catalog.profiles.entries)
        entry.key: _cityBookProfileToJson(entry.value),
    },
    'posts': catalog.posts.map(_cityBookPostToJson).toList(),
    'comment_threads': {
      for (final entry in catalog.commentThreads.entries)
        entry.key: _commentThreadToJson(entry.value),
    },
  };

  static CityBookCatalog _cityBookFromJson(Map<String, Object?> json) =>
      CityBookCatalog(
        profiles: _map(json['profiles'], 'profiles').map(
          (key, value) => MapEntry(
            key,
            _cityBookProfileFromJson(_map(value, 'profiles.$key')),
          ),
        ),
        posts: _maps(json, 'posts').map(_cityBookPostFromJson).toList(),
        commentThreads: _map(json['comment_threads'], 'comment_threads').map(
          (key, value) => MapEntry(
            key,
            _commentThreadFromJson(_map(value, 'comment_threads.$key')),
          ),
        ),
      );

  static Map<String, Object?> _cityBookProfileToJson(CityBookProfile profile) =>
      {
        'candidate_id': profile.candidateId,
        'handle': profile.handle,
        'short_bio': profile.shortBio,
        'affiliation': profile.affiliation,
        'public_attention': profile.publicAttention,
        'profile_asset_key': profile.profileAssetKey,
        'banner_asset_key': profile.bannerAssetKey,
      };

  static CityBookProfile _cityBookProfileFromJson(Map<String, Object?> json) =>
      CityBookProfile(
        candidateId: _text(json, 'candidate_id'),
        handle: _text(json, 'handle'),
        shortBio: _text(json, 'short_bio'),
        affiliation: _text(json, 'affiliation'),
        publicAttention: _int(json, 'public_attention'),
        profileAssetKey: _text(json, 'profile_asset_key'),
        bannerAssetKey: _text(json, 'banner_asset_key'),
      );

  static Map<String, Object?> _cityBookPostToJson(CityBookPost post) => {
    'id': post.id,
    'candidate_id': post.candidateId,
    'fictional_date': post.fictionalDate,
    'type': post.type.name,
    'text': post.text,
    'image_asset_key': post.imageAssetKey,
    'image_aspect_ratio': post.imageAspectRatio,
    'related_issue_families': post.relatedIssueFamilies
        .map((family) => family.name)
        .toList(),
    'related_evidence_ids': post.relatedEvidenceIds,
    'related_news_event_ids': post.relatedNewsEventIds,
    'related_debate_message_ids': post.relatedDebateMessageIds,
    'reactions': {
      for (final entry in post.reactions.counts.entries)
        entry.key.name: entry.value,
    },
    'comment_thread_id': post.commentThreadId,
    'historical': post.historical,
    'visibility': post.visibility.name,
    'source_truth_relation': post.sourceTruthRelation.name,
    'comparison_id': post.comparisonId,
  };

  static CityBookPost _cityBookPostFromJson(Map<String, Object?> json) =>
      CityBookPost(
        id: _text(json, 'id'),
        candidateId: _text(json, 'candidate_id'),
        fictionalDate: _text(json, 'fictional_date'),
        type: _enum(CityBookPostType.values, json['type'], 'type'),
        text: _text(json, 'text'),
        imageAssetKey: _optionalText(json['image_asset_key']),
        imageAspectRatio: _number(
          json['image_aspect_ratio'],
          'image_aspect_ratio',
        ).toDouble(),
        relatedIssueFamilies: _enumList(
          CityIssueFamily.values,
          json['related_issue_families'],
          'related_issue_families',
        ),
        relatedEvidenceIds: _strings(json, 'related_evidence_ids'),
        relatedNewsEventIds: _strings(json, 'related_news_event_ids'),
        relatedDebateMessageIds: _strings(json, 'related_debate_message_ids'),
        reactions: CityBookReactionDistribution(
          _map(json['reactions'], 'reactions').map(
            (key, value) => MapEntry(
              _enum(CityBookReaction.values, key, 'reactions.$key'),
              _number(value, 'reactions.$key').toInt(),
            ),
          ),
        ),
        commentThreadId: _text(json, 'comment_thread_id'),
        historical: _bool(json, 'historical'),
        visibility: _enum(
          CityBookVisibility.values,
          json['visibility'],
          'visibility',
        ),
        sourceTruthRelation: _enum(
          CityBookSourceTruthRelation.values,
          json['source_truth_relation'],
          'source_truth_relation',
        ),
        comparisonId: _optionalText(json['comparison_id']),
      );

  static Map<String, Object?> _commentThreadToJson(
    CityBookCommentThread thread,
  ) => {
    'id': thread.id,
    'comments': thread.comments
        .map(
          (comment) => {
            'id': comment.id,
            'author_name': comment.authorName,
            'author_handle': comment.authorHandle,
            'archetype': comment.archetype.name,
            'text': comment.text,
            'reaction_count': comment.reactionCount,
            'account_clues': comment.accountClues,
          },
        )
        .toList(),
  };

  static CityBookCommentThread _commentThreadFromJson(
    Map<String, Object?> json,
  ) => CityBookCommentThread(
    id: _text(json, 'id'),
    comments: _maps(json, 'comments')
        .map(
          (comment) => CityBookComment(
            id: _text(comment, 'id'),
            authorName: _text(comment, 'author_name'),
            authorHandle: _text(comment, 'author_handle'),
            archetype: _enum(
              CityBookCommentArchetype.values,
              comment['archetype'],
              'archetype',
            ),
            text: _text(comment, 'text'),
            reactionCount: _int(comment, 'reaction_count'),
            accountClues: _strings(comment, 'account_clues'),
          ),
        )
        .toList(),
  );

  static Map<String, Object?> _newsEventToJson(UnderlyingNewsEvent event) => {
    'id': event.id,
    'fictional_date': event.fictionalDate,
    'title': event.title,
    'event_type': event.eventType,
    'chronicle_item_id': event.chronicleItemId,
    'related_problem_id': event.relatedProblemId,
    'related_issue_family': event.relatedIssueFamily?.name,
    'related_candidate_ids': event.relatedCandidateIds,
    'factual_summary': event.factualSummary,
    'known_facts': event.knownFacts,
    'disputed_facts': event.disputedFacts,
    'evidence_ids': event.evidenceIds,
    'public_impact': event.publicImpact,
    'importance': event.importance,
    'image_asset_key': event.imageAssetKey,
    'chronicle_visibility': event.chronicleVisibility,
  };

  static UnderlyingNewsEvent _newsEventFromJson(Map<String, Object?> json) =>
      UnderlyingNewsEvent(
        id: _text(json, 'id'),
        fictionalDate: _text(json, 'fictional_date'),
        title: _text(json, 'title'),
        eventType: _text(json, 'event_type'),
        chronicleItemId: _optionalText(json['chronicle_item_id']),
        relatedProblemId: _optionalText(json['related_problem_id']),
        relatedIssueFamily: json['related_issue_family'] == null
            ? null
            : _enum(
                CityIssueFamily.values,
                json['related_issue_family'],
                'related_issue_family',
              ),
        relatedCandidateIds: _strings(json, 'related_candidate_ids'),
        factualSummary: _text(json, 'factual_summary'),
        knownFacts: _strings(json, 'known_facts'),
        disputedFacts: _strings(json, 'disputed_facts'),
        evidenceIds: _strings(json, 'evidence_ids'),
        publicImpact: _int(json, 'public_impact'),
        importance: _int(json, 'importance'),
        imageAssetKey: _optionalText(json['image_asset_key']),
        chronicleVisibility: _bool(json, 'chronicle_visibility'),
      );

  static Map<String, Object?> _newsCoverageToJson(NewsCoverage coverage) => {
    'id': coverage.id,
    'event_id': coverage.eventId,
    'outlet_id': coverage.outletId,
    'category': coverage.category,
    'publication_time': coverage.publicationTime,
    'headline': coverage.headline,
    'subheadline': coverage.subheadline,
    'article_summary': coverage.articleSummary,
    'framing_angle': coverage.framingAngle,
    'article_body': coverage.articleBody,
    'related_coverage_ids': coverage.relatedCoverageIds,
  };

  static NewsCoverage _newsCoverageFromJson(Map<String, Object?> json) =>
      NewsCoverage(
        id: _text(json, 'id'),
        eventId: _text(json, 'event_id'),
        outletId: _text(json, 'outlet_id'),
        category: _text(json, 'category'),
        publicationTime: _text(json, 'publication_time'),
        headline: _text(json, 'headline'),
        subheadline: _text(json, 'subheadline'),
        articleSummary: _text(json, 'article_summary'),
        framingAngle: _text(json, 'framing_angle'),
        articleBody: _strings(json, 'article_body'),
        relatedCoverageIds: _strings(json, 'related_coverage_ids'),
      );

  static Map<String, Object?> _map(Object? value, String field) {
    if (value is! Map) throw FormatException('Invalid $field map.');
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<Map<String, Object?>> _maps(
    Map<String, Object?> json,
    String field,
  ) {
    final value = json[field];
    if (value is! List) throw FormatException('Invalid $field list.');
    return value.map((item) => _map(item, field)).toList();
  }

  static String _text(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is! String || value.isEmpty) {
      throw FormatException('Invalid $field text.');
    }
    return value;
  }

  static String? _optionalText(Object? value) => value is String ? value : null;

  static num _number(Object? value, String field) {
    if (value is! num) throw FormatException('Invalid $field number.');
    return value;
  }

  static int _int(Map<String, Object?> json, String field) =>
      _number(json[field], field).toInt();

  static bool _bool(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is! bool) throw FormatException('Invalid $field boolean.');
    return value;
  }

  static List<String> _strings(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Invalid $field string list.');
    }
    return value.cast<String>();
  }

  static Map<String, int> _intMap(Object? value, String field) => _map(
    value,
    field,
  ).map((key, item) => MapEntry(key, _number(item, '$field.$key').toInt()));

  static T _enum<T extends Enum>(List<T> values, Object? value, String field) {
    if (value is! String) throw FormatException('Invalid $field enum.');
    for (final item in values) {
      if (item.name == value) return item;
    }
    throw FormatException('Unknown $field value: $value.');
  }

  static List<T> _enumList<T extends Enum>(
    List<T> values,
    Object? value,
    String field,
  ) {
    if (value is! List) throw FormatException('Invalid $field enum list.');
    return value
        .map((item) => _enum(values, item, field))
        .toList(growable: false);
  }
}
