import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/widgets/content_shell.dart';
import '../../domain/models/evidence_item.dart';

class CandidateDossierScreen extends StatelessWidget {
  const CandidateDossierScreen({
    required this.controller,
    required this.candidateId,
    super.key,
  });

  final GameController controller;
  final String candidateId;

  @override
  Widget build(BuildContext context) {
    final candidate = controller.candidateById(candidateId);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text('${candidate.name} • Dossier'),
          actions: [
            TextButton(
              onPressed: () => context.go('/vote'),
              child: const Text(
                'ELECTION DAY',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            ContentShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(candidate.colorValue).withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 112,
                            height: 132,
                            color: Color(
                              candidate.colorValue,
                            ).withValues(alpha: .12),
                            child: Image.asset(
                              'assets/images/candidates/${candidate.id}/${candidate.id}_portrait.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                candidate.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              Text(
                                '${candidate.party} • ${candidate.archetype}',
                              ),
                              const SizedBox(height: 10),
                              Text(candidate.biography),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _DossierList(
                        title: 'Documented strengths',
                        icon: Icons.add_circle_outline,
                        items: candidate.visibleStrengths,
                      ),
                      _DossierList(
                        title: 'Questions to investigate',
                        icon: Icons.help_outline,
                        items: candidate.visibleConcerns,
                      ),
                      _DossierList(
                        title: 'Campaign platform',
                        icon: Icons.campaign_outlined,
                        items: candidate.platform,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Evidence desk',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '${controller.bookmarkedEvidenceIds.length} bookmarked',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A source can be reputable yet incomplete. Open the item before deciding what weight it deserves.',
                  ),
                  const SizedBox(height: 10),
                  ...candidate.evidence.map(
                    (item) => Card(
                      child: ListTile(
                        key: Key('evidence_${item.id}'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Icon(
                          _iconFor(item.type),
                          color: Color(candidate.colorValue),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${item.type.label} • ${item.source}\n${item.summary}',
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          controller.isBookmarked(item.id)
                              ? Icons.bookmark
                              : Icons.chevron_right,
                        ),
                        onTap: () => _openEvidence(context, item),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.go('/candidates'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Roster'),
                      ),
                      FilledButton(
                        onPressed: () => context.go('/vote'),
                        child: const Text('Review ballot'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEvidence(BuildContext context, EvidenceItem item) async {
    controller.markEvidenceViewed(item.id);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.source} • ${item.type.label}',
                style: const TextStyle(
                  color: ResiboColors.teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Divider(height: 28),
              Text(item.details),
              const SizedBox(height: 20),
              Text(
                'Source cue: ${_reliabilityCue(item.reliability)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (item.type == EvidenceType.factCheck) ...[
                const SizedBox(height: 6),
                Text('Fact-check finding: ${item.truthStatus.label}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              controller.toggleBookmark(item.id);
              Navigator.pop(context);
            },
            icon: Icon(
              controller.isBookmarked(item.id)
                  ? Icons.bookmark_remove
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(
              controller.isBookmarked(item.id) ? 'Remove bookmark' : 'Bookmark',
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String _reliabilityCue(int reliability) => switch (reliability) {
    >= 80 => 'strong documentation and accountable sourcing',
    >= 60 => 'credible sourcing with limits to check',
    >= 40 => 'interested source; verify independently',
    _ => 'weak sourcing or no accountable author',
  };

  static IconData _iconFor(EvidenceType type) => switch (type) {
    EvidenceType.profile => Icons.badge_outlined,
    EvidenceType.platform => Icons.list_alt,
    EvidenceType.campaignAd => Icons.campaign,
    EvidenceType.publicRecord => Icons.account_balance,
    EvidenceType.budgetDocument => Icons.receipt_long,
    EvidenceType.socialPost => Icons.forum_outlined,
    EvidenceType.factCheck => Icons.fact_check_outlined,
    EvidenceType.controversy => Icons.warning_amber,
    EvidenceType.debateAnswer => Icons.record_voice_over,
  };
}

class _DossierList extends StatelessWidget {
  const _DossierList({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 330,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text('• $item'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
