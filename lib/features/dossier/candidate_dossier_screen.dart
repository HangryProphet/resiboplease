import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/candidate_dossier_profile.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/models/evidence_item.dart';
import '../../l10n/game_content_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../city/widgets/pre_election_navigation_bar.dart';
import 'widgets/dossier_ui.dart';
import 'widgets/evidence_reader.dart';

enum _DossierTab { overview, platform, evidence }

enum _EvidenceFilter {
  all,
  records,
  campaign,
  publicClaims,
  factChecks,
  debate,
  questions,
  bookmarked,
}

class CandidateDossierScreen extends StatefulWidget {
  const CandidateDossierScreen({
    required this.controller,
    required this.candidateId,
    super.key,
  });

  final GameController controller;
  final String candidateId;

  @override
  State<CandidateDossierScreen> createState() => _CandidateDossierScreenState();
}

class _CandidateDossierScreenState extends State<CandidateDossierScreen> {
  _DossierTab _tab = _DossierTab.overview;
  _EvidenceFilter _evidenceFilter = _EvidenceFilter.all;

  @override
  void didUpdateWidget(CandidateDossierScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candidateId != widget.candidateId) {
      _tab = _DossierTab.overview;
      _evidenceFilter = _EvidenceFilter.all;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final candidate = widget.controller.candidateByIdOrNull(
        widget.candidateId,
      );
      if (candidate == null) {
        return _MissingCandidate(controller: widget.controller);
      }
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        bottomNavigationBar: const PreElectionNavigationBar(
          current: PreElectionDestination.dossiers,
        ),
        body: SafeArea(
          child: InvestigationBackdrop(
            child: Column(
              children: [
                InvestigationHeader(
                  title: context.l10n.dossier,
                  subtitle: candidate.name,
                  onBack: () => context.go('/candidates'),
                  trailing: GameIconButton(
                    tooltip: context.l10n.electionDay,
                    icon: Icons.how_to_vote_rounded,
                    onPressed: () => context.go('/vote'),
                    color: ResiboColors.mutedRed,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('candidate_dossier_scroll'),
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 36),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1060),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CandidateIdentity(
                              controller: widget.controller,
                              candidate: candidate,
                            ),
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  DossierTabButton(
                                    key: const Key('dossier_tab_overview'),
                                    label: context.l10n.overviewTab,
                                    icon: Icons.badge_rounded,
                                    selected: _tab == _DossierTab.overview,
                                    onTap: () => setState(
                                      () => _tab = _DossierTab.overview,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  DossierTabButton(
                                    key: const Key('dossier_tab_platform'),
                                    label: context.l10n.platformTab,
                                    icon: Icons.campaign_rounded,
                                    selected: _tab == _DossierTab.platform,
                                    onTap: () => setState(
                                      () => _tab = _DossierTab.platform,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  DossierTabButton(
                                    key: const Key('dossier_tab_evidence'),
                                    label: context.l10n.evidenceTab,
                                    icon: Icons.folder_copy_rounded,
                                    selected: _tab == _DossierTab.evidence,
                                    onTap: () => setState(
                                      () => _tab = _DossierTab.evidence,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: dossierPaper,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                border: Border.all(color: dossierInk, width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x99000000),
                                    offset: Offset(0, 7),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 180),
                                child: switch (_tab) {
                                  _DossierTab.overview => _OverviewPage(
                                    key: const ValueKey('overview'),
                                    controller: widget.controller,
                                    candidate: candidate,
                                  ),
                                  _DossierTab.platform => _PlatformPage(
                                    key: const ValueKey('platform'),
                                    controller: widget.controller,
                                    candidate: candidate,
                                  ),
                                  _DossierTab.evidence => _EvidencePage(
                                    key: const ValueKey('evidence'),
                                    controller: widget.controller,
                                    candidate: candidate,
                                    selectedFilter: _evidenceFilter,
                                    onFilterChanged: (filter) => setState(
                                      () => _evidenceFilter = filter,
                                    ),
                                  ),
                                },
                              ),
                            ),
                            const SizedBox(height: 26),
                            _DossierNavigation(
                              controller: widget.controller,
                              candidate: candidate,
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
    },
  );
}

class _MissingCandidate extends StatelessWidget {
  const _MissingCandidate({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0B1725),
    body: SafeArea(
      child: InvestigationBackdrop(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: PaperPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_off_rounded,
                      size: 52,
                      color: ResiboColors.mutedRed,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.caseFileMissing,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: dossierInk,
                        fontFamily: 'LuckiestGuy',
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ChunkyActionButton(
                      label: context.l10n.roster,
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => context.go('/candidates'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CandidateIdentity extends StatelessWidget {
  const _CandidateIdentity({required this.controller, required this.candidate});

  final GameController controller;
  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final cityName = controller.scenario.city.name;
    final color = Color(candidate.colorValue);
    final opened = candidate.evidence
        .where((item) => controller.isEvidenceViewed(item.id))
        .length;
    final remaining = controller.remainingInvestigationPoints;
    final profile = buildCandidateDossierProfile(
      candidate: candidate,
      candidateField:
          controller.activeConfiguration?.candidateField ??
          CandidateField.mixed,
      seed: controller.scenario.seed,
    );
    return Container(
      decoration: BoxDecoration(
        color: dossierInk,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB8000000),
            offset: Offset(0, 7),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(3, 3, 3, 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final portrait = _IdentityPortrait(
              candidate: candidate,
              color: color,
            );
            final details = Container(
              padding: EdgeInsets.all(wide ? 23 : 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [dossierPaperLight, dossierPaper],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FileStamp(
                        label: context.l10n.candidateForMayor,
                        color: color,
                        icon: Icons.account_balance_rounded,
                      ),
                      FileStamp(
                        label: context.l10n.candidateArchetypeText(
                          candidate,
                          cityName,
                        ),
                        color: ResiboColors.teal,
                        angle: .025,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    candidate.name.toUpperCase(),
                    style: const TextStyle(
                      color: dossierInk,
                      fontFamily: 'LuckiestGuy',
                      fontSize: 35,
                      height: .94,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    context.l10n.candidatePartyText(candidate, cityName),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '“${context.l10n.candidateSloganText(candidate, cityName)}”',
                    style: const TextStyle(
                      color: Color(0xFF4F4436),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PaperCounter(
                        icon: Icons.history_edu_rounded,
                        label:
                            '${context.l10n.publicServiceExperience}: ${context.l10n.dossierExperienceLabel(profile.experienceBand)}',
                        color: color,
                      ),
                      _PaperCounter(
                        icon: Icons.inventory_2_rounded,
                        label:
                            '${context.l10n.evidenceRecordDepth}: ${context.l10n.dossierEvidenceDepthLabel(profile.evidenceSummary.depth)}',
                        color: ResiboColors.teal,
                      ),
                      _PaperCounter(
                        icon: Icons.folder_open_rounded,
                        label: context.l10n.filesReviewed(
                          opened,
                          candidate.evidence.length,
                        ),
                        color: ResiboColors.teal,
                      ),
                      _PaperCounter(
                        icon: remaining == null
                            ? Icons.all_inclusive_rounded
                            : Icons.hourglass_bottom_rounded,
                        label: remaining == null
                            ? context.l10n.unlimitedInvestigation
                            : context.l10n.investigationPointsRemaining(
                                remaining,
                              ),
                        color: ResiboColors.gold,
                      ),
                    ],
                  ),
                ],
              ),
            );
            if (wide) {
              return SizedBox(
                height: 292,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 290, child: portrait),
                    Expanded(child: details),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 255, child: portrait),
                details,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IdentityPortrait extends StatelessWidget {
  const _IdentityPortrait({required this.candidate, required this.color});

  final Candidate candidate;
  final Color color;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(color, Colors.white, .2)!,
              color,
              Color.lerp(color, dossierInk, .58)!,
            ],
          ),
        ),
      ),
      Positioned(
        left: -15,
        right: -15,
        top: 6,
        bottom: -4,
        child: Hero(
          tag: 'portrait_${candidate.id}',
          child: Image.asset(
            'assets/images/candidates/${candidate.id}/${candidate.id}_portrait.png',
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            semanticLabel: candidate.name,
          ),
        ),
      ),
    ],
  );
}

class _PaperCounter extends StatelessWidget {
  const _PaperCounter({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 36),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: .75), width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: dossierInk,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RecordFact extends StatelessWidget {
  const _RecordFact({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: .65), width: 1.4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: dossierInk,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({
    required this.controller,
    required this.candidate,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final cityName = controller.scenario.city.name;
    final strengths = context.l10n.candidateStrengthsText(candidate, cityName);
    final concerns = context.l10n.candidateConcernsText(candidate, cityName);
    final profile = buildCandidateDossierProfile(
      candidate: candidate,
      candidateField:
          controller.activeConfiguration?.candidateField ??
          CandidateField.mixed,
      seed: controller.scenario.seed,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaperPanel(
          borderWidth: 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                label: context.l10n.biography,
                icon: Icons.person_search_rounded,
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.candidateBiographyText(candidate, cityName),
                style: const TextStyle(
                  color: dossierInk,
                  fontSize: 15,
                  height: 1.52,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final strengthPanel = _FindingPanel(
              title: context.l10n.documentedStrengths,
              icon: Icons.check_circle_rounded,
              color: ResiboColors.teal,
              items: strengths,
            );
            final concernPanel = _FindingPanel(
              title: context.l10n.questionsToInvestigate,
              icon: Icons.help_rounded,
              color: ResiboColors.mutedRed,
              items: concerns,
            );
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: strengthPanel),
                      const SizedBox(width: 14),
                      Expanded(child: concernPanel),
                    ],
                  )
                : Column(
                    children: [
                      strengthPanel,
                      const SizedBox(height: 14),
                      concernPanel,
                    ],
                  );
          },
        ),
        const SizedBox(height: 14),
        PaperPanel(
          borderWidth: 1.5,
          color: const Color(0xFFEDE1C3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                label: context.l10n.recordSnapshot,
                icon: Icons.inventory_2_rounded,
                color: ResiboColors.gold,
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RecordFact(
                    icon: Icons.apartment_rounded,
                    label: context.l10n.accountableRecordsCount(
                      profile.evidenceSummary.accountableRecords,
                    ),
                    color: ResiboColors.teal,
                  ),
                  _RecordFact(
                    icon: Icons.source_rounded,
                    label: context.l10n.distinctSourcesCount(
                      profile.evidenceSummary.distinctSources,
                    ),
                    color: const Color(0xFF426B8C),
                  ),
                  _RecordFact(
                    icon: Icons.help_outline_rounded,
                    label: context.l10n.unresolvedFilesCount(
                      profile.evidenceSummary.unresolvedItems,
                    ),
                    color: ResiboColors.mutedRed,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in const [
                    EvidenceType.profile,
                    EvidenceType.publicRecord,
                    EvidenceType.budgetDocument,
                    EvidenceType.factCheck,
                    EvidenceType.debateAnswer,
                    EvidenceType.controversy,
                  ])
                    if (candidate.evidence.any((item) => item.type == type))
                      FileStamp(
                        label: context.l10n.evidenceTypeLabel(type),
                        color: _colorForEvidence(type),
                        angle: type.index.isEven ? -.018 : .018,
                      ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FindingPanel extends StatelessWidget {
  const _FindingPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) => PaperPanel(
    borderWidth: 1.5,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: title, icon: icon, color: color),
        const SizedBox(height: 11),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: dossierInk,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
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

class _PlatformPage extends StatelessWidget {
  const _PlatformPage({
    required this.controller,
    required this.candidate,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final cityName = controller.scenario.city.name;
    final promises = context.l10n.candidatePlatformText(candidate, cityName);
    final color = Color(candidate.colorValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ResiboColors.gold.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0xFF9B7623), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFF8C6712)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  context.l10n.platformReminder,
                  style: const TextStyle(
                    color: dossierInk,
                    height: 1.38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        for (var index = 0; index < promises.length; index++) ...[
          PaperPanel(
            borderWidth: 1.5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: dossierInk, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x55000000), offset: Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFFFFF1D1),
                      fontFamily: 'LuckiestGuy',
                      fontSize: 23,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promises[index],
                        style: const TextStyle(
                          color: dossierInk,
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        context.l10n.evidenceDeskHint,
                        style: const TextStyle(
                          color: Color(0xFF655B4D),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (index != promises.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _EvidencePage extends StatelessWidget {
  const _EvidencePage({
    required this.controller,
    required this.candidate,
    required this.selectedFilter,
    required this.onFilterChanged,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final _EvidenceFilter selectedFilter;
  final ValueChanged<_EvidenceFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final visible = candidate.evidence
        .where((item) => _matchesFilter(item, selectedFilter, controller))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.evidenceDeskHint,
          style: const TextStyle(
            color: dossierInk,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 13),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in _EvidenceFilter.values) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: _EvidenceFilterChip(
                    filter: filter,
                    label: _filterLabel(context, filter),
                    selected: filter == selectedFilter,
                    onSelected: () => onFilterChanged(filter),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          PaperPanel(
            borderWidth: 1.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(
                children: [
                  const Icon(
                    Icons.folder_off_rounded,
                    color: Color(0xFF8D7956),
                    size: 42,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    context.l10n.noEvidenceInFilter,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: dossierInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 820 ? 2 : 1;
              const gap = 12.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: 12,
                children: [
                  for (final item in visible)
                    SizedBox(
                      width: width,
                      child: _EvidenceFileCard(
                        controller: controller,
                        candidate: candidate,
                        item: item,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  static bool _matchesFilter(
    EvidenceItem item,
    _EvidenceFilter filter,
    GameController controller,
  ) => switch (filter) {
    _EvidenceFilter.all => true,
    _EvidenceFilter.records => const {
      EvidenceType.profile,
      EvidenceType.publicRecord,
      EvidenceType.budgetDocument,
    }.contains(item.type),
    _EvidenceFilter.campaign => const {
      EvidenceType.platform,
      EvidenceType.campaignAd,
    }.contains(item.type),
    _EvidenceFilter.publicClaims => item.type == EvidenceType.socialPost,
    _EvidenceFilter.factChecks => item.type == EvidenceType.factCheck,
    _EvidenceFilter.debate => item.type == EvidenceType.debateAnswer,
    _EvidenceFilter.questions => item.type == EvidenceType.controversy,
    _EvidenceFilter.bookmarked => controller.isBookmarked(item.id),
  };

  static String _filterLabel(BuildContext context, _EvidenceFilter filter) =>
      switch (filter) {
        _EvidenceFilter.all => context.l10n.allEvidence,
        _EvidenceFilter.records => context.l10n.recordsEvidence,
        _EvidenceFilter.campaign => context.l10n.campaignEvidence,
        _EvidenceFilter.publicClaims => context.l10n.publicClaimsEvidence,
        _EvidenceFilter.factChecks => context.l10n.factChecksEvidence,
        _EvidenceFilter.debate => context.l10n.debateEvidence,
        _EvidenceFilter.questions => context.l10n.questionsEvidence,
        _EvidenceFilter.bookmarked => context.l10n.bookmarkedEvidence,
      };
}

class _EvidenceFilterChip extends StatelessWidget {
  const _EvidenceFilterChip({
    required this.filter,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final _EvidenceFilter filter;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Material(
    key: Key('evidence_filter_${filter.name}'),
    color: selected ? ResiboColors.teal : const Color(0xFFE2D1AA),
    borderRadius: BorderRadius.circular(7),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onSelected,
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: dossierInk, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: selected ? const Color(0xFFFFF1D1) : dossierInk,
            fontFamily: 'LilitaOne',
            fontSize: 13,
            letterSpacing: .35,
          ),
        ),
      ),
    ),
  );
}

class _EvidenceFileCard extends StatelessWidget {
  const _EvidenceFileCard({
    required this.controller,
    required this.candidate,
    required this.item,
  });

  final GameController controller;
  final Candidate candidate;
  final EvidenceItem item;

  @override
  Widget build(BuildContext context) {
    final opened = controller.isEvidenceViewed(item.id);
    final bookmarked = controller.isBookmarked(item.id);
    final free = item.type == EvidenceType.profile || opened;
    final cityName = controller.scenario.city.name;
    final typeColor = _colorForEvidence(item.type);
    return Semantics(
      button: true,
      label:
          '${context.l10n.evidenceTitleText(item, cityName)}, ${opened ? context.l10n.fileOpened : context.l10n.fileUnopened}, ${free ? context.l10n.fileFree : context.l10n.filePointCost}',
      child: Container(
        decoration: BoxDecoration(
          color: opened ? const Color(0xFFFFF7E3) : const Color(0xFFE7D8B8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dossierInk, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x55000000), offset: Offset(2, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('evidence_${item.id}'),
            onTap: () => openEvidenceReader(
              context,
              controller: controller,
              candidate: candidate,
              item: item,
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: dossierInk, width: 2),
                        ),
                        child: Icon(
                          _iconForEvidence(item.type),
                          color: const Color(0xFFFFF1D1),
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n
                                  .evidenceTypeLabel(item.type)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: typeColor,
                                fontFamily: 'LilitaOne',
                                fontSize: 13,
                                letterSpacing: .45,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              context.l10n.evidenceTitleText(item, cityName),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: dossierInk,
                                fontSize: 16,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        key: Key('quick_bookmark_${item.id}'),
                        tooltip: bookmarked
                            ? context.l10n.removeBookmark
                            : context.l10n.bookmark,
                        onPressed: () => controller.toggleBookmark(item.id),
                        icon: Icon(
                          bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: bookmarked
                              ? ResiboColors.gold
                              : const Color(0xFF776A55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.evidenceSourceText(item, cityName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF625746),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.l10n.evidenceSummaryText(item, cityName),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: dossierInk,
                      fontSize: 13,
                      height: 1.32,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      FileStamp(
                        label: opened
                            ? context.l10n.fileOpened
                            : context.l10n.fileUnopened,
                        color: opened
                            ? ResiboColors.teal
                            : const Color(0xFF7A6B52),
                        icon: opened
                            ? Icons.check_rounded
                            : Icons.lock_outline_rounded,
                        angle: 0,
                      ),
                      FileStamp(
                        label: free
                            ? (item.type == EvidenceType.profile
                                  ? context.l10n.fileFree
                                  : context.l10n.fileOpened)
                            : context.l10n.filePointCost,
                        color: free ? ResiboColors.teal : ResiboColors.mutedRed,
                        icon: free
                            ? Icons.lock_open_rounded
                            : Icons.hourglass_bottom_rounded,
                        angle: 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DossierNavigation extends StatelessWidget {
  const _DossierNavigation({required this.controller, required this.candidate});

  final GameController controller;
  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final candidates = controller.scenario.candidates;
    final index = candidates.indexWhere((item) => item.id == candidate.id);
    final previous = index > 0 ? candidates[index - 1] : null;
    final next = index >= 0 && index < candidates.length - 1
        ? candidates[index + 1]
        : null;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 12,
      children: [
        ChunkyActionButton(
          label: context.l10n.roster,
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF3C5368),
          compact: true,
          onPressed: () => context.go('/candidates'),
        ),
        if (previous != null)
          ChunkyActionButton(
            label: context.l10n.previousCandidate,
            icon: Icons.arrow_back_rounded,
            color: Color(previous.colorValue),
            compact: true,
            onPressed: () => context.go('/candidates/${previous.id}'),
          ),
        if (next != null)
          ChunkyActionButton(
            label: context.l10n.nextCandidate,
            icon: Icons.arrow_forward_rounded,
            color: Color(next.colorValue),
            compact: true,
            onPressed: () => context.go('/candidates/${next.id}'),
          ),
        ChunkyActionButton(
          buttonKey: const Key('review_ballot'),
          label: context.l10n.reviewBallot,
          icon: Icons.how_to_vote_rounded,
          color: ResiboColors.mutedRed,
          compact: true,
          onPressed: () => context.go('/vote'),
        ),
      ],
    );
  }
}

Color _colorForEvidence(EvidenceType type) => switch (type) {
  EvidenceType.profile => const Color(0xFF5E4B87),
  EvidenceType.platform => ResiboColors.mutedRed,
  EvidenceType.campaignAd => const Color(0xFFC06C32),
  EvidenceType.publicRecord => ResiboColors.teal,
  EvidenceType.budgetDocument => const Color(0xFF9A711B),
  EvidenceType.socialPost => const Color(0xFF547798),
  EvidenceType.factCheck => const Color(0xFF397B55),
  EvidenceType.controversy => const Color(0xFF9D3B3B),
  EvidenceType.debateAnswer => const Color(0xFF426B8C),
};

IconData _iconForEvidence(EvidenceType type) => switch (type) {
  EvidenceType.profile => Icons.badge_rounded,
  EvidenceType.platform => Icons.list_alt_rounded,
  EvidenceType.campaignAd => Icons.campaign_rounded,
  EvidenceType.publicRecord => Icons.account_balance_rounded,
  EvidenceType.budgetDocument => Icons.receipt_long_rounded,
  EvidenceType.socialPost => Icons.forum_rounded,
  EvidenceType.factCheck => Icons.fact_check_rounded,
  EvidenceType.controversy => Icons.warning_amber_rounded,
  EvidenceType.debateAnswer => Icons.record_voice_over_rounded,
};
