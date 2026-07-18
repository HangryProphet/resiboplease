import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/state/game_controller.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/resibo_theme.dart';

class ResiboPleaseApp extends StatefulWidget {
  const ResiboPleaseApp({
    this.gameController,
    this.settingsController,
    super.key,
  });

  final GameController? gameController;
  final AppSettingsController? settingsController;

  @override
  State<ResiboPleaseApp> createState() => _ResiboPleaseAppState();
}

class _ResiboPleaseAppState extends State<ResiboPleaseApp> {
  late final GameController _controller;
  late final bool _ownsGameController;
  late final AppSettingsController _settingsController;
  late final bool _ownsSettingsController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _ownsGameController = widget.gameController == null;
    _controller = widget.gameController ?? GameController();
    _ownsSettingsController = widget.settingsController == null;
    _settingsController =
        widget.settingsController ??
        AppSettingsController(store: MemorySettingsStore());
    _router = buildRouter(_controller, _settingsController);
  }

  @override
  void dispose() {
    _router.dispose();
    if (_ownsGameController) _controller.dispose();
    if (_ownsSettingsController) _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _settingsController,
    builder: (context, _) => ProviderScope(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        locale: _settingsController.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildResiboTheme(highContrast: _settingsController.highContrast),
        highContrastTheme: buildResiboTheme(highContrast: true),
        routerConfig: _router,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              disableAnimations:
                  mediaQuery.disableAnimations ||
                  _settingsController.reduceMotion,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    ),
  );
}
