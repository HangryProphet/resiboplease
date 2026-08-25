import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/evidence_item.dart';
import '../../l10n/candidate_experience_localizations.dart';
import '../dossier/widgets/dossier_ui.dart';
import '../dossier/widgets/evidence_reader.dart';
import '../information/widgets/information_actions.dart';
import 'widgets/candidate_comparison_sheet.dart';

class ReceiptsBoardScreen extends StatefulWidget {
  const ReceiptsBoardScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<ReceiptsBoardScreen> createState() => _ReceiptsBoardScreenState();
}

class _ReceiptsBoardScreenState extends State<ReceiptsBoardScreen> {
  String? _issueFilter;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final items = _buildItems(context, widget.controller)
          .where(
            (item) => _issueFilter == null || item.cityIssueId == _issueFilter,
          )
          .toList(growable: false);
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        body: SafeArea(
          child: InvestigationBackdrop(
            showCity: true,
            child: Column(
              children: [
                InvestigationHeader(
                  title: context.candidateStrings.receiptsBoard,
                  subtitle: widget.controller.activeCityName,
                  onBack: () => context.pop(),
                  trailing: GameIconButton(
                    tooltip: context.candidateStrings.compareCandidates,
                    icon: Icons.compare_arrows_rounded,
                    color: ResiboColors.teal,
                    onPressed: () => showCandidateComparisonSheet(
                      context,
                      controller: widget.controller,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('receipts_board_scroll'),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 36),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1050),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PaperPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionLabel(
                                    label:
                                        context.candidateStrings.receiptsBoard,
                                    icon: Icons.receipt_long_rounded,
                                    color: ResiboColors.mutedRed,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.candidateStrings.noScoreReminder,
                                    style: const TextStyle(
                                      color: dossierInk,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 11),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ChoiceChip(
                                          label: Text(
                                            context.candidateStrings.allIssues,
                                          ),
                                          selected: _issueFilter == null,
                                          onSelected: (_) => setState(
                                            () => _issueFilter = null,
                                          ),
                                        ),
                                        for (final problem
                                            in widget
                                                .controller
                                                .scenario
                                                .city
                                                .problems)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 7,
                                            ),
                                            child: ChoiceChip(
                                              label: Text(problem.title),
                                              selected:
                                                  _issueFilter == problem.id,
                                              onSelected: (_) => setState(
                                                () => _issueFilter = problem.id,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (items.isEmpty)
                              PaperPanel(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.push_pin_outlined,
                                        size: 52,
                                        color: Color(0xFF8D7956),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        context.candidateStrings.noReceipts,
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
                                  final columns = constraints.maxWidth >= 760
                                      ? 2
                                      : 1;
                                  const gap = 12.0;
                                  final width =
                                      (constraints.maxWidth -
                                          gap * (columns - 1)) /
                                      columns;
                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: 13,
                                    children: [
                                      for (final item in items)
                                        SizedBox(
                                          width: width,
                                          child: _ReceiptCard(
                                            controller: widget.controller,
                                            item: item,
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
    },
  );
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.controller, required this.item});

  final GameController controller;
  final _BoardItem item;

  @override
  Widget build(BuildContext context) => PaperPanel(
    borderWidth: 2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: dossierInk, width: 2),
              ),
              child: Icon(item.icon, color: const Color(0xFFFFF1D1)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      color: item.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: dossierInk,
                      fontFamily: 'LilitaOne',
                      fontSize: 18,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.candidateStrings.unpinReceipt,
              onPressed: item.onRemove,
              icon: const Icon(
                Icons.close_rounded,
                color: ResiboColors.mutedRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          item.summary,
          style: const TextStyle(color: dossierInk, height: 1.4),
        ),
        if (item.connections.isNotEmpty) ...[
          const SizedBox(height: 11),
          for (final connection in item.connections)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 17,
                    color: ResiboColors.teal,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      connection,
                      style: const TextStyle(color: dossierInk, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (controller.receiptNote(item.id).isNotEmpty) ...[
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3C9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF9B7623)),
            ),
            child: Text(
              controller.receiptNote(item.id),
              style: const TextStyle(
                color: dossierInk,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 7,
          runSpacing: 7,
          children: [
            InformationActionButton(
              onPressed: () => _editNote(context),
              icon: Icons.edit_note_rounded,
              color: const Color(0xFF5E6470),
              label: context.candidateStrings.privateNote,
            ),
            if (item.onOpen != null)
              InformationActionButton(
                onPressed: item.onOpen,
                icon: Icons.open_in_new_rounded,
                color: ResiboColors.teal,
                label: context.candidateStrings.openDetails,
              ),
          ],
        ),
      ],
    ),
  );

  Future<void> _editNote(BuildContext context) async {
    final textController = TextEditingController(
      text: controller.receiptNote(item.id),
    );
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: PaperPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(
                  label: context.candidateStrings.privateNote,
                  icon: Icons.edit_note_rounded,
                  color: ResiboColors.teal,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('receipt_note_field'),
                  controller: textController,
                  maxLength: 180,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: context.candidateStrings.addNote,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChunkyActionButton(
                        label: context.candidateStrings.cancel,
                        compact: true,
                        color: const Color(0xFF5E6470),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChunkyActionButton(
                        key: const Key('save_receipt_note'),
                        label: context.candidateStrings.saveNote,
                        compact: true,
                        onPressed: () => Navigator.pop(context, true),
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
    if (save == true) controller.setReceiptNote(item.id, textController.text);
    textController.dispose();
  }
}

class _BoardItem {
  const _BoardItem({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.cityIssueId,
    required this.color,
    required this.icon,
    required this.connections,
    required this.onRemove,
    this.onOpen,
  });

  final String id;
  final String category;
  final String title;
  final String summary;
  final String cityIssueId;
  final Color color;
  final IconData icon;
  final List<String> connections;
  final VoidCallback onRemove;
  final VoidCallback? onOpen;
}

List<_BoardItem> _buildItems(BuildContext context, GameController controller) {
  final items = <_BoardItem>[];
  for (final questionId in controller.pinnedQuestionIds) {
    final question = controller.candidateExperience.questionById(questionId);
    if (question == null) continue;
    Candidate? owner;
    for (final candidate in controller.scenario.candidates) {
      final profile = controller.candidateExperience.profileFor(candidate.id);
      if (profile?.questions.any((item) => item.id == questionId) ?? false) {
        owner = candidate;
        break;
      }
    }
    if (owner == null) continue;
    items.add(
      _BoardItem(
        id: 'question:$questionId',
        category: '${owner.name} · ${context.candidateStrings.openQuestion}',
        title: question.text,
        summary: context.candidateStrings.questionReceiptSummary,
        cityIssueId: question.cityIssueId,
        color: Color(owner.colorValue),
        icon: Icons.help_outline_rounded,
        connections: question.relatedEvidenceIds
            .map((id) => controller.evidenceByIdOrNull(id)?.title ?? id)
            .toList(),
        onRemove: () => controller.toggleQuestionPin(questionId),
      ),
    );
  }
  for (final contentId in controller.pinnedContentIds) {
    final content = controller.candidateExperience.contentById(contentId);
    if (content == null) continue;
    final candidate = controller.candidateByIdOrNull(content.candidateId);
    items.add(
      _BoardItem(
        id: 'content:$contentId',
        category: candidate?.name ?? 'Pulse',
        title: content.headline,
        summary: content.summary,
        cityIssueId: content.cityIssueId,
        color: candidate == null
            ? ResiboColors.mutedRed
            : Color(candidate.colorValue),
        icon: Icons.dynamic_feed_rounded,
        connections: content.relatedEvidenceIds
            .map((id) => controller.evidenceByIdOrNull(id)?.title ?? id)
            .toList(),
        onRemove: () => controller.toggleContentPin(contentId),
      ),
    );
  }
  for (final messageId in controller.pinnedDebateMessageIds) {
    final message = controller.candidateExperience.debateMessageById(messageId);
    if (message == null) continue;
    final candidate = controller.candidateByIdOrNull(message.speakerId);
    final topic = controller.candidateExperience.debateTopics.firstWhere(
      (item) => item.id == message.topicId,
    );
    items.add(
      _BoardItem(
        id: 'debate:$messageId',
        category: candidate?.name ?? 'Debate',
        title: topic.title,
        summary: message.text,
        cityIssueId: topic.cityProblemId,
        color: candidate == null
            ? const Color(0xFF526170)
            : Color(candidate.colorValue),
        icon: Icons.forum_rounded,
        connections: message.referencedEvidenceIds
            .map((id) => controller.evidenceByIdOrNull(id)?.title ?? id)
            .toList(),
        onRemove: () => controller.toggleDebatePin(messageId),
      ),
    );
  }
  for (final evidenceId in controller.bookmarkedEvidenceIds) {
    final evidence = controller.evidenceByIdOrNull(evidenceId);
    if (evidence == null) continue;
    Candidate? owner;
    for (final candidate in controller.scenario.candidates) {
      if (candidate.evidence.any((item) => item.id == evidenceId)) {
        owner = candidate;
        break;
      }
    }
    if (owner == null) continue;
    final profile = controller.candidateExperience.profileFor(owner.id)!;
    final relatedContent = profile.pulse
        .where((item) => item.relatedEvidenceIds.contains(evidenceId))
        .toList();
    final issue = relatedContent.isEmpty
        ? 'general'
        : relatedContent.first.cityIssueId;
    final relations = profile.relations
        .where(
          (relation) =>
              relation.fromEvidenceId == evidenceId ||
              relation.toEvidenceId == evidenceId,
        )
        .map((relation) => relation.explanation)
        .toList();
    items.add(
      _BoardItem(
        id: 'evidence:$evidenceId',
        category: owner.name,
        title: evidence.title,
        summary: evidence.summary,
        cityIssueId: issue,
        color: Color(owner.colorValue),
        icon: _evidenceIcon(evidence.type),
        connections: relations,
        onRemove: () => controller.toggleBookmark(evidenceId),
        onOpen: () => openEvidenceReader(
          context,
          controller: controller,
          candidate: owner!,
          item: evidence,
        ),
      ),
    );
  }
  return items;
}

IconData _evidenceIcon(EvidenceType type) => switch (type) {
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
