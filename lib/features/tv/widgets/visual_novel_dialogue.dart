import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvDialogueTiming {
  const TvDialogueTiming({
    required this.characterDelay,
    required this.commaPause,
    required this.sentencePause,
    this.blipCharacterInterval = 3,
  });

  static const standard = TvDialogueTiming(
    characterDelay: Duration(milliseconds: 34),
    commaPause: Duration(milliseconds: 55),
    sentencePause: Duration(milliseconds: 105),
  );

  static const reducedMotion = TvDialogueTiming(
    characterDelay: Duration(milliseconds: 10),
    commaPause: Duration(milliseconds: 15),
    sentencePause: Duration(milliseconds: 25),
    blipCharacterInterval: 4,
  );

  final Duration characterDelay;
  final Duration commaPause;
  final Duration sentencePause;
  final int blipCharacterInterval;
}

class VisualNovelDialogueController extends ChangeNotifier {
  VisualNovelDialogueController({
    required List<String> pages,
    required this.timing,
    this.onBlip,
    this.onUserActivate,
    this.onTypingStopped,
  }) : assert(pages.isNotEmpty),
       pages = List.unmodifiable(pages);

  final List<String> pages;
  final TvDialogueTiming timing;
  final VoidCallback? onBlip;
  final VoidCallback? onUserActivate;
  final VoidCallback? onTypingStopped;

  int _pageIndex = 0;
  int _visibleCharacters = 0;
  int _eligibleSinceBlip = 0;
  bool _finished = false;
  bool _disposed = false;
  Timer? _typingTimer;

  int get pageIndex => _pageIndex;
  int get pageCount => pages.length;
  String get currentPage => pages[_pageIndex];
  String get visibleText =>
      currentPage.substring(0, _visibleCharacters.clamp(0, currentPage.length));
  bool get isTyping => !_finished && _visibleCharacters < currentPage.length;
  bool get isCurrentPageRevealed => _visibleCharacters >= currentPage.length;
  bool get isLastPage => _pageIndex == pages.length - 1;
  bool get isFinished => _finished;

  void start() {
    if (_disposed || _finished || !isTyping) return;
    _typingTimer?.cancel();
    _scheduleNextCharacter();
  }

  void activate() {
    if (_disposed || _finished) return;
    onUserActivate?.call();
    if (isTyping) {
      _completeCurrentPage();
      return;
    }
    if (isLastPage) {
      _finished = true;
      onTypingStopped?.call();
      notifyListeners();
      return;
    }
    _pageIndex++;
    _visibleCharacters = 0;
    _eligibleSinceBlip = 0;
    notifyListeners();
    start();
  }

  void _completeCurrentPage() {
    _typingTimer?.cancel();
    _typingTimer = null;
    _visibleCharacters = currentPage.length;
    _eligibleSinceBlip = 0;
    onTypingStopped?.call();
    notifyListeners();
  }

  void _scheduleNextCharacter() {
    if (_disposed || _finished || !isTyping) return;
    final character = currentPage[_visibleCharacters];
    _typingTimer = Timer(_delayFor(character), () {
      _typingTimer = null;
      if (_disposed || _finished || !isTyping) return;
      _visibleCharacters++;
      if (_canBlip(character)) {
        _eligibleSinceBlip++;
        if (_eligibleSinceBlip >= timing.blipCharacterInterval) {
          _eligibleSinceBlip = 0;
          onBlip?.call();
        }
      }
      notifyListeners();
      if (isTyping) {
        _scheduleNextCharacter();
      } else {
        onTypingStopped?.call();
      }
    });
  }

  Duration _delayFor(String character) {
    if (character == ',' || character == ';' || character == ':') {
      return timing.characterDelay + timing.commaPause;
    }
    if (character == '.' || character == '?' || character == '!') {
      return timing.characterDelay + timing.sentencePause;
    }
    return timing.characterDelay;
  }

  bool _canBlip(String character) =>
      character.trim().isNotEmpty && !RegExp(r'[^\w]').hasMatch(character);

  @override
  void dispose() {
    _disposed = true;
    _typingTimer?.cancel();
    _typingTimer = null;
    onTypingStopped?.call();
    super.dispose();
  }
}

class VisualNovelDialogueBox extends StatelessWidget {
  const VisualNovelDialogueBox({
    required this.controller,
    required this.speakerName,
    required this.speakerTitle,
    required this.typingLabel,
    required this.nextLabel,
    required this.finishLabel,
    required this.progressLabel,
    super.key,
  });

  final VisualNovelDialogueController controller;
  final String speakerName;
  final String speakerTitle;
  final String typingLabel;
  final String nextLabel;
  final String finishLabel;
  final String progressLabel;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final instruction = controller.isTyping
          ? typingLabel
          : controller.isLastPage
          ? finishLabel
          : nextLabel;
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter): controller.activate,
          const SingleActivator(LogicalKeyboardKey.space): controller.activate,
        },
        child: Focus(
          autofocus: true,
          child: Semantics(
            button: true,
            label: '$speakerName. $instruction',
            onTap: controller.activate,
            child: Material(
              key: const Key('tv_dialogue_box'),
              color: const Color(0xFFF9E9C1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFF07111D), width: 3),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: controller.activate,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 168),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(17, 14, 17, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A3449),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: const Color(0xFF07111D),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                speakerName,
                                style: const TextStyle(
                                  color: Color(0xFFFFEDC2),
                                  fontFamily: 'LilitaOne',
                                  fontSize: 17,
                                  letterSpacing: .6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                speakerTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF65553E),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              progressLabel,
                              style: const TextStyle(
                                color: Color(0xFF65553E),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 70),
                          child: Text(
                            controller.visibleText,
                            key: const Key('tv_dialogue_text'),
                            style: const TextStyle(
                              color: Color(0xFF172332),
                              fontSize: 17,
                              height: 1.38,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                instruction,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: Color(0xFF725634),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              controller.isTyping
                                  ? Icons.fast_forward_rounded
                                  : Icons.arrow_drop_down_circle_rounded,
                              color: const Color(0xFFB9444B),
                              size: 19,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
