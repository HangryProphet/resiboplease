import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';

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
      appBar: AppBar(title: const Text('Election day')),
      body: ListView(
        children: [
          ContentShell(
            maxWidth: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cast your Bayhaven ballot',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.controller.viewedEvidenceCount} of ${scenario.candidates.fold<int>(0, (sum, candidate) => sum + candidate.evidence.length)} evidence items opened. Investigation completeness is context, not a score.',
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
                                    '${candidate.party} • “${candidate.slogan}”',
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.go('/candidates/${candidate.id}'),
                              child: const Text('DOSSIER'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Which city issue mattered most?',
                    border: OutlineInputBorder(),
                  ),
                  items: scenario.city.problems
                      .map(
                        (problem) => DropdownMenuItem(
                          value: problem.id,
                          child: Text(problem.title),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _topIssue = value),
                ),
                const SizedBox(height: 22),
                Text(
                  'Confidence: ${(_confidence * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Slider(
                  value: _confidence,
                  divisions: 10,
                  label: '${(_confidence * 100).round()}%',
                  onChanged: (value) => setState(() => _confidence = value),
                ),
                const Card(
                  color: Color(0xFFFFF3D0),
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: ResiboColors.navy),
                    title: Text(
                      'Your selected candidate becomes the administration in this simulation.',
                    ),
                    subtitle: Text(
                      'The report explains consequences; it will not label your vote right or wrong.',
                    ),
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
                    label: const Text('Cast vote'),
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
        title: const Text('Seal this ballot?'),
        content: Text(
          'You are choosing ${candidate.name}. The seeded four-phase term will begin immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep reviewing'),
          ),
          FilledButton(
            key: const Key('confirm_vote'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm vote'),
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
