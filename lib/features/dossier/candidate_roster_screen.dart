import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/candidate_dossier_profile.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/models/city_problem.dart';
import '../../l10n/game_content_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../city/widgets/pre_election_navigation_bar.dart';
import 'widgets/dossier_ui.dart';

class CandidateRosterScreen extends StatelessWidget {
  const CandidateRosterScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      backgroundColor: const Color(0xFF0B1725),
      bottomNavigationBar: const PreElectionNavigationBar(
        current: PreElectionDestination.dossiers,
      ),
      body: SafeArea(
        child: InvestigationBackdrop(
          showCity: true,
          child: Column(
            children: [
              InvestigationHeader(
                title: context.l10n.candidateRoster,
                subtitle: controller.scenario.city.name,
                onBack: () => context.go('/city'),
                trailing: GameIconButton(
                  tooltip: context.l10n.electionDay,
                  icon: Icons.how_to_vote_rounded,
                  onPressed: () => context.go('/vote'),
                  color: ResiboColors.mutedRed,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('candidate_roster_scroll'),
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 34),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _RosterBrief(controller: controller),
                          const SizedBox(height: 18),
                          _CityCaseFiles(controller: controller),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 980
                                  ? 3
                                  : constraints.maxWidth >= 650
                                  ? 2
                                  : 1;
                              const gap = 14.0;
                              final cardWidth =
                                  (constraints.maxWidth - gap * (columns - 1)) /
                                  columns;
                              return Wrap(
                                spacing: gap,
                                runSpacing: 18,
                                children: [
                                  for (final candidate
                                      in controller.scenario.candidates)
                                    SizedBox(
                                      width: cardWidth,
                                      child: _CandidateFileCard(
                                        candidate: candidate,
                                        controller: controller,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          Align(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: SizedBox(
                                width: double.infinity,
                                child: ChunkyActionButton(
                                  buttonKey: const Key('review_ballot'),
                                  label: context.l10n.proceedElection,
                                  icon: Icons.how_to_vote_rounded,
                                  color: ResiboColors.mutedRed,
                                  onPressed: () => context.go('/vote'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            context.l10n.candidateRosterIntro,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFD5DFE4),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
    ),
  );
}

class _RosterBrief extends StatelessWidget {
  const _RosterBrief({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final remaining = controller.remainingInvestigationPoints;
    return PaperPanel(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 670;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                label: context.l10n.candidateRosterHeading,
                icon: Icons.folder_copy_rounded,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.candidateRosterIntro,
                style: const TextStyle(
                  color: dossierInk,
                  height: 1.38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
          final counters = Wrap(
            alignment: compact ? WrapAlignment.start : WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              InvestigationPill(
                icon: Icons.folder_open_rounded,
                label:
                    '${controller.viewedEvidenceCount} / ${controller.scenario.candidates.fold<int>(0, (total, candidate) => total + candidate.evidence.length)} ${context.l10n.evidenceTab}',
                color: ResiboColors.teal,
              ),
              InvestigationPill(
                icon: remaining == null
                    ? Icons.all_inclusive_rounded
                    : Icons.hourglass_bottom_rounded,
                label: remaining == null
                    ? context.l10n.investigationRelaxed
                    : context.l10n.investigationPointsRemaining(remaining),
                color: ResiboColors.gold,
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 13), counters],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 18),
              Flexible(flex: 2, child: counters),
            ],
          );
        },
      ),
    );
  }
}

class _CityCaseFiles extends StatelessWidget {
  const _CityCaseFiles({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          context.l10n.urgentCaseFiles.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFFE5A4),
            fontFamily: 'LilitaOne',
            fontSize: 19,
            letterSpacing: .8,
            shadows: [Shadow(color: Colors.black87, offset: Offset(1, 2))],
          ),
        ),
      ),
      const SizedBox(height: 9),
      LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final width = wide
              ? (constraints.maxWidth - 20) /
                    controller.scenario.city.problems.length
              : constraints.maxWidth;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final problem in controller.scenario.city.problems)
                SizedBox(
                  width: width,
                  child: _ProblemFile(problem: problem),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _ProblemFile extends StatelessWidget {
  const _ProblemFile({required this.problem});

  final CityProblem problem;

  @override
  Widget build(BuildContext context) {
    final color = switch (problem.trend) {
      ProblemTrend.improving => ResiboColors.teal,
      ProblemTrend.stable => ResiboColors.gold,
      ProblemTrend.worsening => const Color(0xFFD46B42),
      ProblemTrend.rapidlyWorsening => ResiboColors.mutedRed,
    };
    final icon = switch (problem.primaryIndicator.name) {
      'waterSecurity' => Icons.water_drop_rounded,
      'employmentQuality' => Icons.work_rounded,
      'publicHealth' => Icons.health_and_safety_rounded,
      'educationQuality' => Icons.school_rounded,
      'foodSecurity' => Icons.restaurant_rounded,
      'climateResilience' => Icons.flood_rounded,
      'urbanResilience' => Icons.location_city_rounded,
      _ => Icons.priority_high_rounded,
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xF7F6EACB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dossierInk, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: dossierInk, width: 2),
            ),
            child: Icon(icon, color: const Color(0xFFFFF1D1), size: 27),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.problemTitleText(problem),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dossierInk,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.trendLabel(problem.trend),
                  style: TextStyle(
                    color: color,
                    fontFamily: 'LilitaOne',
                    fontSize: 12,
                    letterSpacing: .45,
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

class _CandidateFileCard extends StatelessWidget {
  const _CandidateFileCard({required this.candidate, required this.controller});

  final Candidate candidate;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final candidateColor = Color(candidate.colorValue);
    final opened = candidate.evidence
        .where((item) => controller.isEvidenceViewed(item.id))
        .length;
    final cityName = controller.scenario.city.name;
    final profile = buildCandidateDossierProfile(
      candidate: candidate,
      candidateField:
          controller.activeConfiguration?.candidateField ??
          CandidateField.mixed,
      seed: controller.scenario.seed,
    );
    final strengths = context.l10n.candidateStrengthsText(candidate, cityName);
    final concerns = context.l10n.candidateConcernsText(candidate, cityName);
    return Semantics(
      button: true,
      label:
          '${candidate.name}, ${context.l10n.candidatePartyText(candidate, cityName)}, $opened of ${candidate.evidence.length}',
      child: Container(
        decoration: BoxDecoration(
          color: dossierInk,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0xB8000000),
              offset: Offset(0, 7),
              blurRadius: 3,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(3, 3, 3, 6),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('candidate_${candidate.id}'),
            onTap: () => context.go('/candidates/${candidate.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 230,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(candidateColor, Colors.white, .18)!,
                              candidateColor,
                              Color.lerp(candidateColor, dossierInk, .52)!,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: -14,
                        right: -14,
                        top: 4,
                        bottom: -5,
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
                      Positioned(
                        left: 10,
                        top: 10,
                        child: FileStamp(
                          label: context.l10n.dossier,
                          color: const Color(0xFFFFE7A7),
                          angle: -.035,
                          icon: Icons.folder_rounded,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 9,
                        child: FileStamp(
                          label: '$opened / ${candidate.evidence.length}',
                          color: const Color(0xFFFFF1D1),
                          angle: .035,
                          icon: Icons.fact_check_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [dossierPaperLight, dossierPaper],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: dossierInk,
                          fontFamily: 'LuckiestGuy',
                          fontSize: 27,
                          height: .96,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        context.l10n.candidatePartyText(candidate, cityName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: candidateColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 7),
                      FileStamp(
                        label: context.l10n.dossierExperienceLabel(
                          profile.experienceBand,
                        ),
                        color: candidateColor,
                        angle: -.015,
                        icon: Icons.history_edu_rounded,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '“${context.l10n.candidateSloganText(candidate, cityName)}”',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF4C4337),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          height: 1.24,
                        ),
                      ),
                      const SizedBox(height: 13),
                      _FileNote(
                        icon: Icons.check_circle_rounded,
                        color: ResiboColors.teal,
                        label: strengths.first,
                      ),
                      const SizedBox(height: 7),
                      _FileNote(
                        icon: Icons.help_rounded,
                        color: ResiboColors.mutedRed,
                        label: concerns.first,
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ChunkyActionButton(
                          label: context.l10n.openDossier,
                          icon: Icons.folder_open_rounded,
                          color: candidateColor,
                          compact: true,
                          onPressed: () =>
                              context.go('/candidates/${candidate.id}'),
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
    );
  }
}

class _FileNote extends StatelessWidget {
  const _FileNote({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: dossierInk,
            fontSize: 13,
            height: 1.23,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
