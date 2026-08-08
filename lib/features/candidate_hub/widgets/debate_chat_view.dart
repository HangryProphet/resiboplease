import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../domain/models/candidate_experience.dart';
import '../../../l10n/candidate_experience_localizations.dart';
import '../../dossier/widgets/dossier_ui.dart';
import '../../dossier/widgets/evidence_reader.dart';
import 'candidate_image_slot.dart';
import 'then_now_card.dart';

class DebateChatView extends StatefulWidget {
  const DebateChatView({
    required this.controller,
    required this.focusCandidate,
    required this.onOpenBiography,
    required this.onOpenPromise,
    required this.onOpenHistory,
    super.key,
  });

  final GameController controller;
  final Candidate focusCandidate;
  final ValueChanged<String> onOpenBiography;
  final void Function(String candidateId, String promiseId) onOpenPromise;
  final void Function(String candidateId, String historyId) onOpenHistory;

  @override
  State<DebateChatView> createState() => _DebateChatViewState();
}

class _DebateChatViewState extends State<DebateChatView> {
  var _topicIndex = 0;

  @override
  Widget build(BuildContext context) {
    final topics = widget.controller.candidateExperience.debateTopics;
    final topic = topics[_topicIndex.clamp(0, topics.length - 1)];
    return Column(
      key: const Key('debate_chat_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < topics.length; index++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: Key('debate_topic_${topics[index].id}'),
                    selected: index == _topicIndex,
                    label: Text(topics[index].title),
                    onSelected: (_) => setState(() => _topicIndex = index),
                  ),
                ),
            ],
          ),
        ),
        if (topic.issueFamilies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final problem
                  in widget.controller.scenario.city.problems.where(
                    (problem) => topic.issueFamilies.contains(problem.family),
                  ))
                Chip(
                  avatar: const Icon(Icons.location_city_rounded, size: 16),
                  label: Text(
                    '${context.candidateStrings.relatedCityIssue}: ${problem.title}',
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF172A3C),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFFFFD36B), width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.forum_rounded, color: Color(0xFFFFD36B)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  topic.title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFFF1D1),
                    fontFamily: 'LilitaOne',
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                '${topic.messages.length} messages',
                style: const TextStyle(color: Color(0xFFD5DFE4), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        for (final message in topic.messages) ...[
          DebateMessageBubble(
            controller: widget.controller,
            focusCandidate: widget.focusCandidate,
            message: message,
            onOpenBiography: widget.onOpenBiography,
            onOpenPromise: widget.onOpenPromise,
            onOpenHistory: widget.onOpenHistory,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class DebateMessageBubble extends StatelessWidget {
  const DebateMessageBubble({
    required this.controller,
    required this.focusCandidate,
    required this.message,
    required this.onOpenBiography,
    required this.onOpenPromise,
    required this.onOpenHistory,
    super.key,
  });

  final GameController controller;
  final Candidate focusCandidate;
  final DebateMessage message;
  final ValueChanged<String> onOpenBiography;
  final void Function(String candidateId, String promiseId) onOpenPromise;
  final void Function(String candidateId, String historyId) onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final speaker = controller.candidateByIdOrNull(message.speakerId);
    final system = speaker == null;
    final own = message.speakerId == focusCandidate.id;
    final color = speaker == null
        ? const Color(0xFF526170)
        : Color(speaker.colorValue);
    final strings = context.candidateStrings;
    final profile = speaker == null
        ? null
        : controller.candidateExperience.profileFor(speaker.id);
    return Align(
      alignment: system
          ? Alignment.center
          : own
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: system ? 720 : 620),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: own ? TextDirection.rtl : TextDirection.ltr,
          children: [
            if (!system) ...[
              SizedBox(
                width: 48,
                child: CandidateImageSlot(
                  candidateId: speaker.id,
                  assetKey: profile!.portraitAssetKey,
                  semanticLabel: speaker.name,
                  color: color,
                  aspectRatio: 1,
                  borderRadius: 24,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                key: Key('debate_message_${message.id}'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: system ? const Color(0xFFE4E1D8) : dossierPaper,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(own ? 12 : 3),
                    bottomRight: Radius.circular(own ? 3 : 12),
                  ),
                  border: Border.all(color: color, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x77000000), offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            key: speaker == null
                                ? null
                                : Key('debate_bio_${message.id}'),
                            onTap: speaker == null
                                ? null
                                : () => onOpenBiography(speaker.id),
                            child: Text(
                              speaker?.name ??
                                  (message.speakerId == 'moderator'
                                      ? strings.moderator
                                      : strings.recordDesk),
                              style: TextStyle(
                                color: color,
                                fontFamily: 'LilitaOne',
                                fontSize: 16,
                                decoration: speaker == null
                                    ? null
                                    : TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (profile != null)
                          Text(
                            strings.styleLabel(profile.rhetoricalStyle),
                            style: const TextStyle(
                              color: Color(0xFF6A6257),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.text,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: dossierInk,
                        fontSize: 15,
                        height: 1.42,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _ReactionChip(message.publicReaction),
                        for (final evidenceId in message.referencedEvidenceIds)
                          _DebateEvidenceChip(
                            controller: controller,
                            evidenceId: evidenceId,
                          ),
                        for (final evidenceId in message.contradictedByIds)
                          _DebateEvidenceChip(
                            controller: controller,
                            evidenceId: evidenceId,
                            label: strings.referencedRecord,
                            icon: Icons.fact_check_rounded,
                          ),
                        if (speaker != null)
                          for (final promiseId in message.relatedPromiseIds)
                            ActionChip(
                              key: Key(
                                'debate_promise_${message.id}_$promiseId',
                              ),
                              avatar: const Icon(
                                Icons.campaign_rounded,
                                size: 16,
                              ),
                              label: Text(strings.relatedPromise),
                              onPressed: () =>
                                  onOpenPromise(speaker.id, promiseId),
                            ),
                        if (speaker != null)
                          for (final historyId
                              in message.relatedHistoryEventIds)
                            ActionChip(
                              key: Key(
                                'debate_history_${message.id}_$historyId',
                              ),
                              avatar: const Icon(
                                Icons.history_rounded,
                                size: 16,
                              ),
                              label: Text(strings.viewHistory),
                              onPressed: () =>
                                  onOpenHistory(speaker.id, historyId),
                            ),
                        for (final relatedId in message.relatedMessageIds)
                          Chip(
                            key: Key('debate_related_${message.id}_$relatedId'),
                            avatar: const Icon(Icons.forum_rounded, size: 15),
                            label: Text(strings.relatedStatement),
                          ),
                        if (message.comparisonId != null)
                          ActionChip(
                            key: Key('debate_comparison_${message.id}'),
                            avatar: const Icon(
                              Icons.compare_arrows_rounded,
                              size: 16,
                            ),
                            label: Text(
                              '${strings.thenLabel} vs ${strings.nowLabel}',
                            ),
                            onPressed: () => _showComparison(context),
                          ),
                      ],
                    ),
                    if (message.bookmarkable) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 2,
                        children: [
                          IconButton(
                            key: Key('bookmark_debate_${message.id}'),
                            visualDensity: VisualDensity.compact,
                            tooltip: strings.bookmarkStatement,
                            onPressed: () =>
                                controller.toggleDebateBookmark(message.id),
                            icon: Icon(
                              controller.isDebateBookmarked(message.id)
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: ResiboColors.gold,
                            ),
                          ),
                          IconButton(
                            key: Key('pin_debate_${message.id}'),
                            visualDensity: VisualDensity.compact,
                            tooltip: strings.pinReceipt,
                            onPressed: () =>
                                controller.toggleDebatePin(message.id),
                            icon: Icon(
                              controller.isDebatePinned(message.id)
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                              color: ResiboColors.mutedRed,
                            ),
                          ),
                          IconButton(
                            key: Key('suspicious_debate_${message.id}'),
                            visualDensity: VisualDensity.compact,
                            tooltip: strings.suspicious,
                            onPressed: () =>
                                controller.toggleDebateSuspicious(message.id),
                            icon: Icon(
                              controller.isDebateSuspicious(message.id)
                                  ? Icons.flag_rounded
                                  : Icons.outlined_flag_rounded,
                              color: const Color(0xFF9D3B3B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showComparison(BuildContext context) async {
    final comparison = controller.candidateExperience.comparisonById(
      message.comparisonId!,
    );
    if (comparison == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ThenNowCard(
            comparison: comparison,
            onOpenEvidence: (id) async {
              Navigator.of(dialogContext).pop();
              await _openEvidenceById(context, controller, id);
            },
          ),
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip(this.reaction);
  final PublicReaction reaction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE7D7B5),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      '${context.candidateStrings.publicReaction}: ${context.candidateStrings.reactionLabel(reaction)}',
      style: const TextStyle(
        color: dossierInk,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _DebateEvidenceChip extends StatelessWidget {
  const _DebateEvidenceChip({
    required this.controller,
    required this.evidenceId,
    this.label,
    this.icon = Icons.receipt_long_rounded,
  });
  final GameController controller;
  final String evidenceId;
  final String? label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final evidence = controller.evidenceByIdOrNull(evidenceId);
    if (evidence == null) return const SizedBox.shrink();
    Candidate? owner;
    for (final candidate in controller.scenario.candidates) {
      if (candidate.evidence.any((item) => item.id == evidenceId)) {
        owner = candidate;
        break;
      }
    }
    if (owner == null) return const SizedBox.shrink();
    final cost = controller.evidenceInvestigationCost(evidenceId);
    if (label != null) {
      return ActionChip(
        key: Key('debate_evidence_$evidenceId'),
        avatar: Icon(icon, size: 16),
        label: Text(label!),
        onPressed: () => openEvidenceReader(
          context,
          controller: controller,
          candidate: owner!,
          item: evidence,
        ),
      );
    }
    return ActionChip(
      key: Key('debate_evidence_$evidenceId'),
      avatar: Icon(icon, size: 16),
      label: Text(
        '${evidence.type.label} • ${cost == 0 ? context.candidateStrings.free : context.candidateStrings.points(cost)}',
      ),
      onPressed: () => openEvidenceReader(
        context,
        controller: controller,
        candidate: owner!,
        item: evidence,
      ),
    );
  }
}

Future<void> _openEvidenceById(
  BuildContext context,
  GameController controller,
  String evidenceId,
) async {
  final evidence = controller.evidenceByIdOrNull(evidenceId);
  if (evidence == null) return;
  Candidate? owner;
  for (final candidate in controller.scenario.candidates) {
    if (candidate.evidence.any((item) => item.id == evidenceId)) {
      owner = candidate;
      break;
    }
  }
  if (owner == null || !context.mounted) return;
  await openEvidenceReader(
    context,
    controller: controller,
    candidate: owner,
    item: evidence,
  );
}
