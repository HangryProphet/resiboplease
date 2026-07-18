import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../core/widgets/indicator_card.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/game_content_localizations.dart';

class CityOverviewScreen extends StatelessWidget {
  const CityOverviewScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final city = controller.scenario.city;
    final keyIndicators = [
      CityIndicator.waterSecurity,
      CityIndicator.employmentQuality,
      CityIndicator.publicHealth,
      CityIndicator.budgetHealth,
      CityIndicator.publicTrust,
      CityIndicator.climateResilience,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${controller.activeCityName} • ${context.l10n.electionBrief}',
        ),
      ),
      body: ListView(
        children: [
          ContentShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 220,
                    child: Semantics(
                      label: context.l10n.cityImageSemantics,
                      child: Image.asset(
                        'assets/images/city/bayhaven_base.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.cityBeforeVote,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.citySummaryText(city),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (controller.assistanceMode == AssistanceMode.guided) ...[
                  const SizedBox(height: 16),
                  Card(
                    key: const Key('guided_resi_note'),
                    color: const Color(0xFFE9F2E8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.assistant_outlined,
                        color: ResiboColors.teal,
                      ),
                      title: Text(
                        context.l10n.guidedReminderTitle,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(context.l10n.guidedReminderBody),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Text(
                  context.l10n.urgentCaseFiles,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...city.problems.map(
                  (problem) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x1FAA3F4B),
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: ResiboColors.mutedRed,
                        ),
                      ),
                      title: Text(
                        context.l10n.problemTitleText(problem),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${context.l10n.problemDescriptionText(problem, city.name)}\n${context.l10n.trendLabel(problem.trend)} • ${problem.sdgTags.join(' • ')}',
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  context.l10n.cityCondition,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850
                        ? 3
                        : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                    return GridView.count(
                      crossAxisCount: columns,
                      childAspectRatio: columns == 1 ? 3.1 : 2.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final indicator in keyIndicators)
                          IndicatorCard(
                            indicator: indicator,
                            value: city.indicators.valueOf(indicator),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('meet_candidates'),
                    onPressed: () => context.go('/candidates'),
                    icon: const Icon(Icons.groups_rounded),
                    label: Text(context.l10n.meetCandidates),
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
