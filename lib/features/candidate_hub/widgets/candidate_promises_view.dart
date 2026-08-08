import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../domain/models/candidate_biography.dart';
import '../../../domain/models/city_problem.dart';
import '../../../l10n/candidate_experience_localizations.dart';
import '../../dossier/widgets/dossier_ui.dart';
import '../../dossier/widgets/evidence_reader.dart';
import 'then_now_card.dart';

class CandidatePromisesView extends StatelessWidget {
  const CandidatePromisesView({
    required this.controller,
    required this.candidate,
    required this.promises,
    required this.comparisons,
    required this.onOpenHistory,
    required this.campaignTrail,
    this.highlightedPromiseId,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final List<CandidatePromise> promises;
  final List<CandidateStatementComparison> comparisons;
  final ValueChanged<String> onOpenHistory;
  final Widget campaignTrail;
  final String? highlightedPromiseId;

  Future<void> _openEvidence(BuildContext context, String id) async {
    final item = controller.evidenceByIdOrNull(id);
    if (item == null) return;
    await openEvidenceReader(
      context,
      controller: controller,
      candidate: candidate,
      item: item,
    );
  }

  CityProblem? _activeProblem(CandidatePromise promise) {
    for (final problem in controller.scenario.city.problems) {
      if (promise.relatedIssueFamilies.contains(problem.family)) return problem;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('candidate_promises_view'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionLabel(
        label: context.candidateStrings.promises,
        icon: Icons.campaign_rounded,
        color: ResiboColors.mutedRed,
      ),
      const SizedBox(height: 5),
      Text(
        context.candidateStrings.isFilipino
            ? 'Basahin ang mismong pangako, paraan ng pagpapatupad, kaugnay na problema, at dating rekord.'
            : 'Read the candidate wording, proposed delivery, related city problem, and past record.',
        style: const TextStyle(color: Color(0xFFD5DFE4), height: 1.35),
      ),
      const SizedBox(height: 12),
      for (final promise in promises) ...[
        _PromiseCard(
          promise: promise,
          activeProblem: _activeProblem(promise),
          emphasized: promise.id == highlightedPromiseId,
          onEvidence: (id) => _openEvidence(context, id),
          onHistory: onOpenHistory,
        ),
        const SizedBox(height: 12),
        for (final comparison in comparisons.where(
          (item) => item.relatedPromiseId == promise.id,
        )) ...[
          ThenNowCard(
            comparison: comparison,
            onOpenEvidence: (id) => _openEvidence(context, id),
          ),
          const SizedBox(height: 12),
        ],
      ],
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF172A3C),
            border: Border.all(color: const Color(0xFF40596B), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: ExpansionTile(
              key: const Key('campaign_trail_expansion'),
              maintainState: true,
              iconColor: const Color(0xFFFFD36B),
              collapsedIconColor: const Color(0xFFFFD36B),
              title: Text(
                context.candidateStrings.campaignTrail.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFFFF1D1),
                  fontFamily: 'LilitaOne',
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                context.candidateStrings.campaignPulseIntro,
                style: const TextStyle(color: Color(0xFFD5DFE4), fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 5, 12, 14),
                  child: campaignTrail,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _PromiseCard extends StatelessWidget {
  const _PromiseCard({
    required this.promise,
    required this.activeProblem,
    required this.emphasized,
    required this.onEvidence,
    required this.onHistory,
  });
  final CandidatePromise promise;
  final CityProblem? activeProblem;
  final bool emphasized;
  final ValueChanged<String> onEvidence;
  final ValueChanged<String> onHistory;

  @override
  Widget build(BuildContext context) => PaperPanel(
    borderWidth: emphasized ? 3 : 2,
    child: Column(
      key: Key('promise_card_${promise.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.campaign_rounded, color: ResiboColors.mutedRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                promise.title,
                style: const TextStyle(
                  color: dossierInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 21,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0C7),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD6B66B)),
          ),
          child: Text(
            '“${promise.candidateWording}”',
            style: const TextStyle(
              color: dossierInk,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 11),
        _LabeledText(
          label: context.candidateStrings.proposedApproach,
          text: promise.approach,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            InvestigationPill(
              icon: Icons.account_tree_rounded,
              label: context.candidateStrings.complexityLabel(
                promise.complexity,
              ),
              color: ResiboColors.gold,
            ),
            for (final family in promise.relatedIssueFamilies)
              InvestigationPill(
                icon: Icons.location_city_rounded,
                label: context.candidateStrings.issueFamilyLabel(family),
                color: ResiboColors.teal,
              ),
          ],
        ),
        if (activeProblem != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0ECEA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.candidateStrings.relatedCityIssue.toUpperCase(),
                  style: const TextStyle(
                    color: ResiboColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${activeProblem!.title} · ${activeProblem!.severity}% severity',
                  style: const TextStyle(
                    color: dossierInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final evidenceId in promise.evidenceIds)
              ActionChip(
                key: Key('promise_evidence_${promise.id}_$evidenceId'),
                avatar: const Icon(Icons.receipt_long_rounded, size: 15),
                label: Text(context.candidateStrings.openEvidence),
                onPressed: () => onEvidence(evidenceId),
              ),
            for (final eventId in promise.relatedHistoryEventIds)
              ActionChip(
                key: Key('promise_history_${promise.id}_$eventId'),
                avatar: const Icon(Icons.history_rounded, size: 15),
                label: Text(context.candidateStrings.viewHistory),
                onPressed: () => onHistory(eventId),
              ),
          ],
        ),
      ],
    ),
  );
}

class _LabeledText extends StatelessWidget {
  const _LabeledText({required this.label, required this.text});
  final String label;
  final String text;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6A6257),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Text(text, style: const TextStyle(color: dossierInk, height: 1.4)),
    ],
  );
}
