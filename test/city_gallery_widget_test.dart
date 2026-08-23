import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/data/gallery/city_gallery_api_service.dart';
import 'package:resiboplease/data/gallery/city_gallery_cache.dart';
import 'package:resiboplease/data/gallery/city_gallery_repository.dart';
import 'package:resiboplease/domain/models/public_city_snapshot.dart';
import 'package:resiboplease/features/gallery/publish_city_snapshot_panel.dart';
import 'package:resiboplease/features/gallery/visit_cities_screen.dart';
import 'package:resiboplease/l10n/app_localizations.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(Widget home) => MaterialApp(
    theme: buildResiboTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  testWidgets('Visit Cities shows loading then retrieved API data', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final completer = Completer<List<PublicCitySnapshot>>();
    final remote = _FakeRemote(onFetch: () => completer.future);
    final repository = CityGalleryRepository(
      remote: remote,
      cache: MemoryCityGalleryCache(),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repository)));
    expect(find.byKey(const Key('gallery_loading')), findsOneWidget);

    completer.complete([_snapshot()]);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('gallery_results')), findsOneWidget);
    expect(find.text('HARBORLIGHT'), findsOneWidget);
    expect(find.textContaining('Maya Vargas'), findsOneWidget);
    expect(find.textContaining('Water access'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Visit Cities card opens its sanitized detail page', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final game = GameController();
    final repository = CityGalleryRepository(
      remote: _FakeRemote(onFetch: () async => [_snapshot()]),
      cache: MemoryCityGalleryCache(),
    );
    final router = buildRouter(game, null, repository)..go('/visit-cities');
    addTearDown(router.dispose);
    addTearDown(game.dispose);
    addTearDown(repository.close);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildResiboTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('gallery_city_snapshot-1')));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const Key('city_snapshot_detail_screen')),
      findsOneWidget,
    );
    expect(find.text('CITY SNAPSHOT'), findsOneWidget);
    expect(find.text('Bayhaven Civic Alliance'), findsOneWidget);
    expect(find.text('Clinic response'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid response shows safe error and Retry succeeds', (
    tester,
  ) async {
    usePhoneViewport(tester);
    var attempts = 0;
    final remote = _FakeRemote(
      onFetch: () async {
        attempts++;
        if (attempts == 1) {
          throw const CityGalleryApiException(
            CityGalleryFailure.invalidResponse,
          );
        }
        return [_snapshot()];
      },
    );
    final repository = CityGalleryRepository(
      remote: remote,
      cache: MemoryCityGalleryCache(),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repository)));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('gallery_error')), findsOneWidget);
    expect(find.textContaining('could not be read'), findsOneWidget);

    await tester.tap(find.byKey(const Key('gallery_retry')));
    await tester.pump();
    await tester.pump();
    expect(find.text('HARBORLIGHT'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('offline failure displays cached cities and banner', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final remote = _FakeRemote(
      onFetch: () async =>
          throw const CityGalleryApiException(CityGalleryFailure.network),
    );
    final repository = CityGalleryRepository(
      remote: remote,
      cache: MemoryCityGalleryCache([_snapshot()]),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repository)));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('gallery_cache_banner')), findsOneWidget);
    expect(find.textContaining('Offline'), findsOneWidget);
    expect(find.text('HARBORLIGHT'), findsOneWidget);
  });

  testWidgets('successful empty response shows the empty gallery state', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repository = CityGalleryRepository(
      remote: _FakeRemote(onFetch: () async => const []),
      cache: MemoryCityGalleryCache(),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repository)));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('gallery_empty')), findsOneWidget);
    expect(find.textContaining('No cities'), findsOneWidget);
  });

  testWidgets('publish confirms, sends once, and excludes private state', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    final remote = _FakeRemote(onFetch: () async => const []);
    final repository = CityGalleryRepository(
      remote: remote,
      cache: MemoryCityGalleryCache(),
    );
    addTearDown(controller.dispose);
    addTearDown(repository.close);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );

    await tester.pumpWidget(
      app(
        Scaffold(
          body: PublishCitySnapshotPanel(
            controller: controller,
            repository: repository,
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('publish_city_snapshot')));
    await tester.pump();
    expect(find.textContaining('save file'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_publish_city_snapshot')));
    await tester.pump();
    await tester.pump();

    expect(remote.publishCount, 1);
    expect(remote.lastPublished, isNotNull);
    final json = remote.lastPublished!.toPublishJson();
    expect(json, isNot(contains('seed')));
    expect(json, isNot(contains('investigation_history')));
    expect(find.text('PUBLISHED'), findsOneWidget);
  });

  testWidgets('publishing disables duplicate taps until POST completes', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final controller = GameController(activeRun: true);
    final publishCompleter = Completer<PublicCitySnapshot>();
    final remote = _FakeRemote(
      onFetch: () async => const [],
      onPublish: (_) => publishCompleter.future,
    );
    final repository = CityGalleryRepository(
      remote: remote,
      cache: MemoryCityGalleryCache(),
    );
    addTearDown(controller.dispose);
    addTearDown(repository.close);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );
    await tester.pumpWidget(
      app(
        Scaffold(
          body: PublishCitySnapshotPanel(
            controller: controller,
            repository: repository,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('publish_city_snapshot')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm_publish_city_snapshot')));
    await tester.pump();
    expect(find.text('PUBLISHING...'), findsOneWidget);
    expect(remote.publishCount, 1);
    final disabled = tester.widget<InkWell>(
      find.byKey(const Key('publish_city_snapshot')),
    );
    expect(disabled.onTap, isNull);

    publishCompleter.complete(_snapshot());
    await tester.pump();
    await tester.pump();
    expect(find.text('PUBLISHED'), findsOneWidget);
    expect(remote.publishCount, 1);
  });
}

class _FakeRemote implements CityGalleryRemoteDataSource {
  _FakeRemote({required this.onFetch, this.onPublish});

  final Future<List<PublicCitySnapshot>> Function() onFetch;
  final Future<PublicCitySnapshot> Function(PublicCitySnapshot snapshot)?
  onPublish;
  int publishCount = 0;
  PublicCitySnapshot? lastPublished;

  @override
  Future<List<PublicCitySnapshot>> fetchSnapshots() => onFetch();

  @override
  Future<PublicCitySnapshot> publishSnapshot(
    PublicCitySnapshot snapshot,
  ) async {
    publishCount++;
    lastPublished = snapshot;
    final callback = onPublish;
    if (callback != null) return callback(snapshot);
    return PublicCitySnapshot.fromJson({
      'id': 'published-$publishCount',
      ...snapshot.toPublishJson(),
    });
  }

  @override
  void close() {}
}

PublicCitySnapshot _snapshot() => PublicCitySnapshot(
  id: 'snapshot-1',
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
