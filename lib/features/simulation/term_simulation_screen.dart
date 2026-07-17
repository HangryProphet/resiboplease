import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../game/city_game.dart';

class TermSimulationScreen extends StatefulWidget {
  const TermSimulationScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<TermSimulationScreen> createState() => _TermSimulationScreenState();
}

class _TermSimulationScreenState extends State<TermSimulationScreen> {
  int _revealed = 1;

  @override
  Widget build(BuildContext context) {
    final result = widget.controller.termResult;
    if (result == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/vote'),
            child: const Text('Return to ballot'),
          ),
        ),
      );
    }
    var current = result.before;
    for (final phase in result.phases.take(_revealed)) {
      current = current.apply(phase.changes);
    }
    final finished = _revealed == result.phases.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('${result.candidate.name} • Term in progress'),
      ),
      body: ListView(
        children: [
          ContentShell(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 210,
                    child: GameWidget(game: BayhavenCityGame(current)),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Four phases, one administration',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Each entry records what happened and which rules shaped the outcome.',
                ),
                const SizedBox(height: 16),
                ...result.phases
                    .take(_revealed)
                    .map(
                      (phase) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PHASE ${phase.number}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                phase.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 9),
                              Text(phase.narrative),
                              const Divider(height: 24),
                              Text(
                                'Why: ${phase.explanation}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: phase.changes.entries.map((entry) {
                                  final value = entry.value;
                                  return Chip(
                                    label: Text(
                                      '${entry.key.label} ${value >= 0 ? '+' : ''}$value',
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('advance_term'),
                    onPressed: () {
                      if (finished) {
                        context.go('/report');
                      } else {
                        setState(() => _revealed++);
                      }
                    },
                    icon: Icon(
                      finished ? Icons.assessment_outlined : Icons.fast_forward,
                    ),
                    label: Text(
                      finished
                          ? 'Open term report'
                          : 'Advance to phase ${_revealed + 1}',
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
}
