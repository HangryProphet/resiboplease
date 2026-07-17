import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../core/widgets/indicator_card.dart';
import '../../domain/models/city_indicator.dart';

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
      appBar: AppBar(title: Text('${city.name} • Election brief')),
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
                      label:
                          'Illustrated Bayhaven civic hall, waterfront, water infrastructure, clinic, school, and market district.',
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
                  'The city before the vote',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  city.summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 26),
                Text(
                  'Urgent case files',
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
                        problem.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${problem.description}\n${problem.trend.label} • ${problem.sdgTags.join(' • ')}',
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'City condition',
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
                    label: const Text('Meet the candidates'),
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
