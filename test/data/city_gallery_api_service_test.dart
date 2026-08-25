import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resiboplease/data/gallery/city_gallery_api_service.dart';
import 'package:resiboplease/data/gallery/community_auth_service.dart';
import 'package:resiboplease/domain/models/public_city_snapshot.dart';

void main() {
  const config = CityGalleryApiConfig(
    projectUrl: 'https://project.supabase.co',
    anonKey: 'public-anon-key',
  );
  const userId = '00000000-0000-4000-8000-000000000001';

  MemoryCommunityAuthService auth([String? id = userId]) =>
      MemoryCommunityAuthService(userId: id, token: 'user-access-token');

  test(
    'GET retrieves only public snapshots with authenticated owner data',
    () async {
      final logs = <String>[];
      final service = CityGalleryApiService(
        config: config,
        auth: auth(),
        debugResponseLogger: logs.add,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/rest/v1/city_snapshots');
          expect(request.url.queryParameters['is_public'], 'eq.true');
          expect(request.url.queryParameters['order'], 'created_at.desc');
          expect(request.headers['authorization'], 'Bearer user-access-token');
          return http.Response(jsonEncode([_apiJson()]), 200);
        }),
      );
      addTearDown(service.close);

      final snapshots = await service.fetchPublicSnapshots();

      expect(snapshots, hasLength(1));
      expect(snapshots.single.ownerDisplayName, 'Kazuma');
      expect(snapshots.single.isPublic, isTrue);
      expect(logs.single, contains('GET JSON response'));
    },
  );

  test(
    'GET own cities filters to current owner and can return private rows',
    () async {
      final service = CityGalleryApiService(
        config: config,
        auth: auth(),
        client: MockClient((request) async {
          expect(request.url.queryParameters['owner_id'], 'eq.$userId');
          expect(request.url.queryParameters, isNot(contains('is_public')));
          return http.Response(jsonEncode([_apiJson(isPublic: false)]), 200);
        }),
      );

      final snapshots = await service.fetchOwnSnapshots(userId);
      expect(snapshots.single.isPublic, isFalse);
    },
  );

  test(
    'POST encodes only sanitized fields and lets database assign owner',
    () async {
      late Map<String, Object?> posted;
      final service = CityGalleryApiService(
        config: config,
        auth: auth(),
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.headers['prefer'], 'return=representation');
          posted = (jsonDecode(request.body) as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          );
          return http.Response(jsonEncode([_apiJson()]), 201);
        }),
      );

      final published = await service.publishSnapshot(_snapshotWithoutId());

      expect(published.id, 'snapshot-1');
      expect(posted['is_public'], isTrue);
      expect(posted, isNot(contains('owner_id')));
      expect(posted, isNot(contains('seed')));
      expect(posted, isNot(contains('hidden_candidate_stats')));
      expect(posted, isNot(contains('investigation_history')));
      expect(posted, isNot(contains('private_notes')));
    },
  );

  test('PATCH toggles only privacy for an owned snapshot', () async {
    late Map<String, Object?> patched;
    final service = CityGalleryApiService(
      config: config,
      auth: auth(),
      client: MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.queryParameters['id'], 'eq.snapshot-1');
        expect(request.url.queryParameters['owner_id'], 'eq.$userId');
        patched = (jsonDecode(request.body) as Map).cast<String, Object?>();
        return http.Response(jsonEncode([_apiJson(isPublic: false)]), 200);
      }),
    );

    final updated = await service.updateSnapshotPrivacy(_snapshot(), false);
    expect(patched, {'is_public': false});
    expect(updated.isPublic, isFalse);
  });

  test('DELETE removes only the authenticated owner snapshot', () async {
    final service = CityGalleryApiService(
      config: config,
      auth: auth(),
      client: MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.queryParameters['id'], 'eq.snapshot-1');
        expect(request.url.queryParameters['owner_id'], 'eq.$userId');
        return http.Response(jsonEncode([_apiJson()]), 200);
      }),
    );

    await service.deleteSnapshot(_snapshot());
  });

  test(
    'another local session cannot PATCH or DELETE someone else snapshot',
    () async {
      var calls = 0;
      final service = CityGalleryApiService(
        config: config,
        auth: auth('00000000-0000-4000-8000-000000000099'),
        client: MockClient((_) async {
          calls++;
          return http.Response('[]', 200);
        }),
      );

      await expectLater(
        service.updateSnapshotPrivacy(_snapshot(), false),
        throwsA(_failure(CityGalleryFailure.authentication)),
      );
      await expectLater(
        service.deleteSnapshot(_snapshot()),
        throwsA(_failure(CityGalleryFailure.authentication)),
      );
      expect(calls, 0);
    },
  );

  test(
    'profile POST normalizes name and duplicate is friendly typed failure',
    () async {
      var attempts = 0;
      final service = CityGalleryApiService(
        config: config,
        auth: auth(),
        client: MockClient((request) async {
          attempts++;
          final body = jsonDecode(request.body) as Map;
          expect(body['display_name'], 'Kazuma Player');
          expect(body['display_name_normalized'], 'kazuma player');
          expect(body, isNot(contains('user_id')));
          return http.Response('duplicate', 409);
        }),
      );

      await expectLater(
        service.createProfile('  Kazuma   Player '),
        throwsA(_failure(CityGalleryFailure.duplicateName)),
      );
      expect(attempts, 1);
    },
  );

  test(
    'player search uses server-side case-insensitive partial filter',
    () async {
      final service = CityGalleryApiService(
        config: config,
        auth: auth(),
        client: MockClient((request) async {
          expect(
            request.url.queryParameters['display_name_normalized'],
            'ilike.*kazu*',
          );
          expect(request.url.queryParameters['limit'], '20');
          return http.Response(jsonEncode([_profileJson()]), 200);
        }),
      );

      final profiles = await service.searchProfiles('KaZu');
      expect(profiles.single.displayName, 'Kazuma');
    },
  );

  test('server response becomes a typed failure without exposing its body', () {
    final service = CityGalleryApiService(
      config: config,
      auth: auth(),
      client: MockClient((_) async => http.Response('private details', 503)),
    );

    expectLater(
      service.fetchPublicSnapshots(),
      throwsA(
        isA<CityGalleryApiException>()
            .having(
              (error) => error.failure,
              'failure',
              CityGalleryFailure.server,
            )
            .having((error) => error.statusCode, 'status', 503),
      ),
    );
  });

  test('service-role JWTs and non-HTTPS endpoints are rejected', () {
    final payload = base64Url.encode(
      utf8.encode(jsonEncode({'role': 'service_role'})),
    );
    final serviceRole = CityGalleryApiConfig(
      projectUrl: 'https://project.supabase.co',
      anonKey: 'header.$payload.signature',
    );
    const insecure = CityGalleryApiConfig(
      projectUrl: 'http://project.supabase.co',
      anonKey: 'public-anon-key',
    );

    expect(serviceRole.isConfigured, isFalse);
    expect(insecure.isConfigured, isFalse);
  });

  test('oversized or malformed public rows are safely rejected', () async {
    final row = _apiJson()
      ..['outcome_summary'] = List.filled(700, 'x').join()
      ..['major_issues'] = List.filled(9, 'Issue');
    final service = CityGalleryApiService(
      config: config,
      auth: auth(),
      client: MockClient((_) async => http.Response(jsonEncode([row]), 200)),
    );

    await expectLater(
      service.fetchPublicSnapshots(),
      throwsA(_failure(CityGalleryFailure.invalidResponse)),
    );
  });
}

Matcher _failure(CityGalleryFailure failure) => isA<CityGalleryApiException>()
    .having((error) => error.failure, 'failure', failure);

Map<String, Object?> _profileJson() => {
  'user_id': '00000000-0000-4000-8000-000000000001',
  'display_name': 'Kazuma',
  'created_at': '2026-08-18T00:00:00.000Z',
  'updated_at': '2026-08-18T00:00:00.000Z',
};

Map<String, Object?> _apiJson({bool isPublic = true}) => {
  'id': 'snapshot-1',
  'owner_id': '00000000-0000-4000-8000-000000000001',
  'is_public': isPublic,
  'player_profiles': {'display_name': 'Kazuma'},
  ..._snapshotWithoutId(isPublic: isPublic).toPublishJson(),
};

PublicCitySnapshot _snapshot({bool isPublic = true}) => PublicCitySnapshot(
  id: 'snapshot-1',
  ownerId: '00000000-0000-4000-8000-000000000001',
  ownerDisplayName: 'Kazuma',
  isPublic: isPublic,
  cityName: 'Harborlight',
  termNumber: 1,
  startingPressure: 'strained',
  topIssue: 'Water access',
  selectedCandidateName: 'Maya Vargas',
  candidateParty: 'Bayhaven Civic Alliance',
  finalCityCondition: 'mixed',
  outcomeSummary: 'Public health improved while transport declined.',
  majorIssues: const ['Water access', 'Transport'],
  majorEvents: const ['Clinic response'],
  createdAt: DateTime.utc(2026, 8, 18),
);

PublicCitySnapshot _snapshotWithoutId({bool isPublic = true}) =>
    PublicCitySnapshot(
      isPublic: isPublic,
      cityName: 'Harborlight',
      termNumber: 1,
      startingPressure: 'strained',
      topIssue: 'Water access',
      selectedCandidateName: 'Maya Vargas',
      candidateParty: 'Bayhaven Civic Alliance',
      finalCityCondition: 'mixed',
      outcomeSummary: 'Public health improved while transport declined.',
      majorIssues: const ['Water access', 'Transport'],
      majorEvents: const ['Clinic response'],
      createdAt: DateTime.utc(2026, 8, 18),
    );
