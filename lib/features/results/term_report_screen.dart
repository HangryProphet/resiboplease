import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../core/widgets/indicator_card.dart';
import '../../domain/models/city_indicator.dart';

class TermReportScreen extends StatelessWidget {
  const TermReportScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.termResult;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Bayhaven term report')),
      body: ListView(
        children: [
          ContentShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ResiboColors.navy,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ADMINISTRATION RECEIPT',
                        style: TextStyle(
                          color: ResiboColors.gold,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.candidate.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.summary,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'What changed',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Labels show final condition. Signed values show movement during the term; corruption pressure is healthier when it falls.',
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850
                        ? 3
                        : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                    return GridView.count(
                      crossAxisCount: columns,
                      childAspectRatio: columns == 1 ? 3.1 : 2.15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final indicator in CityIndicator.values)
                          IndicatorCard(
                            indicator: indicator,
                            value: result.after.valueOf(indicator),
                            change: result.totalChanges[indicator],
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'How the engine reached this result',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The deterministic model combined Bayhaven’s issue severity and urgency with the administration’s relevant policy skill, implementation, crisis response, integrity, coalition support, budget feasibility, and a logged ±10% seeded variation. Hidden scores were not used as pre-election hints.',
                ),
                const SizedBox(height: 18),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.psychology_alt_outlined),
                    title: const Text(
                      'Your decision context',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'Top issue: ${controller.topIssue?.replaceAll('_', ' ') ?? 'Not recorded'} • Confidence: ${(controller.confidence * 100).round()}% • Evidence opened: ${controller.viewedEvidenceCount}',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('restart_same_seed'),
                      onPressed: () {
                        controller.restartSameSeed();
                        context.go('/city');
                      },
                      icon: const Icon(Icons.replay),
                      label: Text('Replay seed ${result.seed}'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        context.go('/');
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Main menu'),
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
}
