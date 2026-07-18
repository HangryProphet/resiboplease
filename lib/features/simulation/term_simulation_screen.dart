import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../game/city_game.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/game_content_localizations.dart';

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
            child: Text(context.l10n.returnToBallot),
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
        title: Text(
          '${result.candidate.name} • ${context.l10n.termInProgress}',
        ),
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
                  context.l10n.termSimulationHeading,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(context.l10n.termSimulationIntro),
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
                                context.l10n
                                    .phaseNumber(phase.number)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                context.l10n.phaseTitleText(phase),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 9),
                              Text(
                                context.l10n.phaseNarrativeText(
                                  phase,
                                  result.candidate,
                                ),
                              ),
                              const Divider(height: 24),
                              Text(
                                '${context.l10n.whyThisHappened}: ${context.l10n.phaseExplanationText(phase)}',
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
                                      context.l10n.changeValue(
                                        context.l10n.indicatorLabel(entry.key),
                                        '${value >= 0 ? '+' : ''}$value',
                                      ),
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
                          ? context.l10n.viewTermReport
                          : context.l10n.advanceToPhase(_revealed + 1),
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
