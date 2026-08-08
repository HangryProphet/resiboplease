import 'package:flutter/material.dart';

import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../l10n/candidate_experience_localizations.dart';
import '../../dossier/widgets/dossier_ui.dart';
import 'candidate_image_slot.dart';

Future<void> showCandidateComparisonSheet(
  BuildContext context, {
  required GameController controller,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CandidateComparisonSheet(controller: controller),
);

class CandidateComparisonSheet extends StatefulWidget {
  const CandidateComparisonSheet({required this.controller, super.key});

  final GameController controller;

  @override
  State<CandidateComparisonSheet> createState() =>
      _CandidateComparisonSheetState();
}

class _CandidateComparisonSheetState extends State<CandidateComparisonSheet> {
  late final List<String> _selectedIds = _initialSelection();

  List<String> _initialSelection() {
    final available = widget.controller.scenario.candidates
        .map((candidate) => candidate.id)
        .toList(growable: false);
    final selected = widget.controller.pinnedCandidateIds
        .where(available.contains)
        .take(2)
        .toList();
    for (final id in available) {
      if (selected.length == 2) break;
      if (!selected.contains(id)) selected.add(id);
    }
    return selected;
  }

  void _selectCandidate(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        if (_selectedIds.length > 1) _selectedIds.remove(id);
        return;
      }
      if (_selectedIds.length == 2) _selectedIds.removeAt(0);
      _selectedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .88,
    child: Container(
      decoration: const BoxDecoration(
        color: Color(0xFF102235),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(top: BorderSide(color: Color(0xFFFFD36B), width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.candidateStrings.compareCandidates
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFFF1D1),
                            fontFamily: 'LuckiestGuy',
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          context.candidateStrings.comparisonReminder,
                          style: const TextStyle(
                            color: Color(0xFFD5DFE4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFFFF1D1),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  for (final candidate in widget.controller.scenario.candidates)
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: FilterChip(
                        key: Key('compare_candidate_${candidate.id}'),
                        selected: _selectedIds.contains(candidate.id),
                        label: Text(candidate.name),
                        onSelected: (_) => _selectCandidate(candidate.id),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 850
                      ? 3
                      : constraints.maxWidth >= 570
                      ? 2
                      : 1;
                  const gap = 12.0;
                  final width =
                      (constraints.maxWidth - 28 - gap * (columns - 1)) /
                      columns;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final candidate
                            in widget.controller.scenario.candidates.where(
                              (candidate) =>
                                  _selectedIds.contains(candidate.id),
                            ))
                          SizedBox(
                            width: width,
                            child: _ComparisonCard(
                              controller: widget.controller,
                              candidate: candidate,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.controller, required this.candidate});
  final GameController controller;
  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final profile = controller.candidateExperience.profileFor(candidate.id)!;
    final opened = candidate.evidence
        .where((item) => controller.isEvidenceViewed(item.id))
        .length;
    final bookmarked = candidate.evidence
        .where((item) => controller.isBookmarked(item.id))
        .length;
    final color = Color(candidate.colorValue);
    return PaperPanel(
      borderWidth: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: CandidateImageSlot(
                  candidateId: candidate.id,
                  assetKey: profile.portraitAssetKey,
                  semanticLabel: candidate.name,
                  color: color,
                  aspectRatio: 4 / 5,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name.toUpperCase(),
                      style: const TextStyle(
                        color: dossierInk,
                        fontFamily: 'LilitaOne',
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      profile.publicIdentity,
                      style: const TextStyle(color: dossierInk, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$opened / ${candidate.evidence.length} opened • $bookmarked bookmarked',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'DOCUMENTED STRENGTHS',
            style: TextStyle(
              color: dossierInk,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          for (final item in candidate.visibleStrengths)
            Text(
              '• $item',
              style: const TextStyle(color: dossierInk, height: 1.35),
            ),
          const SizedBox(height: 9),
          const Text(
            'QUESTIONS TO INVESTIGATE',
            style: TextStyle(
              color: dossierInk,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          for (final item in candidate.visibleConcerns)
            Text(
              '• $item',
              style: const TextStyle(color: dossierInk, height: 1.35),
            ),
        ],
      ),
    );
  }
}
