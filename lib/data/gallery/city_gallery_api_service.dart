import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/public_city_snapshot.dart';

enum CityGalleryFailure { notConfigured, network, server, invalidResponse }

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
        uri.hasScheme &&
        uri.host.isNotEmpty &&
        anonKey.isNotEmpty;
  }

  Uri get endpoint {
    final base = projectUrl.endsWith('/')
        ? projectUrl.substring(0, projectUrl.length - 1)
        : projectUrl;
    return Uri.parse('$base/rest/v1/city_snapshots');
  }
}

abstract interface class CityGalleryRemoteDataSource {
  Future<List<PublicCitySnapshot>> fetchSnapshots();
  Future<PublicCitySnapshot> publishSnapshot(PublicCitySnapshot snapshot);
  void close();
}

/// Direct Supabase REST integration used by the Public City Gallery.
///
/// GET, POST, jsonDecode, and jsonEncode intentionally remain visible here for
/// the project's API-integration requirement.
class CityGalleryApiService implements CityGalleryRemoteDataSource {
  CityGalleryApiService({
    required this.config,
    http.Client? client,
    this.debugResponseLogger,
  }) {
    _client = client;
  }

  final CityGalleryApiConfig config;
  late final http.Client? _client;
  final void Function(String message)? debugResponseLogger;

  Map<String, String> get _headers => {
    'apikey': config.anonKey,
    'Authorization': 'Bearer ${config.anonKey}',
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  @override
  Future<List<PublicCitySnapshot>> fetchSnapshots() async {
    _ensureConfigured();
    final uri = config.endpoint.replace(
      queryParameters: const {
        'select':
            'id,city_name,term_number,starting_pressure,top_issue,'
            'selected_candidate_name,candidate_party,final_city_condition,'
            'outcome_summary,major_issues,major_events,created_at',
        'order': 'created_at.desc',
        'limit': '50',
      },
    );
    try {
      final response =
          await (_client == null
                  ? http.get(uri, headers: _headers) // HTTP GET
                  : _client.get(uri, headers: _headers))
              .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CityGalleryApiException(
          CityGalleryFailure.server,
          statusCode: response.statusCode,
        );
      }
      final body = utf8.decode(response.bodyBytes);
      _logJson('GET', body);
      final decoded = _decodeJson(body); // JSON decoding
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
    _ensureConfigured();
    try {
      final headers = {..._headers, 'Prefer': 'return=representation'};
      final body = jsonEncode(snapshot.toPublishJson()); // JSON encoding
      final response =
          await (_client == null
                  ? http.post(
                      config.endpoint,
                      headers: headers,
                      body: body,
                    ) // HTTP POST
                  : _client.post(config.endpoint, headers: headers, body: body))
              .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CityGalleryApiException(
          CityGalleryFailure.server,
          statusCode: response.statusCode,
        );
      }
      final responseBody = utf8.decode(response.bodyBytes);
      _logJson('POST', responseBody);
      final decoded = _decodeJson(responseBody);
      if (decoded is! List || decoded.isEmpty) {
        throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
      }
      try {
        return PublicCitySnapshot.fromJson(_stringMap(decoded.first));
      } on FormatException {
        throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
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

  void _ensureConfigured() {
    if (!config.isConfigured) {
      throw const CityGalleryApiException(CityGalleryFailure.notConfigured);
    }
  }

  void _logJson(String method, String body) {
    if (!kDebugMode) return;
    final message = '[CityGalleryApi] $method JSON response: $body';
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

Object? _decodeJson(String body) {
  try {
    return jsonDecode(body);
  } on FormatException {
    throw const CityGalleryApiException(CityGalleryFailure.invalidResponse);
  }
}

Map<String, Object?> _stringMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('City snapshot row must be an object.');
  }
  return value.map((key, item) => MapEntry(key.toString(), item));
}
