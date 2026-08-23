import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_indicator_set.dart';
import '../../domain/models/city_problem.dart';
import '../../domain/models/citybook.dart';
import '../../domain/models/living_city_simulation.dart';
import '../../domain/models/news_media.dart';

abstract final class LivingCityCodec {
  static Map<String, Object?> encode(LivingTermSimulation value) => {
    'generation_version': value.generationVersion,
    'seed': value.seed,
    'term_number': value.termNumber,
    'candidate_id': value.candidateId,
    'initial_indicators': value.initialIndicators.toJson(),
    'final_indicators': value.finalIndicators.toJson(),
    'initial_issues': _encodeIssueMap(value.initialIssueStates),
    'final_issues': _encodeIssueMap(value.finalIssueStates),
    'projects': value.projects.map(_encodeProject).toList(growable: false),
    'phases': value.phases.map(_encodePhase).toList(growable: false),
    'events': value.eventHistory.map(_encodeEvent).toList(growable: false),
    'chronicle': value.chronicleEntries
        .map(_encodeChronicle)
        .toList(growable: false),
    'news': value.newsCoverages.map(_encodeCoverage).toList(growable: false),
    'tv_event_ids': value.tvReportEventIds,
    'citybook_posts': value.cityBookPosts
        .map(_encodePost)
        .toList(growable: false),
    'citybook_threads': value.cityBookCommentThreads.map(
      (id, thread) => MapEntry(id, _encodeThread(thread)),
    ),
    'summary': value.summary,
  };

  static LivingTermSimulation decode(Map<String, Object?> json) {
    final events = _list(
      json['events'],
      'events',
    ).map((item) => _decodeEvent(_map(item, 'event'))).toList(growable: false);
    final eventsById = {for (final event in events) event.id: event};
    final projects = _list(json['projects'], 'projects')
        .map((item) => _decodeProject(_map(item, 'project')))
        .toList(growable: false);
    final phases = _list(json['phases'], 'phases')
        .map((item) => _decodePhase(_map(item, 'phase'), eventsById))
        .toList(growable: false);
    return LivingTermSimulation(
      generationVersion: _int(json['generation_version'], 'generation_version'),
      seed: _int(json['seed'], 'seed'),
      termNumber: _int(json['term_number'], 'term_number'),
      candidateId: _string(json['candidate_id'], 'candidate_id'),
      initialIndicators: CityIndicatorSet.fromJson(
        _map(json['initial_indicators'], 'initial_indicators'),
      ),
      finalIndicators: CityIndicatorSet.fromJson(
        _map(json['final_indicators'], 'final_indicators'),
      ),
      initialIssueStates: _decodeIssueMap(
        _map(json['initial_issues'], 'initial_issues'),
      ),
      finalIssueStates: _decodeIssueMap(
        _map(json['final_issues'], 'final_issues'),
      ),
      projects: List.unmodifiable(projects),
      phases: List.unmodifiable(phases),
      eventHistory: List.unmodifiable(events),
      chronicleEntries: _list(json['chronicle'], 'chronicle')
          .map((item) => _decodeChronicle(_map(item, 'chronicle entry')))
          .toList(growable: false),
      newsCoverages: _list(json['news'], 'news')
          .map((item) => _decodeCoverage(_map(item, 'coverage')))
          .toList(growable: false),
      tvReportEventIds: _strings(json['tv_event_ids'], 'tv_event_ids'),
      cityBookPosts: _list(
        json['citybook_posts'],
        'citybook_posts',
      ).map((item) => _decodePost(_map(item, 'post'))).toList(growable: false),
      cityBookCommentThreads: _map(
        json['citybook_threads'],
        'citybook_threads',
      ).map((id, item) => MapEntry(id, _decodeThread(_map(item, 'thread')))),
      summary: _string(json['summary'], 'summary'),
    );
  }

  static Map<String, Object?> _encodeIssueMap(
    Map<String, CityIssueState> values,
  ) => values.map(
    (id, issue) => MapEntry(id, {
      'problem_id': issue.problemId,
      'family': issue.family.name,
      'severity': issue.severity,
      'trend': issue.trend.name,
    }),
  );
  static Map<String, CityIssueState> _decodeIssueMap(
    Map<String, Object?> json,
  ) => json.map((id, item) {
    final value = _map(item, 'issue');
    return MapEntry(
      id,
      CityIssueState(
        problemId: _string(value['problem_id'], 'problem_id'),
        family: _enum(CityIssueFamily.values, value['family'], 'family'),
        severity: _int(value['severity'], 'severity'),
        trend: _enum(ProblemTrend.values, value['trend'], 'trend'),
      ),
    );
  });

  static Map<String, Object?> _encodeMilestone(ProjectMilestone value) => {
    'id': value.id,
    'project_id': value.projectId,
    'phase': value.phase,
    'from_state': value.fromState.name,
    'to_state': value.toState.name,
    'progress_delta': value.progressDelta,
    'summary': value.summary,
  };
  static ProjectMilestone _decodeMilestone(Map<String, Object?> json) =>
      ProjectMilestone(
        id: _string(json['id'], 'id'),
        projectId: _string(json['project_id'], 'project_id'),
        phase: _int(json['phase'], 'phase'),
        fromState: _enum(
          AdministrationProjectState.values,
          json['from_state'],
          'from_state',
        ),
        toState: _enum(
          AdministrationProjectState.values,
          json['to_state'],
          'to_state',
        ),
        progressDelta: _int(json['progress_delta'], 'progress_delta'),
        summary: _string(json['summary'], 'summary'),
      );

  static Map<String, Object?> _encodeProject(AdministrationProject value) => {
    'id': value.id,
    'candidate_id': value.candidateId,
    'promise_id': value.promiseId,
    'title': value.title,
    'family': value.relatedIssueFamily.name,
    'problem_id': value.relatedProblemId,
    'indicator': value.relevantIndicator.name,
    'cost': value.cost,
    'estimated_phases': value.estimatedPhases,
    'priority': value.priority,
    'difficulty': value.difficulty,
    'corruption_exposure': value.corruptionExposure,
    'public_visibility': value.publicVisibility,
    'progress': value.progress,
    'state': value.state.name,
    'promise_status': value.promiseStatus.name,
    'effects': _indicatorMap(value.outcomeEffects),
    'milestones': value.milestones
        .map(_encodeMilestone)
        .toList(growable: false),
  };
  static AdministrationProject _decodeProject(Map<String, Object?> json) =>
      AdministrationProject(
        id: _string(json['id'], 'id'),
        candidateId: _string(json['candidate_id'], 'candidate_id'),
        promiseId: _string(json['promise_id'], 'promise_id'),
        title: _string(json['title'], 'title'),
        relatedIssueFamily: _enum(
          CityIssueFamily.values,
          json['family'],
          'family',
        ),
        relatedProblemId: _string(json['problem_id'], 'problem_id'),
        relevantIndicator: _enum(
          CityIndicator.values,
          json['indicator'],
          'indicator',
        ),
        cost: _int(json['cost'], 'cost'),
        estimatedPhases: _int(json['estimated_phases'], 'estimated_phases'),
        priority: _int(json['priority'], 'priority'),
        difficulty: _int(json['difficulty'], 'difficulty'),
        corruptionExposure: _int(
          json['corruption_exposure'],
          'corruption_exposure',
        ),
        publicVisibility: _int(json['public_visibility'], 'public_visibility'),
        progress: _int(json['progress'], 'progress'),
        state: _enum(AdministrationProjectState.values, json['state'], 'state'),
        promiseStatus: _enum(
          PromiseProgressStatus.values,
          json['promise_status'],
          'promise_status',
        ),
        outcomeEffects: _decodeIndicatorMap(_map(json['effects'], 'effects')),
        milestones: _list(json['milestones'], 'milestones')
            .map((item) => _decodeMilestone(_map(item, 'milestone')))
            .toList(growable: false),
      );

  static Map<String, Object?> _encodeEvent(CityEvent value) => {
    'id': value.id,
    'template_id': value.templateId,
    'chain_family': value.chainFamily,
    'category': value.category.name,
    'severity': value.severity.name,
    'phase': value.phase,
    'step': value.step,
    'title': value.title,
    'factual_summary': value.factualSummary,
    'explanation': value.explanation,
    'fictional_date': value.fictionalDate,
    'district': value.district.name,
    'issue_ids': value.relatedIssueIds,
    'project_ids': value.relatedProjectIds,
    'candidate_ids': value.relatedCandidateIds,
    'indicator_effects': _indicatorMap(value.indicatorEffects),
    'issue_effects': value.issueSeverityEffects,
    'required_hooks': value.requiredHooks,
    'follow_up_hooks': value.followUpHooks,
    'chronicle_eligible': value.chronicleEligible,
    'news_eligible': value.newsEligible,
    'tv_eligible': value.tvEligible,
    'citybook_eligible': value.cityBookEligible,
    'marker_type': value.markerType.name,
    'marker_x': value.markerX,
    'marker_y': value.markerY,
    'visual_asset_key': value.visualAssetKey,
  };
  static CityEvent _decodeEvent(Map<String, Object?> json) => CityEvent(
    id: _string(json['id'], 'id'),
    templateId: _string(json['template_id'], 'template_id'),
    chainFamily: _string(json['chain_family'], 'chain_family'),
    category: _enum(CityEventCategory.values, json['category'], 'category'),
    severity: _enum(CityEventSeverity.values, json['severity'], 'severity'),
    phase: _int(json['phase'], 'phase'),
    step: _int(json['step'], 'step'),
    title: _string(json['title'], 'title'),
    factualSummary: _string(json['factual_summary'], 'factual_summary'),
    explanation: _string(json['explanation'], 'explanation'),
    fictionalDate: _string(json['fictional_date'], 'fictional_date'),
    district: _enum(
      CitySimulationDistrict.values,
      json['district'],
      'district',
    ),
    relatedIssueIds: _strings(json['issue_ids'], 'issue_ids'),
    relatedProjectIds: _strings(json['project_ids'], 'project_ids'),
    relatedCandidateIds: _strings(json['candidate_ids'], 'candidate_ids'),
    indicatorEffects: _decodeIndicatorMap(
      _map(json['indicator_effects'], 'indicator_effects'),
    ),
    issueSeverityEffects: _intMap(_map(json['issue_effects'], 'issue_effects')),
    requiredHooks: _strings(json['required_hooks'], 'required_hooks'),
    followUpHooks: _strings(json['follow_up_hooks'], 'follow_up_hooks'),
    chronicleEligible: _bool(json['chronicle_eligible'], 'chronicle_eligible'),
    newsEligible: _bool(json['news_eligible'], 'news_eligible'),
    tvEligible: _bool(json['tv_eligible'], 'tv_eligible'),
    cityBookEligible: _bool(json['citybook_eligible'], 'citybook_eligible'),
    markerType: _enum(
      CityMapMarkerType.values,
      json['marker_type'],
      'marker_type',
    ),
    markerX: _double(json['marker_x'], 'marker_x'),
    markerY: _double(json['marker_y'], 'marker_y'),
    visualAssetKey: json['visual_asset_key'] as String?,
  );

  static Map<String, Object?> _encodePhase(LivingCityPhase value) => {
    'number': value.number,
    'title': value.title,
    'event_ids': value.events.map((event) => event.id).toList(growable: false),
    'milestones': value.projectMilestones
        .map(_encodeMilestone)
        .toList(growable: false),
    'indicators_after': value.indicatorsAfter.toJson(),
    'issues_after': _encodeIssueMap(value.issueStatesAfter),
  };
  static LivingCityPhase _decodePhase(
    Map<String, Object?> json,
    Map<String, CityEvent> events,
  ) => LivingCityPhase(
    number: _int(json['number'], 'number'),
    title: _string(json['title'], 'title'),
    events: _strings(json['event_ids'], 'event_ids')
        .map(
          (id) =>
              events[id] ?? (throw FormatException('Unknown phase event $id.')),
        )
        .toList(growable: false),
    projectMilestones: _list(json['milestones'], 'milestones')
        .map((item) => _decodeMilestone(_map(item, 'milestone')))
        .toList(growable: false),
    indicatorsAfter: CityIndicatorSet.fromJson(
      _map(json['indicators_after'], 'indicators_after'),
    ),
    issueStatesAfter: _decodeIssueMap(
      _map(json['issues_after'], 'issues_after'),
    ),
  );

  static Map<String, Object?> _encodeChronicle(LivingChronicleEntry value) => {
    'id': value.id,
    'event_id': value.eventId,
    'headline': value.headline,
    'summary': value.summary,
    'source_label': value.sourceLabel,
    'fictional_date': value.fictionalDate,
    'community_voice': value.communityVoice,
  };
  static LivingChronicleEntry _decodeChronicle(Map<String, Object?> json) =>
      LivingChronicleEntry(
        id: _string(json['id'], 'id'),
        eventId: _string(json['event_id'], 'event_id'),
        headline: _string(json['headline'], 'headline'),
        summary: _string(json['summary'], 'summary'),
        sourceLabel: _string(json['source_label'], 'source_label'),
        fictionalDate: _string(json['fictional_date'], 'fictional_date'),
        communityVoice: _string(json['community_voice'], 'community_voice'),
      );

  static Map<String, Object?> _encodeCoverage(NewsCoverage value) => {
    'id': value.id,
    'event_id': value.eventId,
    'outlet_id': value.outletId,
    'category': value.category,
    'publication_time': value.publicationTime,
    'headline': value.headline,
    'subheadline': value.subheadline,
    'article_summary': value.articleSummary,
    'framing_angle': value.framingAngle,
    'article_body': value.articleBody,
    'related_coverage_ids': value.relatedCoverageIds,
  };
  static NewsCoverage _decodeCoverage(Map<String, Object?> json) =>
      NewsCoverage(
        id: _string(json['id'], 'id'),
        eventId: _string(json['event_id'], 'event_id'),
        outletId: _string(json['outlet_id'], 'outlet_id'),
        category: _string(json['category'], 'category'),
        publicationTime: _string(json['publication_time'], 'publication_time'),
        headline: _string(json['headline'], 'headline'),
        subheadline: _string(json['subheadline'], 'subheadline'),
        articleSummary: _string(json['article_summary'], 'article_summary'),
        framingAngle: _string(json['framing_angle'], 'framing_angle'),
        articleBody: _strings(json['article_body'], 'article_body'),
        relatedCoverageIds: _strings(
          json['related_coverage_ids'],
          'related_coverage_ids',
        ),
      );

  static Map<String, Object?> _encodePost(CityBookPost value) => {
    'id': value.id,
    'candidate_id': value.candidateId,
    'fictional_date': value.fictionalDate,
    'type': value.type.name,
    'text': value.text,
    'image_asset_key': value.imageAssetKey,
    'image_aspect_ratio': value.imageAspectRatio,
    'families': value.relatedIssueFamilies
        .map((item) => item.name)
        .toList(growable: false),
    'evidence_ids': value.relatedEvidenceIds,
    'news_event_ids': value.relatedNewsEventIds,
    'debate_message_ids': value.relatedDebateMessageIds,
    'reactions': value.reactions.counts.map(
      (key, count) => MapEntry(key.name, count),
    ),
    'thread_id': value.commentThreadId,
    'historical': value.historical,
    'visibility': value.visibility.name,
    'truth_relation': value.sourceTruthRelation.name,
    'comparison_id': value.comparisonId,
  };
  static CityBookPost _decodePost(Map<String, Object?> json) => CityBookPost(
    id: _string(json['id'], 'id'),
    candidateId: _string(json['candidate_id'], 'candidate_id'),
    fictionalDate: _string(json['fictional_date'], 'fictional_date'),
    type: _enum(CityBookPostType.values, json['type'], 'type'),
    text: _string(json['text'], 'text'),
    imageAssetKey: json['image_asset_key'] as String?,
    imageAspectRatio: _double(json['image_aspect_ratio'], 'image_aspect_ratio'),
    relatedIssueFamilies: _strings(json['families'], 'families')
        .map((name) => _enum(CityIssueFamily.values, name, 'family'))
        .toList(growable: false),
    relatedEvidenceIds: _strings(json['evidence_ids'], 'evidence_ids'),
    relatedNewsEventIds: _strings(json['news_event_ids'], 'news_event_ids'),
    relatedDebateMessageIds: _strings(
      json['debate_message_ids'],
      'debate_message_ids',
    ),
    reactions: CityBookReactionDistribution(
      _map(json['reactions'], 'reactions').map(
        (name, count) => MapEntry(
          _enum(CityBookReaction.values, name, 'reaction'),
          _int(count, 'reaction count'),
        ),
      ),
    ),
    commentThreadId: _string(json['thread_id'], 'thread_id'),
    historical: _bool(json['historical'], 'historical'),
    visibility: _enum(
      CityBookVisibility.values,
      json['visibility'],
      'visibility',
    ),
    sourceTruthRelation: _enum(
      CityBookSourceTruthRelation.values,
      json['truth_relation'],
      'truth_relation',
    ),
    comparisonId: json['comparison_id'] as String?,
  );

  static Map<String, Object?> _encodeThread(CityBookCommentThread value) => {
    'id': value.id,
    'comments': value.comments
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
        .toList(growable: false),
  };
  static CityBookCommentThread _decodeThread(Map<String, Object?> json) =>
      CityBookCommentThread(
        id: _string(json['id'], 'id'),
        comments: _list(json['comments'], 'comments')
            .map((item) {
              final value = _map(item, 'comment');
              return CityBookComment(
                id: _string(value['id'], 'id'),
                authorName: _string(value['author_name'], 'author_name'),
                authorHandle: _string(value['author_handle'], 'author_handle'),
                archetype: _enum(
                  CityBookCommentArchetype.values,
                  value['archetype'],
                  'archetype',
                ),
                text: _string(value['text'], 'text'),
                reactionCount: _int(value['reaction_count'], 'reaction_count'),
                accountClues: _strings(value['account_clues'], 'account_clues'),
              );
            })
            .toList(growable: false),
      );

  static Map<String, int> _indicatorMap(Map<CityIndicator, int> values) =>
      values.map((key, value) => MapEntry(key.name, value));
  static Map<CityIndicator, int> _decodeIndicatorMap(
    Map<String, Object?> json,
  ) => json.map(
    (name, value) => MapEntry(
      _enum(CityIndicator.values, name, 'indicator'),
      _int(value, 'indicator effect'),
    ),
  );
  static Map<String, int> _intMap(Map<String, Object?> json) =>
      json.map((key, value) => MapEntry(key, _int(value, key)));
  static Map<String, Object?> _map(Object? value, String field) {
    if (value is! Map) throw FormatException('Invalid $field map.');
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<Object?> _list(Object? value, String field) {
    if (value is! List) throw FormatException('Invalid $field list.');
    return value.cast<Object?>();
  }

  static List<String> _strings(Object? value, String field) {
    final items = _list(value, field);
    if (items.any((item) => item is! String)) {
      throw FormatException('Invalid $field strings.');
    }
    return items.cast<String>();
  }

  static String _string(Object? value, String field) {
    if (value is! String) throw FormatException('Invalid $field text.');
    return value;
  }

  static int _int(Object? value, String field) {
    if (value is! num) throw FormatException('Invalid $field number.');
    return value.toInt();
  }

  static double _double(Object? value, String field) {
    if (value is! num) throw FormatException('Invalid $field number.');
    return value.toDouble();
  }

  static bool _bool(Object? value, String field) {
    if (value is! bool) throw FormatException('Invalid $field boolean.');
    return value;
  }

  static T _enum<T extends Enum>(List<T> values, Object? raw, String field) {
    final name = _string(raw, field);
    return values.firstWhere(
      (value) => value.name == name,
      orElse: () => throw FormatException('Invalid $field: $name.'),
    );
  }
}
