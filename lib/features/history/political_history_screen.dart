import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/living_city_simulation.dart';
import '../../domain/models/political_timeline.dart';
import '../../domain/models/civic_prediction.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/living_city_localizations.dart';
import '../candidate_hub/widgets/candidate_image_slot.dart';
import '../city/widgets/city_brief_ui.dart';

class PoliticalHistoryScreen extends StatelessWidget {
  const PoliticalHistoryScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final records = controller.administrationHistory.reversed.toList(
        growable: false,
      );
      return _HistoryScaffold(
        title: context.l10n.politicalHistory,
        cityName: controller.activeCityName,
        child: records.isEmpty
            ? _EmptyHistory(currentElection: controller.currentElectionNumber)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TimelineIntro(
                    count: records.length,
                    currentElection: controller.currentElectionNumber,
                  ),
                  const SizedBox(height: 13),
                  CityActionButton(
                    buttonKey: const Key('open_accountability_journal'),
                    label: context.l10n.openResiboNgBayan,
                    icon: Icons.receipt_long_rounded,
                    color: ResiboColors.mutedRed,
                    onPressed: () => context.go('/accountability'),
                  ),
                  const SizedBox(height: 10),
                  CityActionButton(
                    buttonKey: const Key('open_civic_profile'),
                    label: context.l10n.openCivicProfile,
                    icon: Icons.workspace_premium_rounded,
                    color: const Color(0xFF3277A0),
                    onPressed: () => context.push('/civic-profile'),
                  ),
                  const SizedBox(height: 22),
                  for (var index = 0; index < records.length; index++) ...[
                    _AdministrationCard(record: records[index]),
                    if (index != records.length - 1) const _TimelineConnector(),
                  ],
                ],
              ),
      );
    },
  );
}

class AdministrationHistoryDetailScreen extends StatelessWidget {
  const AdministrationHistoryDetailScreen({
    required this.controller,
    required this.termNumber,
    super.key,
  });

  final GameController controller;
  final int termNumber;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final record = controller.administrationHistory
          .where((item) => item.termNumber == termNumber)
          .firstOrNull;
      if (record == null) {
        return _HistoryScaffold(
          title: context.l10n.historicalReceipt,
          cityName: controller.activeCityName,
          child: CityPaperPanel(
            child: Column(
              children: [
                const Icon(
                  Icons.find_in_page_rounded,
                  color: ResiboColors.mutedRed,
                  size: 42,
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.historicalReceiptMissing,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return _HistoryScaffold(
        title: context.l10n.administrationNumber(record.termNumber),
        cityName: controller.activeCityName,
        child: _AdministrationReceipt(record: record),
      );
    },
  );
}

class _HistoryScaffold extends StatelessWidget {
  const _HistoryScaffold({
    required this.title,
    required this.cityName,
    required this.child,
  });

  final String title;
  final String cityName;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
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
              title: title,
              cityName: cityName,
              showBallot: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('political_history_scroll'),
                padding: const EdgeInsets.fromLTRB(13, 17, 13, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: child,
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.currentElection});

  final int currentElection;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    child: Column(
      children: [
        const Icon(
          Icons.history_edu_rounded,
          color: ResiboColors.teal,
          size: 48,
        ),
        const SizedBox(height: 11),
        Text(
          context.l10n.noAdministrationHistory,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: cityBriefInk,
            fontFamily: 'LilitaOne',
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          context.l10n.historyBeginsAfterTerm(currentElection),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF675946),
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _TimelineIntro extends StatelessWidget {
  const _TimelineIntro({required this.count, required this.currentElection});

  final int count;
  final int currentElection;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    color: const Color(0xFFF2DFAE),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: ResiboColors.mutedRed,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: cityBriefInk, width: 2),
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: Color(0xFFFFF0CB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cityPoliticalTimeline.toUpperCase(),
                style: const TextStyle(
                  color: cityBriefInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.historyTimelineDescription(count, currentElection),
                style: const TextStyle(
                  color: Color(0xFF675946),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AdministrationCard extends StatelessWidget {
  const _AdministrationCard({required this.record});

  final AdministrationRecord record;

  @override
  Widget build(BuildContext context) {
    final completed = record.livingCity.projects
        .where(
          (project) => project.state == AdministrationProjectState.completed,
        )
        .length;
    final importantEvents = record.livingCity.eventHistory
        .where((event) => event.isMajor)
        .length;
    return Semantics(
      button: true,
      label: context.l10n.openAdministrationReceipt(record.termNumber),
      child: InkWell(
        key: Key('administration_card_${record.termNumber}'),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/history/${record.termNumber}'),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF284A61), Color(0xFF132638)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF07111D), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                offset: Offset(0, 6),
                blurRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final portrait = SizedBox(
                width: compact ? 105 : 150,
                height: compact ? 292 : 190,
                child: CandidateImageSlot(
                  candidateId: record.electedCandidateId,
                  assetKey: record.electedPortraitAssetKey,
                  semanticLabel: record.electedCandidateName,
                  color: ResiboColors.teal,
                  aspectRatio: compact ? 105 / 292 : 150 / 190,
                  borderRadius: 0,
                ),
              );
              final details = Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n
                            .administrationNumber(record.termNumber)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFFD36B),
                          fontFamily: 'LilitaOne',
                          fontSize: 13,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.electedCandidateName.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFF0CB),
                          fontFamily: 'LuckiestGuy',
                          fontSize: 23,
                          height: 1,
                          shadows: [
                            Shadow(color: Colors.black87, offset: Offset(1, 2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record.electedParty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFC4D1D8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _DarkStatChip(
                            icon: Icons.monitor_heart_rounded,
                            label: context.conditionLabel(
                              record.livingCity.finalCondition,
                            ),
                          ),
                          _DarkStatChip(
                            icon: Icons.engineering_rounded,
                            label: context.l10n.projectsCompleted(completed),
                          ),
                          _DarkStatChip(
                            icon: Icons.bolt_rounded,
                            label: context.l10n.majorEvents(importantEvents),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.openHistoricalReceipt,
                              style: const TextStyle(
                                color: Color(0xFFFFE3A4),
                                fontFamily: 'LilitaOne',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFFFE3A4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              return SizedBox(
                height: compact ? 292 : 190,
                child: Row(children: [portrait, details]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: 5,
      height: 24,
      margin: const EdgeInsets.only(left: 38),
      color: const Color(0xFFFFD36B),
    ),
  );
}

class _AdministrationReceipt extends StatelessWidget {
  const _AdministrationReceipt({required this.record});

  final AdministrationRecord record;

  @override
  Widget build(BuildContext context) {
    final changes = record.livingCity.finalIndicators.values.entries
        .map(
          (entry) => MapEntry(
            entry.key,
            entry.value -
                record.livingCity.initialIndicators.valueOf(entry.key),
          ),
        )
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReceiptHero(record: record),
        const SizedBox(height: 18),
        CitySectionTitle(
          title: context.l10n.cityOutcome,
          icon: Icons.query_stats_rounded,
        ),
        const SizedBox(height: 10),
        CityPaperPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.livingCity.summary,
                style: const TextStyle(
                  color: cityBriefInk,
                  height: 1.45,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _IndicatorChangeGrid(record: record, changes: changes),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CitySectionTitle(
          title: context.l10n.promiseProjectRecord,
          icon: Icons.engineering_rounded,
        ),
        const SizedBox(height: 10),
        for (final project in record.livingCity.projects)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HistoricalProjectCard(project: project),
          ),
        const SizedBox(height: 14),
        CitySectionTitle(
          title: context.l10n.majorEventsRecorded,
          icon: Icons.newspaper_rounded,
        ),
        const SizedBox(height: 10),
        CityPaperPanel(
          child: Column(
            children: [
              for (final event in record.livingCity.eventHistory.where(
                (item) => item.isMajor,
              ))
                _HistoricalEventRow(event: event),
              if (!record.livingCity.eventHistory.any((item) => item.isMajor))
                Text(
                  context.l10n.noMajorEventsRecorded,
                  style: const TextStyle(
                    color: Color(0xFF675946),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CitySectionTitle(
          title: context.l10n.electionReceipt,
          icon: Icons.receipt_long_rounded,
        ),
        const SizedBox(height: 10),
        _InvestigationReceipt(record: record),
        if (record.investigation.predictionIds.isNotEmpty) ...[
          const SizedBox(height: 24),
          CitySectionTitle(
            title: context.l10n.predictionReflection,
            icon: Icons.compare_arrows_rounded,
          ),
          const SizedBox(height: 5),
          Text(
            context.l10n.predictionReflectionBody,
            style: const TextStyle(
              color: Color(0xFFB9C7CF),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          for (final id in record.investigation.predictionIds)
            if (civicPredictionById(id) case final prediction?)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _HistoricalPredictionCard(
                  prediction: prediction,
                  assessment: prediction.assess(
                    before: record.livingCity.initialIndicators,
                    after: record.livingCity.finalIndicators,
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _HistoricalPredictionCard extends StatelessWidget {
  const _HistoricalPredictionCard({
    required this.prediction,
    required this.assessment,
  });

  final CivicPrediction prediction;
  final CivicPredictionAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final color = switch (assessment.outcome) {
      CivicPredictionOutcome.observed => ResiboColors.teal,
      CivicPredictionOutcome.mixed => const Color(0xFFC27B27),
      CivicPredictionOutcome.notObserved => ResiboColors.mutedRed,
    };
    final outcome = switch (assessment.outcome) {
      CivicPredictionOutcome.observed => context.l10n.predictionObserved,
      CivicPredictionOutcome.mixed => context.l10n.predictionMixed,
      CivicPredictionOutcome.notObserved => context.l10n.predictionNotObserved,
    };
    return CityPaperPanel(
      padding: const EdgeInsets.all(11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: cityBriefInk, width: 1.5),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Color(0xFFFFF0CB),
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _historyPredictionTitle(context, prediction.id),
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontFamily: 'LilitaOne',
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  outcome,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 7,
                  runSpacing: 4,
                  children: [
                    for (final entry in assessment.healthyChanges.entries)
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
}

String _historyPredictionTitle(BuildContext context, String id) => switch (id) {
  'health_access' => context.l10n.predictionHealth,
  'infrastructure_resilience' => context.l10n.predictionInfrastructure,
  'livelihoods' => context.l10n.predictionLivelihoods,
  'budget_protection' => context.l10n.predictionBudget,
  'public_trust' => context.l10n.predictionTrust,
  'corruption_pressure' => context.l10n.predictionCorruption,
  _ => id,
};

class _ReceiptHero extends StatelessWidget {
  const _ReceiptHero({required this.record});

  final AdministrationRecord record;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7B2D38), Color(0xFF172B3E)],
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
        return SizedBox(
          height: compact ? 245 : 225,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: compact ? 125 : 180,
                height: compact ? 245 : 225,
                child: CandidateImageSlot(
                  candidateId: record.electedCandidateId,
                  assetKey: record.electedPortraitAssetKey,
                  semanticLabel: record.electedCandidateName,
                  color: ResiboColors.mutedRed,
                  aspectRatio: compact ? 125 / 245 : 180 / 225,
                  borderRadius: 0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 12 : 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.historicalReceipt.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFFD36B),
                          fontFamily: 'LilitaOne',
                          fontSize: 13,
                          letterSpacing: .7,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        record.electedCandidateName.toUpperCase(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFFFF0CB),
                          fontFamily: 'LuckiestGuy',
                          fontSize: compact ? 21 : 27,
                          height: 1,
                          shadows: const [
                            Shadow(color: Colors.black87, offset: Offset(1, 2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.administrationOutcome(
                          record.termNumber,
                          context.conditionLabel(
                            record.livingCity.finalCondition,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _IndicatorChangeGrid extends StatelessWidget {
  const _IndicatorChangeGrid({required this.record, required this.changes});

  final AdministrationRecord record;
  final List<MapEntry<CityIndicator, int>> changes;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700
          ? 3
          : constraints.maxWidth >= 420
          ? 2
          : 1;
      const gap = 8.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final entry in changes)
            SizedBox(
              width: width,
              child: _IndicatorReceiptTile(
                indicator: entry.key,
                value: record.livingCity.finalIndicators.valueOf(entry.key),
                change: entry.value,
              ),
            ),
        ],
      );
    },
  );
}

class _IndicatorReceiptTile extends StatelessWidget {
  const _IndicatorReceiptTile({
    required this.indicator,
    required this.value,
    required this.change,
  });

  final CityIndicator indicator;
  final int value;
  final int change;

  @override
  Widget build(BuildContext context) {
    final healthyChange = indicator == CityIndicator.corruptionPressure
        ? -change
        : change;
    final color = healthyChange > 0
        ? ResiboColors.teal
        : healthyChange < 0
        ? ResiboColors.mutedRed
        : const Color(0xFF776E60);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9DAB9),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cityBriefInk, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.indicatorLabel(indicator),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: cityBriefInk,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$value ',
            style: const TextStyle(
              color: cityBriefInk,
              fontFamily: 'LuckiestGuy',
              fontSize: 17,
            ),
          ),
          Text(
            '(${change >= 0 ? '+' : ''}$change)',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoricalProjectCard extends StatelessWidget {
  const _HistoricalProjectCard({required this.project});

  final AdministrationProject project;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project.title.toUpperCase(),
                style: const TextStyle(
                  color: cityBriefInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 15,
                ),
              ),
            ),
            _PaperStatusChip(label: project.state.name),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: project.progress / 100,
            minHeight: 9,
            backgroundColor: const Color(0xFFD1C3A5),
            valueColor: AlwaysStoppedAnimation(
              project.state == AdministrationProjectState.completed
                  ? ResiboColors.teal
                  : const Color(0xFFC9872B),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.projectProgressReceipt(
            project.progress,
            project.milestones.length,
          ),
          style: const TextStyle(
            color: Color(0xFF675946),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _HistoricalEventRow extends StatelessWidget {
  const _HistoricalEventRow({required this.event});

  final CityEvent event;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: ResiboColors.mutedRed,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: cityBriefInk, width: 1.5),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Color(0xFFFFF0CB),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${event.fictionalDate} · ${event.factualSummary}',
                style: const TextStyle(
                  color: Color(0xFF675946),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InvestigationReceipt extends StatelessWidget {
  const _InvestigationReceipt({required this.record});

  final AdministrationRecord record;

  @override
  Widget build(BuildContext context) {
    final investigation = record.investigation;
    final roster =
        record.election?.candidates
            .map((candidate) => candidate.name)
            .join(' · ') ??
        context.l10n.notRecorded;
    return CityPaperPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReceiptFact(
            icon: Icons.groups_rounded,
            label: context.l10n.candidatesOnBallot,
            value: roster,
          ),
          _ReceiptFact(
            icon: Icons.visibility_rounded,
            label: context.l10n.evidenceReviewed,
            value: '${investigation.viewedEvidenceIds.length}',
          ),
          _ReceiptFact(
            icon: Icons.bookmark_rounded,
            label: context.l10n.receiptsSaved,
            value: '${investigation.bookmarkedEvidenceIds.length}',
          ),
          _ReceiptFact(
            icon: Icons.fact_check_rounded,
            label: context.l10n.topIssueRecorded,
            value: record.topIssue ?? context.l10n.notRecorded,
          ),
          _ReceiptFact(
            icon: Icons.psychology_alt_rounded,
            label: context.l10n.voterConfidence,
            value: '${(record.confidence * 100).round()}%',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ReceiptFact extends StatelessWidget {
  const _ReceiptFact({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : const Border(
              bottom: BorderSide(color: Color(0xFFD1C3A5), width: 1.5),
            ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ResiboColors.teal, size: 20),
        const SizedBox(width: 9),
        SizedBox(
          width: 118,
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF675946),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: cityBriefInk,
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DarkStatChip extends StatelessWidget {
  const _DarkStatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xC907111D),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF5F7482)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFFD36B), size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _PaperStatusChip extends StatelessWidget {
  const _PaperStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFD7C69F),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: cityBriefInk),
    ),
    child: Text(
      label
          .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
          )
          .toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: cityBriefInk,
        fontSize: 8,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
