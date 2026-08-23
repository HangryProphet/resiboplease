import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_indicator_set.dart';
import '../../domain/models/term_result.dart';
import '../../domain/models/living_city_simulation.dart';
import '../../l10n/game_content_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';
import '../candidate_hub/widgets/candidate_image_slot.dart';

class TermSimulationScreen extends StatefulWidget {
  const TermSimulationScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<TermSimulationScreen> createState() => _TermSimulationScreenState();
}

class _TermSimulationScreenState extends State<TermSimulationScreen> {
  @override
  Widget build(BuildContext context) {
    final result = widget.controller.termResult;
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
    var current = result.before;
    final revealed = widget.controller.revealedTermPhases.clamp(
      0,
      result.phases.length,
    );
    for (final phase in result.phases.take(revealed)) {
      current = current.apply(phase.changes);
    }
    final finished = revealed == result.phases.length;
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
              InvestigationHeader(
                title: context.l10n.termInProgress,
                subtitle: widget.controller.activeCityName,
                onBack: () => context.go('/'),
                trailing: finished
                    ? GameIconButton(
                        tooltip: context.l10n.viewTermReport,
                        icon: Icons.receipt_long_rounded,
                        onPressed: () => context.go('/report'),
                        color: ResiboColors.mutedRed,
                      )
                    : null,
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('term_timeline_scroll'),
                  padding: const EdgeInsets.fromLTRB(13, 16, 13, 38),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TermCityHero(
                            cityName: widget.controller.activeCityName,
                            indicators: current,
                            events: result.livingCity.phases
                                .take(revealed)
                                .expand((phase) => phase.events)
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 12),
                          _AdministrationStrip(
                            result: result,
                            currentPhase: revealed,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ChunkyActionButton(
                                  label: 'City Chronicle',
                                  icon: Icons.newspaper_rounded,
                                  compact: true,
                                  color: const Color(0xFF3277A0),
                                  onPressed: () => context.go('/city/chronicle'),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: ChunkyActionButton(
                                  label: 'CityBook',
                                  icon: Icons.forum_rounded,
                                  compact: true,
                                  color: ResiboColors.teal,
                                  onPressed: () => context.go(
                                    '/citybook/${result.candidate.id}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          CitySectionTitle(
                            title: context.l10n.termTimeline,
                            icon: Icons.timeline_rounded,
                            trailing: _PhaseCounter(
                              current: revealed,
                              total: result.phases.length,
                            ),
                          ),
                          const SizedBox(height: 11),
                          if (revealed == 0)
                            _TermOpeningCard(result: result)
                          else
                            for (final phase in result.phases.take(
                              revealed,
                            )) ...[
                              _TermPhaseCard(
                                key: Key('term_phase_${phase.number}'),
                                phase: phase,
                                livingPhase:
                                    result.livingCity.phases[phase.number - 1],
                                candidate: result.candidate,
                                latest: phase.number == revealed,
                              ),
                              const SizedBox(height: 14),
                            ],
                          const SizedBox(height: 8),
                          Align(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: SizedBox(
                                width: double.infinity,
                                child: ChunkyActionButton(
                                  buttonKey: const Key('advance_term'),
                                  label: finished
                                      ? context.l10n.viewTermReport
                                      : context.l10n.advanceTerm,
                                  icon: finished
                                      ? Icons.receipt_long_rounded
                                      : Icons.fast_forward_rounded,
                                  color: finished
                                      ? ResiboColors.mutedRed
                                      : ResiboColors.teal,
                                  onPressed: () {
                                    if (finished) {
                                      context.go('/report');
                                    } else {
                                      setState(widget.controller.advanceTerm);
                                    }
                                  },
                                ),
                              ),
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
      ),
    );
  }
}

class _TermCityHero extends StatelessWidget {
  const _TermCityHero({
    required this.cityName,
    required this.indicators,
    required this.events,
  });

  final String cityName;
  final CityIndicatorSet indicators;
  final List<CityEvent> events;

  @override
  Widget build(BuildContext context) {
    final visible = <CityIndicator>[
      CityIndicator.waterSecurity,
      CityIndicator.publicHealth,
      CityIndicator.employmentQuality,
      CityIndicator.publicTrust,
    ];
    return AspectRatio(
      aspectRatio: 16 / 8.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/city/bayhaven_base.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [.35, 1],
                  colors: [Colors.transparent, Color(0xE607111D)],
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 11,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEAF4E7C7),
                  borderRadius: BorderRadius.circular(5),
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
            for (final event in events.reversed.take(7))
              Align(
                alignment: Alignment(
                  event.markerX * 2 - 1,
                  event.markerY * 2 - 1,
                ),
                child: Semantics(
                  button: true,
                  label: 'Inspect ${event.title}',
                  child: Tooltip(
                    message: event.title,
                    child: InkWell(
                      key: Key('city_event_marker_${event.id}'),
                      onTap: () => _showCityEvent(context, event),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event.isMajor
                              ? ResiboColors.mutedRed
                              : const Color(0xFF247E78),
                          border: Border.all(color: cityBriefInk, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black87,
                              offset: Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          _markerIcon(event.markerType),
                          size: 17,
                          color: const Color(0xFFFFEBC1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: IgnorePointer(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final indicator in visible)
                      _ConditionPill(
                        label: context.l10n.indicatorLabel(indicator),
                        value: indicators.valueOf(indicator),
                      ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF07111D),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _markerIcon(CityMapMarkerType type) => switch (type) {
    CityMapMarkerType.flood || CityMapMarkerType.weather => Icons.water,
    CityMapMarkerType.clinic => Icons.local_hospital_rounded,
    CityMapMarkerType.water => Icons.water_drop_rounded,
    CityMapMarkerType.roadworks ||
    CityMapMarkerType.transport => Icons.construction_rounded,
    CityMapMarkerType.jobs => Icons.work_rounded,
    CityMapMarkerType.market => Icons.storefront_rounded,
    CityMapMarkerType.publicSafety => Icons.shield_rounded,
    CityMapMarkerType.waste => Icons.delete_rounded,
    CityMapMarkerType.school => Icons.school_rounded,
    CityMapMarkerType.government ||
    CityMapMarkerType.audit => Icons.account_balance_rounded,
    CityMapMarkerType.protest => Icons.campaign_rounded,
    CityMapMarkerType.opportunity => Icons.auto_awesome_rounded,
    CityMapMarkerType.festival => Icons.celebration_rounded,
    CityMapMarkerType.community => Icons.groups_rounded,
    CityMapMarkerType.power => Icons.bolt_rounded,
    CityMapMarkerType.news => Icons.newspaper_rounded,
  };

  static void _showCityEvent(BuildContext context, CityEvent event) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CityPaperPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.fictionalDate} · ${event.district.name.toUpperCase()}',
                  style: const TextStyle(
                    color: ResiboColors.mutedRed,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  event.title.toUpperCase(),
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontFamily: 'LilitaOne',
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(event.factualSummary),
                const SizedBox(height: 10),
                Text(
                  event.explanation,
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final effect in event.indicatorEffects.entries)
                      _ImpactChip(indicator: effect.key, change: effect.value),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionPill extends StatelessWidget {
  const _ConditionPill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value <= 39
        ? ResiboColors.mutedRed
        : value <= 59
        ? const Color(0xFFB57A24)
        : ResiboColors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xEAF8EAC8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '$label · ${context.l10n.indicatorStateLabel(value)}',
        style: TextStyle(
          color: cityBriefInk,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AdministrationStrip extends StatelessWidget {
  const _AdministrationStrip({
    required this.result,
    required this.currentPhase,
  });

  final TermResult result;
  final int currentPhase;

  @override
  Widget build(BuildContext context) {
    final color = Color(result.candidate.colorValue);
    return CityPaperPanel(
      padding: const EdgeInsets.fromLTRB(10, 8, 13, 8),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cityBriefInk, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: CandidateImageSlot(
              candidateId: result.candidate.id,
              assetKey: 'candidate_${result.candidate.id}_neutral',
              semanticLabel: result.candidate.name,
              color: color,
              aspectRatio: 66 / 72,
              fit: BoxFit.cover,
              borderRadius: 0,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n
                      .administrationOf(result.candidate.name)
                      .toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontFamily: 'LilitaOne',
                    fontSize: 18,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.phaseProgress(
                    currentPhase,
                    result.phases.length,
                  ),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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

class _PhaseCounter extends StatelessWidget {
  const _PhaseCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF263C50),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFFD785)),
    ),
    child: Text(
      '$current / $total',
      style: const TextStyle(
        color: Color(0xFFFFEBC1),
        fontWeight: FontWeight.w900,
        fontSize: 11,
      ),
    ),
  );
}

class _TermOpeningCard extends StatelessWidget {
  const _TermOpeningCard({required this.result});

  final TermResult result;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    child: Column(
      children: [
        const Icon(
          Icons.hourglass_top_rounded,
          color: ResiboColors.mutedRed,
          size: 39,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.termSimulationHeading.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: cityBriefInk,
            fontFamily: 'LilitaOne',
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          context.l10n.termSimulationIntro,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: cityBriefInk,
            height: 1.4,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

class _TermPhaseCard extends StatelessWidget {
  const _TermPhaseCard({
    required this.phase,
    required this.livingPhase,
    required this.candidate,
    required this.latest,
    super.key,
  });

  final TermPhase phase;
  final LivingCityPhase livingPhase;
  final Candidate candidate;
  final bool latest;

  @override
  Widget build(BuildContext context) {
    final major = phase.eventKind.hasArtwork;
    final accent = major ? ResiboColors.mutedRed : ResiboColors.teal;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        boxShadow: latest
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: .3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: CityPaperPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(13, 9, 13, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.lerp(accent, Colors.white, .18)!, accent],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                border: const Border(
                  bottom: BorderSide(color: cityBriefInk, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    major ? Icons.warning_rounded : Icons.article_rounded,
                    color: const Color(0xFFFFF0CB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${context.l10n.phaseNumber(phase.number)} · ${major ? context.l10n.majorEvent : context.l10n.cityUpdate}'
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFF0CB),
                        fontFamily: 'LilitaOne',
                        fontSize: 15,
                        shadows: [
                          Shadow(color: Colors.black87, offset: Offset(1, 2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (phase.eventKind.assetPath case final assetPath?)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  assetPath,
                  key: Key('term_event_art_${phase.eventKind.name}'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.phaseTitleText(phase).toUpperCase(),
                    style: const TextStyle(
                      color: cityBriefInk,
                      fontFamily: 'LilitaOne',
                      fontSize: 21,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'CITY EVENTS'.toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'LilitaOne',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 7),
                  for (final event in livingPhase.events)
                    _LivingEventRow(event: event),
                  if (livingPhase.projectMilestones.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'PROJECT LEDGER',
                      style: TextStyle(
                        color: accent,
                        fontFamily: 'LilitaOne',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    for (final milestone in livingPhase.projectMilestones)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.engineering_rounded,
                              size: 17,
                              color: ResiboColors.navy,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                '${milestone.summary} +${milestone.progressDelta}%',
                                style: const TextStyle(
                                  color: cityBriefInk,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.phaseNarrativeText(phase, candidate),
                    style: const TextStyle(
                      color: cityBriefInk,
                      fontSize: 13,
                      height: 1.42,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.eventImpact.toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'LilitaOne',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final entry in phase.changes.entries)
                        _ImpactChip(indicator: entry.key, change: entry.value),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5D8BC),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0x665A4C38)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          color: ResiboColors.navy,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${context.l10n.whyThisHappened}: ${context.l10n.phaseExplanationText(phase)}',
                            style: const TextStyle(
                              color: cityBriefInk,
                              fontSize: 11,
                              height: 1.35,
                              fontStyle: FontStyle.italic,
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
    );
  }
}

class _LivingEventRow extends StatelessWidget {
  const _LivingEventRow({required this.event});

  final CityEvent event;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: event.isMajor ? const Color(0x1FA43D49) : const Color(0x14247E78),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color(0x665A4C38)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          event.isMajor ? Icons.warning_rounded : Icons.place_rounded,
          size: 18,
          color: event.isMajor ? ResiboColors.mutedRed : ResiboColors.teal,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                event.factualSummary,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 10.5,
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

class _ImpactChip extends StatelessWidget {
  const _ImpactChip({required this.indicator, required this.change});

  final CityIndicator indicator;
  final int change;

  @override
  Widget build(BuildContext context) {
    final healthy = indicator == CityIndicator.corruptionPressure
        ? change < 0
        : change > 0;
    final color = change == 0
        ? const Color(0xFF6D7477)
        : healthy
        ? ResiboColors.teal
        : ResiboColors.mutedRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        context.l10n.changeValue(
          context.l10n.indicatorLabel(indicator),
          '${change >= 0 ? '+' : ''}$change',
        ),
        style: TextStyle(
          color: cityBriefInk,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
