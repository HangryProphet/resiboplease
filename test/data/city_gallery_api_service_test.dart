import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resiboplease/data/gallery/city_gallery_api_service.dart';
import 'package:resiboplease/domain/models/public_city_snapshot.dart';

void main() {
  const config = CityGalleryApiConfig(
    projectUrl: 'https://project.supabase.co',
    anonKey: 'public-anon-key',
  );

  test('GET retrieves and decodes ordered public snapshots', () async {
    final logs = <String>[];
    final service = CityGalleryApiService(
      config: config,
      debugResponseLogger: logs.add,
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/rest/v1/city_snapshots');
        expect(request.url.queryParameters['order'], 'created_at.desc');
        expect(request.headers['apikey'], 'public-anon-key');
        return http.Response(jsonEncode([_apiJson()]), 200);
      }),
    );
    addTearDown(service.close);

    final snapshots = await service.fetchSnapshots();

    expect(snapshots, hasLength(1));
    expect(snapshots.single.cityName, 'Harborlight');
    expect(logs.single, contains('GET JSON response'));
    expect(logs.single, contains('Harborlight'));
  });

  test('POST encodes only the sanitized public payload', () async {
    late Map<String, Object?> posted;
    final service = CityGalleryApiService(
      config: config,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['prefer'], 'return=representation');
        posted = (jsonDecode(request.body) as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        );
        return http.Response(jsonEncode([_apiJson()]), 201);
      }),
    );
    addTearDown(service.close);

    final published = await service.publishSnapshot(_snapshotWithoutId());

    expect(published.id, 'snapshot-1');
    expect(posted['city_name'], 'Harborlight');
    expect(posted, isNot(contains('id')));
    expect(posted, isNot(contains('seed')));
    expect(posted, isNot(contains('hidden_candidate_stats')));
    expect(posted, isNot(contains('investigation_history')));
  });

  test('invalid GET shape becomes a typed safe failure', () async {
    final service = CityGalleryApiService(
      config: config,
      client: MockClient((_) async => http.Response('{"rows": []}', 200)),
    );
    addTearDown(service.close);

    await expectLater(
      service.fetchSnapshots(),
      throwsA(
        isA<CityGalleryApiException>().having(
          (error) => error.failure,
          'failure',
          CityGalleryFailure.invalidResponse,
        ),
      ),
    );
  });

  test('server response becomes a typed failure without exposing its body', () {
    final service = CityGalleryApiService(
      config: config,
      client: MockClient((_) async => http.Response('private details', 503)),
    );
    addTearDown(service.close);

    expectLater(
      service.fetchSnapshots(),
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
}

Map<String, Object?> _apiJson() => {
  'id': 'snapshot-1',
  ..._snapshotWithoutId().toPublishJson(),
};

PublicCitySnapshot _snapshotWithoutId() => PublicCitySnapshot(
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
