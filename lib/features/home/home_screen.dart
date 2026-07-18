import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/state/game_controller.dart';
import '../../game/main_menu_atmosphere_game.dart';
import '../../l10n/l10n_extensions.dart';
import 'widgets/city_slots_overlay.dart';
import 'widgets/how_to_play_overlay.dart';
import 'widgets/menu_action_button.dart';
import 'widgets/resibo_logo.dart';
import 'widgets/settings_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.controller,
    this.settingsController,
    super.key,
  });

  final GameController controller;
  final AppSettingsController? settingsController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static final Map<String, String> _lastSplashLines = {};

  late final AnimationController _splashController;
  late final Animation<double> _splashScale;
  late final AppSettingsController _settingsController;
  late final bool _ownsSettingsController;
  String _splashLine = '';
  String? _splashLocale;

  @override
  void initState() {
    super.initState();
    _ownsSettingsController = widget.settingsController == null;
    _settingsController =
        widget.settingsController ??
        AppSettingsController(store: MemorySettingsStore());
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).toLanguageTag();
    if (_splashLocale == locale) return;
    _splashLocale = locale;
    _splashLine = _pickSplashLine(context.l10n.menuSplashLines, locale);
  }

  @override
  void dispose() {
    _splashController.dispose();
    if (_ownsSettingsController) _settingsController.dispose();
    super.dispose();
  }

  String _pickSplashLine(List<String> lines, String locale) {
    final validLines = lines
        .where((line) => line.length <= 40 && !line.contains('\n'))
        .toList(growable: false);
    final choices = validLines
        .where((line) => line != _lastSplashLines[locale])
        .toList(growable: false);
    final pool = choices.isEmpty ? validLines : choices;
    final selected = pool[Random().nextInt(pool.length)];
    _lastSplashLines[locale] = selected;
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
            label: context.l10n.menuBackgroundSemantics,
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
                          settingsController: _settingsController,
                          splashLine: _splashLine,
                          splashScale: splashScale,
                        )
                      : _MobileMenu(
                          controller: widget.controller,
                          settingsController: _settingsController,
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
    required this.settingsController,
    required this.splashLine,
    required this.splashScale,
  });

  final GameController controller;
  final AppSettingsController settingsController;
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
                    settingsController: settingsController,
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
                  semanticLabel: context.l10n.candidateGroupSemantics,
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
    required this.settingsController,
    required this.splashLine,
    required this.splashScale,
  });

  final GameController controller;
  final AppSettingsController settingsController;
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
                child: _MenuActions(
                  controller: controller,
                  settingsController: settingsController,
                ),
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
      semanticLabel: context.l10n.candidateGroupSemantics,
    ),
  );
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.controller,
    required this.settingsController,
    required this.splashLine,
    required this.splashScale,
  });

  final GameController controller;
  final AppSettingsController settingsController;
  final String splashLine;
  final Animation<double> splashScale;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const ResiboLogo(),
      _SplashText(text: splashLine, scale: splashScale),
      const SizedBox(height: 22),
      _MenuActions(
        controller: controller,
        settingsController: settingsController,
      ),
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
  const _MenuActions({
    required this.controller,
    required this.settingsController,
  });

  final GameController controller;
  final AppSettingsController settingsController;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: .84,
    child: Column(
      children: [
        MenuActionButton(
          buttonKey: Key(
            controller.hasActiveRun ? 'continue_city' : 'start_bayhaven',
          ),
          label: controller.hasActiveRun
              ? context.l10n.continueCity
              : context.l10n.startNewCity,
          color: const Color(0xFFC5483E),
          onPressed: () => _openCitySlots(
            context,
            controller.hasActiveRun
                ? CitySlotsMode.continueRun
                : CitySlotsMode.start,
          ),
        ),
        if (controller.hasActiveRun) ...[
          const SizedBox(height: 12),
          MenuActionButton(
            buttonKey: const Key('start_new_city_secondary'),
            label: context.l10n.startNewCity,
            color: const Color(0xFF8F4550),
            onPressed: () => _openCitySlots(context, CitySlotsMode.start),
          ),
        ],
        const SizedBox(height: 12),
        MenuActionButton(
          buttonKey: const Key('how_to_play_button'),
          label: context.l10n.howToPlay,
          color: const Color(0xFF2C70A8),
          onPressed: () => showHowToPlayOverlay(context),
        ),
        const SizedBox(height: 12),
        MenuActionButton(
          label: context.l10n.visitCities,
          color: const Color(0xFF4A873E),
          onPressed: () => _showVisits(context),
        ),
        const SizedBox(height: 17),
        _SettingsButton(
          label: context.l10n.settings,
          onPressed: () => showSettingsOverlay(
            context: context,
            controller: settingsController,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          context.l10n.fictionalDisclaimer,
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

  Future<void> _openCitySlots(BuildContext context, CitySlotsMode mode) async {
    final openCity = await showCitySlotsOverlay(
      context: context,
      controller: controller,
      mode: mode,
    );
    if (openCity && context.mounted) {
      context.go(controller.activeResumeRoute);
    }
  }

  void _showVisits(BuildContext context) => _showPaperDialog(
    context,
    title: context.l10n.visitCities,
    icon: Icons.travel_explore_rounded,
    body: Text(context.l10n.visitCitiesBody),
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
          child: Text(context.l10n.gotIt),
        ),
      ],
    ),
  );
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.label, required this.onPressed});

  final String label;
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.settings_rounded,
                    color: Color(0xFFFFF1CF),
                    size: 19,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label.toUpperCase(),
                        style: const TextStyle(
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
