import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/news_media.dart';
import '../../l10n/information_ecosystem_localizations.dart';
import '../../l10n/tv_broadcast_localizations.dart';
import '../dossier/widgets/dossier_ui.dart';
import 'widgets/information_actions.dart';
import 'widgets/information_media_slots.dart';

class NewsCoverageScreen extends StatelessWidget {
  const NewsCoverageScreen({
    required this.controller,
    required this.eventId,
    super.key,
  });

  final GameController controller;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final news = controller.informationEcosystem.news;
    final event = news.eventById(eventId);
    if (event == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        body: Center(
          child: ChunkyActionButton(
            label: 'Return to Chronicle',
            icon: Icons.arrow_back_rounded,
            color: const Color(0xFF304A61),
            onPressed: () => context.go('/city/chronicle'),
          ),
        ),
      );
    }
    final coverage = news.coverageForEvent(event.id);
    final broadcast = controller.informationEcosystem.tvBroadcasts.forEvent(
      event.id,
    );
    return Scaffold(
      backgroundColor: const Color(0xFF0B1725),
      body: SafeArea(
        child: InvestigationBackdrop(
          showCity: true,
          child: Column(
            children: [
              InvestigationHeader(
                title: context.informationStrings.compareCoverage,
                subtitle: controller.activeCityName,
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go('/city/chronicle'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('news_coverage_scroll'),
                  padding: const EdgeInsets.fromLTRB(13, 16, 13, 36),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _UnderlyingEventPanel(
                            event: event,
                            onWatchReport: broadcast == null
                                ? null
                                : () => context.push('/tv/${broadcast.id}'),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            context.informationStrings.sameEventNote,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFD5DFE4),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 13),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 760
                                  ? 3
                                  : 1;
                              const gap = 12.0;
                              final width =
                                  (constraints.maxWidth - gap * (columns - 1)) /
                                  columns;
                              return Wrap(
                                spacing: gap,
                                runSpacing: 13,
                                children: [
                                  for (final article in coverage)
                                    SizedBox(
                                      width: width,
                                      child: NewsCoverageCard(
                                        coverage: article,
                                        outlet: news.outletById(
                                          article.outletId,
                                        )!,
                                        event: event,
                                        onOpen: () =>
                                            context.push('/news/${article.id}'),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderlyingEventPanel extends StatelessWidget {
  const _UnderlyingEventPanel({
    required this.event,
    required this.onWatchReport,
  });
  final UnderlyingNewsEvent event;
  final VoidCallback? onWatchReport;

  @override
  Widget build(BuildContext context) => PaperPanel(
    key: Key('underlying_news_event_${event.id}'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          label: 'Shared event record',
          icon: Icons.hub_rounded,
          color: ResiboColors.gold,
        ),
        const SizedBox(height: 9),
        Text(
          event.title,
          style: const TextStyle(
            color: dossierInk,
            fontFamily: 'LuckiestGuy',
            fontSize: 27,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          event.factualSummary,
          style: const TextStyle(color: dossierInk, height: 1.45),
        ),
        const SizedBox(height: 9),
        for (final fact in event.knownFacts)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 17,
                  color: ResiboColors.teal,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(fact, style: const TextStyle(color: dossierInk)),
                ),
              ],
            ),
          ),
        if (onWatchReport != null) ...[
          const SizedBox(height: 9),
          InformationActionButton(
            buttonKey: Key('coverage_watch_report_${event.id}'),
            expanded: true,
            color: ResiboColors.mutedRed,
            icon: Icons.live_tv_rounded,
            label: context.tvStrings.watchTvReport,
            onPressed: onWatchReport,
          ),
        ],
      ],
    ),
  );
}

class NewsCoverageCard extends StatelessWidget {
  const NewsCoverageCard({
    required this.coverage,
    required this.outlet,
    required this.event,
    required this.onOpen,
    this.compact = false,
    super.key,
  });

  final NewsCoverage coverage;
  final NewsOutlet outlet;
  final UnderlyingNewsEvent event;
  final VoidCallback onOpen;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = Color(outlet.colorValue);
    return Container(
      key: Key('news_coverage_${coverage.id}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF101820), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NewsOutletHeader(outlet: outlet, compact: true),
          NewsImageSlot(
            assetKey: event.imageAssetKey ?? 'news_generic',
            semanticLabel: context.informationStrings.articleImagePending,
            color: color,
            compact: compact,
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${coverage.category.toUpperCase()} · ${coverage.publicationTime}',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  coverage.headline,
                  maxLines: compact ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF17232D),
                    fontFamily: 'LilitaOne',
                    fontSize: 20,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  coverage.articleSummary,
                  maxLines: compact ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF465663),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${context.informationStrings.framingAngle}: ${coverage.framingAngle}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                InformationActionButton(
                  buttonKey: Key('open_news_${coverage.id}'),
                  expanded: true,
                  color: color,
                  onPressed: onOpen,
                  icon: Icons.article_rounded,
                  label: context.informationStrings.fullStory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewsOutletHeader extends StatelessWidget {
  const NewsOutletHeader({
    required this.outlet,
    this.compact = false,
    this.onBack,
    this.backButtonKey,
    super.key,
  });
  final NewsOutlet outlet;
  final bool compact;
  final VoidCallback? onBack;
  final Key? backButtonKey;

  @override
  Widget build(BuildContext context) => Container(
    color: Color(outlet.colorValue),
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 11 : 18,
      vertical: compact ? 8 : 13,
    ),
    child: Row(
      children: [
        if (onBack != null) ...[
          GameIconButton(
            key: backButtonKey,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icons.arrow_back_rounded,
            color: const Color(0xFF304A61),
            onPressed: onBack!,
          ),
          const SizedBox(width: 11),
        ],
        const Icon(Icons.newspaper_rounded, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                outlet.name.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'LilitaOne',
                  fontSize: compact ? 16 : 23,
                ),
              ),
              if (!compact)
                Text(
                  outlet.tagline,
                  style: const TextStyle(
                    color: Color(0xFFE8EEF1),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
