import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/city_problem.dart';
import '../../l10n/game_content_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../dossier/widgets/dossier_ui.dart';
import 'widgets/winner_reveal.dart';

class ElectionScreen extends StatefulWidget {
  const ElectionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<ElectionScreen> createState() => _ElectionScreenState();
}

class _ElectionScreenState extends State<ElectionScreen> {
  String? _candidateId;
  String? _topIssue;
  double _confidence = .5;

  @override
  Widget build(BuildContext context) {
    final scenario = widget.controller.scenario;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1725),
      body: SafeArea(
        child: InvestigationBackdrop(
          showCity: true,
          child: Column(
            children: [
              InvestigationHeader(
                title: context.l10n.electionDay,
                subtitle: widget.controller.activeCityName,
                onBack: () => context.go('/candidates'),
                trailing: GameIconButton(
                  tooltip: context.l10n.navCity,
                  icon: Icons.location_city_rounded,
                  onPressed: () => context.go('/city'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('election_scroll'),
                  padding: const EdgeInsets.fromLTRB(13, 18, 13, 36),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 930),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PaperPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionLabel(
                                  label: context.l10n.electionDayHeading,
                                  icon: Icons.how_to_vote_rounded,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.ballotInstruction,
                                  style: const TextStyle(
                                    color: dossierInk,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  context.l10n.evidenceOpenedCount(
                                    widget.controller.viewedEvidenceCount,
                                    scenario.candidates.fold<int>(
                                      0,
                                      (sum, candidate) =>
                                          sum + candidate.evidence.length,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF675946),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 23),
                          _DarkSectionLabel(
                            text: context.l10n.ballotCandidateInstruction,
                            icon: Icons.people_alt_rounded,
                          ),
                          const SizedBox(height: 10),
                          for (final candidate in scenario.candidates) ...[
                            _BallotCandidateCard(
                              candidate: candidate,
                              cityName: scenario.city.name,
                              selected: _candidateId == candidate.id,
                              onSelected: () =>
                                  setState(() => _candidateId = candidate.id),
                              onDossier: () =>
                                  context.go('/candidates/${candidate.id}'),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 12),
                          _DarkSectionLabel(
                            text: context.l10n.choosePriority,
                            icon: Icons.flag_rounded,
                          ),
                          const SizedBox(height: 10),
                          PaperPanel(
                            child: Column(
                              children: [
                                for (final problem in scenario.city.problems)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _IssueChoice(
                                      problem: problem,
                                      cityName: scenario.city.name,
                                      selected: _topIssue == problem.id,
                                      onTap: () => setState(
                                        () => _topIssue = problem.id,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 23),
                          _DarkSectionLabel(
                            text: context.l10n.confidenceQuestion,
                            icon: Icons.psychology_alt_rounded,
                          ),
                          const SizedBox(height: 10),
                          PaperPanel(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        context.l10n.confidenceLow,
                                        style: const TextStyle(
                                          color: dossierInk,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 92,
                                      child: Text(
                                        context.l10n.confidenceValue(
                                          (_confidence * 100).round(),
                                        ),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: ResiboColors.mutedRed,
                                          fontFamily: 'LuckiestGuy',
                                          fontSize: 27,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        context.l10n.confidenceHigh,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: dossierInk,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: ResiboColors.mutedRed,
                                    inactiveTrackColor: dossierPaperDark,
                                    thumbColor: const Color(0xFFFFD785),
                                    overlayColor: ResiboColors.mutedRed
                                        .withValues(alpha: .15),
                                    trackHeight: 7,
                                  ),
                                  child: Slider(
                                    key: const Key('ballot_confidence'),
                                    value: _confidence,
                                    divisions: 10,
                                    label: '${(_confidence * 100).round()}%',
                                    onChanged: (value) =>
                                        setState(() => _confidence = value),
                                  ),
                                ),
                                Text(
                                  context.l10n.confidenceReflection,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF675946),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          PaperPanel(
                            color: const Color(0xFFF4DFAE),
                            padding: const EdgeInsets.all(13),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: ResiboColors.navy,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context
                                            .l10n
                                            .selectedCandidateEffectTitle,
                                        style: const TextStyle(
                                          color: dossierInk,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        context
                                            .l10n
                                            .selectedCandidateEffectBody,
                                        style: const TextStyle(
                                          color: dossierInk,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: SizedBox(
                                width: double.infinity,
                                child: ChunkyActionButton(
                                  buttonKey: const Key('cast_vote'),
                                  label: context.l10n.castVote,
                                  icon: Icons.how_to_vote_rounded,
                                  color: ResiboColors.mutedRed,
                                  onPressed:
                                      _candidateId == null || _topIssue == null
                                      ? null
                                      : _confirmVote,
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

  Future<void> _confirmVote() async {
    final candidate = widget.controller.candidateById(_candidateId!);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: PaperPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(
                  label: context.l10n.sealBallotQuestion,
                  icon: Icons.verified_rounded,
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.sealBallotBody(candidate.name),
                  style: const TextStyle(color: dossierInk, height: 1.4),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(context.l10n.keepReviewing),
                    ),
                    SizedBox(
                      width: 190,
                      child: ChunkyActionButton(
                        buttonKey: const Key('confirm_vote'),
                        label: context.l10n.confirmVote,
                        icon: Icons.lock_rounded,
                        compact: true,
                        color: ResiboColors.mutedRed,
                        onPressed: () => Navigator.pop(dialogContext, true),
                      ),
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
    widget.controller.castVote(
      candidate: candidate,
      topIssue: _topIssue!,
      confidence: _confidence,
    );
    final begin = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: context.l10n.winnerDeclared,
      barrierColor: const Color(0xE6000000),
      transitionDuration: const Duration(milliseconds: 480),
      pageBuilder: (_, _, _) => WinnerReveal(
        candidate: candidate,
        cityName: widget.controller.activeCityName,
      ),
      transitionBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(begin: .88, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      ),
    );
    if (begin == true && mounted) context.go('/simulation');
  }
}

class _DarkSectionLabel extends StatelessWidget {
  const _DarkSectionLabel({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFFFFD785), size: 22),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFFEBC1),
            fontFamily: 'LilitaOne',
            fontSize: 19,
            letterSpacing: .5,
            shadows: [Shadow(color: Colors.black87, offset: Offset(1, 2))],
          ),
        ),
      ),
    ],
  );
}

class _BallotCandidateCard extends StatelessWidget {
  const _BallotCandidateCard({
    required this.candidate,
    required this.cityName,
    required this.selected,
    required this.onSelected,
    required this.onDossier,
  });

  final Candidate candidate;
  final String cityName;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback onDossier;

  @override
  Widget build(BuildContext context) {
    final color = Color(candidate.colorValue);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD36B).withValues(alpha: .55),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: dossierPaperLight,
        borderRadius: BorderRadius.circular(9),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('ballot_${candidate.id}'),
          onTap: onSelected,
          child: Container(
            height: 154,
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? const Color(0xFFFFC94F) : dossierInk,
                width: selected ? 4 : 2.5,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 112,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(color, Colors.white, .3)!,
                        color.withValues(alpha: .72),
                      ],
                    ),
                    border: const Border(
                      right: BorderSide(color: dossierInk, width: 2),
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/candidates/${candidate.id}/${candidate.id}_portrait.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 11, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: selected ? color : const Color(0xFF776E60),
                              size: 22,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                candidate.name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: dossierInk,
                                  fontFamily: 'LilitaOne',
                                  fontSize: 20,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          context.l10n.candidatePartyText(candidate, cityName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '“${context.l10n.candidateSloganText(candidate, cityName)}”',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: dossierInk,
                            fontSize: 12,
                            height: 1.25,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (selected)
                              Expanded(
                                child: Text(
                                  context.l10n.ballotSelected.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: color,
                                    fontFamily: 'LilitaOne',
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            else
                              const Spacer(),
                            TextButton(
                              onPressed: onDossier,
                              style: TextButton.styleFrom(
                                foregroundColor: dossierInk,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(context.l10n.viewDossier),
                            ),
                          ],
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
}

class _IssueChoice extends StatelessWidget {
  const _IssueChoice({
    required this.problem,
    required this.cityName,
    required this.selected,
    required this.onTap,
  });

  final CityProblem problem;
  final String cityName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFD9E8DF) : const Color(0xFFF0E4CA),
    borderRadius: BorderRadius.circular(8),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: Key('ballot_issue_${problem.id}'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? ResiboColors.teal : const Color(0x665A4C38),
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? ResiboColors.teal : const Color(0xFF776E60),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.problemTitleText(problem),
                    style: const TextStyle(
                      color: dossierInk,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.problemDescriptionText(problem, cityName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF675946),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
