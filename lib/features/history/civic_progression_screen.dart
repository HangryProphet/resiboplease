import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/citizen_action.dart';
import '../../domain/models/civic_progression.dart';
import '../../l10n/l10n_extensions.dart';
import '../city/widgets/city_brief_ui.dart';
import '../dossier/widgets/dossier_ui.dart';

class CivicProgressionScreen extends StatelessWidget {
  const CivicProgressionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final profile = controller.civicProgression;
      return Scaffold(
        backgroundColor: const Color(0xFF08121D),
        body: SafeArea(
          child: InvestigationBackdrop(
            child: Column(
              children: [
                InvestigationHeader(
                  title: context.l10n.civicProfile,
                  subtitle: controller.activeCityName,
                  onBack: () =>
                      context.canPop() ? context.pop() : context.go('/city'),
                  trailing: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFFD765),
                    size: 30,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 880),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ProfileIntro(profile: profile),
                            const SizedBox(height: 18),
                            CitySectionTitle(
                              title: context.l10n.civicTracks,
                              icon: Icons.route_rounded,
                            ),
                            const SizedBox(height: 10),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth >= 680
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth;
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (final track
                                        in CivicProgressionTrack.values)
                                      SizedBox(
                                        width: width,
                                        child: _TrackCard(
                                          progress: profile.progressFor(track),
                                          delayReduction: switch (track) {
                                            CivicProgressionTrack
                                                .publicAccountability =>
                                              profile.actionDelayReductionDays(
                                                CitizenActionType
                                                    .requestPublicRecords,
                                              ),
                                            CivicProgressionTrack
                                                .civicOrganizing =>
                                              profile.actionDelayReductionDays(
                                                CitizenActionType
                                                    .organizePetition,
                                              ),
                                            _ => 0,
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 22),
                            CitySectionTitle(
                              title: context.l10n.civicAccomplishments,
                              icon: Icons.verified_rounded,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.civicAccomplishmentsCount(
                                profile.accomplishedCount,
                                profile.accomplishments.length,
                              ),
                              style: const TextStyle(
                                color: Color(0xFFB9C7CF),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final accomplishment
                                in profile.accomplishments) ...[
                              _AccomplishmentCard(
                                accomplishment: accomplishment,
                              ),
                              const SizedBox(height: 8),
                            ],
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

class _ProfileIntro extends StatelessWidget {
  const _ProfileIntro({required this.profile});

  final CivicProgressionProfile profile;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: ResiboColors.mutedRed,
            border: Border.all(color: cityBriefInk, width: 3),
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [
              BoxShadow(color: Colors.black45, offset: Offset(2, 3)),
            ],
          ),
          child: const Icon(
            Icons.how_to_reg_rounded,
            color: Color(0xFFFFEBC1),
            size: 34,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.civicProfileSubtitle.toUpperCase(),
                style: const TextStyle(
                  color: cityBriefInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.l10n.civicGrowthExplanation,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 11,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.progress, required this.delayReduction});

  final CivicTrackProgress progress;
  final int delayReduction;

  @override
  Widget build(BuildContext context) {
    final color = _trackColor(progress.track);
    final remaining = progress.nextLevelAt == null
        ? null
        : progress.nextLevelAt! - progress.points;
    return Container(
      key: Key('civic_track_${progress.track.name}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF1C8), Color(0xFFE1CCA0)],
        ),
        border: Border.all(color: const Color(0xFF07111D), width: 3),
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: cityBriefInk, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  _trackIcon(progress.track),
                  color: const Color(0xFFFFEBC1),
                  size: 21,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _trackName(context, progress.track).toUpperCase(),
                      style: const TextStyle(
                        color: cityBriefInk,
                        fontFamily: 'LilitaOne',
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '${context.l10n.civicLevel(progress.level)} · '
                      '${context.l10n.civicPoints(progress.points)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _trackDescription(context, progress.track),
            style: const TextStyle(
              color: cityBriefInk,
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.fractionToNextLevel,
              minHeight: 9,
              backgroundColor: const Color(0xFFB8AA8A),
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            remaining == null
                ? context.l10n.civicMaxLevel
                : context.l10n.civicNextLevel(remaining),
            style: const TextStyle(
              color: Color(0xFF5A4C38),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (delayReduction > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E4CE),
                border: Border.all(color: cityBriefInk, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                context.l10n.responseEfficiencyUnlocked(delayReduction),
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 9,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          if (progress.track == CivicProgressionTrack.research &&
              progress.level >= 2) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFD7E5EC),
                border: Border.all(color: cityBriefInk, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                context.l10n.sourceDeskUnlocked,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 9,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccomplishmentCard extends StatelessWidget {
  const _AccomplishmentCard({required this.accomplishment});

  final CivicAccomplishment accomplishment;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('civic_accomplishment_${accomplishment.id}'),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: accomplishment.achieved
          ? const Color(0xFFF4E3B9)
          : const Color(0xFF263B4A),
      border: Border.all(color: const Color(0xFF07111D), width: 2.5),
      borderRadius: BorderRadius.circular(6),
      boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(2, 2))],
    ),
    child: Row(
      children: [
        Icon(
          accomplishment.achieved
              ? Icons.verified_rounded
              : Icons.lock_outline_rounded,
          color: accomplishment.achieved
              ? const Color(0xFF2D765D)
              : const Color(0xFF91A0A9),
          size: 28,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _accomplishmentTitle(context, accomplishment.id).toUpperCase(),
                style: TextStyle(
                  color: accomplishment.achieved
                      ? cityBriefInk
                      : const Color(0xFFD2D9DD),
                  fontFamily: 'LilitaOne',
                  fontSize: 15,
                ),
              ),
              Text(
                _accomplishmentDescription(context, accomplishment.id),
                style: TextStyle(
                  color: accomplishment.achieved
                      ? const Color(0xFF5A4C38)
                      : const Color(0xFFB9C7CF),
                  fontSize: 10,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${accomplishment.progress}/${accomplishment.target}',
          style: TextStyle(
            color: accomplishment.achieved
                ? const Color(0xFF2D765D)
                : const Color(0xFFB9C7CF),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

String _trackName(BuildContext context, CivicProgressionTrack track) =>
    switch (track) {
      CivicProgressionTrack.research => context.l10n.researchTrack,
      CivicProgressionTrack.publicAccountability =>
        context.l10n.accountabilityTrack,
      CivicProgressionTrack.civicOrganizing => context.l10n.organizingTrack,
      CivicProgressionTrack.historicalAnalysis => context.l10n.historyTrack,
    };

String _trackDescription(BuildContext context, CivicProgressionTrack track) =>
    switch (track) {
      CivicProgressionTrack.research => context.l10n.researchTrackDescription,
      CivicProgressionTrack.publicAccountability =>
        context.l10n.accountabilityTrackDescription,
      CivicProgressionTrack.civicOrganizing =>
        context.l10n.organizingTrackDescription,
      CivicProgressionTrack.historicalAnalysis =>
        context.l10n.historyTrackDescription,
    };

IconData _trackIcon(CivicProgressionTrack track) => switch (track) {
  CivicProgressionTrack.research => Icons.manage_search_rounded,
  CivicProgressionTrack.publicAccountability => Icons.receipt_long_rounded,
  CivicProgressionTrack.civicOrganizing => Icons.groups_rounded,
  CivicProgressionTrack.historicalAnalysis => Icons.history_edu_rounded,
};

Color _trackColor(CivicProgressionTrack track) => switch (track) {
  CivicProgressionTrack.research => const Color(0xFF3277A0),
  CivicProgressionTrack.publicAccountability => ResiboColors.mutedRed,
  CivicProgressionTrack.civicOrganizing => ResiboColors.teal,
  CivicProgressionTrack.historicalAnalysis => const Color(0xFF77539A),
};

String _accomplishmentTitle(BuildContext context, String id) => switch (id) {
  'first_administration' => context.l10n.accomplishmentFirstAdministration,
  'three_administrations' => context.l10n.accomplishmentThreeAdministrations,
  'five_administrations' => context.l10n.accomplishmentFiveAdministrations,
  'multi_source_investigator' => context.l10n.accomplishmentMultiSource,
  'recurring_promise_documented' => context.l10n.accomplishmentRecurringPromise,
  'public_records_obtained' => context.l10n.accomplishmentPublicRecords,
  'successful_petition' => context.l10n.accomplishmentPetition,
  'major_issue_recovery' => context.l10n.accomplishmentIssueRecovery,
  'cross_term_project' => context.l10n.accomplishmentCrossTermProject,
  'political_comeback' => context.l10n.accomplishmentPoliticalComeback,
  _ => id,
};

String _accomplishmentDescription(BuildContext context, String id) =>
    switch (id) {
      'first_administration' =>
        context.l10n.accomplishmentFirstAdministrationDescription,
      'three_administrations' =>
        context.l10n.accomplishmentThreeAdministrationsDescription,
      'five_administrations' =>
        context.l10n.accomplishmentFiveAdministrationsDescription,
      'multi_source_investigator' =>
        context.l10n.accomplishmentMultiSourceDescription,
      'recurring_promise_documented' =>
        context.l10n.accomplishmentRecurringPromiseDescription,
      'public_records_obtained' =>
        context.l10n.accomplishmentPublicRecordsDescription,
      'successful_petition' => context.l10n.accomplishmentPetitionDescription,
      'major_issue_recovery' =>
        context.l10n.accomplishmentIssueRecoveryDescription,
      'cross_term_project' =>
        context.l10n.accomplishmentCrossTermProjectDescription,
      'political_comeback' =>
        context.l10n.accomplishmentPoliticalComebackDescription,
      _ => id,
    };
