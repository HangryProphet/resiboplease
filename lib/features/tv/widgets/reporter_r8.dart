import 'dart:async';

import 'package:flutter/material.dart';

class ReporterR8 extends StatefulWidget {
  const ReporterR8({
    required this.isTalking,
    required this.reducedMotion,
    required this.semanticLabel,
    super.key,
  });

  final bool isTalking;
  final bool reducedMotion;
  final String semanticLabel;

  @override
  State<ReporterR8> createState() => _ReporterR8State();
}

class _ReporterR8State extends State<ReporterR8>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;
  Timer? _talkTimer;
  bool _brightMouth = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant ReporterR8 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTalking != widget.isTalking ||
        oldWidget.reducedMotion != widget.reducedMotion) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.reducedMotion) {
      _idleController.stop();
      _idleController.value = 0;
    } else if (!_idleController.isAnimating) {
      _idleController.repeat(reverse: true);
    }
    _talkTimer?.cancel();
    _talkTimer = null;
    if (widget.isTalking && !widget.reducedMotion) {
      _talkTimer = Timer.periodic(const Duration(milliseconds: 145), (_) {
        if (mounted) setState(() => _brightMouth = !_brightMouth);
      });
    } else {
      _brightMouth = widget.isTalking;
    }
  }

  @override
  void dispose() {
    _talkTimer?.cancel();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: widget.semanticLabel,
    child: AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          widget.reducedMotion ? 0 : -2.5 * _idleController.value,
        ),
        child: child,
      ),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            key: const Key('reporter_r8'),
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/tv/reporter_r8.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    const _ReporterAssetFallback(),
              ),
              Positioned(
                left: constraints.maxWidth * .403,
                top: constraints.maxHeight * .267,
                width: constraints.maxWidth * .262,
                height: constraints.maxHeight * .038,
                child: AnimatedOpacity(
                  opacity: widget.isTalking ? 1 : 0,
                  duration: widget.reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 70),
                  child: DecoratedBox(
                    key: const Key('reporter_r8_mouth_light'),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: _brightMouth
                            ? const [Color(0xFFFFE38D), Color(0xFFE75A44)]
                            : const [Color(0xFFB9444B), Color(0xFF6D2833)],
                      ),
                      boxShadow: _brightMouth
                          ? const [
                              BoxShadow(
                                color: Color(0xAAFFD36A),
                                blurRadius: 9,
                              ),
                            ]
                          : const [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ReporterAssetFallback extends StatelessWidget {
  const _ReporterAssetFallback();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: FractionallySizedBox(
      widthFactor: .82,
      heightFactor: .86,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF17364A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(90)),
          border: Border.all(color: const Color(0xFF07111D), width: 4),
          boxShadow: const [
            BoxShadow(color: Colors.black54, offset: Offset(5, 6)),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_rounded, color: Color(0xFFFFD778), size: 72),
            SizedBox(height: 8),
            Text(
              'R-8',
              style: TextStyle(
                color: Color(0xFFFFEDC2),
                fontFamily: 'LuckiestGuy',
                fontSize: 27,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
