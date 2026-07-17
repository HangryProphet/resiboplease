import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../game/main_menu_atmosphere_game.dart';
import 'widgets/menu_action_button.dart';
import 'widgets/resibo_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _splashLines = <String>[
    'Hanapin ang resibo.',
    'Porma o plataporma?',
    'Facts before fanfare.',
    'Check the source first.',
    'The city remembers.',
    'Popularity is not proof.',
    'Read the fine print.',
    'Walang resibo, bawas tiwala.',
    'Pangako ay madaling sabihin.',
    'Boto now, consequences later.',
    'Not all noise is policy.',
    'May plano ba o slogan lang?',
  ];

  static String? _lastSplashLine;

  late final AnimationController _splashController;
  late final Animation<double> _splashScale;
  late final String _splashLine;

  @override
  void initState() {
    super.initState();
    _splashLine = _pickSplashLine();
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
      reverseDuration: const Duration(milliseconds: 1050),
    )..repeat(reverse: true);
    _splashScale = Tween<double>(begin: 1, end: 1.07).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  String _pickSplashLine() {
    final validLines = _splashLines
        .where((line) => line.length <= 40 && !line.contains('\n'))
        .toList(growable: false);
    final choices = validLines
        .where((line) => line != _lastSplashLine)
        .toList(growable: false);
    final pool = choices.isEmpty ? validLines : choices;
    final selected = pool[Random().nextInt(pool.length)];
    _lastSplashLine = selected;
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final splashScale = reducedMotion
        ? const AlwaysStoppedAnimation<double>(1)
        : _splashScale;

    return Scaffold(
      backgroundColor: ResiboColors.navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            label:
                'Bayhaven civic hall, neighborhoods, clinic, school, drainage canal, and waterfront.',
            image: true,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0x30F4B44B),
                BlendMode.softLight,
              ),
              child: Image.asset(
                'assets/images/main_menu/bayhaven_menu_background_v2.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x2007131D),
                  Color(0x1007131D),
                  Color(0xD0071018),
                  Color(0xFA071018),
                ],
                stops: [0, .28, .58, 1],
              ),
            ),
          ),
          if (!reducedMotion)
            IgnorePointer(
              child: ExcludeSemantics(
                child: GameWidget(game: MainMenuAtmosphereGame()),
              ),
            ),
          SafeArea(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) => LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 880;
                  return wide
                      ? _WideMenu(
                          controller: widget.controller,
                          splashLine: _splashLine,
                          splashScale: splashScale,
                        )
                      : _MobileMenu(
                          controller: widget.controller,
                          splashLine: _splashLine,
                          splashScale: splashScale,
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideMenu extends StatelessWidget {
  const _WideMenu({
    required this.controller,
    required this.splashLine,
    required this.splashScale,
  });

  final GameController controller;
  final String splashLine;
  final Animation<double> splashScale;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1180),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 24),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: _MenuPanel(
                    controller: controller,
                    splashLine: splashLine,
                    splashScale: splashScale,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/main_menu/candidate_group_v2.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  semanticLabel:
                      'Mayoral candidates Julian Pratt, Maya Vargas, and Victor Chen.',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({
    required this.controller,
    required this.splashLine,
    required this.splashScale,
  });

  final GameController controller;
  final String splashLine;
  final Animation<double> splashScale;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final short = constraints.maxHeight < 720;
      final candidateHeight = (constraints.maxWidth / 1.48).clamp(
        short ? 190.0 : 220.0,
        short ? 245.0 : 300.0,
      );
      return SingleChildScrollView(
        physics: short
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Column(
          children: [
            ResiboLogo(compact: short),
            _SplashText(text: splashLine, scale: splashScale, compact: short),
            SizedBox(
              height: candidateHeight,
              width: double.infinity,
              child: const _FadedCandidateGroup(),
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: _MenuActions(controller: controller),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _FadedCandidateGroup extends StatelessWidget {
  const _FadedCandidateGroup();

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (bounds) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.white,
        Color(0xCFFFFFFF),
        Color(0x52FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: [0, .68, .78, .91, 1],
    ).createShader(bounds),
    child: Image.asset(
      'assets/images/main_menu/candidate_group_v2.png',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      semanticLabel:
          'Mayoral candidates Julian Pratt, Maya Vargas, and Victor Chen.',
    ),
  );
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.controller,
    required this.splashLine,
    required this.splashScale,
  });

  final GameController controller;
  final String splashLine;
  final Animation<double> splashScale;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const ResiboLogo(),
      _SplashText(text: splashLine, scale: splashScale),
      const SizedBox(height: 22),
      _MenuActions(controller: controller),
    ],
  );
}

class _SplashText extends StatelessWidget {
  const _SplashText({
    required this.text,
    required this.scale,
    this.compact = false,
  });

  final String text;
  final Animation<double> scale;
  final bool compact;

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: scale,
    alignment: Alignment.center,
    child: Transform.rotate(
      angle: -.012,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 356),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 22,
          vertical: compact ? 7 : 9,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEDBD), Color(0xFFE7C989)],
          ),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFF17242E), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xB0000000), offset: Offset(0, 5)),
          ],
        ),
        child: Text(
          key: const Key('menu_splash_text'),
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF26313A),
            fontSize: compact ? 14 : 16,
            height: 1,
            fontFamily: 'LilitaOne',
            letterSpacing: .25,
            shadows: const [
              Shadow(color: Color(0x50FFFFFF), offset: Offset(0, 1)),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MenuActions extends StatelessWidget {
  const _MenuActions({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: .84,
    child: Column(
      children: [
        MenuActionButton(
          buttonKey: Key(
            controller.hasActiveRun ? 'continue_city' : 'start_bayhaven',
          ),
          label: controller.hasActiveRun ? 'Continue City' : 'Start New City',
          color: const Color(0xFFC5483E),
          onPressed: () => controller.hasActiveRun
              ? context.go('/city')
              : _startNewCity(context),
        ),
        if (controller.hasActiveRun) ...[
          const SizedBox(height: 10),
          _SecondaryNewCityButton(onPressed: () => _startNewCity(context)),
        ],
        const SizedBox(height: 12),
        MenuActionButton(
          label: 'How to Play',
          color: const Color(0xFF2C70A8),
          onPressed: () => _showHowToPlay(context),
        ),
        const SizedBox(height: 12),
        MenuActionButton(
          label: 'Visit Cities',
          color: const Color(0xFF4A873E),
          onPressed: () => _showVisits(context),
        ),
        const SizedBox(height: 17),
        _SettingsButton(onPressed: () => _showSettings(context)),
        const SizedBox(height: 15),
        const Text(
          'A fictional civic decision simulation.\nNot official election guidance.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD7E0E5),
            fontSize: 11,
            height: 1.35,
            shadows: [Shadow(color: Colors.black, blurRadius: 3)],
          ),
        ),
      ],
    ),
  );

  Future<void> _startNewCity(BuildContext context) async {
    if (controller.hasActiveRun) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFC5483E),
            size: 36,
          ),
          title: const Text('Start a new city?'),
          content: const Text(
            'Your current Bayhaven run will be replaced. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep current city'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Start new city'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    controller.startNewRun();
    if (context.mounted) context.go('/city');
  }

  void _showHowToPlay(BuildContext context) => _showPaperDialog(
    context,
    title: 'How to Play',
    icon: Icons.menu_book_rounded,
    body: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GuideStep(number: '1', text: 'Review Bayhaven’s urgent problems.'),
        _GuideStep(
          number: '2',
          text: 'Open candidate dossiers and compare evidence.',
        ),
        _GuideStep(
          number: '3',
          text: 'Choose without a match score or recommendation.',
        ),
        _GuideStep(
          number: '4',
          text: 'Watch one seeded term and inspect its consequences.',
        ),
      ],
    ),
  );

  void _showVisits(BuildContext context) => _showPaperDialog(
    context,
    title: 'Visit Cities',
    icon: Icons.travel_explore_rounded,
    body: const Text(
      'City visits use safe, asynchronous snapshots—not live multiplayer. The menu position is reserved while local snapshot publishing is built.',
    ),
  );

  void _showSettings(BuildContext context) => _showPaperDialog(
    context,
    title: 'Settings',
    icon: Icons.settings_outlined,
    body: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text scaling and reduced motion follow your device accessibility settings. Audio, language, and privacy controls will be added here.',
        ),
        SizedBox(height: 14),
        Divider(),
        _SettingsInfoRow(
          icon: Icons.info_outline_rounded,
          title: 'About Resibo, Please',
          detail: 'A fictional civic decision simulation.',
        ),
        _SettingsInfoRow(
          icon: Icons.groups_outlined,
          title: 'Credits',
          detail: 'Full development credits will appear here.',
        ),
        _SettingsInfoRow(
          icon: Icons.gavel_outlined,
          title: 'Disclaimer',
          detail: 'Not official election guidance.',
        ),
        _SettingsInfoRow(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          detail: 'A release-ready policy will appear here.',
        ),
        _SettingsInfoRow(
          icon: Icons.numbers_rounded,
          title: 'App version',
          detail: '1.0.0 (1)',
        ),
      ],
    ),
  );

  Future<void> _showPaperDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget body,
  }) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      icon: Icon(icon, color: ResiboColors.teal, size: 34),
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: body,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _SecondaryNewCityButton extends StatelessWidget {
  const _SecondaryNewCityButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: .76,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0xB0000000), offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF101820), width: 3),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9C5960), Color(0xFF71373D)],
            ),
          ),
          child: InkWell(
            key: const Key('start_new_city_secondary'),
            onTap: onPressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Text(
                'START NEW CITY',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFF1CF),
                  fontFamily: 'LilitaOne',
                  fontSize: 14,
                  letterSpacing: .5,
                  shadows: [
                    Shadow(color: Colors.black54, offset: Offset(1, 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0xB0000000), offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF0B141C), width: 3),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF344C60), Color(0xFF182B3B)],
            ),
          ),
          child: InkWell(
            key: const Key('settings_button'),
            onTap: onPressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_rounded,
                    color: Color(0xFFFFF1CF),
                    size: 19,
                  ),
                  SizedBox(width: 7),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          color: Color(0xFFFFF1CF),
                          fontFamily: 'LilitaOne',
                          fontSize: 15,
                          letterSpacing: .5,
                          shadows: [
                            Shadow(color: Colors.black54, offset: Offset(1, 2)),
                          ],
                        ),
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

class _SettingsInfoRow extends StatelessWidget {
  const _SettingsInfoRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ResiboColors.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: ResiboColors.navy,
          foregroundColor: Colors.white,
          child: Text(
            number,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
