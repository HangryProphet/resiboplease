import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/assets/visual_asset_catalog.dart';
import '../../../domain/models/pre_election_city_brief.dart';
import '../../../domain/models/city_problem.dart';
import '../../../l10n/city_brief_localizations.dart';
import '../../../l10n/l10n_extensions.dart';
import '../../../l10n/information_ecosystem_localizations.dart';
import '../../../l10n/tv_broadcast_localizations.dart';
import '../../information/widgets/information_actions.dart';

const cityBriefInk = Color(0xFF172332);
const cityBriefPaper = Color(0xFFF4E7C7);
const cityBriefLightPaper = Color(0xFFFFF6DF);

class CityBriefHeader extends StatelessWidget {
  const CityBriefHeader({
    required this.title,
    required this.cityName,
    this.showBallot = true,
    super.key,
  });

  final String title;
  final String cityName;
  final bool showBallot;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
    decoration: const BoxDecoration(
      color: Color(0xF216263B),
      border: Border(bottom: BorderSide(color: Color(0xFF07111D), width: 3)),
      boxShadow: [
        BoxShadow(
          color: Color(0x8A000000),
          offset: Offset(0, 4),
          blurRadius: 7,
        ),
      ],
    ),
    child: Row(
      children: [
        _HeaderIconButton(
          buttonKey: const Key('city_brief_home'),
          tooltip: context.l10n.returnHome,
          icon: Icons.home_rounded,
          onPressed: () => context.go('/'),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: cityBriefPaper,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: cityBriefInk, width: 2.5),
              boxShadow: const [
                BoxShadow(color: Color(0xA5000000), offset: Offset(2, 3)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontFamily: 'LuckiestGuy',
                    fontSize: 21,
                    height: 1,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cityName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF675946),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 9),
        if (showBallot)
          _HeaderIconButton(
            buttonKey: const Key('city_brief_ballot'),
            tooltip: context.l10n.reviewBallot,
            icon: Icons.how_to_vote_rounded,
            color: ResiboColors.mutedRed,
            onPressed: () => context.go('/vote'),
          )
        else
          const SizedBox(width: 46),
      ],
    ),
  );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.buttonKey,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFF304A61),
  });

  final Key buttonKey;
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: const BorderSide(color: Color(0xFF07111D), width: 2.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        child: SizedBox(
          width: 43,
          height: 43,
          child: Icon(icon, color: const Color(0xFFFFF0CB), size: 23),
        ),
      ),
    ),
  );
}

class CityPaperPanel extends StatelessWidget {
  const CityPaperPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = cityBriefLightPaper,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(color, Colors.white, .13)!, color],
      ),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: cityBriefInk, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x70000000),
          offset: Offset(2, 5),
          blurRadius: 3,
        ),
      ],
    ),
    child: child,
  );
}

class CitySectionTitle extends StatelessWidget {
  const CitySectionTitle({
    required this.title,
    required this.icon,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFFFFD785), size: 23),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFFEBC1),
            fontFamily: 'LilitaOne',
            fontSize: 20,
            height: 1,
            letterSpacing: .55,
            shadows: [Shadow(color: Colors.black87, offset: Offset(1, 2))],
          ),
        ),
      ),
      ?trailing,
    ],
  );
}

class FrozenSnapshotBanner extends StatelessWidget {
  const FrozenSnapshotBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('pre_election_frozen_notice'),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFF2DFAE),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: cityBriefInk, width: 2),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.pause_circle_filled_rounded,
          color: ResiboColors.mutedRed,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.preElectionSnapshot.toUpperCase(),
                style: const TextStyle(
                  color: cityBriefInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 16,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.preElectionFrozenNote,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class CityActionButton extends StatelessWidget {
  const CityActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = ResiboColors.teal,
    this.buttonKey,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF07111D),
      borderRadius: BorderRadius.circular(9),
      boxShadow: const [BoxShadow(color: Colors.black87, offset: Offset(0, 5))],
    ),
    padding: const EdgeInsets.only(bottom: 3),
    child: Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: const BorderSide(color: Color(0xFF07111D), width: 2.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(color, Colors.white, .22)!,
              color,
              Color.lerp(color, Colors.black, .26)!,
            ],
          ),
        ),
        child: InkWell(
          key: buttonKey,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFFFFF0CB), size: 21),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFF0CB),
                        fontFamily: 'LilitaOne',
                        fontSize: 16,
                        height: 1,
                        letterSpacing: .4,
                        shadows: [
                          Shadow(color: Colors.black87, offset: Offset(1, 2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class CityMetricCard extends StatelessWidget {
  const CityMetricCard({required this.metric, super.key});

  final CityBriefMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = metric.conditionScore <= 39
        ? ResiboColors.mutedRed
        : metric.conditionScore <= 59
        ? ResiboColors.gold
        : ResiboColors.teal;
    return CityPaperPanel(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cityBriefInk, width: 2),
            ),
            child: Icon(
              _metricIcon(metric.kind),
              color: const Color(0xFFFFF1CF),
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cityMetricValue(metric),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'LuckiestGuy',
                    fontSize: 22,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.cityMetricLabel(metric.kind),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontSize: 12,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
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

class CityIssueVisualSlot extends StatelessWidget {
  const CityIssueVisualSlot({
    required this.family,
    required this.visualKey,
    this.compact = false,
    super.key,
  });

  final CityIssueFamily family;
  final String visualKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = cityIssueFamilyColor(family);
    final assetPath = VisualAssetCatalog.issue(visualKey);
    return Semantics(
      label: visualKey,
      image: true,
      child: SizedBox(
        height: compact ? 72 : 126,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: cityBriefInk, width: 2)),
          ),
          child: assetPath == null
              ? _CityIssueVisualFallback(
                  family: family,
                  color: color,
                  compact: compact,
                )
              : Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) =>
                      _CityIssueVisualFallback(
                        family: family,
                        color: color,
                        compact: compact,
                      ),
                ),
        ),
      ),
    );
  }
}

class _CityIssueVisualFallback extends StatelessWidget {
  const _CityIssueVisualFallback({
    required this.family,
    required this.color,
    required this.compact,
  });

  final CityIssueFamily family;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(color, Colors.white, .22)!, color],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -12,
          bottom: -24,
          child: Icon(
            cityIssueFamilyIcon(family),
            size: compact ? 104 : 160,
            color: const Color(0x28FFF2D0),
          ),
        ),
        Center(
          child: Icon(
            cityIssueFamilyIcon(family),
            size: compact ? 39 : 58,
            color: const Color(0xFFFFF1CF),
            shadows: const [
              Shadow(color: Colors.black54, offset: Offset(2, 3)),
            ],
          ),
        ),
      ],
    ),
  );
}

class CityNewsCard extends StatelessWidget {
  const CityNewsCard({
    required this.item,
    required this.cityName,
    this.compact = false,
    this.onReadCoverage,
    this.onWatchReport,
    this.coverageCount = 0,
    super.key,
  });

  final CityNewsItem item;
  final String cityName;
  final bool compact;
  final VoidCallback? onReadCoverage;
  final VoidCallback? onWatchReport;
  final int coverageCount;

  @override
  Widget build(BuildContext context) {
    final color = item.isUnverified
        ? ResiboColors.mutedRed
        : cityTopicColor(item.topic);
    return CityPaperPanel(
      padding: EdgeInsets.all(compact ? 13 : 16),
      color: item.isUnverified ? const Color(0xFFF4DED0) : cityBriefLightPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 39 : 45,
                height: compact ? 39 : 45,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cityBriefInk, width: 2),
                ),
                child: Icon(
                  item.isUnverified
                      ? Icons.forum_rounded
                      : cityTopicIcon(item.topic),
                  color: const Color(0xFFFFF1CF),
                  size: compact ? 21 : 25,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.isUnverified
                          ? context.l10n.unverifiedClaim.toUpperCase()
                          : context.l10n.cityNewsSourceLabel(item.source),
                      style: TextStyle(
                        color: color,
                        fontFamily: 'LilitaOne',
                        fontSize: 12,
                        letterSpacing: .4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.cityNewsTitle(item, cityName),
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cityBriefInk,
                        fontSize: compact ? 15 : 17,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.cityNewsSummary(item, cityName),
            maxLines: compact ? 3 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
            style: const TextStyle(
              color: cityBriefInk,
              fontSize: 13,
              height: 1.38,
            ),
          ),
          if (onReadCoverage != null || onWatchReport != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (onWatchReport != null)
                    InformationActionButton(
                      buttonKey: Key('watch_report_${item.id}'),
                      onPressed: onWatchReport,
                      color: ResiboColors.mutedRed,
                      icon: Icons.live_tv_rounded,
                      label: context.tvStrings.watchReport,
                    ),
                  if (onReadCoverage != null)
                    InformationActionButton(
                      buttonKey: Key('read_coverage_${item.id}'),
                      onPressed: onReadCoverage,
                      color: const Color(0xFF3277A0),
                      icon: Icons.newspaper_rounded,
                      label:
                          '${context.informationStrings.readCoverage} ($coverageCount)',
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CitizenVoiceCard extends StatelessWidget {
  const CitizenVoiceCard({required this.voice, super.key});

  final CitizenVoice voice;

  @override
  Widget build(BuildContext context) {
    final color = cityTopicColor(voice.topic);
    return CityPaperPanel(
      padding: const EdgeInsets.all(13),
      color: const Color(0xFFF0E4CA),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: cityBriefInk, width: 2),
            ),
            child: Icon(
              _roleIcon(voice.role),
              color: const Color(0xFFFFF1CF),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.citizenRoleLabel(voice.role)} · ${context.l10n.citizenDistrictLabel(voice.district)} · ${context.l10n.citizenSentimentLabel(voice.sentiment)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '“${context.l10n.citizenVoiceQuote(voice)}”',
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
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

IconData cityTopicIcon(CityBriefTopic topic) => switch (topic) {
  CityBriefTopic.food => Icons.shopping_basket_rounded,
  CityBriefTopic.poverty => Icons.home_work_rounded,
  CityBriefTopic.health => Icons.local_hospital_rounded,
  CityBriefTopic.education => Icons.school_rounded,
  CityBriefTopic.water => Icons.water_drop_rounded,
  CityBriefTopic.jobs => Icons.work_rounded,
  CityBriefTopic.cityServices => Icons.directions_bus_rounded,
  CityBriefTopic.climate => Icons.flood_rounded,
};

Color cityTopicColor(CityBriefTopic topic) => switch (topic) {
  CityBriefTopic.food => const Color(0xFFB47A24),
  CityBriefTopic.poverty => const Color(0xFF8C5966),
  CityBriefTopic.health => const Color(0xFF3D8A63),
  CityBriefTopic.education => const Color(0xFF67528D),
  CityBriefTopic.water => const Color(0xFF3277A0),
  CityBriefTopic.jobs => const Color(0xFFC0662E),
  CityBriefTopic.cityServices => const Color(0xFF55717E),
  CityBriefTopic.climate => const Color(0xFF337C79),
};

IconData cityIssueFamilyIcon(CityIssueFamily family) => switch (family) {
  CityIssueFamily.floodingDrainage => Icons.flood_rounded,
  CityIssueFamily.corruptionPublicFunds => Icons.receipt_long_rounded,
  CityIssueFamily.unfinishedRoads => Icons.construction_rounded,
  CityIssueFamily.drugsCommunitySafety => Icons.health_and_safety_rounded,
  CityIssueFamily.garbageCleanliness => Icons.delete_sweep_rounded,
  CityIssueFamily.trafficTransport => Icons.traffic_rounded,
  CityIssueFamily.waterSupply => Icons.water_drop_rounded,
  CityIssueFamily.healthcareCapacity => Icons.local_hospital_rounded,
  CityIssueFamily.employmentQuality => Icons.work_rounded,
  CityIssueFamily.costOfLiving => Icons.shopping_basket_rounded,
  CityIssueFamily.governmentServices => Icons.account_balance_rounded,
  CityIssueFamily.educationCapacity => Icons.school_rounded,
};

Color cityIssueFamilyColor(CityIssueFamily family) => switch (family) {
  CityIssueFamily.floodingDrainage => const Color(0xFF337C79),
  CityIssueFamily.corruptionPublicFunds => const Color(0xFF8C5966),
  CityIssueFamily.unfinishedRoads => const Color(0xFF9B6B2C),
  CityIssueFamily.drugsCommunitySafety => const Color(0xFF765A83),
  CityIssueFamily.garbageCleanliness => const Color(0xFF4C7B59),
  CityIssueFamily.trafficTransport => const Color(0xFF55717E),
  CityIssueFamily.waterSupply => const Color(0xFF3277A0),
  CityIssueFamily.healthcareCapacity => const Color(0xFF3D8A63),
  CityIssueFamily.employmentQuality => const Color(0xFFC0662E),
  CityIssueFamily.costOfLiving => const Color(0xFFB47A24),
  CityIssueFamily.governmentServices => const Color(0xFF5B6374),
  CityIssueFamily.educationCapacity => const Color(0xFF67528D),
};

Offset cityIssueHotspot(CityIssueFamily family) => switch (family) {
  CityIssueFamily.floodingDrainage => const Offset(.17, .75),
  CityIssueFamily.corruptionPublicFunds => const Offset(.52, .49),
  CityIssueFamily.unfinishedRoads => const Offset(.58, .79),
  CityIssueFamily.drugsCommunitySafety => const Offset(.73, .64),
  CityIssueFamily.garbageCleanliness => const Offset(.83, .79),
  CityIssueFamily.trafficTransport => const Offset(.43, .81),
  CityIssueFamily.waterSupply => const Offset(.12, .59),
  CityIssueFamily.healthcareCapacity => const Offset(.34, .58),
  CityIssueFamily.employmentQuality => const Offset(.70, .76),
  CityIssueFamily.costOfLiving => const Offset(.82, .59),
  CityIssueFamily.governmentServices => const Offset(.62, .56),
  CityIssueFamily.educationCapacity => const Offset(.89, .68),
};

IconData _metricIcon(CityMetricKind kind) => switch (kind) {
  CityMetricKind.reliableFoodAccess => Icons.shopping_basket_rounded,
  CityMetricKind.financiallySecureHouseholds => Icons.savings_rounded,
  CityMetricKind.clinicWaitTime => Icons.schedule_rounded,
  CityMetricKind.classroomSize => Icons.groups_rounded,
  CityMetricKind.reliableWater => Icons.water_drop_rounded,
  CityMetricKind.stableEmployment => Icons.work_rounded,
  CityMetricKind.commuteTime => Icons.directions_bus_rounded,
  CityMetricKind.floodReadiness => Icons.flood_rounded,
  CityMetricKind.publicTrust => Icons.handshake_rounded,
  CityMetricKind.budgetRoom => Icons.account_balance_wallet_rounded,
};

IconData _roleIcon(CitizenRole role) => switch (role) {
  CitizenRole.vendor => Icons.storefront_rounded,
  CitizenRole.caregiver => Icons.family_restroom_rounded,
  CitizenRole.clinicWorker => Icons.medical_services_rounded,
  CitizenRole.student => Icons.school_rounded,
  CitizenRole.teacher => Icons.menu_book_rounded,
  CitizenRole.commuter => Icons.directions_bus_rounded,
  CitizenRole.tradesWorker => Icons.construction_rounded,
  CitizenRole.resident => Icons.person_rounded,
};
