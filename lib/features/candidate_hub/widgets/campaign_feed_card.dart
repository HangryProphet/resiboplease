import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../domain/models/candidate_experience.dart';
import '../../../l10n/candidate_experience_localizations.dart';
import '../../dossier/widgets/dossier_ui.dart';
import '../../dossier/widgets/evidence_reader.dart';
import 'evidence_media_slot.dart';

class CampaignFeedCard extends StatelessWidget {
  const CampaignFeedCard({
    required this.controller,
    required this.candidate,
    required this.item,
    required this.expanded,
    required this.onToggleExpanded,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final CandidateContentItem item;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final color = Color(candidate.colorValue);
    final strings = context.candidateStrings;
    return Container(
      key: Key('pulse_${item.id}'),
      decoration: BoxDecoration(
        color: dossierPaper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: dossierInk, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), offset: Offset(0, 5)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(13, 9, 10, 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.lerp(color, Colors.white, .12)!, color],
              ),
              border: const Border(
                bottom: BorderSide(color: dossierInk, width: 2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _contentIcon(item.type),
                  color: const Color(0xFFFFF1D1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _contentLabel(item.type).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFF1D1),
                      fontFamily: 'LilitaOne',
                      letterSpacing: .7,
                    ),
                  ),
                ),
                IconButton(
                  key: Key('pin_content_${item.id}'),
                  visualDensity: VisualDensity.compact,
                  tooltip: controller.isContentPinned(item.id)
                      ? strings.unpinReceipt
                      : strings.pinReceipt,
                  onPressed: () => controller.toggleContentPin(item.id),
                  icon: Icon(
                    controller.isContentPinned(item.id)
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: const Color(0xFFFFE29A),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.media != null) ...[
                  EvidenceMediaSlot(media: item.media!, color: color),
                  const SizedBox(height: 13),
                ],
                Text(
                  item.headline,
                  style: const TextStyle(
                    color: dossierInk,
                    fontFamily: 'LuckiestGuy',
                    fontSize: 22,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.summary,
                  style: const TextStyle(
                    color: dossierInk,
                    fontSize: 15,
                    height: 1.38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _MetaChip(
                      icon: Icons.apartment_rounded,
                      label: item.source,
                    ),
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: item.fictionalDate,
                    ),
                    if (item.publicAttention > 0)
                      _MetaChip(
                        icon: Icons.campaign_rounded,
                        label:
                            '${strings.publicAttention}: ${_attentionLabel(item.publicAttention)}',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ChunkyActionButton(
                  key: Key('inspect_content_${item.id}'),
                  onPressed: onToggleExpanded,
                  compact: true,
                  color: ResiboColors.navy,
                  icon: expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  label: expanded ? strings.closeDetails : strings.openDetails,
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: _InspectLayer(
                      controller: controller,
                      candidate: candidate,
                      item: item,
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

  String _attentionLabel(int attention) => switch (attention) {
    >= 85 => 'Very high',
    >= 65 => 'High',
    >= 45 => 'Moderate',
    _ => 'Low',
  };
}

class _InspectLayer extends StatelessWidget {
  const _InspectLayer({
    required this.controller,
    required this.candidate,
    required this.item,
  });

  final GameController controller;
  final Candidate candidate;
  final CandidateContentItem item;

  @override
  Widget build(BuildContext context) {
    final strings = context.candidateStrings;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFE9DFC7),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF9D8B67)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.inspectBody,
            style: const TextStyle(color: dossierInk, height: 1.48),
          ),
          if (item.keyFigures.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DetailBlock(
              icon: Icons.numbers_rounded,
              title: strings.keyFigures,
              text: item.keyFigures.join(' • '),
            ),
          ],
          if (item.candidateResponse != null) ...[
            const SizedBox(height: 9),
            _DetailBlock(
              icon: Icons.record_voice_over_rounded,
              title: strings.candidateResponse,
              text: item.candidateResponse!,
            ),
          ],
          if (item.missingContext != null) ...[
            const SizedBox(height: 9),
            _DetailBlock(
              icon: Icons.help_outline_rounded,
              title: strings.missingContext,
              text: item.missingContext!,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            item.deepDivePrompt,
            style: const TextStyle(
              color: dossierInk,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final evidenceId in item.relatedEvidenceIds)
                _EvidenceButton(
                  controller: controller,
                  candidate: candidate,
                  contentId: item.id,
                  evidenceId: evidenceId,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceButton extends StatelessWidget {
  const _EvidenceButton({
    required this.controller,
    required this.candidate,
    required this.contentId,
    required this.evidenceId,
  });

  final GameController controller;
  final Candidate candidate;
  final String contentId;
  final String evidenceId;

  @override
  Widget build(BuildContext context) {
    final evidence = candidate.evidence
        .where((item) => item.id == evidenceId)
        .firstOrNull;
    if (evidence == null) return const SizedBox.shrink();
    final cost = controller.evidenceInvestigationCost(evidenceId);
    final strings = context.candidateStrings;
    return ActionChip(
      key: Key('pulse_evidence_${contentId}_$evidenceId'),
      avatar: Icon(
        controller.isEvidenceViewed(evidenceId)
            ? Icons.check_circle_rounded
            : Icons.receipt_long_rounded,
        size: 18,
        color: ResiboColors.teal,
      ),
      label: Text(
        '${context.candidateStrings.deepDive}: ${evidence.type.label} • ${cost == 0 ? strings.free : strings.points(cost)}',
      ),
      onPressed: () => openEvidenceReader(
        context,
        controller: controller,
        candidate: candidate,
        item: evidence,
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: ResiboColors.mutedRed),
      const SizedBox(width: 7),
      Expanded(
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: dossierInk, height: 1.35),
            children: [
              TextSpan(
                text: '$title: ',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              TextSpan(text: text),
            ],
          ),
        ),
      ),
    ],
  );
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4D8),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF8D7956)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF5E594F)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: dossierInk),
          ),
        ),
      ],
    ),
  );
}

String _contentLabel(CandidateContentType type) => switch (type) {
  CandidateContentType.campaignAd => 'Campaign ad',
  CandidateContentType.news => 'News',
  CandidateContentType.speech => 'Speech',
  CandidateContentType.socialPost => 'Social post',
  CandidateContentType.poll => 'Poll',
  CandidateContentType.endorsement => 'Endorsement',
  CandidateContentType.residentReaction => 'Resident voice',
  CandidateContentType.protestReaction => 'Protest reaction',
  CandidateContentType.scandal => 'Developing story',
  CandidateContentType.correction => 'Correction',
  CandidateContentType.factCheckAlert => 'Fact-check alert',
  CandidateContentType.meme => 'Campaign meme',
  CandidateContentType.publicEvent => 'Public event',
  CandidateContentType.statement => 'Statement',
};

IconData _contentIcon(CandidateContentType type) => switch (type) {
  CandidateContentType.campaignAd => Icons.campaign_rounded,
  CandidateContentType.news => Icons.newspaper_rounded,
  CandidateContentType.speech => Icons.mic_rounded,
  CandidateContentType.socialPost => Icons.forum_rounded,
  CandidateContentType.poll => Icons.poll_rounded,
  CandidateContentType.endorsement => Icons.handshake_rounded,
  CandidateContentType.residentReaction => Icons.groups_rounded,
  CandidateContentType.protestReaction => Icons.sign_language_rounded,
  CandidateContentType.scandal => Icons.warning_amber_rounded,
  CandidateContentType.correction => Icons.edit_note_rounded,
  CandidateContentType.factCheckAlert => Icons.fact_check_rounded,
  CandidateContentType.meme => Icons.emoji_emotions_rounded,
  CandidateContentType.publicEvent => Icons.event_rounded,
  CandidateContentType.statement => Icons.record_voice_over_rounded,
};
