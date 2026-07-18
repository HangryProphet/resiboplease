import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import 'game_overlay_shell.dart';

Future<void> showHowToPlayOverlay(BuildContext context) =>
    showGameOverlay<void>(
      context: context,
      builder: (overlayContext) => GameOverlayShell(
        kicker: 'The voter\'s pocket guide',
        title: 'How to Play',
        onBack: () => Navigator.pop(overlayContext),
        child: const _HowToPlaySheet(),
      ),
    );

class _HowToPlaySheet extends StatelessWidget {
  const _HowToPlaySheet();

  static const _steps = <_GuideCopy>[
    _GuideCopy(
      number: '1',
      icon: Icons.location_city_rounded,
      color: Color(0xFF2B6E87),
      title: 'Read the city',
      body: 'See what is going wrong and which problems need attention first.',
    ),
    _GuideCopy(
      number: '2',
      icon: Icons.folder_copy_rounded,
      color: Color(0xFF74508A),
      title: 'Check the candidates',
      body:
          'Open their files. Compare promises, records, and sources. Noise is not proof.',
    ),
    _GuideCopy(
      number: '3',
      icon: Icons.how_to_vote_rounded,
      color: Color(0xFFAA3F4B),
      title: 'Choose for yourself',
      body: 'Cast your vote. The game will not tell you who is “best.”',
    ),
    _GuideCopy(
      number: '4',
      icon: Icons.hourglass_bottom_rounded,
      color: Color(0xFFB67923),
      title: 'Watch the term',
      body:
          'Your choice governs. Plans, skill, honesty, money, and surprise events shape the city.',
    ),
    _GuideCopy(
      number: '5',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF3E783A),
      title: 'Find the receipts',
      body:
          'See what improved, what got worse, and why. Then carry that city into the next election.',
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 680;
      return ListView(
        key: const Key('how_to_play_sheet'),
        padding: EdgeInsets.fromLTRB(wide ? 34 : 17, 4, wide ? 34 : 17, 24),
        children: [
          const _VoterBrief(),
          const SizedBox(height: 16),
          if (wide)
            Wrap(
              spacing: 13,
              runSpacing: 13,
              children: [
                for (final step in _steps)
                  SizedBox(
                    width: (constraints.maxWidth - 34 * 2 - 13) / 2,
                    child: _GuideStepCard(copy: step),
                  ),
              ],
            )
          else
            ..._steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _GuideStepCard(copy: step),
              ),
            ),
          const SizedBox(height: 15),
          const _RememberNote(),
          const SizedBox(height: 19),
          ChunkyPaperButton(
            label: 'Back to Main Menu',
            icon: Icons.arrow_back_rounded,
            color: ResiboColors.navy,
            buttonKey: const Key('close_how_to_play'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

class _VoterBrief extends StatelessWidget {
  const _VoterBrief();

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: .008,
    child: Container(
      padding: const EdgeInsets.fromLTRB(17, 14, 17, 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D8),
        border: Border.all(color: const Color(0xFF594127), width: 2),
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(color: Color(0x43604426), offset: Offset(3, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.campaign_rounded,
            color: ResiboColors.mutedRed,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU ARE THE VOTER',
                  style: TextStyle(
                    color: ResiboColors.navy,
                    fontFamily: 'LilitaOne',
                    fontSize: 19,
                    letterSpacing: .6,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Help a fictional city, one election at a time. Look for good evidence, make a choice, and live with the result.',
                  style: TextStyle(
                    color: Color(0xFF382E24),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _GuideStepCard extends StatelessWidget {
  const _GuideStepCard({required this.copy});

  final _GuideCopy copy;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 108),
    decoration: BoxDecoration(
      color: const Color(0xEFFFF8E8),
      border: Border.all(color: const Color(0xFF5C452C), width: 2),
      borderRadius: BorderRadius.circular(5),
      boxShadow: const [
        BoxShadow(color: Color(0x33604426), offset: Offset(2, 3)),
      ],
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 62,
            decoration: BoxDecoration(
              color: copy.color,
              border: const Border(
                right: BorderSide(color: Color(0xFF1A2228), width: 3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  copy.number,
                  style: const TextStyle(
                    color: Color(0xFFFFF1C9),
                    fontFamily: 'LuckiestGuy',
                    fontSize: 27,
                    height: 1,
                    shadows: [
                      Shadow(color: Colors.black54, offset: Offset(1, 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Icon(copy.icon, color: const Color(0xFFFFF1C9), size: 25),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.title.toUpperCase(),
                    style: const TextStyle(
                      color: ResiboColors.navy,
                      fontFamily: 'LilitaOne',
                      fontSize: 17,
                      height: 1,
                      letterSpacing: .35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    copy.body,
                    style: const TextStyle(
                      color: Color(0xFF40352A),
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RememberNote extends StatelessWidget {
  const _RememberNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
    decoration: BoxDecoration(
      color: const Color(0x1A16263B),
      border: Border.all(color: ResiboColors.navy, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Row(
      children: [
        InkStamp(text: 'Remember', color: ResiboColors.navy),
        SizedBox(width: 13),
        Expanded(
          child: Text(
            'There is rarely a perfect candidate. Read. Question. Decide. See what happens.',
            style: TextStyle(
              color: ResiboColors.navy,
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _GuideCopy {
  const _GuideCopy({
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final String number;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}
