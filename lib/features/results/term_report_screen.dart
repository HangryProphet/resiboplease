import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../core/widgets/indicator_card.dart';
import '../../domain/models/city_indicator.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/game_content_localizations.dart';

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
            child: Text(context.l10n.returnToBallot),
          ),
        ),
      );
    }
    final decisionIssue = controller.scenario.city.problems
        .where((problem) => problem.id == controller.topIssue)
        .map(context.l10n.problemTitleText)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${controller.activeCityName} • ${context.l10n.termReport}',
        ),
      ),
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
                      Text(
                        context.l10n.administrationReceipt.toUpperCase(),
                        style: const TextStyle(
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
                        context.l10n.termSummaryText(result),
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
                  context.l10n.whatChanged,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(context.l10n.whatChangedBody),
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
                  context.l10n.whyThisHappened,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(context.l10n.modelExplanation),
                const SizedBox(height: 18),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.psychology_alt_outlined),
                    title: Text(
                      context.l10n.yourDecisionContext,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      context.l10n.decisionContextBody(
                        decisionIssue ?? context.l10n.notRecorded,
                        (controller.confidence * 100).round(),
                        controller.viewedEvidenceCount,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('restart_same_seed'),
                      onPressed: () {
                        controller.restartSameSeed();
                        context.go('/city');
                      },
                      icon: const Icon(Icons.replay),
                      label: Text(context.l10n.replaySeed(result.seed)),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        context.go('/');
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: Text(context.l10n.mainMenu),
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
