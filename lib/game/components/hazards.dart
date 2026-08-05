import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/components/player_signal.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';

enum HazardType { shortCircuit, electricSpark, overheatedChip }

class Hazard extends PositionComponent with HazardMarker {
  Hazard({
    required this.type,
    required super.position,
    required this.velocity,
    required this.bounds,
  }) : super(
          size: Vector2.all(switch (type) {
            HazardType.shortCircuit => 38,
            HazardType.electricSpark => 24,
            HazardType.overheatedChip => 62,
          }),
          anchor: Anchor.center,
          priority: 10,
        );

  final HazardType type;
  final Vector2 velocity;
  final PlayfieldBounds Function() bounds;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox(radius: size.x * .42, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    final area = bounds();
    const margin = 90.0;
    if (position.x < area.left - margin ||
        position.x > area.right + margin ||
        position.y < area.top - margin ||
        position.y > area.bottom + margin) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final color = type == HazardType.overheatedChip
        ? GameplayConfig.warning
        : GameplayConfig.danger;
    if (type == HazardType.electricSpark) {
      final path = Path()
        ..moveTo(size.x * .1, size.y * .55)
        ..lineTo(size.x * .48, size.y * .1)
        ..lineTo(size.x * .4, size.y * .45)
        ..lineTo(size.x * .9, size.y * .35)
        ..lineTo(size.x * .42, size.y * .9);
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke);
    } else if (type == HazardType.overheatedChip) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Offset.zero & Size(size.x, size.y), const Radius.circular(8)),
        Paint()..color = color,
      );
      canvas.drawCircle(
          center, size.x * .18, Paint()..color = const Color(0xFF521612));
    } else {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < 3; i++) {
        final y = size.y * (.25 + i * .25);
        canvas.drawLine(Offset(2, y), Offset(size.x - 2, size.y - y), paint);
      }
      canvas.drawCircle(center, size.x * .16, Paint()..color = Colors.white);
    }
  }
}

Vector2 velocityToward(Vector2 from, Vector2 target, double speed) {
  final delta = target - from;
  if (delta.length2 == 0) return Vector2(0, speed);
  return delta.normalized() * speed;
}

double hazardBaseSpeed(HazardType type) => switch (type) {
      HazardType.shortCircuit => 115,
      HazardType.electricSpark => 185,
      HazardType.overheatedChip => 78,
    };

HazardType weightedHazard(math.Random random, int level) {
  final shift = math.min(level, 8) * .025;
  final shortWeight = .60 - shift;
  final sparkWeight = .25 + shift * .58;
  final roll = random.nextDouble();
  if (roll < shortWeight) return HazardType.shortCircuit;
  if (roll < shortWeight + sparkWeight) return HazardType.electricSpark;
  return HazardType.overheatedChip;
}
