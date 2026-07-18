import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/game_content_localizations.dart';

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
      appBar: AppBar(title: Text(context.l10n.electionDay)),
      body: ListView(
        children: [
          ContentShell(
            maxWidth: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.electionDayHeading,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.evidenceOpenedCount(
                    widget.controller.viewedEvidenceCount,
                    scenario.candidates.fold<int>(
                      0,
                      (sum, candidate) => sum + candidate.evidence.length,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...scenario.candidates.map((candidate) {
                  final selected = _candidateId == candidate.id;
                  return Card(
                    color: selected
                        ? Color(candidate.colorValue).withValues(alpha: .12)
                        : null,
                    child: InkWell(
                      key: Key('ballot_${candidate.id}'),
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _candidateId = candidate.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected
                                  ? Color(candidate.colorValue)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    candidate.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${context.l10n.candidatePartyText(candidate, scenario.city.name)} • “${context.l10n.candidateSloganText(candidate, scenario.city.name)}”',
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.go('/candidates/${candidate.id}'),
                              child: Text(context.l10n.dossier.toUpperCase()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: context.l10n.topIssueQuestion,
                    border: const OutlineInputBorder(),
                  ),
                  items: scenario.city.problems
                      .map(
                        (problem) => DropdownMenuItem(
                          value: problem.id,
                          child: Text(context.l10n.problemTitleText(problem)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _topIssue = value),
                ),
                const SizedBox(height: 22),
                Text(
                  context.l10n.confidenceValue((_confidence * 100).round()),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Slider(
                  value: _confidence,
                  divisions: 10,
                  label: '${(_confidence * 100).round()}%',
                  onChanged: (value) => setState(() => _confidence = value),
                ),
                Card(
                  color: const Color(0xFFFFF3D0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: ResiboColors.navy,
                    ),
                    title: Text(context.l10n.selectedCandidateEffectTitle),
                    subtitle: Text(context.l10n.selectedCandidateEffectBody),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('cast_vote'),
                    onPressed: _candidateId == null || _topIssue == null
                        ? null
                        : _confirmVote,
                    icon: const Icon(Icons.how_to_vote),
                    label: Text(context.l10n.castVote),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmVote() async {
    final candidate = widget.controller.candidateById(_candidateId!);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.sealBallotQuestion),
        content: Text(context.l10n.sealBallotBody(candidate.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.keepReviewing),
          ),
          FilledButton(
            key: const Key('confirm_vote'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.confirmVote),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.controller.castVote(
      candidate: candidate,
      topIssue: _topIssue!,
      confidence: _confidence,
    );
    context.go('/simulation');
  }
}
