import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';

class PlayerSignal extends PositionComponent with CollisionCallbacks {
  PlayerSignal({
    required super.position,
    required this.bounds,
    required this.hasShield,
    required this.onHazardCollision,
  }) : super(
          size: Vector2.all(GameplayConfig.playerDiameter),
          anchor: Anchor.center,
          priority: 20,
        );

  final PlayfieldBounds Function() bounds;
  final bool Function() hasShield;
  final void Function(PositionComponent hazard) onHazardCollision;
  Vector2? _target;
  double _pulse = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox(radius: size.x * .38, anchor: Anchor.center));
  }

  void setTarget(Vector2 target) => _target = target;
  void clearTarget() => _target = null;

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 4;
    final target = _target;
    if (target != null) {
      final clamped = bounds().clampCenter(target, size);
      if (position.distanceTo(clamped) <=
          GameplayConfig.playerArrivalTolerance) {
        position = clamped;
        _target = null;
        return;
      }
      final factor = 1 - math.exp(-GameplayConfig.playerFollowSpeed * dt);
      position += (clamped - position) * factor;
    }
    position = bounds().clampCenter(position, size);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is HazardMarker) onHazardCollision(other);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    if (hasShield()) {
      final shieldPaint = Paint()
        ..color = GameplayConfig.cyan.withOpacity(.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
          center, size.x * (.59 + .025 * math.sin(_pulse)), shieldPaint);
    }
    canvas.drawCircle(
      center,
      size.x * (.44 + .02 * math.sin(_pulse)),
      Paint()..color = GameplayConfig.cyan.withOpacity(.22),
    );
    canvas.drawCircle(
        center, size.x * .31, Paint()..color = GameplayConfig.cyan);
    canvas.drawCircle(
      Offset(size.x * .42, size.y * .38),
      size.x * .1,
      Paint()..color = Colors.white,
    );
  }
}

mixin HazardMarker on PositionComponent {}
