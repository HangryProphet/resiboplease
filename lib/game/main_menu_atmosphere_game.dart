import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';

class MainMenuAtmosphereGame extends FlameGame {
  double _elapsed = 0;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  void update(double dt) {
    _elapsed += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return;

    const colors = [
      Color(0xBFF4E2AE),
      Color(0xAFC95B3F),
      Color(0xAF2F827B),
      Color(0x9FE2A82A),
    ];
    for (var index = 0; index < 10; index++) {
      final phase = index * 1.73;
      final travel =
          (_elapsed * (9 + index % 3 * 3) + index * 97) % (size.y + 100);
      final y = travel - 50;
      final baseX = size.x * ((index * 0.217) % 1);
      final x = baseX + math.sin(_elapsed * .7 + phase) * 24;
      final angle = math.sin(_elapsed * .9 + phase) * .55;
      final width = 9.0 + (index % 3) * 4;
      final height = 6.0 + (index % 2) * 5;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: width, height: height),
          const Radius.circular(1.5),
        ),
        Paint()..color = colors[index % colors.length],
      );
      canvas.restore();
    }
  }
}
