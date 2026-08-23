import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/resibo_theme.dart';
import '../../data/gallery/city_gallery_api_service.dart';
import '../../data/gallery/city_gallery_repository.dart';
import '../../domain/models/public_city_snapshot.dart';
import '../../l10n/city_gallery_localizations.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';
import '../information/widgets/information_actions.dart';

class VisitCitiesScreen extends StatefulWidget {
  const VisitCitiesScreen({required this.repository, super.key});

  final CityGalleryRepository repository;

  @override
  State<VisitCitiesScreen> createState() => _VisitCitiesScreenState();
}

class _VisitCitiesScreenState extends State<VisitCitiesScreen> {
  bool _loading = true;
  CityGalleryLoadResult? _result;
  CityGalleryFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_loading && mounted) setState(() => _loading = true);
    try {
      final result = await widget.repository.fetchSnapshots();
      if (!mounted) return;
      setState(() {
        _result = result;
        _failure = null;
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
              title: strings.title,
              subtitle: strings.subtitle,
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
                child: _body(strings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(CityGalleryStrings strings) {
    if (_loading) {
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
          title: switch (failure) {
            CityGalleryFailure.notConfigured => strings.notConfigured,
            CityGalleryFailure.invalidResponse => strings.invalidResponse,
            _ => strings.unavailable,
          },
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
          icon: Icons.location_city_rounded,
          title: strings.empty,
          body: strings.emptyBody,
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
                    _CitySnapshotCard(snapshot: snapshot),
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
        await widget.repository.fetchSnapshots();
        snapshot = widget.repository.findById(widget.snapshotId);
      } catch (_) {
        // The detail page uses a single player-safe missing state.
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

class _CitySnapshotCard extends StatelessWidget {
  const _CitySnapshotCard({required this.snapshot});

  final PublicCitySnapshot snapshot;

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
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: snapshot.id == null
              ? null
              : () => context.go(
                  '/visit-cities/${Uri.encodeComponent(snapshot.id!)}',
                ),
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
                          const SizedBox(height: 4),
                          Text(
                            '${strings.term} ${snapshot.termNumber} • ${snapshot.selectedCandidateName}',
                            style: const TextStyle(
                              color: Color(0xFF675946),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: ResiboColors.mutedRed,
                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
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
        const SizedBox(height: 15),
        Text(
          strings.publicSharingNote,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9FB1BC),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
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
        Text(
          text,
          style: const TextStyle(
            color: cityBriefInk,
            fontSize: 10,
            fontWeight: FontWeight.w900,
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
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    ),
  );
}

String _displayValue(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
