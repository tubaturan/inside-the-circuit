import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/components/player_signal.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';

enum CollectibleType { electron, capacitor }

class Collectible extends PositionComponent with CollisionCallbacks {
  Collectible({
    required this.type,
    required super.position,
    required this.isPlaying,
    required this.onCollected,
  }) : super(
          size: Vector2.all(type == CollectibleType.electron ? 25 : 34),
          anchor: Anchor.center,
          priority: 5,
        );

  final CollectibleType type;
  final bool Function() isPlaying;
  final void Function(Collectible) onCollected;
  double _age = 0;
  double _pulse = 0;
  bool _collected = false;

  double get lifetime => type == CollectibleType.electron
      ? GameplayConfig.electronLifetime
      : GameplayConfig.capacitorLifetime;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox(radius: size.x * .43, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying()) return;
    _age += dt;
    _pulse += dt * 4;
    if (_age >= lifetime) removeFromParent();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_collected && other is PlayerSignal) {
      _collected = true;
      onCollected(this);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final color = type == CollectibleType.electron
        ? GameplayConfig.cyan
        : const Color(0xFFB7FF5A);
    final radius = size.x * (.34 + .025 * math.sin(_pulse));
    canvas.drawCircle(
        center, radius + 4, Paint()..color = color.withOpacity(.22));
    canvas.drawCircle(center, radius, Paint()..color = color);
    if (type == CollectibleType.capacitor) {
      final paint = Paint()
        ..color = const Color(0xFF10230A)
        ..strokeWidth = 3;
      canvas.drawLine(
          Offset(size.x * .42, 7), Offset(size.x * .42, size.y - 7), paint);
      canvas.drawLine(
          Offset(size.x * .58, 7), Offset(size.x * .58, size.y - 7), paint);
    }
  }
}
