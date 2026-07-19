import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/models/pre_election_city_brief.dart';
import '../../l10n/city_brief_localizations.dart';
import '../../l10n/game_content_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import 'widgets/city_brief_ui.dart';
import 'widgets/pre_election_navigation_bar.dart';

class CityOverviewScreen extends StatelessWidget {
  const CityOverviewScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final city = controller.scenario.city;
      final brief = controller.preElectionBrief;
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        bottomNavigationBar: const PreElectionNavigationBar(
          current: PreElectionDestination.city,
        ),
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF172B3E), Color(0xFF09131F)],
              ),
            ),
            child: Column(
              children: [
                CityBriefHeader(
                  title: context.l10n.cityHubTitle,
                  cityName: controller.activeCityName,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('city_hub_scroll'),
                    padding: const EdgeInsets.fromLTRB(13, 17, 13, 34),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CityMap(
                              brief: brief,
                              cityName: controller.activeCityName,
                              onConcernTap: (concern) => _showConcernDetails(
                                context,
                                controller,
                                brief,
                                concern,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const FrozenSnapshotBanner(),
                            const SizedBox(height: 14),
                            CityPaperPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.cityBeforeVote.toUpperCase(),
                                    style: const TextStyle(
                                      color: cityBriefInk,
                                      fontFamily: 'LilitaOne',
                                      fontSize: 20,
                                      letterSpacing: .45,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    context.l10n.citySummaryText(city),
                                    style: const TextStyle(
                                      color: cityBriefInk,
                                      height: 1.42,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (controller.assistanceMode ==
                                      AssistanceMode.guided) ...[
                                    const SizedBox(height: 12),
                                    _GuidedReminder(),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            CitySectionTitle(
                              title: context.l10n.cityPulse,
                              icon: Icons.monitor_heart_rounded,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.fictionalCityEstimate,
                              style: const TextStyle(
                                color: Color(0xFFB9C7CF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 11),
                            _MetricGrid(metrics: brief.metrics),
                            const SizedBox(height: 27),
                            CitySectionTitle(
                              title: context.l10n.urgentConcerns,
                              icon: Icons.fact_check_rounded,
                            ),
                            const SizedBox(height: 11),
                            _ConcernGrid(
                              brief: brief,
                              cityName: controller.activeCityName,
                              onConcernTap: (concern) => _showConcernDetails(
                                context,
                                controller,
                                brief,
                                concern,
                              ),
                            ),
                            const SizedBox(height: 27),
                            CitySectionTitle(
                              title: context.l10n.latestChronicle,
                              icon: Icons.newspaper_rounded,
                            ),
                            const SizedBox(height: 11),
                            if (brief.news.isNotEmpty)
                              CityNewsCard(
                                item: brief.news.first,
                                cityName: controller.activeCityName,
                                compact: true,
                              ),
                            if (brief.voices.isNotEmpty) ...[
                              const SizedBox(height: 11),
                              CitizenVoiceCard(voice: brief.voices.first),
                            ],
                            const SizedBox(height: 13),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 360,
                                ),
                                child: CityActionButton(
                                  buttonKey: const Key('open_chronicle'),
                                  label: context.l10n.openChronicle,
                                  icon: Icons.menu_book_rounded,
                                  color: const Color(0xFF3277A0),
                                  onPressed: () =>
                                      context.go('/city/chronicle'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _ElectionActions(),
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
    },
  );
}

class _CityMap extends StatelessWidget {
  const _CityMap({
    required this.brief,
    required this.cityName,
    required this.onConcernTap,
  });

  final PreElectionCityBrief brief;
  final String cityName;
  final ValueChanged<CityConcernSnapshot> onConcernTap;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 8.7,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF07111D), width: 3),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                label: context.l10n.cityImageSemantics,
                image: true,
                child: Image.asset(
                  'assets/images/city/bayhaven_base.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [.45, 1],
                      colors: [Colors.transparent, Color(0xCC07111D)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 11,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * .63,
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 6),
                  decoration: BoxDecoration(
                    color: const Color(0xEAF4E7C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: cityBriefInk, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black87, offset: Offset(2, 3)),
                    ],
                  ),
                  child: Text(
                    cityName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: cityBriefInk,
                      fontFamily: 'LuckiestGuy',
                      fontSize: 17,
                      height: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 11,
                right: 11,
                bottom: 8,
                child: IgnorePointer(
                  child: Text(
                    context.l10n.cityMapHint,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFE8B7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                    ),
                  ),
                ),
              ),
              for (final concern in brief.concerns)
                _ConcernMarker(
                  concern: concern,
                  constraints: constraints,
                  onTap: () => onConcernTap(concern),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ConcernMarker extends StatelessWidget {
  const _ConcernMarker({
    required this.concern,
    required this.constraints,
    required this.onTap,
  });

  final CityConcernSnapshot concern;
  final BoxConstraints constraints;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final point = cityTopicHotspot(concern.topic);
    const size = 43.0;
    return Positioned(
      left: (constraints.maxWidth * point.dx - size / 2).clamp(
        2,
        constraints.maxWidth - size - 2,
      ),
      top: (constraints.maxHeight * point.dy - size / 2).clamp(
        2,
        constraints.maxHeight - size - 2,
      ),
      child: Tooltip(
        message: context.l10n.problemTitleText(concern.problem),
        child: Material(
          color: cityTopicColor(concern.topic),
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFFFFE7AF), width: 2.5),
          ),
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('city_hotspot_${concern.problem.id}'),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                cityTopicIcon(concern.topic),
                color: const Color(0xFFFFF2D0),
                size: 23,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidedReminder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    key: const Key('guided_resi_note'),
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFD8E7D8),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color(0xFF2D6259), width: 1.5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.assistant_outlined, color: ResiboColors.teal),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.guidedReminderTitle,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.guidedReminderBody,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<CityBriefMetric> metrics;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760 ? 3 : 2;
      const gap = 10.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final metric in metrics)
            SizedBox(
              key: Key('city_metric_${metric.kind.name}'),
              width: width,
              child: CityMetricCard(metric: metric),
            ),
        ],
      );
    },
  );
}

class _ConcernGrid extends StatelessWidget {
  const _ConcernGrid({
    required this.brief,
    required this.cityName,
    required this.onConcernTap,
  });

  final PreElectionCityBrief brief;
  final String cityName;
  final ValueChanged<CityConcernSnapshot> onConcernTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760 ? 3 : 1;
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final concern in brief.concerns)
            SizedBox(
              key: Key('city_concern_${concern.problem.id}'),
              width: width,
              child: _ConcernCard(
                concern: concern,
                cityName: cityName,
                onTap: () => onConcernTap(concern),
              ),
            ),
        ],
      );
    },
  );
}

class _ConcernCard extends StatelessWidget {
  const _ConcernCard({
    required this.concern,
    required this.cityName,
    required this.onTap,
  });

  final CityConcernSnapshot concern;
  final String cityName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = cityTopicColor(concern.topic);
    final problem = concern.problem;
    return CityPaperPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.lerp(color, Colors.white, .17)!, color],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
              border: const Border(
                bottom: BorderSide(color: cityBriefInk, width: 2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  cityTopicIcon(concern.topic),
                  color: const Color(0xFFFFF0C9),
                  size: 25,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    context.l10n.problemTitleText(problem).toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFF0C9),
                      fontFamily: 'LilitaOne',
                      fontSize: 17,
                      height: 1.05,
                      shadows: [
                        Shadow(color: Colors.black87, offset: Offset(1, 2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.problemDescriptionText(problem, cityName),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.affectedResidentsEstimate(
                    concern.affectedResidentsPercent,
                  ),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _ConcernTag(
                      label: context.l10n.severityValue(
                        context.l10n.citySeverityLabel(problem.severity),
                      ),
                    ),
                    _ConcernTag(
                      label: context.l10n.urgencyValue(
                        context.l10n.cityUrgencyLabel(problem.urgency),
                      ),
                    ),
                    _ConcernTag(label: context.l10n.trendLabel(problem.trend)),
                  ],
                ),
                const SizedBox(height: 11),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                    label: Text(context.l10n.openCaseFile),
                    style: TextButton.styleFrom(
                      foregroundColor: cityBriefInk,
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcernTag extends StatelessWidget {
  const _ConcernTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0x1D172332),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0x4D172332)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: cityBriefInk,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ElectionActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked = constraints.maxWidth < 560;
      final candidates = CityActionButton(
        buttonKey: const Key('meet_candidates'),
        label: context.l10n.meetCandidates,
        icon: Icons.groups_rounded,
        color: ResiboColors.teal,
        onPressed: () => context.go('/candidates'),
      );
      final ballot = CityActionButton(
        buttonKey: const Key('review_ballot'),
        label: context.l10n.reviewBallot,
        icon: Icons.how_to_vote_rounded,
        color: ResiboColors.mutedRed,
        onPressed: () => context.go('/vote'),
      );
      if (stacked) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [candidates, const SizedBox(height: 12), ballot],
        );
      }
      return Row(
        children: [
          Expanded(child: candidates),
          const SizedBox(width: 12),
          Expanded(child: ballot),
        ],
      );
    },
  );
}

void _showConcernDetails(
  BuildContext context,
  GameController controller,
  PreElectionCityBrief brief,
  CityConcernSnapshot concern,
) {
  final problem = concern.problem;
  final matchingMetrics = brief.metrics
      .where(
        (metric) =>
            metric.sourceIndicator == problem.primaryIndicator ||
            problem.relatedIndicators.contains(metric.sourceIndicator),
      )
      .toList(growable: false);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF101E2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: .84,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 11, 9, 8),
            child: Row(
              children: [
                Icon(
                  cityTopicIcon(concern.topic),
                  color: const Color(0xFFFFD785),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    sheetContext.l10n.caseFileDetails.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFEBC1),
                      fontFamily: 'LilitaOne',
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(
                    sheetContext,
                  ).closeButtonTooltip,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: Key('concern_detail_${problem.id}'),
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CityPaperPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sheetContext.l10n
                                  .problemTitleText(problem)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: cityBriefInk,
                                fontFamily: 'LilitaOne',
                                fontSize: 22,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              sheetContext.l10n.problemDescriptionText(
                                problem,
                                controller.activeCityName,
                              ),
                              style: const TextStyle(
                                color: cityBriefInk,
                                fontSize: 14,
                                height: 1.42,
                              ),
                            ),
                            const SizedBox(height: 13),
                            Text(
                              sheetContext.l10n.affectedResidentsEstimate(
                                concern.affectedResidentsPercent,
                              ),
                              style: TextStyle(
                                color: cityTopicColor(concern.topic),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: [
                                _ConcernTag(
                                  label: sheetContext.l10n.severityValue(
                                    sheetContext.l10n.citySeverityLabel(
                                      problem.severity,
                                    ),
                                  ),
                                ),
                                _ConcernTag(
                                  label: sheetContext.l10n.urgencyValue(
                                    sheetContext.l10n.cityUrgencyLabel(
                                      problem.urgency,
                                    ),
                                  ),
                                ),
                                _ConcernTag(
                                  label: sheetContext.l10n.trendLabel(
                                    problem.trend,
                                  ),
                                ),
                                for (final tag in problem.sdgTags)
                                  _ConcernTag(label: tag),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      CitySectionTitle(
                        title: sheetContext.l10n.currentCondition,
                        icon: Icons.analytics_rounded,
                      ),
                      const SizedBox(height: 10),
                      for (final metric in matchingMetrics) ...[
                        CityMetricCard(metric: metric),
                        const SizedBox(height: 9),
                      ],
                      const SizedBox(height: 9),
                      CityPaperPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sheetContext.l10n.relatedIndicators,
                              style: const TextStyle(
                                color: cityBriefInk,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            for (final indicator in <CityIndicator>{
                              problem.primaryIndicator,
                              ...problem.relatedIndicators,
                            })
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_right_rounded,
                                      color: ResiboColors.teal,
                                    ),
                                    Expanded(
                                      child: Text(
                                        sheetContext.l10n.indicatorLabel(
                                          indicator,
                                        ),
                                        style: const TextStyle(
                                          color: cityBriefInk,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
  );
}
