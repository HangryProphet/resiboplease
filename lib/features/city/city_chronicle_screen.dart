import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/pre_election_city_brief.dart';
import '../../l10n/l10n_extensions.dart';
import 'widgets/city_brief_ui.dart';
import 'widgets/pre_election_navigation_bar.dart';

class CityChronicleScreen extends StatelessWidget {
  const CityChronicleScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final brief = controller.preElectionBrief;
      return Scaffold(
        backgroundColor: const Color(0xFF0B1725),
        bottomNavigationBar: const PreElectionNavigationBar(
          current: PreElectionDestination.chronicle,
        ),
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF172B3E), Color(0xFF09131F)],
              ),
            ),
            child: Column(
              children: [
                CityBriefHeader(
                  title: context.l10n.chronicleTitle,
                  cityName: controller.activeCityName,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('city_chronicle_scroll'),
                    padding: const EdgeInsets.fromLTRB(13, 17, 13, 34),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 980),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CommunityIllustration(
                              cityName: controller.activeCityName,
                            ),
                            const SizedBox(height: 14),
                            const FrozenSnapshotBanner(),
                            const SizedBox(height: 14),
                            CityPaperPanel(
                              child: Text(
                                context.l10n.chronicleIntro,
                                style: const TextStyle(
                                  color: cityBriefInk,
                                  fontSize: 14,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            CitySectionTitle(
                              title: context.l10n.cityNews,
                              icon: Icons.newspaper_rounded,
                            ),
                            const SizedBox(height: 11),
                            for (
                              var index = 0;
                              index < brief.news.length;
                              index++
                            ) ...[
                              KeyedSubtree(
                                key: Key('city_news_${brief.news[index].id}'),
                                child: CityNewsCard(
                                  item: brief.news[index],
                                  cityName: controller.activeCityName,
                                ),
                              ),
                              if (index != brief.news.length - 1)
                                const SizedBox(height: 11),
                            ],
                            const SizedBox(height: 28),
                            CitySectionTitle(
                              title: context.l10n.communityVoices,
                              icon: Icons.record_voice_over_rounded,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              context.l10n.voiceSampleNote,
                              style: const TextStyle(
                                color: Color(0xFFB9C7CF),
                                fontSize: 11,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 11),
                            _VoiceGrid(voices: brief.voices),
                            const SizedBox(height: 29),
                            _ChronicleActions(),
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

class _CommunityIllustration extends StatelessWidget {
  const _CommunityIllustration({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 2.35,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            image: true,
            label: context.l10n.communityVoices,
            child: Image.asset(
              'assets/images/city/bayhaven_community_voices.jpg',
              key: const Key('community_voices_asset'),
              fit: BoxFit.cover,
              alignment: const Alignment(0, -.08),
              filterQuality: FilterQuality.medium,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [.45, 1],
                colors: [Colors.transparent, Color(0xD9172332)],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 11,
            child: Text(
              '${context.l10n.communityVoices.toUpperCase()} · $cityName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFE8B7),
                fontFamily: 'LilitaOne',
                fontSize: 20,
                letterSpacing: .4,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF07111D), width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    ),
  );
}

class _VoiceGrid extends StatelessWidget {
  const _VoiceGrid({required this.voices});

  final List<CitizenVoice> voices;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700 ? 2 : 1;
      const gap = 11.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final voice in voices)
            SizedBox(
              key: Key('citizen_voice_${voice.id}'),
              width: width,
              child: CitizenVoiceCard(voice: voice),
            ),
        ],
      );
    },
  );
}

class _ChronicleActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final city = CityActionButton(
        label: context.l10n.navCity,
        icon: Icons.location_city_rounded,
        color: const Color(0xFF3277A0),
        onPressed: () => context.go('/city'),
      );
      final dossiers = CityActionButton(
        label: context.l10n.meetCandidates,
        icon: Icons.folder_copy_rounded,
        color: ResiboColors.teal,
        onPressed: () => context.go('/candidates'),
      );
      if (constraints.maxWidth < 560) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [city, const SizedBox(height: 12), dossiers],
        );
      }
      return Row(
        children: [
          Expanded(child: city),
          const SizedBox(width: 12),
          Expanded(child: dossiers),
        ],
      );
    },
  );
}
