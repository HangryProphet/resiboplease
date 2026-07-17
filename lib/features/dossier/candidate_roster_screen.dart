import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';

class CandidateRosterScreen extends StatelessWidget {
  const CandidateRosterScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Candidate roster')),
    body: ListView(
      children: [
        ContentShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Three folders. No perfect answer.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Compare claims, records, budgets, and contradictions. No candidate score or recommendation is shown.',
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 780;
                  final cards = controller.scenario.candidates.map(
                    (candidate) => Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: Key('candidate_${candidate.id}'),
                        onTap: () => context.go('/candidates/${candidate.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Color(
                                  candidate.colorValue,
                                ).withValues(alpha: .15),
                                backgroundImage: AssetImage(
                                  'assets/images/candidates/${candidate.id}/${candidate.id}_portrait.png',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                candidate.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(candidate.party),
                              const SizedBox(height: 12),
                              Text(
                                '“${candidate.slogan}”',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                candidate.archetype.toUpperCase(),
                                style: TextStyle(
                                  color: Color(candidate.colorValue),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8,
                                ),
                              ),
                              const Spacer(),
                              const Row(
                                children: [
                                  Text(
                                    'Open dossier',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  return wide
                      ? SizedBox(
                          height: 390,
                          child: Row(
                            children: cards
                                .map(
                                  (card) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: card,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      : Column(
                          children: cards
                              .map((card) => SizedBox(height: 330, child: card))
                              .toList(),
                        );
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/vote'),
                  icon: const Icon(Icons.how_to_vote_outlined),
                  label: const Text('Proceed to election day'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
