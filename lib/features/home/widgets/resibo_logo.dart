import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';

class ResiboLogo extends StatelessWidget {
  const ResiboLogo({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 60.0 : 82.0;
    return Semantics(
      header: true,
      label: 'Resibo, Please',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Transform.rotate(
                angle: -.025,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'RESIBO,',
                      style: _titleStyle(titleSize).copyWith(
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = compact ? 9 : 12
                          ..color = const Color(0xFF101820),
                      ),
                    ),
                    Text('RESIBO,', style: _titleStyle(titleSize)),
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, compact ? -2 : -4),
            child: Transform.rotate(
              angle: .018,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 22 : 30,
                  vertical: compact ? 3 : 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFC75A63),
                      ResiboColors.mutedRed,
                      Color(0xFF7C2733),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFF101820), width: 4),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(color: Color(0xB0000000), offset: Offset(0, 6)),
                    BoxShadow(
                      color: Color(0x50FFFFFF),
                      offset: Offset(0, 2),
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  'PLEASE',
                  style: TextStyle(
                    color: const Color(0xFFFFF3D0),
                    fontSize: compact ? 38 : 50,
                    fontFamily: 'LilitaOne',
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: const [
                      Shadow(color: Color(0xFF101820), offset: Offset(2, 2)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle(double size) => TextStyle(
    color: const Color(0xFFFFF3D0),
    fontSize: size,
    fontFamily: 'LuckiestGuy',
    height: .9,
    fontWeight: FontWeight.w900,
    letterSpacing: -2,
    shadows: const [Shadow(color: Color(0xB0000000), offset: Offset(0, 8))],
  );
}
