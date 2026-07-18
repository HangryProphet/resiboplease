import '../../domain/models/city_indicator_set.dart';
import '../../domain/models/city_run_configuration.dart';

class GameSaveData {
  GameSaveData({
    required this.activeSlotIndex,
    required this.slots,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc();

  static const currentSchemaVersion = 1;

  final int? activeSlotIndex;
  final List<RunSaveData?> slots;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'schema_version': currentSchemaVersion,
    'active_slot_index': activeSlotIndex,
    'updated_at': updatedAt.toIso8601String(),
    'slots': slots.map((slot) => slot?.toJson()).toList(growable: false),
  };

  factory GameSaveData.fromJson(Map<String, Object?> source) {
    final json = RunSaveMigrator.migrate(source);
    final slotsValue = json['slots'];
    if (slotsValue is! List) {
      throw const FormatException('Saved game slots are missing.');
    }
    return GameSaveData(
      activeSlotIndex: _optionalInt(json['active_slot_index']),
      updatedAt: _dateTime(json['updated_at'], 'updated_at'),
      slots: slotsValue
          .map(
            (slot) => slot == null
                ? null
                : RunSaveData.fromJson(_stringMap(slot, 'slot')),
          )
          .toList(growable: false),
    );
  }
}

class RunSaveData {
  RunSaveData({
    required this.seed,
    required this.configuration,
    required this.indicators,
    required this.term,
    required this.bookmarkedEvidenceIds,
    required this.viewedEvidenceIds,
    required this.chargedEvidenceIds,
    required this.selectedCandidateId,
    required this.termResultReady,
    required this.topIssue,
    required this.confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc();

  final int seed;
  final CityRunConfiguration configuration;
  final CityIndicatorSet indicators;
  final int term;
  final Set<String> bookmarkedEvidenceIds;
  final Set<String> viewedEvidenceIds;
  final Set<String> chargedEvidenceIds;
  final String? selectedCandidateId;
  final bool termResultReady;
  final String? topIssue;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'seed': seed,
    'configuration': _configurationToJson(configuration),
    'indicators': indicators.toJson(),
    'term': term,
    'bookmarked_evidence_ids': bookmarkedEvidenceIds.toList()..sort(),
    'viewed_evidence_ids': viewedEvidenceIds.toList()..sort(),
    'charged_evidence_ids': chargedEvidenceIds.toList()..sort(),
    'selected_candidate_id': selectedCandidateId,
    'term_result_ready': termResultReady,
    'top_issue': topIssue,
    'confidence': confidence,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory RunSaveData.fromJson(Map<String, Object?> json) => RunSaveData(
    seed: _requiredInt(json['seed'], 'seed'),
    configuration: _configurationFromJson(
      _stringMap(json['configuration'], 'configuration'),
    ),
    indicators: CityIndicatorSet.fromJson(
      _stringMap(json['indicators'], 'indicators'),
    ),
    term: _requiredInt(json['term'], 'term'),
    bookmarkedEvidenceIds: _stringSet(
      json['bookmarked_evidence_ids'],
      'bookmarked_evidence_ids',
    ),
    viewedEvidenceIds: _stringSet(
      json['viewed_evidence_ids'],
      'viewed_evidence_ids',
    ),
    chargedEvidenceIds: _stringSet(
      json['charged_evidence_ids'],
      'charged_evidence_ids',
    ),
    selectedCandidateId: _optionalString(json['selected_candidate_id']),
    termResultReady: json['term_result_ready'] == true,
    topIssue: _optionalString(json['top_issue']),
    confidence: _requiredNum(json['confidence'], 'confidence').toDouble(),
    createdAt: _dateTime(json['created_at'], 'created_at'),
    updatedAt: _dateTime(json['updated_at'], 'updated_at'),
  );
}

abstract final class RunSaveMigrator {
  static Map<String, Object?> migrate(Map<String, Object?> source) {
    var json = Map<String, Object?>.from(source);
    var version = _optionalInt(json['schema_version']) ?? 0;
    if (version > GameSaveData.currentSchemaVersion) {
      throw UnsupportedError(
        'Save schema $version is newer than supported schema '
        '${GameSaveData.currentSchemaVersion}.',
      );
    }
    while (version < GameSaveData.currentSchemaVersion) {
      json = switch (version) {
        0 => _migrateV0ToV1(json),
        _ => throw UnsupportedError('No migration exists for schema $version.'),
      };
      version = _requiredInt(json['schema_version'], 'schema_version');
    }
    return json;
  }

  static Map<String, Object?> _migrateV0ToV1(Map<String, Object?> source) => {
    ...source,
    'schema_version': 1,
    'active_slot_index': source['active_slot_index'] ?? source['active_slot'],
    'updated_at':
        source['updated_at'] ??
        DateTime.fromMillisecondsSinceEpoch(0).toUtc().toIso8601String(),
  }..remove('active_slot');
}

Map<String, Object?> _configurationToJson(CityRunConfiguration value) => {
  'city_name': value.cityName,
  'starting_pressure': value.startingPressure.name,
  'main_concerns': value.mainConcerns
      .map((concern) => concern.name)
      .toList(growable: false),
  'candidate_field': value.candidateField.name,
  'assistance_mode': value.assistanceMode.name,
  'campaign_noise': value.campaignNoise.name,
  'investigation_time': value.investigationTime.name,
};

CityRunConfiguration _configurationFromJson(Map<String, Object?> json) =>
    CityRunConfiguration(
      cityName: _requiredString(json['city_name'], 'city_name'),
      startingPressure: _enumValue(
        StartingPressure.values,
        json['starting_pressure'],
        'starting_pressure',
      ),
      mainConcerns: _stringList(json['main_concerns'], 'main_concerns')
          .map((name) => _enumValue(CityConcern.values, name, 'main_concerns'))
          .toList(growable: false),
      candidateField: _enumValue(
        CandidateField.values,
        json['candidate_field'],
        'candidate_field',
      ),
      assistanceMode: _enumValue(
        AssistanceMode.values,
        json['assistance_mode'],
        'assistance_mode',
      ),
      campaignNoise: _enumValue(
        CampaignNoise.values,
        json['campaign_noise'],
        'campaign_noise',
      ),
      investigationTime: _enumValue(
        InvestigationTime.values,
        json['investigation_time'],
        'investigation_time',
      ),
    );

T _enumValue<T extends Enum>(List<T> values, Object? raw, String field) {
  final name = _requiredString(raw, field);
  return values.firstWhere(
    (value) => value.name == name,
    orElse: () => throw FormatException('Invalid $field value: $name.'),
  );
}

Map<String, Object?> _stringMap(Object? value, String field) {
  if (value is! Map) throw FormatException('Invalid $field map.');
  return value.map((key, item) => MapEntry(key.toString(), item));
}

List<String> _stringList(Object? value, String field) {
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('Invalid $field list.');
  }
  return value.cast<String>();
}

Set<String> _stringSet(Object? value, String field) =>
    _stringList(value, field).toSet();

int _requiredInt(Object? value, String field) {
  if (value is! num) throw FormatException('Invalid $field number.');
  return value.toInt();
}

int? _optionalInt(Object? value) => value is num ? value.toInt() : null;

num _requiredNum(Object? value, String field) {
  if (value is! num) throw FormatException('Invalid $field number.');
  return value;
}

String _requiredString(Object? value, String field) {
  if (value is! String || value.isEmpty) {
    throw FormatException('Invalid $field text.');
  }
  return value;
}

String? _optionalString(Object? value) => value is String ? value : null;

DateTime _dateTime(Object? value, String field) {
  if (value is! String) throw FormatException('Invalid $field timestamp.');
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw FormatException('Invalid $field timestamp.');
  return parsed.toUtc();
}
