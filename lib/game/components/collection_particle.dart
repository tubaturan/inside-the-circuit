import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CollectionBurst extends PositionComponent {
  CollectionBurst({required super.position, required this.color})
      : super(anchor: Anchor.center, priority: 30);

  final Color color;
  double _age = 0;
  static const _lifetime = .38;
  bool get isExpired => _age >= _lifetime;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (isExpired) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = (_age / _lifetime).clamp(0.0, 1.0).toDouble();
    final radius = 7 + progress * 22;
    final paint = Paint()
      ..color = color.withOpacity(1 - progress)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final inner = Offset(math.cos(angle), math.sin(angle)) * radius * .55;
      final outer = Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawLine(inner, outer, paint);
    }
  }
}
