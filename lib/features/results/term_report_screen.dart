import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/term_result.dart';
import '../../l10n/game_content_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';

class TermReportScreen extends StatelessWidget {
  const TermReportScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.termResult;
    if (result == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: ChunkyActionButton(
              label: context.l10n.returnToBallot,
              icon: Icons.how_to_vote_rounded,
              onPressed: () => context.go('/vote'),
            ),
          ),
        ),
      );
    }
    final decisionIssue = controller.scenario.city.problems
        .where((problem) => problem.id == controller.topIssue)
        .map(context.l10n.problemTitleText)
        .firstOrNull;
    final ranked = result.totalChanges.entries.toList(growable: false)
      ..sort(
        (a, b) => _healthyChange(
          b.key,
          b.value,
        ).compareTo(_healthyChange(a.key, a.value)),
      );
    final gains = ranked
        .where((entry) => _healthyChange(entry.key, entry.value) > 0)
        .take(3)
        .toList(growable: false);
    final setbacks = ranked.reversed
        .where((entry) => _healthyChange(entry.key, entry.value) < 0)
        .take(3)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1725),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF172B3E), Color(0xFF08121D)],
            ),
          ),
          child: Column(
            children: [
              CityBriefHeader(
                title: context.l10n.termReport,
                cityName: controller.activeCityName,
                showBallot: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('term_report_scroll'),
                  padding: const EdgeInsets.fromLTRB(13, 17, 13, 38),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReportHero(result: result),
                          const SizedBox(height: 13),
                          CityPaperPanel(
                            color: const Color(0xFFF2DFAE),
                            padding: const EdgeInsets.all(13),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.balance_rounded,
                                  color: ResiboColors.mutedRed,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    context.l10n.outcomeNotVerdict,
                                    style: const TextStyle(
                                      color: cityBriefInk,
                                      fontSize: 13,
                                      height: 1.35,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26),
                          _GainSetbackGrid(gains: gains, setbacks: setbacks),
                          const SizedBox(height: 27),
                          CitySectionTitle(
                            title: context.l10n.whatChanged,
                            icon: Icons.query_stats_rounded,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            context.l10n.whatChangedBody,
                            style: const TextStyle(
                              color: Color(0xFFB9C7CF),
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 11),
                          _IndicatorReportGrid(result: result),
                          const SizedBox(height: 27),
                          CitySectionTitle(
                            title: context.l10n.administrationTimeline,
                            icon: Icons.history_rounded,
                          ),
                          const SizedBox(height: 11),
                          for (final phase in result.phases) ...[
                            _ReportPhaseCard(phase: phase),
                            const SizedBox(height: 11),
                          ],
                          const SizedBox(height: 16),
                          CitySectionTitle(
                            title: context.l10n.whyThisHappened,
                            icon: Icons.receipt_long_rounded,
                          ),
                          const SizedBox(height: 10),
                          CityPaperPanel(
                            child: Text(
                              context.l10n.modelExplanation,
                              style: const TextStyle(
                                color: cityBriefInk,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          CityPaperPanel(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.psychology_alt_rounded,
                                  color: ResiboColors.teal,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.yourDecisionContext,
                                        style: const TextStyle(
                                          color: cityBriefInk,
                                          fontFamily: 'LilitaOne',
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        context.l10n.decisionContextBody(
                                          decisionIssue ??
                                              context.l10n.notRecorded,
                                          (controller.confidence * 100).round(),
                                          controller.viewedEvidenceCount,
                                        ),
                                        style: const TextStyle(
                                          color: cityBriefInk,
                                          fontSize: 12,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ReportActions(
                            controller: controller,
                            result: result,
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

int _healthyChange(CityIndicator indicator, int change) =>
    indicator == CityIndicator.corruptionPressure ? -change : change;

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.result});

  final TermResult result;

  @override
  Widget build(BuildContext context) {
    final color = Color(result.candidate.colorValue);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.black, .35)!,
            const Color(0xFF101E2E),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF07111D), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black87, offset: Offset(0, 7), blurRadius: 8),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final portrait = SizedBox(
            width: compact ? 138 : 210,
            height: compact ? 300 : 235,
            child: Image.asset(
              'assets/images/candidates/${result.candidate.id}/${result.candidate.id}_portrait.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          );
          final copy = Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.administrationReceipt.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFD36B),
                      fontFamily: 'LilitaOne',
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    result.candidate.name.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFF0CB),
                      fontFamily: 'LuckiestGuy',
                      fontSize: 27,
                      height: 1,
                      shadows: [
                        Shadow(color: Colors.black87, offset: Offset(1, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.termSummaryText(result),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
          return SizedBox(
            height: compact ? 430 : 235,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [portrait, copy],
            ),
          );
        },
      ),
    );
  }
}

class _GainSetbackGrid extends StatelessWidget {
  const _GainSetbackGrid({required this.gains, required this.setbacks});

  final List<MapEntry<CityIndicator, int>> gains;
  final List<MapEntry<CityIndicator, int>> setbacks;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked = constraints.maxWidth < 620;
      final gainPanel = _MovementPanel(
        title: context.l10n.strongestGains,
        icon: Icons.trending_up_rounded,
        color: ResiboColors.teal,
        entries: gains,
      );
      final setbackPanel = _MovementPanel(
        title: context.l10n.hardestSetbacks,
        icon: Icons.trending_down_rounded,
        color: ResiboColors.mutedRed,
        entries: setbacks,
      );
      if (stacked) {
        return Column(
          children: [gainPanel, const SizedBox(height: 12), setbackPanel],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: gainPanel),
          const SizedBox(width: 12),
          Expanded(child: setbackPanel),
        ],
      );
    },
  );
}

class _MovementPanel extends StatelessWidget {
  const _MovementPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<MapEntry<CityIndicator, int>> entries;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontFamily: 'LilitaOne',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        if (entries.isEmpty)
          Text(
            context.l10n.noMajorChange,
            style: const TextStyle(color: cityBriefInk),
          )
        else
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.indicatorLabel(entry.key),
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value >= 0 ? '+' : ''}${entry.value}',
                    style: TextStyle(
                      color: color,
                      fontFamily: 'LuckiestGuy',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
      ],
    ),
  );
}

class _IndicatorReportGrid extends StatelessWidget {
  const _IndicatorReportGrid({required this.result});

  final TermResult result;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 780 ? 3 : 2;
      const gap = 10.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final indicator in CityIndicator.values)
            SizedBox(
              width: width,
              child: _ReportIndicatorCard(
                indicator: indicator,
                before: result.before.valueOf(indicator),
                after: result.after.valueOf(indicator),
              ),
            ),
        ],
      );
    },
  );
}

class _ReportIndicatorCard extends StatelessWidget {
  const _ReportIndicatorCard({
    required this.indicator,
    required this.before,
    required this.after,
  });

  final CityIndicator indicator;
  final int before;
  final int after;

  @override
  Widget build(BuildContext context) {
    final change = after - before;
    final healthy = _healthyChange(indicator, change) >= 0;
    final color = change == 0
        ? const Color(0xFF687176)
        : healthy
        ? ResiboColors.teal
        : ResiboColors.mutedRed;
    return CityPaperPanel(
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.indicatorLabel(indicator),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: cityBriefInk,
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                '$before',
                style: const TextStyle(
                  color: Color(0xFF776E60),
                  fontFamily: 'LuckiestGuy',
                  fontSize: 16,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: Color(0xFF776E60),
                ),
              ),
              Text(
                '$after',
                style: TextStyle(
                  color: color,
                  fontFamily: 'LuckiestGuy',
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              Text(
                '${change >= 0 ? '+' : ''}$change',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportPhaseCard extends StatelessWidget {
  const _ReportPhaseCard({required this.phase});

  final TermPhase phase;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (phase.eventKind.assetPath case final path?) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 92,
              height: 76,
              child: Image.asset(path, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 11),
        ] else ...[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ResiboColors.teal,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cityBriefInk, width: 2),
            ),
            child: const Icon(Icons.article_rounded, color: Color(0xFFFFF0CB)),
          ),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.phaseNumber(phase.number).toUpperCase(),
                style: const TextStyle(
                  color: ResiboColors.mutedRed,
                  fontFamily: 'LilitaOne',
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.phaseTitleText(phase),
                style: const TextStyle(
                  color: cityBriefInk,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final entry in phase.changes.entries.take(4))
                    Text(
                      '${context.l10n.indicatorLabel(entry.key)} ${entry.value >= 0 ? '+' : ''}${entry.value}',
                      style: const TextStyle(
                        color: Color(0xFF675946),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.controller, required this.result});

  final GameController controller;
  final TermResult result;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final replay = ChunkyActionButton(
        buttonKey: const Key('restart_same_seed'),
        label: context.l10n.replaySeed(result.seed),
        icon: Icons.replay_rounded,
        color: const Color(0xFF3277A0),
        onPressed: () {
          controller.restartSameSeed();
          context.go('/city');
        },
      );
      final home = ChunkyActionButton(
        label: context.l10n.mainMenu,
        icon: Icons.home_rounded,
        color: ResiboColors.mutedRed,
        onPressed: () => context.go('/'),
      );
      if (constraints.maxWidth < 560) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [replay, const SizedBox(height: 12), home],
        );
      }
      return Row(
        children: [
          Expanded(child: replay),
          const SizedBox(width: 12),
          Expanded(child: home),
        ],
      );
    },
  );
}
