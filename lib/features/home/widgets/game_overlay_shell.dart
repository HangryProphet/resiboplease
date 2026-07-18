import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';

Future<T?> showGameOverlay<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: false,
  barrierColor: const Color(0xE600080F),
  transitionDuration: const Duration(milliseconds: 260),
  pageBuilder: (context, animation, secondaryAnimation) => builder(context),
  transitionBuilder: (context, animation, secondaryAnimation, child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: .96, end: 1).animate(curved),
        child: child,
      ),
    );
  },
);

class GameOverlayShell extends StatelessWidget {
  const GameOverlayShell({
    required this.kicker,
    required this.title,
    required this.child,
    required this.onBack,
    this.backTooltip = 'Back to main menu',
    this.maxWidth = 820,
    super.key,
  });

  final String kicker;
  final String title;
  final Widget child;
  final VoidCallback onBack;
  final String backTooltip;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      color: const Color(0xFF071018),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: .18,
            child: Image.asset(
              'assets/images/main_menu/bayhaven_menu_background_v2.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              excludeFromSemantics: true,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [Color(0x2B2E7189), Color(0xEE071018)],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                return AnimatedPadding(
                  duration: reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.fromLTRB(
                    compact ? 7 : 22,
                    compact ? 8 : 16,
                    compact ? 7 : 22,
                    MediaQuery.viewInsetsOf(context).bottom +
                        (compact ? 8 : 16),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                        maxHeight: constraints.maxHeight,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xD9000000),
                              offset: Offset(8, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFEFC4),
                                  Color(0xFFF3D89B),
                                  Color(0xFFE8C481),
                                ],
                                stops: [0, .56, 1],
                              ),
                              border: Border.all(
                                color: const Color(0xFF101820),
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: CustomPaint(
                              painter: const _PaperGrainPainter(),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 10,
                                    right: 10,
                                    top: 10,
                                    bottom: 10,
                                    child: IgnorePointer(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0x3B6A492A),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      _OverlayHeader(
                                        kicker: kicker,
                                        title: title,
                                        compact: compact,
                                        onBack: onBack,
                                        backTooltip: backTooltip,
                                      ),
                                      Expanded(child: child),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayHeader extends StatelessWidget {
  const _OverlayHeader({
    required this.kicker,
    required this.title,
    required this.compact,
    required this.onBack,
    required this.backTooltip,
  });

  final String kicker;
  final String title;
  final bool compact;
  final VoidCallback onBack;
  final String backTooltip;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: compact ? 102 : 112,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          left: compact ? 54 : 82,
          right: compact ? 16 : 82,
          top: compact ? 19 : 22,
          child: Transform.rotate(
            angle: -.012,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 24,
                compact ? 10 : 11,
                compact ? 14 : 24,
                compact ? 9 : 11,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD25C4C),
                    Color(0xFFAA3F36),
                    Color(0xFF772B2A),
                  ],
                ),
                border: Border.all(color: const Color(0xFF101820), width: 3),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Color(0xA8000000), offset: Offset(0, 5)),
                  BoxShadow(color: Color(0x45FFFFFF), offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kicker.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFFFD77B),
                      fontFamily: 'LilitaOne',
                      fontSize: compact ? 10 : 11,
                      height: 1,
                      letterSpacing: 1.7,
                      shadows: const [
                        Shadow(color: Colors.black54, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: _titleStyle(compact).copyWith(
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = const Color(0xFF17212A),
                          ),
                        ),
                        Text(title.toUpperCase(), style: _titleStyle(compact)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: compact ? 12 : 18,
          top: compact ? 22 : 27,
          child: _BackButton(
            onPressed: onBack,
            tooltip: backTooltip,
            compact: compact,
          ),
        ),
      ],
    ),
  );

  TextStyle _titleStyle(bool compact) => TextStyle(
    color: const Color(0xFFFFF2CD),
    fontFamily: 'LilitaOne',
    fontSize: compact ? 25 : 32,
    height: 1,
    letterSpacing: .8,
    shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 3))],
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
    required this.tooltip,
    required this.compact,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final bool compact;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Container(
      decoration: BoxDecoration(
        color: ResiboColors.navy,
        border: Border.all(color: const Color(0xFF101820), width: 3),
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Color(0x9C000000), offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('overlay_back_button'),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: compact ? 43 : 47,
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFFFE6A9),
              size: 27,
            ),
          ),
        ),
      ),
    ),
  );
}

class ChunkyPaperButton extends StatelessWidget {
  const ChunkyPaperButton({
    required this.label,
    required this.onPressed,
    this.color = ResiboColors.navy,
    this.icon,
    this.expand = true,
    this.buttonKey,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final bool expand;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final top = Color.lerp(color, Colors.white, .18)!;
    final bottom = Color.lerp(color, Colors.black, .27)!;
    final button = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(color: Color(0x8F000000), offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: const BorderSide(color: Color(0xFF111B24), width: 3),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, color, bottom],
            ),
          ),
          child: InkWell(
            key: buttonKey,
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 49),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: const Color(0xFFFFF0C8), size: 21),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label.toUpperCase(),
                          maxLines: 1,
                          style: TextStyle(
                            color: onPressed == null
                                ? const Color(0xFFB7AA91)
                                : const Color(0xFFFFF0C8),
                            fontFamily: 'LilitaOne',
                            fontSize: 17,
                            letterSpacing: .65,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(1, 2),
                              ),
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
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class InkStamp extends StatelessWidget {
  const InkStamp({
    required this.text,
    this.color = ResiboColors.mutedRed,
    this.angle = -.035,
    super.key,
  });

  final String text;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontFamily: 'LilitaOne',
          fontSize: 12,
          height: 1,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}

class _PaperGrainPainter extends CustomPainter {
  const _PaperGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0x125E3D20);
    final scratchPaint = Paint()
      ..color = const Color(0x0F5E3D20)
      ..strokeWidth = 1;
    for (var i = 0; i < 135; i++) {
      final x = ((i * 47) % 997) / 997 * size.width;
      final y = ((i * 83) % 991) / 991 * size.height;
      final radius = i % 4 == 0 ? 1.1 : .55;
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
    for (var i = 0; i < 11; i++) {
      final y = ((i * 97 + 31) % 941) / 941 * size.height;
      final x = ((i * 59 + 19) % 887) / 887 * size.width * .65;
      canvas.drawLine(
        Offset(x, y),
        Offset((x + 28 + i * 3).clamp(0, size.width), y + .7),
        scratchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
