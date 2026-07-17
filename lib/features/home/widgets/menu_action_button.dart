import 'package:flutter/material.dart';

class MenuActionButton extends StatelessWidget {
  const MenuActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.buttonKey,
    super.key,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final highlight = Color.lerp(color, Colors.white, .22)!;
    final shadow = Color.lerp(color, Colors.black, .30)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Color(0xC0000000),
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: Color(0xFF101820), width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [highlight, color, color, shadow],
              stops: const [0, .16, .72, 1],
            ),
          ),
          child: InkWell(
            key: buttonKey,
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 7,
                    right: 7,
                    top: 3,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0x70FFFFFF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: _labelStyle.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 4
                                ..color = const Color(0xFF15212B),
                            ),
                          ),
                          Text(label.toUpperCase(), style: _labelStyle),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 12,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFFFF4D7),
                      size: 31,
                      shadows: [
                        Shadow(color: Colors.black54, offset: Offset(1, 2)),
                      ],
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

  static const _labelStyle = TextStyle(
    color: Color(0xFFFFF1CF),
    fontSize: 21,
    height: 1,
    fontFamily: 'LilitaOne',
    letterSpacing: .6,
    shadows: [Shadow(color: Color(0xB0000000), offset: Offset(1, 3))],
  );
}
