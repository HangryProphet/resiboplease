import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/app/router.dart';
import 'package:resiboplease/app/theme/resibo_theme.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/features/tv/dialogue_blip_player.dart';
import 'package:resiboplease/features/tv/tv_broadcast_screen.dart';
import 'package:resiboplease/features/tv/widgets/reporter_r8.dart';
import 'package:resiboplease/features/tv/widgets/visual_novel_dialogue.dart';
import 'package:resiboplease/l10n/app_localizations.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Chronicle opens the matching player-paced TV report', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final game = GameController(activeRun: true);
    final settings = AppSettingsController(store: MemorySettingsStore());
    await settings.setDialogueSounds(false);
    final broadcast = game.informationEcosystem.tvBroadcasts.broadcasts.first;
    final event = game.informationEcosystem.news.eventById(
      broadcast.underlyingEventId,
    )!;
    final router = buildRouter(game, settings)..go('/city/chronicle');
    addTearDown(router.dispose);
    addTearDown(game.dispose);
    addTearDown(settings.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildResiboTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final watch = find.byKey(Key('watch_report_${event.chronicleItemId}'));
    await tester.ensureVisible(watch);
    final watchButton = tester.widget<InkWell>(watch);
    expect(watchButton.onTap, isNotNull);
    watchButton.onTap!();
    await tester.pump();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/tv/${broadcast.id}',
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(Key('tv_broadcast_${broadcast.id}')), findsOneWidget);
    expect(find.byKey(const Key('reporter_r8')), findsOneWidget);
    expect(find.text(broadcast.headline.english.toUpperCase()), findsOneWidget);

    final firstPage = broadcast.dialoguePages.first.text.english;
    String visibleText() =>
        tester.widget<Text>(find.byKey(const Key('tv_dialogue_text'))).data!;
    expect(visibleText(), isNotEmpty);
    expect(visibleText(), isNot(firstPage));

    final dialogueBox = find.byKey(const Key('tv_dialogue_box'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(dialogueBox));
    await mouse.down(tester.getCenter(dialogueBox));
    await mouse.up();
    await tester.pump();
    expect(visibleText(), firstPage);
    expect(find.text('Page 1 of 5'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('Page 2 of 5'), findsOneWidget);

    for (var page = 1; page < broadcast.dialoguePages.length; page++) {
      await tester.tap(dialogueBox);
      await tester.pump();
      expect(visibleText(), broadcast.dialoguePages[page].text.english);
      await tester.tap(dialogueBox);
      await tester.pump();
    }
    expect(find.byKey(const Key('tv_broadcast_end_controls')), findsOneWidget);
    final readArticle = find.byKey(const Key('tv_read_full_article'));
    await tester.ensureVisible(readArticle);
    final readArticleButton = tester.widget<InkWell>(readArticle);
    expect(readArticleButton.onTap, isNotNull);
    readArticleButton.onTap!();
    await tester.pump();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/news/${broadcast.relatedArticleIds.first}',
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byKey(Key('news_article_${broadcast.relatedArticleIds.first}')),
      findsOneWidget,
    );
    expect(find.byKey(Key('article_watch_report_${event.id}')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sound setting, Filipino copy, and disposal are respected', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final game = GameController(activeRun: true);
    final settings = AppSettingsController(store: MemorySettingsStore());
    final player = _RecordingBlipPlayer();
    final broadcast = game.informationEcosystem.tvBroadcasts.broadcasts.first;
    addTearDown(game.dispose);
    addTearDown(settings.dispose);

    await settings.setDialogueSounds(false);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fil'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: TvBroadcastScreen(
            controller: game,
            settingsController: settings,
            broadcastId: broadcast.id,
            blipPlayer: player,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(player.playCount, 0);
    expect(
      find.text(broadcast.headline.filipino.toUpperCase()),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('tv_dialogue_sound_toggle')));
    await tester.pump(const Duration(milliseconds: 180));
    expect(settings.dialogueSounds, isTrue);
    expect(player.playCount, greaterThan(0));

    await tester.tap(find.byKey(const Key('tv_dialogue_box')));
    await tester.pump();
    expect(player.stopCount, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(player.stopCount, greaterThan(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('medium broadcast stage gives both visuals enough space', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(565, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final game = GameController(activeRun: true);
    final settings = AppSettingsController(store: MemorySettingsStore());
    final broadcast = game.informationEcosystem.tvBroadcasts.broadcasts.first;
    addTearDown(game.dispose);
    addTearDown(settings.dispose);

    await settings.setDialogueSounds(false);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: TvBroadcastScreen(
            controller: game,
            settingsController: settings,
            broadcastId: broadcast.id,
            blipPlayer: _RecordingBlipPlayer(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 40));

    expect(
      tester.getSize(find.byKey(const Key('reporter_r8'))).width,
      closeTo(259.9, .1),
    );
    expect(
      tester.getSize(find.byKey(const Key('tv_story_inset'))).width,
      greaterThan(270),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps reporter position still', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(
            child: SizedBox(
              width: 220,
              child: ReporterR8(
                isTalking: true,
                reducedMotion: true,
                semanticLabel: 'R-8',
              ),
            ),
          ),
        ),
      ),
    );
    final transform = tester.widget<Transform>(
      find
          .ancestor(
            of: find.byKey(const Key('reporter_r8')),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.getTranslation().y, 0);
    await tester.pump(const Duration(seconds: 2));
    final after = tester.widget<Transform>(
      find
          .ancestor(
            of: find.byKey(const Key('reporter_r8')),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(after.transform.getTranslation().y, 0);
  });

  test(
    'rapid activation follows complete, advance, complete, finish order',
    () {
      final controller = VisualNovelDialogueController(
        pages: const ['First page.', 'Second page.'],
        timing: const TvDialogueTiming(
          characterDelay: Duration(days: 1),
          commaPause: Duration.zero,
          sentencePause: Duration.zero,
        ),
      );
      addTearDown(controller.dispose);
      controller.start();

      controller.activate();
      expect(controller.visibleText, 'First page.');
      expect(controller.pageIndex, 0);
      expect(controller.isFinished, isFalse);

      controller.activate();
      expect(controller.pageIndex, 1);
      expect(controller.visibleText, isEmpty);

      controller.activate();
      expect(controller.visibleText, 'Second page.');
      expect(controller.isFinished, isFalse);

      controller.activate();
      expect(controller.isFinished, isTrue);
    },
  );
}

class _RecordingBlipPlayer implements DialogueBlipPlayer {
  int playCount = 0;
  int stopCount = 0;

  @override
  void dispose() {}

  @override
  void playBlip() => playCount++;

  @override
  void stop() => stopCount++;
}
