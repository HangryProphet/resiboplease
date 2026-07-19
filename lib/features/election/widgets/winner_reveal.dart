import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../domain/models/candidate.dart';
import '../../../l10n/l10n_extensions.dart';
import '../../dossier/widgets/dossier_ui.dart';

class WinnerReveal extends StatefulWidget {
  const WinnerReveal({
    required this.candidate,
    required this.cityName,
    super.key,
  });

  final Candidate candidate;
  final String cityName;

  @override
  State<WinnerReveal> createState() => _WinnerRevealState();
}

class _WinnerRevealState extends State<WinnerReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _motionDisabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.of(context).disableAnimations;
    if (_motionDisabled == disabled) return;
    _motionDisabled = disabled;
    if (disabled) {
      _controller
        ..stop()
        ..value = .08;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.candidate.colorValue);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FileStamp(
                    label: context.l10n.winnerDeclared,
                    color: const Color(0xFFFFD36B),
                    angle: -.025,
                    icon: Icons.campaign_rounded,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 330,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _controller.value * math.pi * 2,
                            child: CustomPaint(
                              size: const Size.square(300),
                              painter: _VictoryRaysPainter(),
                            ),
                          ),
                          Container(
                            width: 226,
                            height: 292,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.lerp(color, Colors.white, .28)!,
                                  color,
                                  const Color(0xFF142234),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(120),
                                bottom: Radius.circular(18),
                              ),
                              border: Border.all(
                                color: const Color(0xFFFFD36B),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD36B,
                                  ).withValues(alpha: .48),
                                  blurRadius:
                                      24 +
                                      math.sin(_controller.value * 6.28) * 6,
                                  spreadRadius: 5,
                                ),
                                const BoxShadow(
                                  color: Colors.black87,
                                  offset: Offset(0, 9),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/images/candidates/${widget.candidate.id}/${widget.candidate.id}_portrait.png',
                              key: const Key('winner_portrait'),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                          for (var index = 0; index < 8; index++)
                            _PaperConfetti(
                              angle:
                                  index * math.pi / 4 +
                                  _controller.value * math.pi * 2,
                              radius: 135 + (index.isEven ? 12 : 0),
                              color: index.isEven
                                  ? const Color(0xFFFFD36B)
                                  : index % 3 == 0
                                  ? ResiboColors.teal
                                  : ResiboColors.mutedRed,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    widget.candidate.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFEDBE),
                      fontFamily: 'LuckiestGuy',
                      fontSize: 34,
                      height: 1,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(2, 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.nowGovernsCity(
                      widget.candidate.name,
                      widget.cityName,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ChunkyActionButton(
                      buttonKey: const Key('begin_term'),
                      label: context.l10n.beginTerm,
                      icon: Icons.play_arrow_rounded,
                      color: color,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperConfetti extends StatelessWidget {
  const _PaperConfetti({
    required this.angle,
    required this.radius,
    required this.color,
  });

  final double angle;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
    child: Transform.rotate(
      angle: angle * 1.7,
      child: Container(width: 12, height: 7, color: color),
    ),
  );
}

class _VictoryRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..color = const Color(0x55FFD36B);
    const rayCount = 18;
    for (var index = 0; index < rayCount; index++) {
      final start = index * math.pi * 2 / rayCount;
      final end = start + math.pi / rayCount * .62;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(start) * size.width * .5,
          center.dy + math.sin(start) * size.height * .5,
        )
        ..lineTo(
          center.dx + math.cos(end) * size.width * .5,
          center.dy + math.sin(end) * size.height * .5,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VictoryRaysPainter oldDelegate) => false;
}
