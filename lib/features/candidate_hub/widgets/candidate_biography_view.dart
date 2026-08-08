import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../domain/models/candidate_biography.dart';
import '../../../l10n/candidate_experience_localizations.dart';
import '../../dossier/widgets/dossier_ui.dart';
import '../../dossier/widgets/evidence_reader.dart';
import 'candidate_image_slot.dart';
import 'then_now_card.dart';

class CandidateBiographyView extends StatelessWidget {
  const CandidateBiographyView({
    required this.controller,
    required this.candidate,
    required this.biography,
    required this.comparisons,
    this.highlightedHistoryId,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final CandidateBiography biography;
  final List<CandidateStatementComparison> comparisons;
  final String? highlightedHistoryId;

  Future<void> _openEvidence(BuildContext context, String evidenceId) async {
    final evidence = controller.evidenceByIdOrNull(evidenceId);
    if (evidence == null) return;
    await openEvidenceReader(
      context,
      controller: controller,
      candidate: candidate,
      item: evidence,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = controller.candidateExperience.profileFor(candidate.id)!;
    final highlighted = highlightedHistoryId == null
        ? null
        : biography.eventById(highlightedHistoryId!);
    return Column(
      key: const Key('candidate_biography_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF172A3C),
            border: Border.all(color: ResiboColors.gold, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                context.candidateStrings.civicArchive.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD36B),
                  fontFamily: 'LilitaOne',
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.candidateStrings.archiveIntro,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD5DFE4), height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final info = _BiographyInfobox(
              candidate: candidate,
              biography: biography,
              portraitAssetKey: profile.portraitAssetKey,
            );
            final lead = PaperPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(
                    label: context.candidateStrings.article,
                    icon: Icons.menu_book_rounded,
                    color: ResiboColors.mutedRed,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    candidate.name,
                    style: const TextStyle(
                      color: dossierInk,
                      fontFamily: 'LuckiestGuy',
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    biography.summary,
                    style: const TextStyle(
                      color: dossierInk,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    context.candidateStrings.citationsAreReceipts,
                    style: const TextStyle(
                      color: Color(0xFF6A6257),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
            if (constraints.maxWidth < 720) {
              return Column(children: [info, const SizedBox(height: 12), lead]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: lead),
                const SizedBox(width: 14),
                SizedBox(width: 285, child: info),
              ],
            );
          },
        ),
        if (highlighted != null) ...[
          const SizedBox(height: 14),
          _HistoryEventCard(
            event: highlighted,
            emphasized: true,
            onEvidence: (id) => _openEvidence(context, id),
          ),
        ],
        const SizedBox(height: 17),
        SectionLabel(
          label: context.candidateStrings.careerTimeline,
          icon: Icons.timeline_rounded,
          color: ResiboColors.teal,
        ),
        const SizedBox(height: 9),
        for (final event in biography.timeline) ...[
          _HistoryEventCard(
            event: event,
            emphasized: event.id == highlightedHistoryId,
            onEvidence: (id) => _openEvidence(context, id),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 10),
        for (final section in biography.sections) ...[
          PaperPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    color: dossierInk,
                    fontFamily: 'LilitaOne',
                    fontSize: 21,
                  ),
                ),
                const Divider(height: 18),
                for (final statement in section.statements)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          statement.text,
                          style: const TextStyle(
                            color: dossierInk,
                            height: 1.45,
                          ),
                        ),
                        for (var i = 0; i < statement.evidenceIds.length; i++)
                          TextButton(
                            key: Key(
                              'bio_citation_${statement.id}_${statement.evidenceIds[i]}',
                            ),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(28, 28),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                            ),
                            onPressed: () => _openEvidence(
                              context,
                              statement.evidenceIds[i],
                            ),
                            child: Text(
                              '[${candidate.evidence.indexWhere((e) => e.id == statement.evidenceIds[i]) + 1}]',
                              style: const TextStyle(
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
          const SizedBox(height: 12),
        ],
        for (final comparison in comparisons) ...[
          ThenNowCard(
            comparison: comparison,
            onOpenEvidence: (id) => _openEvidence(context, id),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BiographyInfobox extends StatelessWidget {
  const _BiographyInfobox({
    required this.candidate,
    required this.biography,
    required this.portraitAssetKey,
  });
  final Candidate candidate;
  final CandidateBiography biography;
  final String portraitAssetKey;
  @override
  Widget build(BuildContext context) => PaperPanel(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        CandidateImageSlot(
          candidateId: candidate.id,
          assetKey: portraitAssetKey,
          semanticLabel: candidate.name,
          color: Color(candidate.colorValue),
          aspectRatio: 4 / 3,
          borderRadius: 0,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _InfoRow(
                context.candidateStrings.born,
                '${biography.birthYear} (age ${biography.ageIn(2025)})',
              ),
              _InfoRow(
                context.candidateStrings.occupation,
                biography.occupation,
              ),
              _InfoRow(context.candidateStrings.party, candidate.party),
              _InfoRow(
                context.candidateStrings.currentPosition,
                biography.currentPosition,
              ),
              _InfoRow(context.candidateStrings.hometown, biography.hometown),
              _InfoRow(
                context.candidateStrings.education,
                biography.education.join('\n'),
              ),
              _InfoRow(
                context.candidateStrings.previousPositions,
                biography.previousPositions.join('\n'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6A6257),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: dossierInk,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}

class _HistoryEventCard extends StatelessWidget {
  const _HistoryEventCard({
    required this.event,
    required this.emphasized,
    required this.onEvidence,
  });
  final CandidateLifeEvent event;
  final bool emphasized;
  final ValueChanged<String> onEvidence;
  @override
  Widget build(BuildContext context) => Container(
    key: Key('history_event_${event.id}'),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: emphasized ? const Color(0xFFFFF0C7) : dossierPaper,
      border: Border.all(
        color: emphasized ? ResiboColors.mutedRed : const Color(0xFF756A58),
        width: emphasized ? 2.5 : 1.5,
      ),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF23394C),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '${event.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFF1D1),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: dossierInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                event.summary,
                style: const TextStyle(color: dossierInk, height: 1.35),
              ),
              if (emphasized) ...[
                const SizedBox(height: 6),
                Text(
                  event.details,
                  style: const TextStyle(
                    color: Color(0xFF6A6257),
                    height: 1.35,
                  ),
                ),
              ],
              if (event.evidenceIds.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: [
                    for (final id in event.evidenceIds)
                      TextButton.icon(
                        onPressed: () => onEvidence(id),
                        icon: const Icon(Icons.receipt_long_rounded, size: 15),
                        label: Text(context.candidateStrings.openCitation),
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
