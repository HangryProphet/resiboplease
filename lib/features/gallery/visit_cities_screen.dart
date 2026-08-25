import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/audio/game_audio_service.dart';
import '../../data/gallery/city_gallery_api_service.dart';
import '../../data/gallery/city_gallery_repository.dart';
import '../../domain/models/player_profile.dart';
import '../../domain/models/public_city_snapshot.dart';
import '../../l10n/city_gallery_localizations.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';
import '../information/widgets/information_actions.dart';
import 'player_name_setup_dialog.dart';

enum _GalleryTab { explore, myCities }

class VisitCitiesScreen extends StatefulWidget {
  const VisitCitiesScreen({required this.repository, super.key});

  final CityGalleryRepository repository;

  @override
  State<VisitCitiesScreen> createState() => _VisitCitiesScreenState();
}

class _VisitCitiesScreenState extends State<VisitCitiesScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  PlayerProfile? _profile;
  _GalleryTab _tab = _GalleryTab.explore;
  bool _initializing = true;
  bool _loading = false;
  bool _searching = false;
  CityGalleryLoadResult? _result;
  CityGalleryFailure? _failure;
  CityGalleryFailure? _searchFailure;
  List<PlayerProfile> _searchResults = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      var profile = await widget.repository.restoreProfile();
      if (!mounted) return;
      profile ??= await showPlayerNameSetupDialog(context, widget.repository);
      if (!mounted) return;
      if (profile == null) {
        context.go('/');
        return;
      }
      setState(() {
        _profile = profile;
        _initializing = false;
      });
      await _load();
    } on CityGalleryApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _failure = error.failure;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _failure = CityGalleryFailure.network;
      });
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final result = _tab == _GalleryTab.explore
          ? await widget.repository.fetchPublicSnapshots()
          : await widget.repository.fetchOwnSnapshots();
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } on CityGalleryApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _result = null;
        _failure = error.failure;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _result = null;
        _failure = CityGalleryFailure.network;
        _loading = false;
      });
    }
  }

  void _selectTab(_GalleryTab value) {
    if (_tab == value) return;
    GameAudioScope.maybeOf(context)?.play(GameSound.uiTab);
    setState(() {
      _tab = value;
      _result = null;
      _failure = null;
    });
    _load();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searching = false;
        _searchFailure = null;
        _searchResults = const [];
      });
      return;
    }
    setState(() => _searching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await widget.repository.searchProfiles(query);
        if (!mounted || _searchController.text != query) return;
        setState(() {
          _searchResults = results;
          _searchFailure = null;
          _searching = false;
        });
      } on CityGalleryApiException catch (error) {
        if (!mounted || _searchController.text != query) return;
        setState(() {
          _searchResults = const [];
          _searchFailure = error.failure;
          _searching = false;
        });
      } catch (_) {
        if (!mounted || _searchController.text != query) return;
        setState(() {
          _searchResults = const [];
          _searchFailure = CityGalleryFailure.network;
          _searching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.galleryStrings;
    return Scaffold(
      key: const Key('visit_cities_screen'),
      backgroundColor: const Color(0xFF08131F),
      body: SafeArea(
        child: Column(
          children: [
            _GalleryHeader(
              title: strings.visitCities,
              subtitle: _profile == null
                  ? strings.subtitle
                  : 'Sharing as ${_profile!.displayName}',
              onBack: () => context.go('/'),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B3B4A), Color(0xFF08131F)],
                  ),
                ),
                child: _initializing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: ResiboColors.teal,
                        ),
                      )
                    : Column(
                        children: [
                          _GalleryControls(
                            searchController: _searchController,
                            onSearchChanged: _onSearchChanged,
                            tab: _tab,
                            onTab: _selectTab,
                          ),
                          if (_searchController.text.trim().isNotEmpty)
                            _SearchResults(
                              loading: _searching,
                              failure: _searchFailure,
                              profiles: _searchResults,
                              onOpen: (profile) => context.go(
                                '/visit-cities/player/${Uri.encodeComponent(profile.userId)}',
                              ),
                            ),
                          Expanded(child: _body(strings)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(CityGalleryStrings strings) {
    if (_loading || (_result == null && _failure == null)) {
      return Center(
        key: const Key('gallery_loading'),
        child: _StatePanel(
          icon: Icons.cloud_download_rounded,
          title: strings.loading,
          loading: true,
        ),
      );
    }
    if (_failure case final failure?) {
      return Center(
        key: const Key('gallery_error'),
        child: _StatePanel(
          icon: Icons.cloud_off_rounded,
          title: _failureText(strings, failure),
          actionLabel: strings.retry,
          onAction: _load,
        ),
      );
    }
    final result = _result!;
    if (result.snapshots.isEmpty) {
      return Center(
        key: const Key('gallery_empty'),
        child: _StatePanel(
          icon: _tab == _GalleryTab.explore
              ? Icons.location_city_rounded
              : Icons.inventory_2_rounded,
          title: _tab == _GalleryTab.explore
              ? strings.empty
              : 'You have not uploaded a city yet.',
          body: _tab == _GalleryTab.explore
              ? strings.emptyBody
              : 'Publishing a snapshot never uploads or deletes your local save.',
          actionLabel: strings.retry,
          onAction: _load,
        ),
      );
    }
    return RefreshIndicator(
      color: ResiboColors.mutedRed,
      onRefresh: _load,
      child: ListView(
        key: const Key('gallery_results'),
        padding: const EdgeInsets.fromLTRB(13, 14, 13, 34),
        children: [
          if (result.fromCache) ...[
            _CacheBanner(
              message: result.liveFailure == CityGalleryFailure.network
                  ? strings.offline
                  : strings.cachedServer,
              onRetry: _load,
              retryLabel: strings.retry,
            ),
            const SizedBox(height: 12),
          ],
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  for (final snapshot in result.snapshots) ...[
                    _tab == _GalleryTab.explore
                        ? _PublicCityCard(snapshot: snapshot)
                        : _MyCityCard(
                            snapshot: snapshot,
                            onPrivacy: () => _setPrivacy(snapshot),
                            onDelete: () => _confirmDelete(snapshot),
                          ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setPrivacy(PublicCitySnapshot snapshot) async {
    try {
      await widget.repository.setPrivacy(snapshot, !snapshot.isPublic);
      if (!mounted) return;
      _notice(
        snapshot.isPublic ? 'City is now private.' : 'City is now public.',
      );
      await _load();
    } on CityGalleryApiException catch (error) {
      if (mounted) _notice(_writeFailureText(error.failure));
    }
  }

  Future<void> _confirmDelete(PublicCitySnapshot snapshot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: PaperPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel(
                  label: 'Delete Shared Snapshot?',
                  icon: Icons.delete_forever_rounded,
                  color: ResiboColors.mutedRed,
                ),
                const SizedBox(height: 10),
                const Text(
                  'This only removes the shared city snapshot. Your local city save will not be deleted.',
                  style: TextStyle(color: dossierInk, height: 1.4),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    ChunkyActionButton(
                      label: 'Cancel',
                      compact: true,
                      color: ResiboColors.navy,
                      sound: GameSound.uiBack,
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                    ChunkyActionButton(
                      buttonKey: const Key('confirm_delete_snapshot'),
                      label: 'Delete Snapshot',
                      compact: true,
                      color: ResiboColors.mutedRed,
                      sound: GameSound.uiConfirm,
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.repository.deleteSnapshot(snapshot);
      if (!mounted) return;
      _notice('Shared snapshot deleted. Your local save is unchanged.');
      await _load();
    } on CityGalleryApiException catch (error) {
      if (mounted) _notice(_writeFailureText(error.failure));
    }
  }

  void _notice(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ResiboColors.navy,
      content: Text(message, style: const TextStyle(fontFamily: 'LilitaOne')),
    ),
  );
}

class PlayerPublicCitiesScreen extends StatefulWidget {
  const PlayerPublicCitiesScreen({
    required this.repository,
    required this.userId,
    super.key,
  });

  final CityGalleryRepository repository;
  final String userId;

  @override
  State<PlayerPublicCitiesScreen> createState() =>
      _PlayerPublicCitiesScreenState();
}

class _PlayerPublicCitiesScreenState extends State<PlayerPublicCitiesScreen> {
  bool _loading = true;
  List<PublicCitySnapshot> _snapshots = const [];
  CityGalleryFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final snapshots = await widget.repository.fetchPlayerPublicCities(
        widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _snapshots = snapshots;
        _loading = false;
      });
    } on CityGalleryApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = error.failure;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.repository.findProfile(widget.userId);
    return Scaffold(
      key: const Key('player_public_cities_screen'),
      backgroundColor: const Color(0xFF08131F),
      body: SafeArea(
        child: Column(
          children: [
            _GalleryHeader(
              title: profile?.displayName ?? 'Player Cities',
              subtitle: 'Public cities only',
              onBack: () => context.go('/visit-cities'),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: ResiboColors.teal,
                      ),
                    )
                  : _failure != null
                  ? Center(
                      child: _StatePanel(
                        icon: Icons.cloud_off_rounded,
                        title: 'This player’s public cities are unavailable.',
                        actionLabel: 'Retry',
                        onAction: _load,
                      ),
                    )
                  : _snapshots.isEmpty
                  ? const Center(
                      child: _StatePanel(
                        icon: Icons.visibility_off_rounded,
                        title: 'This player has no public cities.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(13),
                      itemCount: _snapshots.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) =>
                          _PublicCityCard(snapshot: _snapshots[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CitySnapshotDetailScreen extends StatefulWidget {
  const CitySnapshotDetailScreen({
    required this.repository,
    required this.snapshotId,
    super.key,
  });

  final CityGalleryRepository repository;
  final String snapshotId;

  @override
  State<CitySnapshotDetailScreen> createState() =>
      _CitySnapshotDetailScreenState();
}

class _CitySnapshotDetailScreenState extends State<CitySnapshotDetailScreen> {
  PublicCitySnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    var snapshot = widget.repository.findById(widget.snapshotId);
    if (snapshot == null) {
      try {
        await widget.repository.fetchPublicSnapshots();
        snapshot = widget.repository.findById(widget.snapshotId);
      } catch (_) {
        // Use one safe missing state for deleted or inaccessible snapshots.
      }
    }
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.galleryStrings;
    return Scaffold(
      key: const Key('city_snapshot_detail_screen'),
      backgroundColor: const Color(0xFF08131F),
      body: SafeArea(
        child: Column(
          children: [
            _GalleryHeader(
              title: strings.citySnapshot,
              subtitle: _snapshot?.cityName ?? strings.subtitle,
              onBack: () => context.go('/visit-cities'),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _snapshot == null
                  ? Center(
                      child: _StatePanel(
                        icon: Icons.location_off_rounded,
                        title: strings.unavailable,
                        actionLabel: strings.retry,
                        onAction: _resolve,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(13, 17, 13, 36),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: _SnapshotDetails(snapshot: _snapshot!),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryControls extends StatelessWidget {
  const _GalleryControls({
    required this.searchController,
    required this.onSearchChanged,
    required this.tab,
    required this.onTab,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final _GalleryTab tab;
  final ValueChanged<_GalleryTab> onTab;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(13, 13, 13, 10),
    decoration: const BoxDecoration(
      color: Color(0xFF102638),
      border: Border(bottom: BorderSide(color: Color(0xFF050A10), width: 2)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            TextField(
              key: const Key('player_search_input'),
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search players...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: const Color(0xFFFFEFC8),
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: cityBriefInk, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: cityBriefInk, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _GalleryTabButton(
                    key: const Key('gallery_tab_explore'),
                    label: 'Explore',
                    icon: Icons.public_rounded,
                    selected: tab == _GalleryTab.explore,
                    onTap: () => onTab(_GalleryTab.explore),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _GalleryTabButton(
                    key: const Key('gallery_tab_my_cities'),
                    label: 'My Cities',
                    icon: Icons.inventory_2_rounded,
                    selected: tab == _GalleryTab.myCities,
                    onTap: () => onTab(_GalleryTab.myCities),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _GalleryTabButton extends StatelessWidget {
  const _GalleryTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF050A10),
      borderRadius: BorderRadius.circular(9),
    ),
    padding: const EdgeInsets.only(bottom: 4),
    child: Material(
      color: selected ? ResiboColors.mutedRed : const Color(0xFF304A61),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFFFEDC2), size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFEDC2),
                    fontFamily: 'LilitaOne',
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.loading,
    required this.failure,
    required this.profiles,
    required this.onOpen,
  });

  final bool loading;
  final CityGalleryFailure? failure;
  final List<PlayerProfile> profiles;
  final ValueChanged<PlayerProfile> onOpen;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 190),
    color: const Color(0xFF0B1926),
    child: loading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: ResiboColors.teal),
            ),
          )
        : failure != null
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Player search is unavailable. Check your connection.',
                style: TextStyle(color: Color(0xFFFFEDC2)),
              ),
            ),
          )
        : profiles.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No matching players.',
                style: TextStyle(color: Color(0xFFB9C8D2)),
              ),
            ),
          )
        : ListView.builder(
            key: const Key('player_search_results'),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  key: Key('player_result_${profile.userId}'),
                  leading: const CircleAvatar(
                    backgroundColor: ResiboColors.teal,
                    child: Icon(Icons.person_rounded, color: Color(0xFFFFEDC2)),
                  ),
                  title: Text(
                    profile.displayName,
                    style: const TextStyle(
                      color: Color(0xFFFFEDC2),
                      fontFamily: 'LilitaOne',
                    ),
                  ),
                  subtitle: const Text(
                    'View public cities',
                    style: TextStyle(color: Color(0xFF9FB1BC)),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFFFD778),
                  ),
                  onTap: () => onOpen(profile),
                ),
              );
            },
          ),
  );
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
    decoration: const BoxDecoration(
      color: Color(0xFF14283B),
      border: Border(bottom: BorderSide(color: Color(0xFF050A10), width: 3)),
      boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(0, 4))],
    ),
    child: Row(
      children: [
        GameIconButton(
          key: const Key('gallery_back'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: Icons.arrow_back_rounded,
          color: const Color(0xFF304A61),
          onPressed: onBack,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFEDC2),
                  fontFamily: 'LuckiestGuy',
                  fontSize: 23,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFB9C8D2),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.public_rounded, color: Color(0xFFFFD778), size: 30),
      ],
    ),
  );
}

class _PublicCityCard extends StatelessWidget {
  const _PublicCityCard({required this.snapshot});

  final PublicCitySnapshot snapshot;

  @override
  Widget build(BuildContext context) => _SnapshotCardSurface(
    snapshot: snapshot,
    footer: InformationActionButton(
      label: 'View City',
      icon: Icons.visibility_rounded,
      color: const Color(0xFF3277A0),
      onPressed: snapshot.id == null
          ? null
          : () => context.go(
              '/visit-cities/${Uri.encodeComponent(snapshot.id!)}',
            ),
    ),
  );
}

class _MyCityCard extends StatelessWidget {
  const _MyCityCard({
    required this.snapshot,
    required this.onPrivacy,
    required this.onDelete,
  });

  final PublicCitySnapshot snapshot;
  final VoidCallback onPrivacy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => _SnapshotCardSurface(
    snapshot: snapshot,
    showOwner: false,
    badge: _PrivacyBadge(isPublic: snapshot.isPublic),
    footer: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChunkyActionButton(
          label: 'View',
          icon: Icons.visibility_rounded,
          compact: true,
          color: const Color(0xFF3277A0),
          onPressed: snapshot.id == null
              ? null
              : () => context.go(
                  '/visit-cities/${Uri.encodeComponent(snapshot.id!)}',
                ),
        ),
        ChunkyActionButton(
          buttonKey: Key('toggle_privacy_${snapshot.id}'),
          label: snapshot.isPublic ? 'Make Private' : 'Make Public',
          icon: snapshot.isPublic ? Icons.lock_rounded : Icons.public_rounded,
          compact: true,
          color: ResiboColors.teal,
          onPressed: onPrivacy,
        ),
        ChunkyActionButton(
          buttonKey: Key('delete_snapshot_${snapshot.id}'),
          label: 'Delete',
          icon: Icons.delete_rounded,
          compact: true,
          color: ResiboColors.mutedRed,
          onPressed: onDelete,
        ),
      ],
    ),
  );
}

class _SnapshotCardSurface extends StatelessWidget {
  const _SnapshotCardSurface({
    required this.snapshot,
    required this.footer,
    this.showOwner = true,
    this.badge,
  });

  final PublicCitySnapshot snapshot;
  final Widget footer;
  final bool showOwner;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final strings = context.galleryStrings;
    return Container(
      key: Key('gallery_city_${snapshot.id ?? snapshot.cityName}'),
      decoration: BoxDecoration(
        color: const Color(0xFF07111D),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 6), blurRadius: 5),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: cityBriefPaper,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: ResiboColors.teal,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cityBriefInk, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: Color(0xFFFFEDC2),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.cityName.toUpperCase(),
                          style: const TextStyle(
                            color: cityBriefInk,
                            fontFamily: 'LuckiestGuy',
                            fontSize: 22,
                            height: 1,
                          ),
                        ),
                        if (showOwner) ...[
                          const SizedBox(height: 3),
                          Text(
                            'by ${snapshot.ownerDisplayName}',
                            style: const TextStyle(
                              color: ResiboColors.mutedRed,
                              fontFamily: 'LilitaOne',
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${strings.term} ${snapshot.termNumber} • Mayor: ${snapshot.selectedCandidateName}',
                          style: const TextStyle(
                            color: Color(0xFF675946),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?badge,
                ],
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _SnapshotChip(
                    icon: Icons.priority_high_rounded,
                    text: snapshot.topIssue,
                  ),
                  _SnapshotChip(
                    icon: Icons.monitor_heart_rounded,
                    text: _displayValue(snapshot.finalCityCondition),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.outcomeSummary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 11),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyBadge extends StatelessWidget {
  const _PrivacyBadge({required this.isPublic});

  final bool isPublic;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: isPublic ? ResiboColors.teal : const Color(0xFF5B6370),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: cityBriefInk, width: 2),
    ),
    child: Text(
      isPublic ? 'PUBLIC' : 'PRIVATE',
      style: const TextStyle(
        color: Color(0xFFFFEDC2),
        fontFamily: 'LilitaOne',
        fontSize: 10,
      ),
    ),
  );
}

class _SnapshotDetails extends StatelessWidget {
  const _SnapshotDetails({required this.snapshot});

  final PublicCitySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final strings = context.galleryStrings;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(snapshot.createdAt.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CityPaperPanel(
          color: const Color(0xFFF2DFAE),
          child: Column(
            children: [
              const Icon(
                Icons.location_city_rounded,
                color: ResiboColors.mutedRed,
                size: 44,
              ),
              const SizedBox(height: 8),
              Text(
                snapshot.cityName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontFamily: 'LuckiestGuy',
                  fontSize: 28,
                ),
              ),
              Text(
                'by ${snapshot.ownerDisplayName}',
                style: const TextStyle(
                  color: ResiboColors.mutedRed,
                  fontFamily: 'LilitaOne',
                  fontSize: 14,
                ),
              ),
              Text(
                '${strings.term} ${snapshot.termNumber} • $date',
                style: const TextStyle(
                  color: Color(0xFF675946),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CityPaperPanel(
          child: Column(
            children: [
              _DetailRow(
                label: strings.electedLeader,
                value: snapshot.selectedCandidateName,
              ),
              _DetailRow(label: strings.party, value: snapshot.candidateParty),
              _DetailRow(label: strings.topIssue, value: snapshot.topIssue),
              _DetailRow(
                label: strings.startingCondition,
                value: _displayValue(snapshot.startingPressure),
              ),
              _DetailRow(
                label: strings.finalCondition,
                value: _displayValue(snapshot.finalCityCondition),
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CityPaperPanel(
          child: Text(
            snapshot.outcomeSummary,
            style: const TextStyle(
              color: cityBriefInk,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 18),
        CitySectionTitle(
          title: strings.majorIssues,
          icon: Icons.fact_check_rounded,
        ),
        const SizedBox(height: 8),
        _PublicList(items: snapshot.majorIssues),
        const SizedBox(height: 18),
        CitySectionTitle(
          title: strings.majorEvents,
          icon: Icons.history_rounded,
        ),
        const SizedBox(height: 8),
        _PublicList(items: snapshot.majorEvents),
      ],
    );
  }
}

class _PublicList extends StatelessWidget {
  const _PublicList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: ResiboColors.teal,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  items[index],
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (index != items.length - 1) const Divider(height: 16),
        ],
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: ResiboColors.mutedRed,
                fontFamily: 'LilitaOne',
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: cityBriefInk,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      if (!last) const Divider(height: 17),
    ],
  );
}

class _SnapshotChip extends StatelessWidget {
  const _SnapshotChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFE4CE9C),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: cityBriefInk, width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ResiboColors.mutedRed),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: cityBriefInk,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(18),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: CityPaperPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ResiboColors.mutedRed, size: 46),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: cityBriefInk,
                fontFamily: 'LilitaOne',
                fontSize: 19,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: cityBriefInk, height: 1.35),
              ),
            ],
            if (loading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: ResiboColors.teal),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              InformationActionButton(
                buttonKey: const Key('gallery_retry'),
                label: actionLabel!,
                icon: Icons.refresh_rounded,
                color: const Color(0xFF3277A0),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _CacheBanner extends StatelessWidget {
  const _CacheBanner({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Container(
        key: const Key('gallery_cache_banner'),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE2B653),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cityBriefInk, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: cityBriefInk),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            ChunkyActionButton(
              label: retryLabel,
              compact: true,
              color: ResiboColors.navy,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    ),
  );
}

String _failureText(CityGalleryStrings strings, CityGalleryFailure failure) =>
    switch (failure) {
      CityGalleryFailure.notConfigured => strings.notConfigured,
      CityGalleryFailure.invalidResponse => strings.invalidResponse,
      CityGalleryFailure.authentication =>
        'Your community session could not be restored.',
      _ => strings.unavailable,
    };

String _writeFailureText(CityGalleryFailure failure) => switch (failure) {
  CityGalleryFailure.authentication =>
    'This shared city no longer belongs to this session.',
  CityGalleryFailure.notFound => 'That shared snapshot no longer exists.',
  _ => 'A connection is required. No remote change was made.',
};

String _displayValue(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
