import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/player_profile.dart';
import '../../domain/models/public_city_snapshot.dart';
import 'community_auth_service.dart';

enum CityGalleryFailure {
  notConfigured,
  authentication,
  duplicateName,
  network,
  server,
  invalidResponse,
  notFound,
}

class CityGalleryApiException implements Exception {
  const CityGalleryApiException(this.failure, {this.statusCode});

  final CityGalleryFailure failure;
  final int? statusCode;
}

class CityGalleryApiConfig {
  const CityGalleryApiConfig({required this.projectUrl, required this.anonKey});

  factory CityGalleryApiConfig.fromEnvironment() => const CityGalleryApiConfig(
    projectUrl: String.fromEnvironment('SUPABASE_URL'),
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final String projectUrl;
  final String anonKey;

  bool get isConfigured {
    final uri = Uri.tryParse(projectUrl);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        anonKey.isNotEmpty &&
        !_isServiceRoleJwt(anonKey);
  }

  Uri endpoint(String resource) {
    final base = projectUrl.endsWith('/')
        ? projectUrl.substring(0, projectUrl.length - 1)
        : projectUrl;
    return Uri.parse('$base/rest/v1/$resource');
  }
}

abstract interface class CityGalleryRemoteDataSource {
  Future<List<PublicCitySnapshot>> fetchPublicSnapshots({String? ownerId});
  Future<List<PublicCitySnapshot>> fetchOwnSnapshots(String userId);
  Future<PlayerProfile?> fetchProfile(String userId);
  Future<PlayerProfile> createProfile(String displayName);
  Future<List<PlayerProfile>> searchProfiles(String query);
  Future<PublicCitySnapshot> publishSnapshot(PublicCitySnapshot snapshot);
  Future<PublicCitySnapshot> updateSnapshotPrivacy(
    PublicCitySnapshot snapshot,
    bool isPublic,
  );
  Future<void> deleteSnapshot(PublicCitySnapshot snapshot);
  void close();
}

/// Explicit Supabase PostgREST integration used by the community gallery.
///
/// Authentication/session persistence is owned by [CommunityAuthService]. The
/// school API requirement remains visible here through direct GET, POST, PATCH,
/// DELETE, jsonDecode, and jsonEncode calls.
class CityGalleryApiService implements CityGalleryRemoteDataSource {
  CityGalleryApiService({
    required this.config,
    required this.auth,
    http.Client? client,
    this.debugResponseLogger,
  }) {
    _client = client;
  }

  static const _snapshotSelect =
      'id,owner_id,is_public,city_name,term_number,starting_pressure,'
      'top_issue,selected_candidate_name,candidate_party,'
      'final_city_condition,outcome_summary,major_issues,major_events,'
      'created_at,player_profiles(display_name)';

  final CityGalleryApiConfig config;
  final CommunityAuthService auth;
  late final http.Client? _client;
  final void Function(String message)? debugResponseLogger;

  Future<Map<String, String>> _headers() async {
    _ensureConfigured();
    try {
      final token = await auth.accessToken();
      return {
        'apikey': config.anonKey,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      };
    } on CommunityAuthException {
      throw const CityGalleryApiException(CityGalleryFailure.authentication);
    }
  }

  @override
  Future<List<PublicCitySnapshot>> fetchPublicSnapshots({String? ownerId}) =>
      _fetchSnapshots({
        'select': _snapshotSelect,
        'is_public': 'eq.true',
        if (ownerId != null) 'owner_id': 'eq.$ownerId',
        'order': 'created_at.desc',
        'limit': '50',
      });

  @override
  Future<List<PublicCitySnapshot>> fetchOwnSnapshots(String userId) async {
    await _assertCurrentUser(userId);
    return _fetchSnapshots({
      'select': _snapshotSelect,
      'owner_id': 'eq.$userId',
      'order': 'created_at.desc',
      'limit': '50',
    });
  }

  Future<List<PublicCitySnapshot>> _fetchSnapshots(
    Map<String, String> query,
  ) async {
    final uri = config
        .endpoint('city_snapshots')
        .replace(queryParameters: query);
    try {
      final headers = await _headers();
      final response =
          await (_client == null
                  ? http.get(uri, headers: headers) // HTTP GET
                  : _client.get(uri, headers: headers))
              .timeout(const Duration(seconds: 12));
      _checkResponse(response);
      final body = utf8.decode(response.bodyBytes);
      _logJson('GET', body);
      return _decodeSnapshotList(body);
    } on CityGalleryApiException {
      rethrow;
    } on TimeoutException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } on http.ClientException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } catch (_) {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    }
  }

  @override
  Future<PlayerProfile?> fetchProfile(String userId) async {
    await _assertCurrentUser(userId);
    final uri = config
        .endpoint('player_profiles')
        .replace(
          queryParameters: {
            'select': 'user_id,display_name,created_at,updated_at',
            'user_id': 'eq.$userId',
            'limit': '1',
          },
        );
    final profiles = await _getProfiles(uri);
    return profiles.firstOrNull;
  }

  @override
  Future<PlayerProfile> createProfile(String displayName) async {
    final cleaned = validatePlayerDisplayName(displayName);
    final userId = auth.currentUserId;
    if (userId == null) {
      throw const CityGalleryApiException(CityGalleryFailure.authentication);
    }
    final uri = config.endpoint('player_profiles');
    try {
      final headers = {...await _headers(), 'Prefer': 'return=representation'};
      final body = jsonEncode({
        'display_name': cleaned,
        'display_name_normalized': normalizePlayerDisplayName(cleaned),
      });
      final response =
          await (_client == null
                  ? http.post(uri, headers: headers, body: body) // HTTP POST
                  : _client.post(uri, headers: headers, body: body))
              .timeout(const Duration(seconds: 12));
      _checkResponse(response, duplicateNameOnConflict: true);
      final responseBody = utf8.decode(response.bodyBytes);
      _logJson('POST profile', responseBody);
      final profiles = _decodeProfileList(responseBody);
      if (profiles.isEmpty) {
        throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
      }
      return profiles.first;
    } on CityGalleryApiException {
      rethrow;
    } on TimeoutException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } on http.ClientException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } catch (_) {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    }
  }

  @override
  Future<List<PlayerProfile>> searchProfiles(String query) async {
    final normalized = _normalizeSearchQuery(query);
    if (normalized.isEmpty) return const [];
    final uri = config
        .endpoint('player_profiles')
        .replace(
          queryParameters: {
            'select': 'user_id,display_name,created_at,updated_at',
            'display_name_normalized': 'ilike.*$normalized*',
            'order': 'display_name.asc',
            'limit': '20',
          },
        );
    return _getProfiles(uri);
  }

  Future<List<PlayerProfile>> _getProfiles(Uri uri) async {
    try {
      final headers = await _headers();
      final response =
          await (_client == null
                  ? http.get(uri, headers: headers) // HTTP GET
                  : _client.get(uri, headers: headers))
              .timeout(const Duration(seconds: 12));
      _checkResponse(response);
      final body = utf8.decode(response.bodyBytes);
      _logJson('GET profile', body);
      return _decodeProfileList(body);
    } on CityGalleryApiException {
      rethrow;
    } on TimeoutException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } on http.ClientException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } catch (_) {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    }
  }

  @override
  Future<PublicCitySnapshot> publishSnapshot(
    PublicCitySnapshot snapshot,
  ) async {
    final uri = config
        .endpoint('city_snapshots')
        .replace(queryParameters: {'select': _snapshotSelect});
    try {
      final headers = {...await _headers(), 'Prefer': 'return=representation'};
      final body = jsonEncode(snapshot.toPublishJson()); // JSON encoding
      final response =
          await (_client == null
                  ? http.post(uri, headers: headers, body: body) // HTTP POST
                  : _client.post(uri, headers: headers, body: body))
              .timeout(const Duration(seconds: 12));
      _checkResponse(response);
      final responseBody = utf8.decode(response.bodyBytes);
      _logJson('POST city', responseBody);
      return _singleSnapshot(responseBody);
    } on CityGalleryApiException {
      rethrow;
    } on TimeoutException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } on http.ClientException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } catch (_) {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    }
  }

  @override
  Future<PublicCitySnapshot> updateSnapshotPrivacy(
    PublicCitySnapshot snapshot,
    bool isPublic,
  ) async {
    await _assertSnapshotOwner(snapshot);
    final uri = config
        .endpoint('city_snapshots')
        .replace(
          queryParameters: {
            'id': 'eq.${snapshot.id}',
            'owner_id': 'eq.${snapshot.ownerId}',
            'select': _snapshotSelect,
          },
        );
    try {
      final headers = {...await _headers(), 'Prefer': 'return=representation'};
      final body = jsonEncode({'is_public': isPublic});
      final response =
          await (_client == null
                  ? http.patch(uri, headers: headers, body: body) // HTTP PATCH
                  : _client.patch(uri, headers: headers, body: body))
              .timeout(const Duration(seconds: 12));
      _checkResponse(response);
      final responseBody = utf8.decode(response.bodyBytes);
      _logJson('PATCH city', responseBody);
      return _singleSnapshot(responseBody, emptyIsNotFound: true);
    } on CityGalleryApiException {
      rethrow;
    } on TimeoutException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } on http.ClientException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } catch (_) {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    }
  }

  @override
  Future<void> deleteSnapshot(PublicCitySnapshot snapshot) async {
    await _assertSnapshotOwner(snapshot);
    final uri = config
        .endpoint('city_snapshots')
        .replace(
          queryParameters: {
            'id': 'eq.${snapshot.id}',
            'owner_id': 'eq.${snapshot.ownerId}',
          },
        );
    try {
      final headers = {...await _headers(), 'Prefer': 'return=representation'};
      final response =
          await (_client == null
                  ? http.delete(uri, headers: headers) // HTTP DELETE
                  : _client.delete(uri, headers: headers))
              .timeout(const Duration(seconds: 12));
      _checkResponse(response);
      final responseBody = utf8.decode(response.bodyBytes);
      _logJson('DELETE city', responseBody);
      final decoded = _decodeJson(responseBody);
      if (decoded is! List || decoded.isEmpty) {
        throw const CityGalleryApiException(CityGalleryFailure.notFound);
      }
    } on CityGalleryApiException {
      rethrow;
    } on TimeoutException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } on http.ClientException {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    } catch (_) {
      throw const CityGalleryApiException(CityGalleryFailure.network);
    }
  }

  Future<void> _assertSnapshotOwner(PublicCitySnapshot snapshot) async {
    if (snapshot.id == null || snapshot.ownerId == null) {
      throw const CityGalleryApiException(CityGalleryFailure.notFound);
    }
    await _assertCurrentUser(snapshot.ownerId!);
  }

  Future<void> _assertCurrentUser(String expectedUserId) async {
    final restored = await auth.restoreUserId();
    if (restored == null || restored != expectedUserId) {
      throw const CityGalleryApiException(CityGalleryFailure.authentication);
    }
  }

  void _ensureConfigured() {
    if (!config.isConfigured) {
      throw const CityGalleryApiException(CityGalleryFailure.notConfigured);
    }
  }

  void _checkResponse(
    http.Response response, {
    bool duplicateNameOnConflict = false,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (duplicateNameOnConflict && response.statusCode == 409) {
      throw const CityGalleryApiException(CityGalleryFailure.duplicateName);
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw CityGalleryApiException(
        CityGalleryFailure.authentication,
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode == 404) {
      throw const CityGalleryApiException(CityGalleryFailure.notFound);
    }
    throw CityGalleryApiException(
      CityGalleryFailure.server,
      statusCode: response.statusCode,
    );
  }

  List<PublicCitySnapshot> _decodeSnapshotList(String body) {
    final decoded = _decodeJson(body);
    if (decoded is! List) {
      throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
    }
    try {
      return List.unmodifiable(
        decoded.map((row) => PublicCitySnapshot.fromJson(_stringMap(row))),
      );
    } on FormatException {
      throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
    }
  }

  PublicCitySnapshot _singleSnapshot(
    String body, {
    bool emptyIsNotFound = false,
  }) {
    final snapshots = _decodeSnapshotList(body);
    if (snapshots.isEmpty) {
      throw CityGalleryApiException(
        emptyIsNotFound
            ? CityGalleryFailure.notFound
            : CityGalleryFailure.invalidResponse,
      );
    }
    return snapshots.first;
  }

  List<PlayerProfile> _decodeProfileList(String body) {
    final decoded = _decodeJson(body);
    if (decoded is! List) {
      throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
    }
    try {
      return List.unmodifiable(
        decoded.map((row) => PlayerProfile.fromJson(_stringMap(row))),
      );
    } on FormatException {
      throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
    }
  }

  void _logJson(String method, String body) {
    if (!kDebugMode) return;
    final safeBody = body.length <= 2000 ? body : '${body.substring(0, 2000)}…';
    final message = '[CityGalleryApi] $method JSON response: $safeBody';
    final logger = debugResponseLogger;
    if (logger != null) {
      logger(message);
    } else {
      debugPrint(message);
    }
  }

  @override
  void close() => _client?.close();
}

String _normalizeSearchQuery(String value) => value
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp(r'[^A-Za-z0-9_À-ÖØ-öø-ÿ ]'), '')
    .toLowerCase();

bool _isServiceRoleJwt(String value) {
  final parts = value.split('.');
  if (parts.length != 3) return false;
  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final decoded = jsonDecode(payload);
    return decoded is Map && decoded['role'] == 'service_role';
  } catch (_) {
    return false;
  }
}

Object? _decodeJson(String body) {
  try {
    return jsonDecode(body);
  } on FormatException {
    throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
  }
}

Map<String, Object?> _stringMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('API row must be an object.');
  }
  return value.map((key, item) => MapEntry(key.toString(), item));
}
