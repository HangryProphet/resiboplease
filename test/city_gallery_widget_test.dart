import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/data/gallery/city_gallery_api_service.dart';
import 'package:resiboplease/data/gallery/city_gallery_cache.dart';
import 'package:resiboplease/data/gallery/city_gallery_repository.dart';
import 'package:resiboplease/data/gallery/community_auth_service.dart';
import 'package:resiboplease/domain/models/player_profile.dart';
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

  CityGalleryRepository repository(
    _FakeRemote remote,
    MemoryCommunityAuthService auth, {
    MemoryCityGalleryCache? cache,
  }) => CityGalleryRepository(
    remote: remote,
    cache: cache ?? MemoryCityGalleryCache(),
    auth: auth,
  );

  testWidgets('first Visit Cities open prompts for a player name', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final auth = MemoryCommunityAuthService();
    final remote = _FakeRemote(auth: auth, publicSnapshots: [_snapshot()]);
    final repo = repository(remote, auth);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repo)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('player_name_setup_dialog')), findsOneWidget);
    expect(find.text('CHOOSE A PLAYER NAME'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('player_name_input')),
      'Kazuma',
    );
    await tester.tap(find.byKey(const Key('save_player_name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(auth.anonymousSignInCount, 1);
    expect(find.byKey(const Key('player_name_setup_dialog')), findsNothing);
    expect(find.text('HARBORLIGHT'), findsOneWidget);
    expect(find.text('by Kazuma'), findsOneWidget);
  });

  testWidgets('existing profile skips setup and loads Explore', (tester) async {
    usePhoneViewport(tester);
    final auth = MemoryCommunityAuthService(userId: _ownerId);
    final remote = _FakeRemote(
      auth: auth,
      profile: _profile(),
      publicSnapshots: [_snapshot()],
    );
    final repo = repository(remote, auth);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repo)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('player_name_setup_dialog')), findsNothing);
    expect(find.textContaining('Sharing as Kazuma'), findsOneWidget);
    expect(find.text('HARBORLIGHT'), findsOneWidget);
  });

  testWidgets('duplicate display name is rejected with friendly copy', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final auth = MemoryCommunityAuthService();
    final remote = _FakeRemote(auth: auth, duplicateName: true);
    final repo = repository(remote, auth);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repo)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(
      find.byKey(const Key('player_name_input')),
      'Used Name',
    );
    await tester.tap(find.byKey(const Key('save_player_name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('already being used'), findsOneWidget);
    expect(find.byKey(const Key('player_name_setup_dialog')), findsOneWidget);
  });

  testWidgets('My Cities shows private rows and owner can toggle and delete', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final auth = MemoryCommunityAuthService(userId: _ownerId);
    final remote = _FakeRemote(
      auth: auth,
      profile: _profile(),
      publicSnapshots: [_snapshot()],
      ownSnapshots: [
        _snapshot(),
        _snapshot(id: 'private-1', isPublic: false),
      ],
    );
    final repo = repository(remote, auth);

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repo)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gallery_tab_my_cities')));
    await tester.pumpAndSettle();

    expect(find.text('PRIVATE'), findsOneWidget);
    expect(find.byKey(const Key('gallery_city_private-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggle_privacy_private-1')));
    await tester.pumpAndSettle();
    expect(
      remote.own.firstWhere((item) => item.id == 'private-1').isPublic,
      isTrue,
    );

    await tester.drag(
      find.byKey(const Key('gallery_results')),
      const Offset(0, -180),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('delete_snapshot_private-1')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Your local city save will not be deleted'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('confirm_delete_snapshot')));
    await tester.pumpAndSettle();

    expect(remote.own.where((item) => item.id == 'private-1'), isEmpty);
    expect(find.byKey(const Key('gallery_city_private-1')), findsNothing);
  });

  testWidgets(
    'debounced player search returns profiles without private cities',
    (tester) async {
      usePhoneViewport(tester);
      final auth = MemoryCommunityAuthService(userId: _ownerId);
      final other = _profile(userId: _otherId, displayName: 'Kazumi');
      final remote = _FakeRemote(
        auth: auth,
        profile: _profile(),
        profiles: [other],
        publicSnapshots: [
          _snapshot(id: 'other-public', ownerId: _otherId, owner: 'Kazumi'),
        ],
        ownSnapshots: [_snapshot(id: 'own-private', isPublic: false)],
      );
      final repo = repository(remote, auth);

      await tester.pumpWidget(app(VisitCitiesScreen(repository: repo)));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('player_search_input')),
        'kazu',
      );
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Kazumi'), findsOneWidget);
      expect(remote.lastSearch, 'kazu');
      final otherCities = await repo.fetchPlayerPublicCities(_otherId);
      expect(otherCities.map((item) => item.id), ['other-public']);
      expect(otherCities.every((item) => item.isPublic), isTrue);
    },
  );

  testWidgets(
    'publish prompts for privacy and never uploads full local state',
    (tester) async {
      usePhoneViewport(tester);
      final auth = MemoryCommunityAuthService(userId: _ownerId);
      final remote = _FakeRemote(auth: auth, profile: _profile());
      final repo = repository(remote, auth);
      final controller = GameController(activeRun: true);
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
              repository: repo,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('publish_city_snapshot')));
      await tester.pumpAndSettle();
      expect(find.textContaining('save file'), findsOneWidget);
      await tester.tap(find.byKey(const Key('publish_privacy_private')));
      await tester.tap(find.byKey(const Key('confirm_publish_city_snapshot')));
      await tester.pumpAndSettle();

      expect(remote.publishCount, 1);
      expect(remote.lastPublished!.isPublic, isFalse);
      final json = remote.lastPublished!.toPublishJson();
      expect(json, isNot(contains('owner_id')));
      expect(json, isNot(contains('seed')));
      expect(json, isNot(contains('investigation_history')));
      expect(find.text('SAVED PRIVATELY'), findsOneWidget);
    },
  );

  testWidgets('gallery API failure leaves local gameplay state untouched', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final auth = MemoryCommunityAuthService(userId: _ownerId);
    final remote = _FakeRemote(
      auth: auth,
      profile: _profile(),
      fetchFailure: CityGalleryFailure.network,
    );
    final repo = repository(remote, auth);
    final game = GameController(activeRun: true);
    final cityName = game.activeCityName;

    await tester.pumpWidget(app(VisitCitiesScreen(repository: repo)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const Key('gallery_error')), findsOneWidget);
    expect(game.hasActiveRun, isTrue);
    expect(game.activeCityName, cityName);
  });
}

class _FakeRemote implements CityGalleryRemoteDataSource {
  _FakeRemote({
    required this.auth,
    this.profile,
    this.duplicateName = false,
    List<PublicCitySnapshot> publicSnapshots = const [],
    List<PublicCitySnapshot> ownSnapshots = const [],
    this.profiles = const [],
    this.fetchFailure,
  }) : public = List.of(publicSnapshots),
       own = List.of(ownSnapshots);

  final MemoryCommunityAuthService auth;
  PlayerProfile? profile;
  final bool duplicateName;
  List<PublicCitySnapshot> public;
  List<PublicCitySnapshot> own;
  final List<PlayerProfile> profiles;
  final CityGalleryFailure? fetchFailure;
  String? lastSearch;
  int publishCount = 0;
  PublicCitySnapshot? lastPublished;

  @override
  Future<PlayerProfile> createProfile(String displayName) async {
    if (duplicateName) {
      throw const CityGalleryApiException(CityGalleryFailure.duplicateName);
    }
    return profile = _profile(
      userId: auth.currentUserId!,
      displayName: displayName.trim(),
    );
  }

  @override
  Future<void> deleteSnapshot(PublicCitySnapshot snapshot) async {
    own = own.where((item) => item.id != snapshot.id).toList();
    public = public.where((item) => item.id != snapshot.id).toList();
  }

  @override
  Future<List<PublicCitySnapshot>> fetchOwnSnapshots(String userId) async =>
      own.where((item) => item.ownerId == userId).toList();

  @override
  Future<PlayerProfile?> fetchProfile(String userId) async =>
      profile?.userId == userId ? profile : null;

  @override
  Future<List<PublicCitySnapshot>> fetchPublicSnapshots({
    String? ownerId,
  }) async {
    if (fetchFailure case final failure?) {
      throw CityGalleryApiException(failure);
    }
    return public
        .where(
          (item) =>
              item.isPublic && (ownerId == null || item.ownerId == ownerId),
        )
        .toList();
  }

  @override
  Future<PublicCitySnapshot> publishSnapshot(
    PublicCitySnapshot snapshot,
  ) async {
    publishCount++;
    lastPublished = snapshot;
    final published = _copySnapshot(
      snapshot,
      id: 'published-$publishCount',
      ownerId: auth.currentUserId,
      owner: profile?.displayName ?? 'Kazuma',
    );
    own = [published, ...own];
    if (published.isPublic) public = [published, ...public];
    return published;
  }

  @override
  Future<List<PlayerProfile>> searchProfiles(String query) async {
    lastSearch = query;
    final normalized = query.toLowerCase();
    return profiles
        .where((item) => item.displayName.toLowerCase().contains(normalized))
        .toList();
  }

  @override
  Future<PublicCitySnapshot> updateSnapshotPrivacy(
    PublicCitySnapshot snapshot,
    bool isPublic,
  ) async {
    final updated = _copySnapshot(snapshot, isPublic: isPublic);
    own = [for (final item in own) item.id == snapshot.id ? updated : item];
    public = [
      for (final item in public)
        if (item.id != snapshot.id) item,
      if (isPublic) updated,
    ];
    return updated;
  }

  @override
  void close() {}
}

const _ownerId = '00000000-0000-4000-8000-000000000001';
const _otherId = '00000000-0000-4000-8000-000000000002';

PlayerProfile _profile({
  String userId = _ownerId,
  String displayName = 'Kazuma',
}) => PlayerProfile(
  userId: userId,
  displayName: displayName,
  createdAt: DateTime.utc(2026, 8, 18),
  updatedAt: DateTime.utc(2026, 8, 18),
);

PublicCitySnapshot _snapshot({
  String id = 'snapshot-1',
  String ownerId = _ownerId,
  String owner = 'Kazuma',
  bool isPublic = true,
}) => PublicCitySnapshot(
  id: id,
  ownerId: ownerId,
  ownerDisplayName: owner,
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

PublicCitySnapshot _copySnapshot(
  PublicCitySnapshot source, {
  String? id,
  String? ownerId,
  String? owner,
  bool? isPublic,
}) => PublicCitySnapshot(
  id: id ?? source.id,
  ownerId: ownerId ?? source.ownerId,
  ownerDisplayName: owner ?? source.ownerDisplayName,
  isPublic: isPublic ?? source.isPublic,
  cityName: source.cityName,
  termNumber: source.termNumber,
  startingPressure: source.startingPressure,
  topIssue: source.topIssue,
  selectedCandidateName: source.selectedCandidateName,
  candidateParty: source.candidateParty,
  finalCityCondition: source.finalCityCondition,
  outcomeSummary: source.outcomeSummary,
  majorIssues: source.majorIssues,
  majorEvents: source.majorEvents,
  createdAt: source.createdAt,
);
