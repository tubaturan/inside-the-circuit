import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';

class CircuitBackground extends Component {
  double _offset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _offset = (_offset + dt * 7) % 64;
  }

  @override
  void render(Canvas canvas) {
    final linePaint = Paint()
      ..color = GameplayConfig.cyan.withOpacity(.075)
      ..strokeWidth = 1;
    final nodePaint = Paint()..color = GameplayConfig.cyan.withOpacity(.16);

    for (var x = -64.0 + _offset; x < 900; x += 64) {
      canvas.drawLine(Offset(x, 0), Offset(x, 1800), linePaint);
    }
    for (var y = 76.0 + _offset; y < 1800; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(900, y), linePaint);
      for (var x = 32.0; x < 900; x += 128) {
        canvas.drawCircle(Offset(x, y), 2.2, nodePaint);
      }
    }
  }
}
