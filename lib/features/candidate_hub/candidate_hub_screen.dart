import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/candidate_experience.dart';
import '../../l10n/candidate_experience_localizations.dart';
import '../dossier/widgets/dossier_ui.dart';
import 'widgets/campaign_feed_card.dart';
import 'widgets/candidate_biography_view.dart';
import 'widgets/candidate_image_slot.dart';
import 'widgets/candidate_promises_view.dart';
import 'widgets/debate_chat_view.dart';
import '../information/widgets/recent_candidate_coverage.dart';

enum CandidateHubSection { bio, promises, debate, records }

CandidateHubSection candidateHubSectionFromName(String? name) =>
    CandidateHubSection.values
        .where((section) => section.name == name)
        .firstOrNull ??
    CandidateHubSection.bio;

class CandidateHubScreen extends StatefulWidget {
  const CandidateHubScreen({
    required this.controller,
    required this.candidateId,
    this.initialSection = CandidateHubSection.bio,
    this.initialPromiseId,
    this.initialHistoryId,
    super.key,
  });

  final GameController controller;
  final String candidateId;
  final CandidateHubSection initialSection;
  final String? initialPromiseId;
  final String? initialHistoryId;

  @override
  State<CandidateHubScreen> createState() => _CandidateHubScreenState();
}

class _CandidateHubScreenState extends State<CandidateHubScreen> {
  late CandidateHubSection _section = widget.initialSection;
  late String? _highlightedPromiseId = widget.initialPromiseId;
  late String? _highlightedHistoryId = widget.initialHistoryId;
  final Set<String> _expandedPulseIds = {};

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final candidate = widget.controller.candidateByIdOrNull(
        widget.candidateId,
      );
      final profile = widget.controller.candidateExperience.profileFor(
        widget.candidateId,
      );
      if (candidate == null || profile == null) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B1725),
          body: Center(
            child: ChunkyActionButton(
              label: 'Return to candidates',
              icon: Icons.folder_copy_rounded,
              onPressed: () => context.go('/candidates'),
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        body: SafeArea(
          child: InvestigationBackdrop(
            showCity: true,
            child: Column(
              children: [
                InvestigationHeader(
                  title: context.candidateStrings.campaignHub,
                  subtitle: widget.controller.activeCityName,
                  onBack: () => context.go('/candidates'),
                  trailing: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GameIconButton(
                        tooltip: context.candidateStrings.receiptsBoard,
                        icon: Icons.receipt_long_rounded,
                        color: ResiboColors.mutedRed,
                        onPressed: () => context.push('/receipts'),
                      ),
                      if (widget.controller.receiptCount > 0)
                        Positioned(
                          right: -4,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD36B),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${widget.controller.receiptCount}',
                              style: const TextStyle(
                                color: dossierInk,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('candidate_hub_scroll'),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 38),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CandidateHeader(
                              controller: widget.controller,
                              candidate: candidate,
                              profile: profile,
                            ),
                            const SizedBox(height: 10),
                            RecentCandidateCoverage(
                              controller: widget.controller,
                              candidate: candidate,
                            ),
                            const SizedBox(height: 14),
                            CandidateSectionTabs(
                              selected: _section,
                              onSelected: (section) =>
                                  setState(() => _section = section),
                            ),
                            const SizedBox(height: 17),
                            switch (_section) {
                              CandidateHubSection.bio => CandidateBiographyView(
                                controller: widget.controller,
                                candidate: candidate,
                                biography: widget.controller.candidateExperience
                                    .biographyFor(candidate.id)!,
                                comparisons: widget
                                    .controller
                                    .candidateExperience
                                    .comparisonsFor(candidate.id),
                                highlightedHistoryId: _highlightedHistoryId,
                              ),
                              CandidateHubSection.promises =>
                                CandidatePromisesView(
                                  controller: widget.controller,
                                  candidate: candidate,
                                  promises: widget
                                      .controller
                                      .candidateExperience
                                      .promisesFor(candidate.id),
                                  comparisons: widget
                                      .controller
                                      .candidateExperience
                                      .comparisonsFor(candidate.id),
                                  highlightedPromiseId: _highlightedPromiseId,
                                  onOpenHistory: (id) => setState(() {
                                    _highlightedHistoryId = id;
                                    _section = CandidateHubSection.bio;
                                  }),
                                  campaignTrail: CandidatePulseFeed(
                                    controller: widget.controller,
                                    candidate: candidate,
                                    profile: profile,
                                    expandedIds: _expandedPulseIds,
                                    onToggle: (id) => setState(() {
                                      if (!_expandedPulseIds.remove(id)) {
                                        _expandedPulseIds.add(id);
                                      }
                                    }),
                                  ),
                                ),
                              CandidateHubSection.records =>
                                CandidateDossierView(
                                  controller: widget.controller,
                                  candidate: candidate,
                                  profile: profile,
                                ),
                              CandidateHubSection.debate => DebateChatView(
                                controller: widget.controller,
                                focusCandidate: candidate,
                                onOpenBiography: (candidateId) {
                                  if (candidateId == candidate.id) {
                                    setState(
                                      () => _section = CandidateHubSection.bio,
                                    );
                                  } else {
                                    context.go(
                                      '/candidates/$candidateId?section=bio',
                                    );
                                  }
                                },
                                onOpenPromise: (candidateId, promiseId) {
                                  if (candidateId == candidate.id) {
                                    setState(() {
                                      _highlightedPromiseId = promiseId;
                                      _section = CandidateHubSection.promises;
                                    });
                                  } else {
                                    context.go(
                                      '/candidates/$candidateId?section=promises&promise=$promiseId',
                                    );
                                  }
                                },
                                onOpenHistory: (candidateId, historyId) {
                                  if (candidateId == candidate.id) {
                                    setState(() {
                                      _highlightedHistoryId = historyId;
                                      _section = CandidateHubSection.bio;
                                    });
                                  } else {
                                    context.go(
                                      '/candidates/$candidateId?section=bio&history=$historyId',
                                    );
                                  }
                                },
                              ),
                            },
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

class CandidateHeader extends StatelessWidget {
  const CandidateHeader({
    required this.controller,
    required this.candidate,
    required this.profile,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final CandidateExperienceProfile profile;

  @override
  Widget build(BuildContext context) {
    final opened = candidate.evidence
        .where((item) => controller.isEvidenceViewed(item.id))
        .length;
    final remaining = controller.remainingInvestigationPoints;
    final color = Color(candidate.colorValue);
    return PaperPanel(
      padding: EdgeInsets.zero,
      borderWidth: 2.5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final portrait = SizedBox(
            width: narrow ? 118 : 155,
            child: CandidateImageSlot(
              candidateId: candidate.id,
              assetKey: profile.portraitAssetKey,
              semanticLabel: candidate.name,
              color: color,
              aspectRatio: 4 / 5,
              borderRadius: 0,
            ),
          );
          final information = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.name.toUpperCase(),
                            style: const TextStyle(
                              color: dossierInk,
                              fontFamily: 'LuckiestGuy',
                              fontSize: 28,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            candidate.party,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: Key('pin_candidate_${candidate.id}'),
                      tooltip: controller.isCandidatePinned(candidate.id)
                          ? context.candidateStrings.unpinCandidate
                          : context.candidateStrings.pinCandidate,
                      onPressed: () =>
                          controller.toggleCandidatePin(candidate.id),
                      icon: Icon(
                        controller.isCandidatePinned(candidate.id)
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        color: ResiboColors.mutedRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  profile.publicIdentity,
                  style: const TextStyle(
                    color: dossierInk,
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.position,
                  style: const TextStyle(color: Color(0xFF6A6257)),
                ),
                const SizedBox(height: 10),
                Text(
                  '“${candidate.slogan}”',
                  style: const TextStyle(
                    color: dossierInk,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InvestigationPill(
                      icon: Icons.folder_open_rounded,
                      label: '$opened / ${candidate.evidence.length} dossier',
                      color: ResiboColors.teal,
                    ),
                    InvestigationPill(
                      icon: remaining == null
                          ? Icons.all_inclusive_rounded
                          : Icons.hourglass_bottom_rounded,
                      label: remaining == null
                          ? context.candidateStrings.free
                          : context.candidateStrings.points(remaining),
                      color: ResiboColors.gold,
                    ),
                    InvestigationPill(
                      icon: Icons.record_voice_over_rounded,
                      label: context.candidateStrings.styleLabel(
                        profile.rhetoricalStyle,
                      ),
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
          );
          return narrow
              ? Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        portrait,
                        Expanded(child: information),
                      ],
                    ),
                    _QuestionsStrip(controller: controller, profile: profile),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        portrait,
                        Expanded(child: information),
                      ],
                    ),
                    _QuestionsStrip(controller: controller, profile: profile),
                  ],
                );
        },
      ),
    );
  }
}

class _QuestionsStrip extends StatelessWidget {
  const _QuestionsStrip({required this.controller, required this.profile});
  final GameController controller;
  final CandidateExperienceProfile profile;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: const BoxDecoration(
      color: Color(0xFFE9DFC7),
      border: Border(top: BorderSide(color: dossierInk, width: 2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          label: context.candidateStrings.unresolvedQuestions,
          icon: Icons.help_outline_rounded,
          color: ResiboColors.mutedRed,
        ),
        const SizedBox(height: 8),
        for (final question in profile.questions)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 17,
                    color: ResiboColors.mutedRed,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      question.text,
                      style: const TextStyle(
                        color: dossierInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: Key('pin_question_${question.id}'),
                  visualDensity: VisualDensity.compact,
                  tooltip: controller.isQuestionPinned(question.id)
                      ? context.candidateStrings.unpinReceipt
                      : context.candidateStrings.markQuestion,
                  onPressed: () => controller.toggleQuestionPin(question.id),
                  icon: Icon(
                    controller.isQuestionPinned(question.id)
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: ResiboColors.mutedRed,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class CandidateSectionTabs extends StatelessWidget {
  const CandidateSectionTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final CandidateHubSection selected;
  final ValueChanged<CandidateHubSection> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final section in CandidateHubSection.values)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: section == CandidateHubSection.records ? 0 : 7,
            ),
            child: _HubTab(
              section: section,
              selected: section == selected,
              onTap: () => onSelected(section),
            ),
          ),
        ),
    ],
  );
}

class _HubTab extends StatelessWidget {
  const _HubTab({
    required this.section,
    required this.selected,
    required this.onTap,
  });
  final CandidateHubSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (section) {
      CandidateHubSection.bio => (
        context.candidateStrings.bio,
        Icons.menu_book_rounded,
      ),
      CandidateHubSection.promises => (
        context.candidateStrings.promises,
        Icons.campaign_rounded,
      ),
      CandidateHubSection.debate => (
        context.candidateStrings.debate,
        Icons.forum_rounded,
      ),
      CandidateHubSection.records => (
        context.candidateStrings.records,
        Icons.folder_copy_rounded,
      ),
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('candidate_hub_${section.name}'),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? ResiboColors.mutedRed : const Color(0xFF23394C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF0B1725), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black87, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFFFF1D1), size: 18),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFF1D1),
                    fontFamily: 'LilitaOne',
                    fontSize: 15,
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

class CandidatePulseFeed extends StatelessWidget {
  const CandidatePulseFeed({
    required this.controller,
    required this.candidate,
    required this.profile,
    required this.expandedIds,
    required this.onToggle,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final CandidateExperienceProfile profile;
  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('candidate_pulse_feed'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionLabel(
        label: context.candidateStrings.campaignPulse,
        icon: Icons.dynamic_feed_rounded,
        color: ResiboColors.mutedRed,
      ),
      const SizedBox(height: 5),
      Text(
        context.candidateStrings.campaignPulseIntro,
        style: const TextStyle(color: Color(0xFFD5DFE4), height: 1.35),
      ),
      const SizedBox(height: 13),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 820 ? 2 : 1;
          const gap = 14.0;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: 15,
            children: [
              for (final item in profile.pulse)
                SizedBox(
                  width: width,
                  child: CampaignFeedCard(
                    controller: controller,
                    candidate: candidate,
                    item: item,
                    expanded: expandedIds.contains(item.id),
                    onToggleExpanded: () => onToggle(item.id),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class CandidateDossierView extends StatelessWidget {
  const CandidateDossierView({
    required this.controller,
    required this.candidate,
    required this.profile,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final CandidateExperienceProfile profile;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('candidate_dossier_view'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PaperPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionLabel(
              label: context.candidateStrings.dossier,
              icon: Icons.folder_copy_rounded,
              color: ResiboColors.teal,
            ),
            const SizedBox(height: 8),
            Text(
              context.candidateStrings.dossierIntro,
              style: const TextStyle(color: dossierInk, height: 1.4),
            ),
            const SizedBox(height: 13),
            ChunkyActionButton(
              buttonKey: const Key('open_full_dossier'),
              label: context.candidateStrings.openArchive,
              icon: Icons.inventory_2_rounded,
              color: ResiboColors.teal,
              onPressed: () =>
                  context.push('/candidates/${candidate.id}/dossier'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SectionLabel(
        label: context.candidateStrings.sourceRelations,
        icon: Icons.hub_rounded,
        color: ResiboColors.gold,
      ),
      const SizedBox(height: 9),
      for (final relation in profile.relations)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: PaperPanel(
            borderWidth: 1.5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.link_rounded, color: ResiboColors.gold),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.candidateStrings
                            .relationLabel(relation.type)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: dossierInk,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        relation.explanation,
                        style: const TextStyle(color: dossierInk, height: 1.35),
                      ),
                      if (relation.unlocksTarget)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            context.candidateStrings.unlockedFollowUp,
                            style: const TextStyle(
                              color: ResiboColors.teal,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
