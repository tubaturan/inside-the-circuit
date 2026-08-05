import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';

class DifficultyPulse extends Component {
  DifficultyPulse({required this.level, required this.gameSize})
      : super(priority: 40);

  final int level;
  final Vector2 Function() gameSize;
  double _age = 0;

  bool get isExpired => _age >= GameplayConfig.difficultyPulseDuration;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (isExpired) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final size = gameSize();
    final progress =
        (_age / GameplayConfig.difficultyPulseDuration).clamp(0.0, 1.0);
    final opacity = math.sin(progress * math.pi).clamp(0.0, 1.0);
    final center = Offset(size.x / 2, size.y * .24);
    final width = math.min(size.x - 48, 310.0);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: 58),
      const Radius.circular(14),
    );

    canvas.drawRRect(
      rect,
      Paint()..color = GameplayConfig.background.withOpacity(opacity * .86),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = GameplayConfig.warning.withOpacity(opacity * .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final label = TextPainter(
      text: TextSpan(
        text: 'SYSTEM LOAD  //  LEVEL $level',
        style: TextStyle(
          color: Colors.white.withOpacity(opacity),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
      canvas,
      center - Offset(label.width / 2, label.height / 2),
    );
  }
}
