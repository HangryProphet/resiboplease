import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../l10n/information_ecosystem_localizations.dart';
import 'information_actions.dart';

class RecentCandidateCoverage extends StatelessWidget {
  const RecentCandidateCoverage({
    required this.controller,
    required this.candidate,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final news = controller.informationEcosystem.news;
    final coverage = news.coverageForCandidate(candidate.id).take(3).toList();
    return Container(
      key: const Key('candidate_information_strip'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF172A3C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF07111D), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), offset: Offset(0, 4)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cityBookButton = InformationActionButton(
            buttonKey: const Key('open_candidate_citybook'),
            expanded: true,
            color: const Color(0xFF3277A0),
            onPressed: () => context.push('/citybook/${candidate.id}'),
            icon: Icons.public_rounded,
            label: context.informationStrings.cityBook,
          );
          final recent = coverage.isEmpty
              ? const SizedBox.shrink()
              : InformationLinkTile(
                  buttonKey: const Key('open_recent_candidate_coverage'),
                  color: const Color(0xFFB57A24),
                  icon: Icons.newspaper_rounded,
                  eyebrow: context.informationStrings.recentCoverage,
                  title: coverage.first.headline,
                  subtitle:
                      '${news.outletById(coverage.first.outletId)!.name} · +${coverage.length - 1} more framing${coverage.length == 2 ? '' : 's'}',
                  onPressed: () => context.push('/news/${coverage.first.id}'),
                );
          if (constraints.maxWidth < 580) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                cityBookButton,
                if (coverage.isNotEmpty) const SizedBox(height: 9),
                recent,
              ],
            );
          }
          return Row(
            children: [
              SizedBox(width: 174, child: cityBookButton),
              const SizedBox(width: 10),
              Expanded(child: recent),
            ],
          );
        },
      ),
    );
  }
}
