import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/candidate.dart';
import '../../domain/models/citybook.dart';
import '../../l10n/information_ecosystem_localizations.dart';
import '../candidate_hub/widgets/candidate_image_slot.dart';
import '../candidate_hub/widgets/then_now_card.dart';
import '../dossier/widgets/dossier_ui.dart';
import '../dossier/widgets/evidence_reader.dart';
import 'widgets/information_actions.dart';
import 'widgets/information_media_slots.dart';

enum _CityBookTab { posts, about, media }

class CityBookProfileScreen extends StatefulWidget {
  const CityBookProfileScreen({
    required this.controller,
    required this.candidateId,
    super.key,
  });

  final GameController controller;
  final String candidateId;

  @override
  State<CityBookProfileScreen> createState() => _CityBookProfileScreenState();
}

class _CityBookProfileScreenState extends State<CityBookProfileScreen> {
  var _tab = _CityBookTab.posts;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final candidate = widget.controller.candidateByIdOrNull(
        widget.candidateId,
      );
      final ecosystem = widget.controller.informationEcosystem;
      final profile = ecosystem.cityBook.profileFor(widget.candidateId);
      if (candidate == null || profile == null) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B1725),
          body: Center(
            child: ChunkyActionButton(
              label: 'Return to candidates',
              icon: Icons.arrow_back_rounded,
              color: const Color(0xFF304A61),
              onPressed: () => context.go('/candidates'),
            ),
          ),
        );
      }
      final posts = ecosystem.cityBook.postsFor(candidate.id);
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        body: SafeArea(
          child: InvestigationBackdrop(
            showCity: true,
            child: Column(
              children: [
                InvestigationHeader(
                  title: context.informationStrings.cityBook,
                  subtitle: profile.handle,
                  onBack: () => context.go('/candidates/${candidate.id}'),
                  trailing: GameIconButton(
                    tooltip: context.informationStrings.recentCoverage,
                    icon: Icons.newspaper_rounded,
                    color: ResiboColors.teal,
                    onPressed: () {
                      final coverage = ecosystem.news
                          .coverageForCandidate(candidate.id)
                          .firstOrNull;
                      if (coverage != null) {
                        context.push('/news/${coverage.id}');
                      }
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('citybook_profile_scroll'),
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 36),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CityBookProfileHeader(
                              controller: widget.controller,
                              candidate: candidate,
                              profile: profile,
                            ),
                            const SizedBox(height: 12),
                            _CityBookTabs(
                              selected: _tab,
                              onSelected: (tab) => setState(() => _tab = tab),
                            ),
                            const SizedBox(height: 14),
                            switch (_tab) {
                              _CityBookTab.posts => CityBookFeed(
                                controller: widget.controller,
                                candidate: candidate,
                                posts: posts,
                              ),
                              _CityBookTab.about => _CityBookAbout(
                                controller: widget.controller,
                                candidate: candidate,
                                profile: profile,
                              ),
                              _CityBookTab.media => _CityBookMedia(
                                candidate: candidate,
                                posts: posts,
                              ),
                            },
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class CityBookProfileHeader extends StatelessWidget {
  const CityBookProfileHeader({
    required this.controller,
    required this.candidate,
    required this.profile,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final CityBookProfile profile;

  @override
  Widget build(BuildContext context) {
    final color = Color(candidate.colorValue);
    final experience = controller.candidateExperience.profileFor(candidate.id)!;
    return Container(
      key: const Key('citybook_profile_header'),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF101D2A), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 5)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileBannerSlot(
                assetKey: profile.bannerAssetKey,
                semanticLabel: context.informationStrings.profileBannerPending,
                color: color,
              ),
              Positioned(
                left: 18,
                bottom: -42,
                child: Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CandidateImageSlot(
                      candidateId: candidate.id,
                      assetKey: experience.portraitAssetKey,
                      semanticLabel: candidate.name,
                      color: color,
                      aspectRatio: 1,
                      borderRadius: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(126, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    color: Color(0xFF14283A),
                    fontFamily: 'LilitaOne',
                    fontSize: 25,
                  ),
                ),
                Text(
                  profile.handle,
                  style: const TextStyle(color: Color(0xFF667788)),
                ),
                const SizedBox(height: 7),
                Text(
                  profile.shortBio,
                  style: const TextStyle(
                    color: Color(0xFF14283A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 12,
                  runSpacing: 5,
                  children: [
                    Text(
                      profile.affiliation,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${context.informationStrings.formatCount(profile.publicAttention)} ${context.informationStrings.followers}',
                      style: const TextStyle(
                        color: Color(0xFF526779),
                        fontWeight: FontWeight.w800,
                      ),
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

class _CityBookTabs extends StatelessWidget {
  const _CityBookTabs({required this.selected, required this.onSelected});
  final _CityBookTab selected;
  final ValueChanged<_CityBookTab> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: const Color(0xFF172A3C),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: Colors.black, width: 2),
    ),
    child: Row(
      children: [
        for (final tab in _CityBookTab.values)
          Expanded(
            child: TextButton(
              key: Key('citybook_tab_${tab.name}'),
              style: TextButton.styleFrom(
                backgroundColor: selected == tab
                    ? const Color(0xFF3F78A8)
                    : Colors.transparent,
                foregroundColor: const Color(0xFFFFF1D1),
              ),
              onPressed: () => onSelected(tab),
              child: Text(
                switch (tab) {
                  _CityBookTab.posts => context.informationStrings.posts,
                  _CityBookTab.about => context.informationStrings.about,
                  _CityBookTab.media => context.informationStrings.media,
                }.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'LilitaOne'),
              ),
            ),
          ),
      ],
    ),
  );
}

class CityBookFeed extends StatelessWidget {
  const CityBookFeed({
    required this.controller,
    required this.candidate,
    required this.posts,
    super.key,
  });
  final GameController controller;
  final Candidate candidate;
  final List<CityBookPost> posts;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('citybook_feed'),
    children: [
      for (final post in posts) ...[
        CityBookPostCard(
          controller: controller,
          candidate: candidate,
          post: post,
        ),
        const SizedBox(height: 13),
      ],
    ],
  );
}

class CityBookPostCard extends StatelessWidget {
  const CityBookPostCard({
    required this.controller,
    required this.candidate,
    required this.post,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final CityBookPost post;

  @override
  Widget build(BuildContext context) {
    final profile = controller.informationEcosystem.cityBook.profileFor(
      candidate.id,
    )!;
    final experience = controller.candidateExperience.profileFor(candidate.id)!;
    final color = Color(candidate.colorValue);
    return Container(
      key: Key('citybook_post_${post.id}'),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF182938), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: ClipOval(
                        child: CandidateImageSlot(
                          candidateId: candidate.id,
                          assetKey: experience.portraitAssetKey,
                          semanticLabel: candidate.name,
                          color: color,
                          aspectRatio: 1,
                          borderRadius: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.name,
                            style: const TextStyle(
                              color: Color(0xFF14283A),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${profile.handle} · ${post.fictionalDate}',
                            style: const TextStyle(
                              color: Color(0xFF667788),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.public_rounded,
                      size: 17,
                      color: Color(0xFF667788),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                if (post.historical) ...[
                  _HistoricalBadge(),
                  const SizedBox(height: 8),
                ],
                Text(
                  post.text,
                  style: const TextStyle(
                    color: Color(0xFF14283A),
                    fontSize: 15,
                    height: 1.42,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.informationStrings
                      .postTypeLabel(post.type)
                      .toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
          if (post.imageAssetKey != null)
            SocialMediaImageSlot(
              assetKey: post.imageAssetKey!,
              semanticLabel: context.informationStrings.postMediaPending,
              aspectRatio: post.imageAspectRatio,
              color: color,
            ),
          CityBookReactionBar(reactions: post.reactions),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 6,
              runSpacing: 6,
              children: [
                InformationActionButton(
                  buttonKey: Key('citybook_comments_${post.id}'),
                  onPressed: () => _showComments(context),
                  icon: Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFF304A61),
                  label: context.informationStrings.viewComments,
                ),
                if (post.comparisonId != null)
                  InformationActionButton(
                    buttonKey: Key('citybook_context_${post.id}'),
                    onPressed: () => _showContext(context),
                    icon: Icons.compare_arrows_rounded,
                    color: const Color(0xFF8A681E),
                    label: context.informationStrings.viewContext,
                  ),
                for (final evidenceId in post.relatedEvidenceIds.take(2))
                  InformationActionButton(
                    buttonKey: Key('citybook_evidence_${post.id}_$evidenceId'),
                    onPressed: () => _openEvidence(context, evidenceId),
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFFAA3F4B),
                    label: context.informationStrings.viewReceipt,
                  ),
                if (post.relatedNewsEventIds.isNotEmpty)
                  InformationActionButton(
                    buttonKey: Key('citybook_news_${post.id}'),
                    onPressed: () => context.push(
                      '/news/event/${post.relatedNewsEventIds.first}',
                    ),
                    icon: Icons.newspaper_rounded,
                    color: const Color(0xFF3277A0),
                    label: context.informationStrings.readCoverage,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEvidence(BuildContext context, String id) async {
    final item = controller.evidenceByIdOrNull(id);
    if (item == null) return;
    await openEvidenceReader(
      context,
      controller: controller,
      candidate: candidate,
      item: item,
    );
  }

  Future<void> _showComments(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CityBookCommentsSheet(
          thread: controller.informationEcosystem.cityBook.commentsFor(post)!,
        ),
      );

  Future<void> _showContext(BuildContext context) async {
    final comparison = controller.candidateExperience.comparisonById(
      post.comparisonId!,
    );
    if (comparison == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ThenNowCard(
            comparison: comparison,
            onOpenEvidence: (id) {
              Navigator.pop(context);
              _openEvidence(context, id);
            },
          ),
        ),
      ),
    );
  }
}

class CityBookReactionBar extends StatelessWidget {
  const CityBookReactionBar({required this.reactions, super.key});
  final CityBookReactionDistribution reactions;

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFF0F4F7),
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 9,
          runSpacing: 5,
          children: [
            for (final entry in reactions.counts.entries)
              _ReactionCount(reaction: entry.key, count: entry.value),
          ],
        ),
      ],
    ),
  );
}

class _ReactionCount extends StatelessWidget {
  const _ReactionCount({required this.reaction, required this.count});
  final CityBookReaction reaction;
  final int count;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(_reactionIcon(reaction), size: 16, color: _reactionColor(reaction)),
      const SizedBox(width: 3),
      Text(
        '${context.informationStrings.reactionLabel(reaction)} ${context.informationStrings.formatCount(count)}',
        style: const TextStyle(
          color: Color(0xFF405466),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class CityBookCommentsSheet extends StatelessWidget {
  const CityBookCommentsSheet({required this.thread, super.key});
  final CityBookCommentThread thread;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .82,
    child: Material(
      key: const Key('citybook_comments_sheet'),
      color: const Color(0xFFF5F7F9),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.informationStrings.comments.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF14283A),
                      fontFamily: 'LilitaOne',
                      fontSize: 21,
                    ),
                  ),
                ),
                GameIconButton(
                  key: const Key('close_citybook_comments'),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.close_rounded,
                  color: const Color(0xFF304A61),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: thread.comments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  CityBookCommentTile(comment: thread.comments[index]),
            ),
          ),
        ],
      ),
    ),
  );
}

class CityBookCommentTile extends StatelessWidget {
  const CityBookCommentTile({required this.comment, super.key});
  final CityBookComment comment;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundColor: const Color(0xFF3F78A8),
        child: Text(
          comment.authorName.characters.first,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Container(
          key: Key('citybook_comment_${comment.id}'),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD6DEE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${comment.authorName}  ${comment.authorHandle}',
                style: const TextStyle(
                  color: Color(0xFF14283A),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
                style: const TextStyle(color: Color(0xFF24384A), height: 1.35),
              ),
              if (comment.accountClues.isNotEmpty) ...[
                const SizedBox(height: 7),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (final clue in comment.accountClues)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                        ),
                        label: Text(clue),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

class _HistoricalBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE5A8),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: const Color(0xFF8A6520)),
    ),
    child: Text(
      context.informationStrings.historicalPost.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF5E430F),
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _CityBookAbout extends StatelessWidget {
  const _CityBookAbout({
    required this.controller,
    required this.candidate,
    required this.profile,
  });
  final GameController controller;
  final Candidate candidate;
  final CityBookProfile profile;

  @override
  Widget build(BuildContext context) {
    final biography = controller.candidateExperience.biographyFor(candidate.id);
    return PaperPanel(
      key: const Key('citybook_about'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            label: context.informationStrings.about,
            icon: Icons.info_outline_rounded,
            color: Color(candidate.colorValue),
          ),
          const SizedBox(height: 11),
          Text(
            profile.shortBio,
            style: const TextStyle(color: dossierInk, height: 1.4),
          ),
          const SizedBox(height: 9),
          Text(
            'Affiliation: ${profile.affiliation}',
            style: const TextStyle(
              color: dossierInk,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (biography != null) ...[
            const SizedBox(height: 9),
            Text(
              biography.summary,
              style: const TextStyle(color: dossierInk, height: 1.45),
            ),
          ],
          const SizedBox(height: 13),
          ChunkyActionButton(
            label: 'Open Civic Archive',
            icon: Icons.menu_book_rounded,
            color: ResiboColors.teal,
            onPressed: () =>
                context.go('/candidates/${candidate.id}?section=bio'),
          ),
        ],
      ),
    );
  }
}

class _CityBookMedia extends StatelessWidget {
  const _CityBookMedia({required this.candidate, required this.posts});
  final Candidate candidate;
  final List<CityBookPost> posts;

  @override
  Widget build(BuildContext context) {
    final media = posts.where((post) => post.imageAssetKey != null).toList();
    return LayoutBuilder(
      key: const Key('citybook_media'),
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 620 ? 3 : 2;
        const gap = 8.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final post in media)
              SizedBox(
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SocialMediaImageSlot(
                    assetKey: post.imageAssetKey!,
                    semanticLabel: context.informationStrings.postMediaPending,
                    aspectRatio: 1,
                    color: Color(candidate.colorValue),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

IconData _reactionIcon(CityBookReaction reaction) => switch (reaction) {
  CityBookReaction.like => Icons.thumb_up_rounded,
  CityBookReaction.love => Icons.favorite_rounded,
  CityBookReaction.laugh => Icons.sentiment_very_satisfied_rounded,
  CityBookReaction.shock => Icons.sentiment_very_dissatisfied_rounded,
  CityBookReaction.sad => Icons.sentiment_dissatisfied_rounded,
  CityBookReaction.angry => Icons.local_fire_department_rounded,
  CityBookReaction.receipt => Icons.receipt_long_rounded,
};

Color _reactionColor(CityBookReaction reaction) => switch (reaction) {
  CityBookReaction.like => const Color(0xFF3777B3),
  CityBookReaction.love => const Color(0xFFCE4165),
  CityBookReaction.laugh => const Color(0xFFE0A51F),
  CityBookReaction.shock => const Color(0xFFE0A51F),
  CityBookReaction.sad => const Color(0xFF537DA0),
  CityBookReaction.angry => const Color(0xFFC34C32),
  CityBookReaction.receipt => const Color(0xFF267B68),
};
