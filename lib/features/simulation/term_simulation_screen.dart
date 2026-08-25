import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/audio/game_audio_service.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_indicator_set.dart';
import '../../domain/models/living_city_simulation.dart';
import '../../domain/models/term_result.dart';
import '../../domain/simulation/simulation_clock.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/living_city_localizations.dart';
import '../candidate_hub/widgets/candidate_image_slot.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';

class TermSimulationScreen extends StatefulWidget {
  const TermSimulationScreen({
    required this.controller,
    this.settingsController,
    super.key,
  });

  final GameController controller;
  final AppSettingsController? settingsController;

  @override
  State<TermSimulationScreen> createState() => _TermSimulationScreenState();
}

class _TermSimulationScreenState extends State<TermSimulationScreen> {
  late final AppSettingsController _settings;
  late final bool _ownsSettings;
  late final SimulationClock _clock;
  bool _showingInterrupt = false;
  CityEvent? _criticalNotice;

  @override
  void initState() {
    super.initState();
    _ownsSettings = widget.settingsController == null;
    _settings =
        widget.settingsController ??
        AppSettingsController(store: MemorySettingsStore());
    _clock = SimulationClock(onPulse: _processPulse);
  }

  void _processPulse(int requestedDays) {
    if (!mounted) return;
    final result = widget.controller.advanceSimulationDays(
      requestedDays,
      interruptionPreference: _settings.criticalEventInterruption,
    );
    _handleAdvanceResult(result);
  }

  void _fastForwardYear() {
    final result = widget.controller.fastForwardToYearEnd(
      interruptionPreference: _settings.criticalEventInterruption,
    );
    _handleAdvanceResult(result);
  }

  void _handleAdvanceResult(SimulationAdvanceResult? result) {
    if (!mounted || result == null) return;
    final event = result.criticalEvent;
    if (event != null && (result.shouldNotify || result.shouldOpenEvent)) {
      GameAudioScope.maybeOf(context)?.play(GameSound.criticalAlert);
    } else {
      final latest = widget.controller.termResult?.livingCity.eventHistory
          .where(
            (candidate) =>
                candidate.day > result.fromDay && candidate.day <= result.toDay,
          )
          .lastOrNull;
      if (latest != null) {
        GameAudioScope.maybeOf(context)?.play(_eventSound(latest));
      }
    }
    if (event != null && result.shouldNotify) {
      setState(() => _criticalNotice = event);
    }
    if (event != null && result.shouldOpenEvent && !_showingInterrupt) {
      _showingInterrupt = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _showEvent(event);
        _showingInterrupt = false;
      });
    }
  }

  GameSound _eventSound(CityEvent event) => switch (event.category) {
    CityEventCategory.positiveOpportunity => GameSound.positiveEvent,
    CityEventCategory.externalShock ||
    CityEventCategory.rare => GameSound.negativeEvent,
    _ => GameSound.notification,
  };

  @override
  void dispose() {
    _clock.dispose();
    if (_ownsSettings) _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([widget.controller, _settings]),
    builder: (context, _) {
      final result = widget.controller.termResult;
      if (result == null) return _missingElection(context);
      final day = widget.controller.simulationDay;
      final paused = widget.controller.simulationPaused;
      _clock.sync(speed: widget.controller.simulationSpeed, paused: paused);
      final indicators = result.livingCity.indicatorsThroughDay(day);
      final visibleEvents = result.livingCity.eventsThroughDay(day);
      final activeWorldConditions = result.livingCity.worldConditionsOnDay(day);
      final acknowledgedEventIds = widget.controller.inspectedCityEventIds;
      final markers = result.livingCity
          .activeMarkersOnDay(day)
          .where((event) => !acknowledgedEventIds.contains(event.id))
          .toList(growable: false);
      final latestEvent = visibleEvents.lastOrNull;
      final condition = overallCityCondition(indicators);
      return Scaffold(
        backgroundColor: const Color(0xFF08121D),
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF19334A), Color(0xFF07111C)],
              ),
            ),
            child: Column(
              children: [
                InvestigationHeader(
                  title: context.citySimulation.toUpperCase(),
                  subtitle: widget.controller.activeCityName,
                  onBack: () {
                    widget.controller.pauseSimulation();
                    context.go('/');
                  },
                  trailing: GameIconButton(
                    tooltip: context.eventHistory,
                    icon: Icons.history_rounded,
                    onPressed: () => _showHistory(result),
                    color: widget.controller.unreadCityEventCount > 0
                        ? ResiboColors.mutedRed
                        : ResiboColors.teal,
                  ),
                ),
                _CalendarStrip(
                  day: day,
                  term: result.livingCity.termNumber,
                  condition: condition,
                  paused: paused,
                ),
                _WorldConditionStrip(
                  conditions: activeWorldConditions,
                  day: day,
                ),
                if (_criticalNotice case final notice?)
                  _CriticalEventNotice(
                    event: notice,
                    onOpen: () => _showEvent(notice),
                    onDismiss: () => setState(() => _criticalNotice = null),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                    child: _InteractiveCityMap(
                      controller: widget.controller,
                      indicators: indicators,
                      markers: markers,
                      reducedMotion:
                          _settings.reduceMotion ||
                          MediaQuery.disableAnimationsOf(context),
                      onEvent: _showEvent,
                      onLandmark: (anchor) => anchor.id == 'city_hall'
                          ? _showMayorOffice(result, indicators)
                          : _showLandmark(result, anchor),
                    ),
                  ),
                ),
                _LatestDevelopmentBar(
                  event: latestEvent,
                  unreadCount: widget.controller.unreadCityEventCount,
                  onEvent: latestEvent == null
                      ? null
                      : () => _showEvent(latestEvent),
                  onHistory: () => _showHistory(result),
                ),
                _SimulationDock(
                  day: day,
                  paused: paused,
                  speed: widget.controller.simulationSpeed,
                  onPause: widget.controller.pauseSimulation,
                  onSpeed: (speed) => speed == SimulationSpeed.year
                      ? _fastForwardYear()
                      : widget.controller.setSimulationSpeed(speed),
                  onReport: day >= 365 ? () => context.go('/report') : null,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _missingElection(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0B1725),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 270),
        child: ChunkyActionButton(
          label: context.l10n.returnToBallot,
          icon: Icons.how_to_vote_rounded,
          onPressed: () => context.go('/vote'),
        ),
      ),
    ),
  );

  Future<void> _showEvent(CityEvent event) async {
    if (_criticalNotice?.id == event.id && mounted) {
      setState(() => _criticalNotice = null);
    }
    widget.controller.markCityEventInspected(event.id);
    final result = widget.controller.termResult;
    if (result == null || !mounted) return;
    final anchor = cityMapAnchorById(event.locationId);
    final broadcast = widget.controller.informationEcosystem.tvBroadcasts
        .forEvent(event.id);
    final project = event.relatedProjectIds.isEmpty
        ? null
        : result.livingCity.projects
              .where((item) => event.relatedProjectIds.contains(item.id))
              .firstOrNull;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: CityPaperPanel(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ImportanceBadge(importance: event.importance),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${anchor.label.toUpperCase()} · ${event.fictionalDate}',
                            style: const TextStyle(
                              color: ResiboColors.mutedRed,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    if (event.visualAssetKey case final asset?) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AspectRatio(
                          aspectRatio: 16 / 7.5,
                          child: Image.asset(
                            asset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      event.title.toUpperCase(),
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontFamily: 'LilitaOne',
                        fontSize: 24,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.factualSummary,
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      event.explanation,
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                    if (event.parentEventId != null) ...[
                      const SizedBox(height: 9),
                      const _ChainNotice(),
                    ],
                    if (event.indicatorEffects.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final effect in event.indicatorEffects.entries)
                            _ImpactChip(
                              indicator: effect.key,
                              change: effect.value,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _EventAction(
                          icon: Icons.newspaper_rounded,
                          label: context.openChronicle,
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            widget.controller.pauseSimulation();
                            context.push('/city/chronicle');
                          },
                        ),
                        if (event.newsEligible)
                          _EventAction(
                            icon: Icons.article_rounded,
                            label: context.readNews,
                            color: const Color(0xFF3277A0),
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              widget.controller.pauseSimulation();
                              context.push('/news/event/${event.id}');
                            },
                          ),
                        if (broadcast != null)
                          _EventAction(
                            icon: Icons.live_tv_rounded,
                            label: context.watchReport,
                            color: ResiboColors.mutedRed,
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              widget.controller.pauseSimulation();
                              context.push('/tv/${broadcast.id}');
                            },
                          ),
                        if (project != null)
                          _EventAction(
                            icon: Icons.construction_rounded,
                            label: context.viewProject,
                            color: ResiboColors.teal,
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _showMayorOffice(
                                result,
                                result.livingCity.indicatorsThroughDay(
                                  widget.controller.simulationDay,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showHistory(TermResult result) async {
    var filter = _HistoryFilter.all;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final allEvents = result.livingCity
              .eventsThroughDay(widget.controller.simulationDay)
              .reversed
              .toList(growable: false);
          final events = allEvents
              .where((event) => filter.includes(event))
              .toList(growable: false);
          return SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                height: MediaQuery.sizeOf(context).height * .82,
                margin: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF101F2D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF07111D), width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black87, offset: Offset(4, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            color: Color(0xFFFFD765),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              context.eventHistory.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFFFEBC1),
                                fontFamily: 'LilitaOne',
                                fontSize: 23,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            color: const Color(0xFFFFEBC1),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          for (final option in _HistoryFilter.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: _FilterButton(
                                label: option.label(context),
                                selected: option == filter,
                                onPressed: () =>
                                    setSheetState(() => filter = option),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: events.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  context.noEventsYet,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFB9C7CF),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 22),
                              itemCount: events.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final event = events[index];
                                final unread = !widget
                                    .controller
                                    .inspectedCityEventIds
                                    .contains(event.id);
                                return _HistoryEventTile(
                                  event: event,
                                  unread: unread,
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                    _showEvent(event);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLandmark(TermResult result, CityMapAnchor anchor) async {
    final events = result.livingCity
        .eventsThroughDay(widget.controller.simulationDay)
        .where((event) => event.locationId == anchor.id)
        .toList(growable: false)
        .reversed
        .take(3)
        .toList(growable: false);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: CityPaperPanel(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: ResiboColors.teal,
                            border: Border.all(color: cityBriefInk, width: 2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            _landmarkIcon(anchor.type),
                            color: const Color(0xFFFFEBC1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.cityLandmark.toUpperCase(),
                                style: const TextStyle(
                                  color: ResiboColors.mutedRed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .6,
                                ),
                              ),
                              Text(
                                context.mapLocationLabel(anchor).toUpperCase(),
                                style: const TextStyle(
                                  color: cityBriefInk,
                                  fontFamily: 'LilitaOne',
                                  fontSize: 23,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Text(
                      context.landmarkDescription(anchor),
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.recentDevelopments.toUpperCase(),
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontFamily: 'LilitaOne',
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 7),
                    if (events.isEmpty)
                      Text(
                        context.noDevelopmentsAtLocation,
                        style: const TextStyle(
                          color: Color(0xFF4B5359),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      for (final event in events) ...[
                        _HistoryEventTile(
                          event: event,
                          unread: !widget.controller.inspectedCityEventIds
                              .contains(event.id),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showEvent(event);
                          },
                        ),
                        const SizedBox(height: 7),
                      ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMayorOffice(
    TermResult result,
    CityIndicatorSet indicators,
  ) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final candidate = result.candidate;
      final day = widget.controller.simulationDay;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: CityPaperPanel(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_rounded,
                          color: ResiboColors.mutedRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.mayorOffice.toUpperCase(),
                            style: const TextStyle(
                              color: cityBriefInk,
                              fontFamily: 'LilitaOne',
                              fontSize: 24,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MayorSummary(
                      candidate: candidate,
                      portraitAssetKey:
                          widget.controller.candidateExperience
                              .profileFor(candidate.id)
                              ?.portraitAssetKey ??
                          'candidate_${candidate.id}_neutral',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _OfficeMetric(
                          label: context.publicTrust,
                          value: indicators.valueOf(CityIndicator.publicTrust),
                        ),
                        _OfficeMetric(
                          label: context.budgetHealth,
                          value: indicators.valueOf(CityIndicator.budgetHealth),
                        ),
                        _OfficeMetric(
                          label: context.cityCondition,
                          textValue: context.conditionLabel(
                            overallCityCondition(indicators),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.projects.toUpperCase(),
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontFamily: 'LilitaOne',
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final project in result.livingCity.projects) ...[
                      _ProjectCard(project: project, day: day),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({
    required this.day,
    required this.term,
    required this.condition,
    required this.paused,
  });

  final int day;
  final int term;
  final OverallCityCondition condition;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(
      2026,
      1,
      1,
    ).add(Duration(days: (day - 1).clamp(0, 364)));
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    final dateText = day == 0
        ? 'JANUARY 1 — YEAR $term'
        : '${months[date.month - 1]} ${date.day} — YEAR $term';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF102434),
        border: Border(bottom: BorderSide(color: Color(0xFF07111D), width: 3)),
      ),
      child: Row(
        children: [
          Icon(
            paused ? Icons.pause_circle_filled : Icons.play_circle_fill_rounded,
            color: paused ? const Color(0xFFFFD765) : const Color(0xFF83C99A),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFEBC1),
                fontFamily: 'LilitaOne',
                fontSize: 17,
                letterSpacing: .4,
              ),
            ),
          ),
          _ConditionTag(label: context.conditionLabel(condition)),
        ],
      ),
    );
  }
}

class _InteractiveCityMap extends StatefulWidget {
  const _InteractiveCityMap({
    required this.controller,
    required this.indicators,
    required this.markers,
    required this.reducedMotion,
    required this.onEvent,
    required this.onLandmark,
  });

  final GameController controller;
  final CityIndicatorSet indicators;
  final List<CityEvent> markers;
  final bool reducedMotion;
  final ValueChanged<CityEvent> onEvent;
  final ValueChanged<CityMapAnchor> onLandmark;

  @override
  State<_InteractiveCityMap> createState() => _InteractiveCityMapState();
}

class _InteractiveCityMapState extends State<_InteractiveCityMap> {
  static const _minimumScale = 1.0;
  static const _maximumScale = 3.4;
  static const _initialScale = 1.65;

  late final TransformationController _transformationController;
  double _scale = _minimumScale;
  Size _viewportSize = Size.zero;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController()
      ..addListener(_handleTransformChanged);
  }

  void _handleTransformChanged() {
    final nextScale = _transformationController.value.getMaxScaleOnAxis();
    if ((nextScale - _scale).abs() > .001 && mounted) {
      setState(() => _scale = nextScale);
    }
  }

  void _setScale(double requestedScale) {
    if (_viewportSize.isEmpty) return;
    final target = requestedScale.clamp(_minimumScale, _maximumScale);
    final focalPoint = _viewportSize.center(Offset.zero);
    final focalPointScene = _transformationController.toScene(focalPoint);
    final translation = focalPoint - focalPointScene * target;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(translation.dx, translation.dy, 0, 1)
      ..scaleByDouble(target, target, 1, 1);
  }

  void _resetMap() {
    _setScale(_initialScale);
  }

  @override
  void dispose() {
    _transformationController
      ..removeListener(_handleTransformChanged)
      ..dispose();
    super.dispose();
  }

  List<({CityEvent event, double x, double y})> _spreadEventMarkers(
    List<CityEvent> events,
  ) {
    final placements = <({CityEvent event, double x, double y})>[];
    for (final event in events) {
      final anchor = cityMapAnchorById(event.locationId);
      final storedDx = event.markerX - anchor.x;
      final storedDy = event.markerY - anchor.y;
      var angle = storedDx.abs() + storedDy.abs() > .004
          ? math.atan2(storedDy, storedDx)
          : _stableMarkerAngle(event.id);
      var radius = anchor.landmark ? .034 : .014;
      var x = event.markerX;
      var y = event.markerY;
      for (var attempt = 0; attempt < 12; attempt++) {
        x = anchor.x + math.cos(angle) * radius;
        y = anchor.y + math.sin(angle) * radius;
        final overlapsEvent = placements.any(
          (placed) => _distance(x, y, placed.x, placed.y) < .045,
        );
        final overlapsLandmark = BayhavenMapAnchors.persistentLandmarks.any(
          (landmark) => _distance(x, y, landmark.x, landmark.y) < .027,
        );
        if (!overlapsEvent && !overlapsLandmark) break;
        angle += 2.399963229728653;
        if (attempt.isOdd) radius += .009;
      }
      placements.add((
        event: event,
        x: x.clamp(.04, .96),
        y: y.clamp(.06, .94),
      ));
    }
    return placements;
  }

  double _stableMarkerAngle(String id) {
    var hash = 17;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return (hash % 360) * math.pi / 180;
  }

  double _distance(double ax, double ay, double bx, double by) {
    final dx = ax - bx;
    final dy = ay - by;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  Widget build(BuildContext context) {
    final prioritized = [...widget.markers]
      ..sort((left, right) {
        final importance = right.importance.index.compareTo(
          left.importance.index,
        );
        return importance != 0 ? importance : right.day.compareTo(left.day);
      });
    final visibleMarkers = prioritized.take(9).toList(growable: false);
    final markerPlacements = _spreadEventMarkers(visibleMarkers);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF06101B), width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            _viewportSize = constraints.biggest;
            if (!_cameraInitialized && !_viewportSize.isEmpty) {
              _cameraInitialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _setScale(_initialScale);
              });
            }
            final mapSide = constraints.biggest.shortestSide;
            final mapLeft = (constraints.maxWidth - mapSide) / 2;
            final mapTop = (constraints.maxHeight - mapSide) / 2;
            return Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  key: const Key('bayhaven_interactive_map'),
                  transformationController: _transformationController,
                  minScale: _minimumScale,
                  maxScale: _maximumScale,
                  boundaryMargin: EdgeInsets.all(mapSide * .32),
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: mapLeft,
                            top: mapTop,
                            width: mapSide,
                            height: mapSide,
                            child: Image.asset(
                              'assets/images/city/bayhaven_topdown_map_districts.png',
                              key: const Key('bayhaven_districts_topdown_map'),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0, .72, 1],
                                colors: [
                                  Color(0x12071926),
                                  Colors.transparent,
                                  Color(0xA807111D),
                                ],
                              ),
                            ),
                          ),
                          for (final anchor
                              in BayhavenMapAnchors.persistentLandmarks)
                            Positioned(
                              left: mapLeft + anchor.x * mapSide - 38,
                              top: mapTop + anchor.y * mapSide - 13,
                              child: Transform.scale(
                                scale: 1 / _scale,
                                child: _LandmarkMarker(
                                  anchor: anchor,
                                  showLabel:
                                      _scale >= 2.05 ||
                                      anchor.id == 'city_hall',
                                  onPressed: () => widget.onLandmark(anchor),
                                ),
                              ),
                            ),
                          for (final placement in markerPlacements)
                            Positioned(
                              left: mapLeft + placement.x * mapSide - 24,
                              top: mapTop + placement.y * mapSide - 24,
                              child: Transform.scale(
                                scale: 1 / _scale,
                                child: _MapEventMarker(
                                  key: Key(
                                    'city_event_marker_${placement.event.id}',
                                  ),
                                  event: placement.event,
                                  reducedMotion: widget.reducedMotion,
                                  inspected: false,
                                  onPressed: () =>
                                      widget.onEvent(placement.event),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: IgnorePointer(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  _MapMetric(
                                    icon: Icons.favorite_rounded,
                                    value: widget.indicators.valueOf(
                                      CityIndicator.publicHealth,
                                    ),
                                  ),
                                  _MapMetric(
                                    icon: Icons.work_rounded,
                                    value: widget.indicators.valueOf(
                                      CityIndicator.employmentQuality,
                                    ),
                                  ),
                                  _MapMetric(
                                    icon: Icons.water_drop_rounded,
                                    value: widget.indicators.valueOf(
                                      CityIndicator.waterSecurity,
                                    ),
                                  ),
                                  _MapMetric(
                                    icon: Icons.groups_rounded,
                                    value: widget.indicators.valueOf(
                                      CityIndicator.publicTrust,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xDDF8E9C4),
                                border: Border.all(
                                  color: cityBriefInk,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.pinch_rounded, size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.markerHint,
                                    style: const TextStyle(
                                      color: cityBriefInk,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Column(
                    children: [
                      _MapZoomButton(
                        tooltip: context.zoomIn,
                        icon: Icons.add_rounded,
                        onPressed: () => _setScale(_scale * 1.35),
                      ),
                      const SizedBox(height: 6),
                      _MapZoomButton(
                        tooltip: context.zoomOut,
                        icon: Icons.remove_rounded,
                        onPressed: () => _setScale(_scale / 1.35),
                      ),
                      const SizedBox(height: 6),
                      _MapZoomButton(
                        tooltip: context.resetMap,
                        icon: Icons.center_focus_strong_rounded,
                        onPressed: _resetMap,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LandmarkMarker extends StatelessWidget {
  const _LandmarkMarker({
    required this.anchor,
    required this.showLabel,
    required this.onPressed,
  });

  final CityMapAnchor anchor;
  final bool showLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = context.mapLocationLabel(anchor);
    return _LabeledLandmark(
      key: anchor.id == 'city_hall'
          ? const Key('mayor_office_marker')
          : Key('map_landmark_${anchor.id}'),
      label: label,
      shortLabel: context.mapLocationShortLabel(anchor),
      icon: _landmarkIcon(anchor.type),
      color: anchor.id == 'city_hall'
          ? ResiboColors.mutedRed
          : ResiboColors.teal,
      showLabel: showLabel,
      onPressed: onPressed,
    );
  }
}

class _LabeledLandmark extends StatelessWidget {
  const _LabeledLandmark({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.color,
    required this.showLabel,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final Color color;
  final bool showLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            width: 76,
            height: 44,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xEFFFF0C5),
                    border: Border.all(color: cityBriefInk, width: 1.8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black87, offset: Offset(2, 3)),
                    ],
                  ),
                  child: Icon(icon, size: 13, color: color),
                ),
                if (showLabel) ...[
                  const SizedBox(height: 2),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 76),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xEAF8E9C4),
                      border: Border.all(color: cityBriefInk, width: 1.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      shortLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontFamily: 'LilitaOne',
                        fontSize: 7,
                        height: 1.1,
                        letterSpacing: .15,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF244C69), Color(0xFF102B40)],
            ),
            border: Border.all(color: const Color(0xFFFFE4A3), width: 2),
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(color: Colors.black87, offset: Offset(2, 3)),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFFFEBC1), size: 22),
        ),
      ),
    ),
  );
}

class _MapEventMarker extends StatefulWidget {
  const _MapEventMarker({
    required this.event,
    required this.reducedMotion,
    required this.inspected,
    required this.onPressed,
    super.key,
  });

  final CityEvent event;
  final bool reducedMotion;
  final bool inspected;
  final VoidCallback onPressed;

  @override
  State<_MapEventMarker> createState() => _MapEventMarkerState();
}

class _MapEventMarkerState extends State<_MapEventMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
      lowerBound: 0,
      upperBound: 1,
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _MapEventMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion ||
        oldWidget.inspected != widget.inspected) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.reducedMotion || widget.inspected) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.event.importance) {
      CityEventImportance.ambient => const Color(0xFF247E78),
      CityEventImportance.minor => const Color(0xFF3277A0),
      CityEventImportance.important => const Color(0xFFC64A50),
      CityEventImportance.critical => const Color(0xFFE14747),
      CityEventImportance.rare => const Color(0xFFE4A82D),
    };
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Transform.scale(scale: 1 + _controller.value * .12, child: child),
      child: Semantics(
        button: true,
        label: 'Inspect ${widget.event.title}',
        child: Tooltip(
          message: widget.event.title,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.inspected
                          ? color.withValues(alpha: .78)
                          : color,
                      border: Border.all(
                        color: const Color(0xFF07111D),
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black87, offset: Offset(2, 3)),
                      ],
                    ),
                    child: Icon(
                      _markerIcon(widget.event.markerType),
                      size: 15,
                      color: const Color(0xFFFFEBC1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestDevelopmentBar extends StatelessWidget {
  const _LatestDevelopmentBar({
    required this.event,
    required this.unreadCount,
    required this.onEvent,
    required this.onHistory,
  });

  final CityEvent? event;
  final int unreadCount;
  final VoidCallback? onEvent;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(10, 7, 10, 7),
    decoration: BoxDecoration(
      color: const Color(0xFFF3E4BC),
      border: Border.all(color: const Color(0xFF07111D), width: 3),
      borderRadius: BorderRadius.circular(6),
      boxShadow: const [BoxShadow(color: Colors.black87, offset: Offset(2, 3))],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('latest_city_development'),
        onTap: onEvent ?? onHistory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: const BoxDecoration(
                  color: ResiboColors.mutedRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFFFEBC1),
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.latestDevelopment.toUpperCase(),
                      style: const TextStyle(
                        color: ResiboColors.mutedRed,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                    Text(
                      event?.title ?? context.noEventsYet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                key: const Key('open_event_history'),
                onTap: onHistory,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.history_rounded, color: cityBriefInk),
                      if (unreadCount > 0)
                        Positioned(
                          right: -7,
                          top: -7,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: ResiboColors.mutedRed,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _WorldConditionStrip extends StatelessWidget {
  const _WorldConditionStrip({required this.conditions, required this.day});

  final List<WorldCondition> conditions;
  final int day;

  @override
  Widget build(BuildContext context) {
    final condition = conditions.isEmpty
        ? null
        : ([...conditions]..sort(
                (left, right) => right.intensity.compareTo(left.intensity),
              ))
              .first;
    return Container(
      key: const Key('world_condition_strip'),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: const BoxDecoration(
        color: Color(0xFF203C4C),
        border: Border(bottom: BorderSide(color: Color(0xFF07111D), width: 2)),
      ),
      child: Row(
        children: [
          Icon(
            condition == null
                ? Icons.wb_sunny_rounded
                : _worldConditionIcon(condition.type),
            color: const Color(0xFFF2BE58),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.currentCondition,
                  style: const TextStyle(
                    color: Color(0xFFF2BE58),
                    fontFamily: 'LilitaOne',
                    fontSize: 9,
                    letterSpacing: .5,
                  ),
                ),
                Text(
                  condition == null
                      ? context.noExternalPressure
                      : '${context.worldConditionLabel(condition.type)} · ${context.conditionDaysRemaining(condition.daysRemainingOn(day))}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFEDC0),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (conditions.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFB4474F),
                border: Border.all(color: const Color(0xFF07111D), width: 1.5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '+${conditions.length - 1}',
                style: const TextStyle(
                  color: Color(0xFFFFEDC0),
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

IconData _worldConditionIcon(WorldConditionType type) => switch (type) {
  WorldConditionType.sunnyStretch ||
  WorldConditionType.heatWave => Icons.wb_sunny_rounded,
  WorldConditionType.heavyRain ||
  WorldConditionType.monsoonPeriod => Icons.water_drop_rounded,
  WorldConditionType.severeThunderstorms ||
  WorldConditionType.strongTyphoon => Icons.thunderstorm_rounded,
  WorldConditionType.oilPriceCrisis ||
  WorldConditionType.fuelPriceDrop => Icons.local_gas_station_rounded,
  WorldConditionType.supplyShortage ||
  WorldConditionType.logisticsDisruption => Icons.local_shipping_rounded,
  WorldConditionType.regionalEconomicSlowdown ||
  WorldConditionType.businessExpansion => Icons.trending_up_rounded,
  WorldConditionType.constructionMaterialIncrease => Icons.construction_rounded,
  WorldConditionType.regionalPowerInstability => Icons.bolt_rounded,
  WorldConditionType.waterSupplyPressure => Icons.water_rounded,
  WorldConditionType.telecommunicationsOutage =>
    Icons.signal_cellular_off_rounded,
  WorldConditionType.festivalWeek ||
  WorldConditionType.holidayRush => Icons.celebration_rounded,
  WorldConditionType.schoolOpening ||
  WorldConditionType.graduationPeriod => Icons.school_rounded,
  WorldConditionType.fluDengueSeason => Icons.health_and_safety_rounded,
};

class _CriticalEventNotice extends StatelessWidget {
  const _CriticalEventNotice({
    required this.event,
    required this.onOpen,
    required this.onDismiss,
  });

  final CityEvent event;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('critical_event_notice_${event.id}'),
    margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF9F2834), Color(0xFFC8484E)],
      ),
      border: Border.all(color: const Color(0xFF07111D), width: 2.5),
      borderRadius: BorderRadius.circular(7),
      boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 3))],
    ),
    child: Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            Icons.notification_important_rounded,
            color: Color(0xFFFFEDBE),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            key: const Key('open_critical_event_notice'),
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFEDBE),
                      fontFamily: 'LilitaOne',
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${event.fictionalDate} · ${context.viewStory}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: onDismiss,
          icon: const Icon(Icons.close_rounded, color: Color(0xFFFFEDBE)),
        ),
      ],
    ),
  );
}

class _SimulationDock extends StatelessWidget {
  const _SimulationDock({
    required this.day,
    required this.paused,
    required this.speed,
    required this.onPause,
    required this.onSpeed,
    required this.onReport,
  });

  final int day;
  final bool paused;
  final SimulationSpeed speed;
  final VoidCallback onPause;
  final ValueChanged<SimulationSpeed> onSpeed;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
    decoration: const BoxDecoration(
      color: Color(0xFF102434),
      border: Border(top: BorderSide(color: Color(0xFF07111D), width: 3)),
    ),
    child: SafeArea(
      top: false,
      child: onReport != null
          ? Row(
              children: [
                const Expanded(
                  child: Text(
                    '365 / 365 DAYS',
                    style: TextStyle(
                      color: Color(0xFFFFD765),
                      fontFamily: 'LilitaOne',
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: ChunkyActionButton(
                    buttonKey: const Key('open_term_report'),
                    label: context.openTermReport,
                    icon: Icons.receipt_long_rounded,
                    compact: true,
                    color: ResiboColors.mutedRed,
                    onPressed: onReport!,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _SpeedButton(
                    buttonKey: const Key('simulation_pause'),
                    label: context.pause,
                    icon: Icons.pause_rounded,
                    selected: paused,
                    onPressed: onPause,
                  ),
                ),
                for (final option in SimulationSpeed.values) ...[
                  const SizedBox(width: 5),
                  Expanded(
                    child: _SpeedButton(
                      buttonKey: Key('simulation_speed_${option.name}'),
                      label: context.speedLabel(option),
                      icon: switch (option) {
                        SimulationSpeed.day => Icons.play_arrow_rounded,
                        SimulationSpeed.week => Icons.fast_forward_rounded,
                        SimulationSpeed.month => Icons.double_arrow_rounded,
                        SimulationSpeed.year => Icons.skip_next_rounded,
                      },
                      selected: !paused && speed == option,
                      onPressed: () => onSpeed(option),
                    ),
                  ),
                ],
              ],
            ),
    ),
  );
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      key: buttonKey,
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? const [Color(0xFF4A9B73), Color(0xFF24705D)]
                : const [Color(0xFF29475F), Color(0xFF173248)],
          ),
          border: Border.all(color: const Color(0xFF07111D), width: 2.5),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(color: Color(0xFF050B12), offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFEBC1), size: 20),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFEBC1),
                fontFamily: 'LilitaOne',
                fontSize: 10,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HistoryEventTile extends StatelessWidget {
  const _HistoryEventTile({
    required this.event,
    required this.unread,
    required this.onPressed,
  });

  final CityEvent event;
  final bool unread;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: unread ? const Color(0xFFFFF1C8) : const Color(0xFFE5D7B5),
          border: Border.all(color: const Color(0xFF07111D), width: 2),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(color: Colors.black54, offset: Offset(2, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unread ? ResiboColors.mutedRed : const Color(0xFF536778),
                border: Border.all(color: cityBriefInk, width: 2),
              ),
              child: Icon(
                _markerIcon(event.markerType),
                color: const Color(0xFFFFEBC1),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.fictionalDate.toUpperCase(),
                    style: const TextStyle(
                      color: ResiboColors.mutedRed,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    event.title.toUpperCase(),
                    style: const TextStyle(
                      color: cityBriefInk,
                      fontFamily: 'LilitaOne',
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    event.factualSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: cityBriefInk,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: cityBriefInk),
          ],
        ),
      ),
    ),
  );
}

enum _HistoryFilter { all, major, projects, community }

extension on _HistoryFilter {
  bool includes(CityEvent event) => switch (this) {
    _HistoryFilter.all => true,
    _HistoryFilter.major =>
      event.importance == CityEventImportance.important ||
          event.importance == CityEventImportance.critical ||
          event.importance == CityEventImportance.rare,
    _HistoryFilter.projects =>
      event.category == CityEventCategory.administration,
    _HistoryFilter.community => event.category == CityEventCategory.cityLife,
  };

  String label(BuildContext context) => switch (this) {
    _HistoryFilter.all => context.allEvents,
    _HistoryFilter.major => context.majorEvents,
    _HistoryFilter.projects => context.projectEvents,
    _HistoryFilter.community => context.communityEvents,
  };
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? ResiboColors.mutedRed : const Color(0xFF29475F),
          border: Border.all(color: const Color(0xFF07111D), width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFFEBC1),
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
    ),
  );
}

class _EventAction extends StatelessWidget {
  const _EventAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = ResiboColors.navy,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: const Color(0xFF07111D), width: 2),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(color: Colors.black45, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFEBC1), size: 17),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFFFEBC1),
                fontFamily: 'LilitaOne',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MayorSummary extends StatelessWidget {
  const _MayorSummary({
    required this.candidate,
    required this.portraitAssetKey,
  });

  final Candidate candidate;
  final String portraitAssetKey;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 82,
        child: CandidateImageSlot(
          candidateId: candidate.id,
          assetKey: portraitAssetKey,
          semanticLabel: candidate.name,
          color: Color(candidate.colorValue),
          aspectRatio: 4 / 5,
          borderRadius: 5,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.currentMayor.toUpperCase(),
              style: const TextStyle(
                color: ResiboColors.mutedRed,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              candidate.name.toUpperCase(),
              style: const TextStyle(
                color: cityBriefInk,
                fontFamily: 'LilitaOne',
                fontSize: 22,
              ),
            ),
            Text(
              candidate.party,
              style: const TextStyle(
                color: Color(0xFF65533D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Observer view · City Hall acts from the elected administration\'s saved abilities and commitments.',
              style: const TextStyle(fontSize: 11, height: 1.3),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.day});

  final AdministrationProject project;
  final int day;

  @override
  Widget build(BuildContext context) {
    final milestones = project.milestones
        .where((milestone) => milestone.day <= day)
        .toList(growable: false);
    final progress = milestones
        .fold<int>(0, (sum, milestone) => sum + milestone.progressDelta)
        .clamp(0, 100);
    final state =
        milestones.lastOrNull?.toState ?? AdministrationProjectState.proposed;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        border: Border.all(color: const Color(0xFF725634), width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.construction_rounded,
                color: ResiboColors.mutedRed,
                size: 19,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  project.title.toUpperCase(),
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: ResiboColors.teal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 9,
              color: ResiboColors.teal,
              backgroundColor: const Color(0xFFD3C29C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.name
                .replaceAllMapped(
                  RegExp(r'([A-Z])'),
                  (match) => ' ${match.group(1)}',
                )
                .toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF65533D),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficeMetric extends StatelessWidget {
  const _OfficeMetric({required this.label, this.value, this.textValue});

  final String label;
  final int? value;
  final String? textValue;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 118),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFE5D7B5),
      border: Border.all(color: cityBriefInk, width: 2),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF65533D),
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          textValue ?? '${value ?? 0}/100',
          style: const TextStyle(
            color: cityBriefInk,
            fontFamily: 'LilitaOne',
            fontSize: 17,
          ),
        ),
      ],
    ),
  );
}

class _ConditionTag extends StatelessWidget {
  const _ConditionTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF2E7766),
      border: Border.all(color: const Color(0xFF07111D), width: 2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFFFFEBC1),
        fontSize: 9,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ImportanceBadge extends StatelessWidget {
  const _ImportanceBadge({required this.importance});

  final CityEventImportance importance;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: switch (importance) {
        CityEventImportance.ambient => const Color(0xFF536778),
        CityEventImportance.minor => const Color(0xFF3277A0),
        CityEventImportance.important => ResiboColors.mutedRed,
        CityEventImportance.critical => const Color(0xFF9F2834),
        CityEventImportance.rare => const Color(0xFFB87C18),
      },
      border: Border.all(color: cityBriefInk, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      importance.name.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFFFFEBC1),
        fontSize: 9,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ChainNotice extends StatelessWidget {
  const _ChainNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: const Color(0xFFE6D9B6),
      border: Border.all(color: const Color(0xFF725634), width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Row(
      children: [
        Icon(Icons.link_rounded, color: ResiboColors.mutedRed, size: 18),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'FOLLOW-UP: This is a later chapter of an earlier saved city event.',
            style: TextStyle(
              color: cityBriefInk,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: change >= 0 ? const Color(0xFFD7E6CB) : const Color(0xFFF0CBC6),
      border: Border.all(color: cityBriefInk, width: 1.5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '${context.l10n.indicatorLabel(indicator)} ${change >= 0 ? '+' : ''}$change',
      style: const TextStyle(
        color: cityBriefInk,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _MapMetric extends StatelessWidget {
  const _MapMetric({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xEAF4E7C7),
      border: Border.all(color: cityBriefInk, width: 1.5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: ResiboColors.navy, size: 14),
        const SizedBox(width: 3),
        Text(
          '$value',
          style: const TextStyle(
            color: cityBriefInk,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

IconData _landmarkIcon(CityMapAnchorType type) => switch (type) {
  CityMapAnchorType.civic => Icons.account_balance_rounded,
  CityMapAnchorType.health => Icons.local_hospital_rounded,
  CityMapAnchorType.education => Icons.school_rounded,
  CityMapAnchorType.market => Icons.storefront_rounded,
  CityMapAnchorType.transport => Icons.directions_bus_rounded,
  CityMapAnchorType.media => Icons.newspaper_rounded,
  CityMapAnchorType.sanitation => Icons.recycling_rounded,
  CityMapAnchorType.residential => Icons.holiday_village_rounded,
  CityMapAnchorType.commercial => Icons.local_mall_rounded,
  CityMapAnchorType.publicSafety => Icons.local_police_rounded,
  CityMapAnchorType.emergency => Icons.fire_truck_rounded,
  CityMapAnchorType.utility => Icons.water_drop_rounded,
  CityMapAnchorType.park => Icons.park_rounded,
  CityMapAnchorType.industrial => Icons.factory_rounded,
  CityMapAnchorType.logistics => Icons.warehouse_rounded,
  CityMapAnchorType.road => Icons.add_road_rounded,
  CityMapAnchorType.recreation => Icons.sports_basketball_rounded,
};

IconData _markerIcon(CityMapMarkerType type) => switch (type) {
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
