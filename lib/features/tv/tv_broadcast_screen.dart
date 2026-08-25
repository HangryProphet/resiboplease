import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/assets/visual_asset_catalog.dart';
import '../../core/audio/game_audio_service.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/tv_broadcast.dart';
import '../../l10n/tv_broadcast_localizations.dart';
import '../dossier/widgets/dossier_ui.dart';
import '../information/widgets/information_actions.dart';
import 'dialogue_blip_player.dart';
import 'widgets/reporter_r8.dart';
import 'widgets/visual_novel_dialogue.dart';

class TvBroadcastScreen extends StatefulWidget {
  const TvBroadcastScreen({
    required this.controller,
    required this.settingsController,
    required this.broadcastId,
    this.blipPlayer,
    super.key,
  });

  final GameController controller;
  final AppSettingsController settingsController;
  final String broadcastId;
  final DialogueBlipPlayer? blipPlayer;

  @override
  State<TvBroadcastScreen> createState() => _TvBroadcastScreenState();
}

class _TvBroadcastScreenState extends State<TvBroadcastScreen> {
  VisualNovelDialogueController? _dialogueController;
  DialogueBlipPlayer? _blipPlayer;
  String? _languageCode;
  bool _webAudioUnlocked = !kIsWeb;
  GameAudioService? _gameAudio;

  TvBroadcast? get _broadcast => widget
      .controller
      .informationEcosystem
      .tvBroadcasts
      .byId(widget.broadcastId);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextAudio = GameAudioScope.maybeOf(context);
    if (!identical(nextAudio, _gameAudio)) {
      _gameAudio?.setMusicDucked(false);
      _gameAudio = nextAudio;
      _gameAudio?.setMusicDucked(true);
    }
    final languageCode = Localizations.localeOf(context).languageCode;
    if (_dialogueController != null && _languageCode == languageCode) return;
    _languageCode = languageCode;
    _dialogueController?.dispose();
    final broadcast = _broadcast;
    if (broadcast == null) return;
    _blipPlayer ??= widget.blipPlayer ?? AssetDialogueBlipPlayer();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    _dialogueController = VisualNovelDialogueController(
      pages: [
        for (final page in broadcast.dialoguePages)
          page.text.resolve(languageCode),
      ],
      timing: reducedMotion
          ? TvDialogueTiming.reducedMotion
          : TvDialogueTiming.standard,
      onBlip: () {
        if (widget.settingsController.dialogueSounds && _webAudioUnlocked) {
          _blipPlayer?.playBlip();
        }
      },
      onUserActivate: () {
        _webAudioUnlocked = true;
        if (widget.settingsController.dialogueSounds &&
            !(_dialogueController?.isTyping ?? true)) {
          _blipPlayer?.playBlip();
        }
      },
      onTypingStopped: () => _blipPlayer?.stop(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dialogueController?.start();
    });
  }

  @override
  void dispose() {
    _dialogueController?.dispose();
    _blipPlayer?.stop();
    if (widget.blipPlayer == null) _blipPlayer?.dispose();
    _gameAudio?.setMusicDucked(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final broadcast = _broadcast;
    final dialogue = _dialogueController;
    if (broadcast == null || dialogue == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF08111C),
        body: SafeArea(
          child: Center(
            child: ChunkyActionButton(
              label: context.tvStrings.backToChronicle,
              icon: Icons.arrow_back_rounded,
              color: const Color(0xFF304A61),
              onPressed: () => context.go('/city/chronicle'),
            ),
          ),
        ),
      );
    }
    final languageCode = Localizations.localeOf(context).languageCode;
    final strings = context.tvStrings;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      key: Key('tv_broadcast_${broadcast.id}'),
      backgroundColor: const Color(0xFF08111C),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: dialogue,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              key: const Key('tv_broadcast_scroll'),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BroadcastTopBar(
                      date: broadcast.date,
                      liveLabel: strings.live,
                      channelName: strings.channelName,
                      soundEnabled: widget.settingsController.dialogueSounds,
                      soundTooltip: strings.dialogueSounds,
                      onSoundPressed: _toggleDialogueSounds,
                      onBack: () {
                        _gameAudio?.play(GameSound.uiBack);
                        context.canPop()
                            ? context.pop()
                            : context.go('/city/chronicle');
                      },
                    ),
                    _BroadcastStage(
                      broadcast: broadcast,
                      languageCode: languageCode,
                      reporterName: strings.reporterName,
                      reporterTitle: strings.reporterTitle,
                      isTalking: dialogue.isTyping,
                      reducedMotion: reducedMotion,
                    ),
                    _LowerThird(
                      kicker: strings.broadcastType(broadcast.broadcastType),
                      category: broadcast.category.resolve(languageCode),
                      headline: broadcast.headline.resolve(languageCode),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                      child: VisualNovelDialogueBox(
                        controller: dialogue,
                        speakerName: strings.reporterName,
                        speakerTitle: strings.reporterTitle,
                        typingLabel: strings.tapToComplete,
                        nextLabel: strings.tapForNext,
                        finishLabel: strings.tapToFinish,
                        progressLabel: strings.pageProgress(
                          dialogue.pageIndex + 1,
                          dialogue.pageCount,
                        ),
                      ),
                    ),
                    if (dialogue.isFinished)
                      _BroadcastEndControls(
                        broadcast: broadcast,
                        strings: strings,
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

  Future<void> _toggleDialogueSounds() async {
    if (kIsWeb &&
        widget.settingsController.dialogueSounds &&
        !_webAudioUnlocked) {
      setState(() => _webAudioUnlocked = true);
      _blipPlayer?.playBlip();
      return;
    }
    final enabled = !widget.settingsController.dialogueSounds;
    await widget.settingsController.setDialogueSounds(enabled);
    if (!mounted) return;
    setState(() {});
    if (enabled) {
      _webAudioUnlocked = true;
      _blipPlayer?.playBlip();
    } else {
      _blipPlayer?.stop();
    }
  }
}

class _BroadcastTopBar extends StatelessWidget {
  const _BroadcastTopBar({
    required this.date,
    required this.liveLabel,
    required this.channelName,
    required this.soundEnabled,
    required this.soundTooltip,
    required this.onSoundPressed,
    required this.onBack,
  });

  final String date;
  final String liveLabel;
  final String channelName;
  final bool soundEnabled;
  final String soundTooltip;
  final VoidCallback onSoundPressed;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: const BoxDecoration(
      color: Color(0xFF14283B),
      border: Border(bottom: BorderSide(color: Color(0xFF050A10), width: 3)),
      boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(0, 4))],
    ),
    child: Row(
      children: [
        GameIconButton(
          key: const Key('back_from_tv_broadcast'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: Icons.arrow_back_rounded,
          color: const Color(0xFF304A61),
          onPressed: onBack,
        ),
        const SizedBox(width: 10),
        Container(
          width: 38,
          height: 34,
          decoration: BoxDecoration(
            color: ResiboColors.gold,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF07111D), width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            '8',
            style: TextStyle(
              color: Color(0xFF172332),
              fontFamily: 'LuckiestGuy',
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channelName,
                style: const TextStyle(
                  color: Color(0xFFFFEDC2),
                  fontFamily: 'LilitaOne',
                  fontSize: 20,
                  letterSpacing: .7,
                ),
              ),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFB9C8D2),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        GameIconButton(
          key: const Key('tv_dialogue_sound_toggle'),
          tooltip: soundTooltip,
          icon: soundEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          color: soundEnabled
              ? const Color(0xFF3277A0)
              : const Color(0xFF586674),
          onPressed: onSoundPressed,
        ),
        const SizedBox(width: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: ResiboColors.mutedRed,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF07111D), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, color: Colors.white, size: 10),
              const SizedBox(width: 5),
              Text(
                liveLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BroadcastStage extends StatelessWidget {
  const _BroadcastStage({
    required this.broadcast,
    required this.languageCode,
    required this.reporterName,
    required this.reporterTitle,
    required this.isTalking,
    required this.reducedMotion,
  });

  final TvBroadcast broadcast;
  final String languageCode;
  final String reporterName;
  final String reporterTitle;
  final bool isTalking;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 720;
      final stageWidth = constraints.maxWidth;
      final reporterWidth = wide
          ? (stageWidth * .38).clamp(285.0, 360.0)
          : (stageWidth * .46).clamp(180.0, 260.0);
      final storyWidth = wide
          ? (stageWidth * .48).clamp(340.0, 500.0)
          : (stageWidth * .48).clamp(186.0, 275.0);
      final height = wide ? 420.0 : (reporterWidth * 1.36).clamp(300.0, 350.0);
      final assetPath = broadcast.visualAssetKey == null
          ? null
          : VisualAssetCatalog.information(broadcast.visualAssetKey!);
      return SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF274F63), Color(0xFF102130)],
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: _StudioLinesPainter())),
            Positioned(
              left: wide ? 30 : 4,
              bottom: wide ? -36 : -30,
              width: reporterWidth,
              height: reporterWidth * 1.5,
              child: ReporterR8(
                isTalking: isTalking,
                reducedMotion: reducedMotion,
                semanticLabel: '$reporterName, $reporterTitle',
              ),
            ),
            Positioned(
              top: wide ? 34 : 24,
              right: wide ? 38 : 12,
              width: storyWidth,
              child: _StoryInset(
                assetPath: assetPath,
                semanticLabel: broadcast.headline.resolve(languageCode),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 34,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC050A10)],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _StoryInset extends StatelessWidget {
  const _StoryInset({required this.assetPath, required this.semanticLabel});

  final String? assetPath;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => AspectRatio(
    key: const Key('tv_story_inset'),
    aspectRatio: 16 / 9,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09131E),
        border: Border.all(color: const Color(0xFFFFD77A), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black87, offset: Offset(4, 5), blurRadius: 4),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: assetPath == null
          ? const Icon(
              Icons.videocam_rounded,
              color: Color(0xFFFFE7B0),
              size: 54,
            )
          : Semantics(
              image: true,
              label: semanticLabel,
              child: Image.asset(
                assetPath!,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
    ),
  );
}

class _LowerThird extends StatelessWidget {
  const _LowerThird({
    required this.kicker,
    required this.category,
    required this.headline,
  });

  final String kicker;
  final String category;
  final String headline;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF0D1B28),
      border: Border(
        top: BorderSide(color: Color(0xFFFFD778), width: 3),
        bottom: BorderSide(color: Color(0xFF050A10), width: 3),
      ),
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 112,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
            color: ResiboColors.mutedRed,
            alignment: Alignment.center,
            child: Text(
              kicker,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'LilitaOne',
                fontSize: 13,
                height: 1.05,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFD778),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    headline.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFEEC8),
                      fontFamily: 'LilitaOne',
                      fontSize: 19,
                      height: 1.03,
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

class _BroadcastEndControls extends StatelessWidget {
  const _BroadcastEndControls({required this.broadcast, required this.strings});

  final TvBroadcast broadcast;
  final TvBroadcastStrings strings;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('tv_broadcast_end_controls'),
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF14283B),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF050A10), width: 3),
      boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 5))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.broadcastComplete.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFD778),
            fontFamily: 'LuckiestGuy',
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          strings.sharedEventNotice,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD5E0E6),
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 9,
          runSpacing: 9,
          children: [
            InformationActionButton(
              buttonKey: const Key('tv_back_to_chronicle'),
              icon: Icons.newspaper_rounded,
              color: const Color(0xFF3277A0),
              label: strings.backToChronicle,
              onPressed: () => context.go('/city/chronicle'),
            ),
            if (broadcast.relatedArticleIds.isNotEmpty)
              InformationActionButton(
                buttonKey: const Key('tv_read_full_article'),
                icon: Icons.article_rounded,
                color: ResiboColors.teal,
                label: strings.readFullArticle,
                onPressed: () =>
                    context.go('/news/${broadcast.relatedArticleIds.first}'),
              ),
          ],
        ),
      ],
    ),
  );
}

class _StudioLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1AFFF0C8)
      ..strokeWidth = 2;
    for (var x = -size.height; x < size.width; x += 42) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
