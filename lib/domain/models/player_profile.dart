class PlayerProfile {
  const PlayerProfile({
    required this.userId,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PlayerProfile.fromJson(Map<String, Object?> json) => PlayerProfile(
    userId: _requiredText(json['user_id'], 'user_id', maxLength: 100),
    displayName: validatePlayerDisplayName(json['display_name']),
    createdAt: _requiredDate(json['created_at'], 'created_at'),
    updatedAt: _requiredDate(json['updated_at'], 'updated_at'),
  );
}

String validatePlayerDisplayName(Object? value) {
  if (value is! String) {
    throw const FormatException('Invalid display name.');
  }
  if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(value)) {
    throw const FormatException('Display name contains control characters.');
  }
  final normalizedSpaces = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalizedSpaces.length < 3 || normalizedSpaces.length > 24) {
    throw const FormatException('Display name must be 3 to 24 characters.');
  }
  if (!RegExp(r'^[A-Za-z0-9_À-ÖØ-öø-ÿ ]+$').hasMatch(normalizedSpaces)) {
    throw const FormatException(
      'Display name contains unsupported characters.',
    );
  }
  return normalizedSpaces;
}

String normalizePlayerDisplayName(String value) =>
    validatePlayerDisplayName(value).toLowerCase();

String _requiredText(Object? value, String field, {required int maxLength}) {
  if (value is! String ||
      value.trim().isEmpty ||
      value.trim().length > maxLength) {
    throw FormatException('Invalid $field in player profile.');
  }
  return value.trim();
}

DateTime _requiredDate(Object? value, String field) {
  final parsed = value is String ? DateTime.tryParse(value) : null;
  if (parsed == null) {
    throw FormatException('Invalid $field in player profile.');
  }
  return parsed.toUtc();
}
