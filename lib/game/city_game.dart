import 'dart:ui';

import 'package:flame/game.dart';

import '../domain/models/city_indicator_set.dart';

class BayhavenCityGame extends FlameGame {
  BayhavenCityGame(this.indicators);

  final CityIndicatorSet indicators;

  @override
  Color backgroundColor() => const Color(0xFFBDE4DF);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final width = size.x;
    final height = size.y;
    final paint = Paint();

    paint.color = const Color(0xFFF3D58C);
    canvas.drawRect(Rect.fromLTWH(0, height * .68, width, height * .32), paint);

    final buildingColors = [
      const Color(0xFF315A6B),
      const Color(0xFF426F77),
      const Color(0xFF27485E),
      const Color(0xFF59847D),
    ];
    for (var i = 0; i < 9; i++) {
      final buildingWidth = width / 10;
      final x = i * width / 9;
      final resilience = indicators.urbanResilience / 100;
      final buildingHeight =
          height * (.20 + ((i * 17) % 5) * .035 + resilience * .08);
      paint.color = buildingColors[i % buildingColors.length];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            height * .68 - buildingHeight,
            buildingWidth,
            buildingHeight,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }

    paint.color = const Color(
      0xFF3D91A3,
    ).withValues(alpha: (1 - indicators.waterSecurity / 160).clamp(.24, .72));
    canvas.drawRect(Rect.fromLTWH(0, height * .86, width, height * .14), paint);

    paint.color = const Color(0xFFFFE9A8);
    canvas.drawCircle(Offset(width * .83, height * .2), 24, paint);
  }
}
