import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityAuthException implements Exception {
  const CommunityAuthException();
}

abstract interface class CommunityAuthService {
  String? get currentUserId;
  Future<String?> restoreUserId();
  Future<String> ensureAnonymousUser();
  Future<String> accessToken();
}

class SupabaseCommunityAuthService implements CommunityAuthService {
  SupabaseCommunityAuthService(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<String?> restoreUserId() async => currentUserId;

  @override
  Future<String> ensureAnonymousUser() async {
    final existing = currentUserId;
    if (existing != null) return existing;
    try {
      final response = await _client.auth.signInAnonymously();
      final userId = response.user?.id;
      if (userId == null) throw const CommunityAuthException();
      return userId;
    } on AuthException {
      throw const CommunityAuthException();
    }
  }

  @override
  Future<String> accessToken() async {
    var session = _client.auth.currentSession;
    if (session == null) throw const CommunityAuthException();
    if (session.isExpired) {
      try {
        final response = await _client.auth.refreshSession();
        session = response.session;
      } on AuthException {
        throw const CommunityAuthException();
      }
    }
    final token = session?.accessToken;
    if (token == null || token.isEmpty) throw const CommunityAuthException();
    return token;
  }
}

class MemoryCommunityAuthService implements CommunityAuthService {
  MemoryCommunityAuthService({
    String? userId,
    String token = 'test-token',
  }) : _activeUserId = userId,
       _accessToken = token;

  String? _activeUserId;
  final String _accessToken;
  int anonymousSignInCount = 0;

  @override
  String? get currentUserId => _activeUserId;

  @override
  Future<String?> restoreUserId() async => _activeUserId;

  @override
  Future<String> ensureAnonymousUser() async {
    if (_activeUserId != null) return _activeUserId!;
    anonymousSignInCount++;
    return _activeUserId = '00000000-0000-4000-8000-000000000001';
  }

  @override
  Future<String> accessToken() async {
    if (_activeUserId == null) throw const CommunityAuthException();
    return _accessToken;
  }
}

class UnavailableCommunityAuthService implements CommunityAuthService {
  const UnavailableCommunityAuthService();

  @override
  String? get currentUserId => null;

  @override
  Future<String?> restoreUserId() async => null;

  @override
  Future<String> ensureAnonymousUser() async =>
      throw const CommunityAuthException();

  @override
  Future<String> accessToken() async => throw const CommunityAuthException();
}
