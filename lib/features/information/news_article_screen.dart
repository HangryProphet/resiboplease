import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/news_media.dart';
import '../../l10n/information_ecosystem_localizations.dart';
import '../../l10n/tv_broadcast_localizations.dart';
import '../dossier/widgets/dossier_ui.dart';
import '../dossier/widgets/evidence_reader.dart';
import 'news_coverage_screen.dart';
import 'widgets/information_actions.dart';
import 'widgets/information_media_slots.dart';

class NewsArticleScreen extends StatelessWidget {
  const NewsArticleScreen({
    required this.controller,
    required this.coverageId,
    super.key,
  });

  final GameController controller;
  final String coverageId;

  @override
  Widget build(BuildContext context) {
    final news = controller.informationEcosystem.news;
    final coverage = news.coverageById(coverageId);
    final event = coverage == null ? null : news.eventById(coverage.eventId);
    final outlet = coverage == null ? null : news.outletById(coverage.outletId);
    if (coverage == null || event == null || outlet == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        body: Center(
          child: ChunkyActionButton(
            label: 'Return to Chronicle',
            icon: Icons.arrow_back_rounded,
            color: const Color(0xFF304A61),
            onPressed: () => context.go('/city/chronicle'),
          ),
        ),
      );
    }
    final color = Color(outlet.colorValue);
    final related = news
        .coverageForEvent(event.id)
        .where((item) => item.id != coverage.id)
        .toList(growable: false);
    return Scaffold(
      key: Key('news_article_${coverage.id}'),
      backgroundColor: const Color(0xFFE9E7E0),
      body: SafeArea(
        child: Column(
          children: [
            NewsOutletHeader(
              outlet: outlet,
              backButtonKey: const Key('back_from_news_article'),
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go('/city/chronicle'),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('news_article_scroll'),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 13),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${coverage.category.toUpperCase()} · ${coverage.publicationTime}',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  coverage.headline,
                                  style: const TextStyle(
                                    color: Color(0xFF17232D),
                                    fontFamily: 'LuckiestGuy',
                                    fontSize: 34,
                                    height: 1.02,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  coverage.subheadline,
                                  style: const TextStyle(
                                    color: Color(0xFF4F5D68),
                                    fontSize: 17,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 11),
                                Text(
                                  'By ${outlet.name} City Desk',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NewsImageSlot(
                            assetKey: event.imageAssetKey ?? 'news_generic',
                            semanticLabel:
                                context.informationStrings.articleImagePending,
                            color: color,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: .09),
                                    border: Border(
                                      left: BorderSide(color: color, width: 5),
                                    ),
                                  ),
                                  child: Text(
                                    coverage.articleSummary,
                                    style: const TextStyle(
                                      color: Color(0xFF17232D),
                                      fontSize: 16,
                                      height: 1.45,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                for (final paragraph
                                    in coverage.articleBody) ...[
                                  Text(
                                    paragraph,
                                    style: const TextStyle(
                                      color: Color(0xFF263540),
                                      fontSize: 16,
                                      height: 1.58,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                                _OutletPersonality(outlet: outlet),
                                const SizedBox(height: 18),
                                _RelatedInformation(
                                  controller: controller,
                                  event: event,
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  context.informationStrings.relatedStories
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF17232D),
                                    fontFamily: 'LilitaOne',
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                for (final item in related) ...[
                                  _RelatedStory(
                                    coverage: item,
                                    outlet: news.outletById(item.outletId)!,
                                    onTap: () => context.pushReplacement(
                                      '/news/${item.id}',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutletPersonality extends StatelessWidget {
  const _OutletPersonality({required this.outlet});
  final NewsOutlet outlet;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2F3),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.tune_rounded, color: Color(0xFF526779)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.informationStrings.outletPersonality.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF526779),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.informationStrings.outletTraits(outlet),
                style: const TextStyle(color: Color(0xFF263540)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RelatedInformation extends StatelessWidget {
  const _RelatedInformation({required this.controller, required this.event});
  final GameController controller;
  final UnderlyingNewsEvent event;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: [
      if (controller.informationEcosystem.tvBroadcasts.forEvent(event.id)
          case final broadcast?)
        InformationActionButton(
          buttonKey: Key('article_watch_report_${event.id}'),
          icon: Icons.live_tv_rounded,
          color: ResiboColors.mutedRed,
          label: context.tvStrings.watchTvReport,
          onPressed: () => context.push('/tv/${broadcast.id}'),
        ),
      if (event.relatedIssueFamily != null)
        InformationActionButton(
          icon: Icons.location_city_rounded,
          color: ResiboColors.navy,
          label:
              '${context.informationStrings.relatedCityIssue}: ${event.title}',
          onPressed: () => context.go('/city'),
        ),
      for (final candidateId in event.relatedCandidateIds)
        if (controller.candidateByIdOrNull(candidateId) case final candidate?)
          InformationActionButton(
            buttonKey: Key('article_candidate_$candidateId'),
            icon: Icons.person_rounded,
            color: Color(candidate.colorValue),
            label: candidate.name,
            onPressed: () => context.go('/candidates/$candidateId'),
          ),
      for (final evidenceId in event.evidenceIds.take(3))
        InformationActionButton(
          buttonKey: Key('article_evidence_$evidenceId'),
          icon: Icons.receipt_long_rounded,
          color: ResiboColors.mutedRed,
          label: context.informationStrings.relatedRecord,
          onPressed: () => _openEvidence(context, evidenceId),
        ),
      InformationActionButton(
        icon: Icons.compare_rounded,
        color: const Color(0xFF3277A0),
        label: context.informationStrings.compareCoverage,
        onPressed: () => context.push('/news/event/${event.id}'),
      ),
    ],
  );

  Future<void> _openEvidence(BuildContext context, String evidenceId) async {
    final item = controller.evidenceByIdOrNull(evidenceId);
    if (item == null) return;
    Candidate? owner;
    for (final candidate in controller.scenario.candidates) {
      if (candidate.evidence.any((evidence) => evidence.id == evidenceId)) {
        owner = candidate;
        break;
      }
    }
    if (owner == null) return;
    await openEvidenceReader(
      context,
      controller: controller,
      candidate: owner,
      item: item,
    );
  }
}

class _RelatedStory extends StatelessWidget {
  const _RelatedStory({
    required this.coverage,
    required this.outlet,
    required this.onTap,
  });
  final NewsCoverage coverage;
  final NewsOutlet outlet;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InformationLinkTile(
    title: coverage.headline,
    eyebrow: outlet.name,
    subtitle: coverage.framingAngle,
    icon: Icons.article_rounded,
    color: Color(outlet.colorValue),
    onPressed: onTap,
  );
}
