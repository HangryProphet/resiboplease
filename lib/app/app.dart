import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/state/game_controller.dart';
import 'router.dart';
import 'theme/resibo_theme.dart';

class ResiboPleaseApp extends StatefulWidget {
  const ResiboPleaseApp({super.key});

  @override
  State<ResiboPleaseApp> createState() => _ResiboPleaseAppState();
}

class _ResiboPleaseAppState extends State<ResiboPleaseApp> {
  late final GameController _controller;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _router = buildRouter(_controller);
  }

  @override
  void dispose() {
    _router.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: MaterialApp.router(
      title: 'Resibo, Please',
      debugShowCheckedModeBanner: false,
      theme: buildResiboTheme(),
      routerConfig: _router,
    ),
  );
}
