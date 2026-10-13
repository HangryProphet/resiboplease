import '../../domain/models/political_timeline.dart';
import 'living_city_codec.dart';
import 'procedural_election_codec.dart';

abstract final class PoliticalTimelineCodec {
  static Map<String, Object?> encode(AdministrationRecord record) => {
    'id': record.id,
    'term_number': record.termNumber,
    'election_seed': record.electionSeed,
    'elected_candidate_id': record.electedCandidateId,
    'elected_candidate_name': record.electedCandidateName,
    'elected_party': record.electedParty,
    'elected_portrait_asset_key': record.electedPortraitAssetKey,
    'top_issue': record.topIssue,
    'confidence': record.confidence,
    'election': record.election == null
        ? null
        : ProceduralElectionCodec.encode(record.election!),
    'living_city': LivingCityCodec.encode(record.livingCity),
    'investigation': _investigationToJson(record.investigation),
    'completed_at': record.completedAt.toUtc().toIso8601String(),
  };

  static AdministrationRecord decode(Map<String, Object?> json) {
    final record = AdministrationRecord(
      id: _text(json, 'id'),
      termNumber: _int(json, 'term_number'),
      electionSeed: _int(json, 'election_seed'),
      electedCandidateId: _text(json, 'elected_candidate_id'),
      electedCandidateName: _text(json, 'elected_candidate_name'),
      electedParty: _text(json, 'elected_party'),
      electedPortraitAssetKey: _text(json, 'elected_portrait_asset_key'),
      topIssue: _optionalText(json['top_issue']),
      confidence: _number(json, 'confidence').toDouble(),
      election: json['election'] == null
          ? null
          : ProceduralElectionCodec.decode(_map(json['election'], 'election')),
      livingCity: LivingCityCodec.decode(
        _map(json['living_city'], 'living_city'),
      ),
      investigation: _investigationFromJson(
        _map(json['investigation'], 'investigation'),
      ),
      completedAt: _date(json, 'completed_at'),
    );
    final errors = record.validate();
    if (errors.isNotEmpty) {
      throw FormatException(
        'Saved administration is inconsistent: ${errors.join(' | ')}',
      );
    }
    return record;
  }

  static Map<String, Object?> _investigationToJson(
    AdministrationInvestigationSnapshot value,
  ) => {
    'viewed_evidence_ids': _sorted(value.viewedEvidenceIds),
    'bookmarked_evidence_ids': _sorted(value.bookmarkedEvidenceIds),
    'pinned_candidate_ids': _sorted(value.pinnedCandidateIds),
    'pinned_content_ids': _sorted(value.pinnedContentIds),
    'pinned_question_ids': _sorted(value.pinnedQuestionIds),
    'bookmarked_debate_message_ids': _sorted(value.bookmarkedDebateMessageIds),
    'pinned_debate_message_ids': _sorted(value.pinnedDebateMessageIds),
    'suspicious_debate_message_ids': _sorted(value.suspiciousDebateMessageIds),
    'receipt_notes': Map<String, String>.from(value.receiptNotes),
    'prediction_ids': _sorted(value.predictionIds),
  };

  static AdministrationInvestigationSnapshot _investigationFromJson(
    Map<String, Object?> json,
  ) => AdministrationInvestigationSnapshot(
    viewedEvidenceIds: _strings(json, 'viewed_evidence_ids').toSet(),
    bookmarkedEvidenceIds: _strings(json, 'bookmarked_evidence_ids').toSet(),
    pinnedCandidateIds: _strings(json, 'pinned_candidate_ids').toSet(),
    pinnedContentIds: _strings(json, 'pinned_content_ids').toSet(),
    pinnedQuestionIds: _strings(json, 'pinned_question_ids').toSet(),
    bookmarkedDebateMessageIds: _strings(
      json,
      'bookmarked_debate_message_ids',
    ).toSet(),
    pinnedDebateMessageIds: _strings(json, 'pinned_debate_message_ids').toSet(),
    suspiciousDebateMessageIds: _strings(
      json,
      'suspicious_debate_message_ids',
    ).toSet(),
    receiptNotes: _map(json['receipt_notes'], 'receipt_notes').map((
      key,
      value,
    ) {
      if (value is! String) {
        throw FormatException('Invalid receipt note for $key.');
      }
      return MapEntry(key, value);
    }),
    predictionIds: _optionalStrings(json['prediction_ids']).toSet(),
  );

  static List<String> _sorted(Iterable<String> values) =>
      values.toList(growable: false)..sort();

  static Map<String, Object?> _map(Object? value, String field) {
    if (value is! Map) throw FormatException('Invalid $field map.');
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<String> _strings(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Invalid $field string list.');
    }
    return value.cast<String>();
  }

  static List<String> _optionalStrings(Object? value) {
    if (value == null) return const [];
    if (value is! List || value.any((item) => item is! String)) {
      throw const FormatException('Invalid optional string list.');
    }
    return value.cast<String>();
  }

  static String _text(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is! String || value.isEmpty) {
      throw FormatException('Invalid $field text.');
    }
    return value;
  }

  static String? _optionalText(Object? value) => value is String ? value : null;

  static num _number(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is! num) throw FormatException('Invalid $field number.');
    return value;
  }

  static int _int(Map<String, Object?> json, String field) =>
      _number(json, field).toInt();

  static DateTime _date(Map<String, Object?> json, String field) {
    final parsed = DateTime.tryParse(_text(json, field));
    if (parsed == null) throw FormatException('Invalid $field date.');
    return parsed.toUtc();
  }
}
