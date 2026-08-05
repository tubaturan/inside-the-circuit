import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/components/player_signal.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';

enum HazardType { shortCircuit, electricSpark, overheatedChip }

abstract class Hazard extends PositionComponent with HazardMarker {
  Hazard({
    required super.position,
    required this.velocity,
    required this.bounds,
    required double diameter,
  }) : super(
          size: Vector2.all(diameter),
          anchor: Anchor.center,
          priority: 10,
        );

  final Vector2 velocity;
  final PlayfieldBounds Function() bounds;
  HazardType get type;
  double get hitboxScale;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(
        CircleHitbox(radius: size.x * hitboxScale, anchor: Anchor.center));
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
}

class ShortCircuit extends Hazard {
  ShortCircuit({
    required super.position,
    required super.velocity,
    required super.bounds,
  }) : super(diameter: 38);

  @override
  HazardType get type => HazardType.shortCircuit;
  @override
  double get hitboxScale => .4;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GameplayConfig.danger
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      final y = size.y * (.25 + i * .25);
      canvas.drawLine(Offset(2, y), Offset(size.x - 2, size.y - y), paint);
    }
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * .16,
      Paint()..color = Colors.white,
    );
  }
}

class ElectricSpark extends Hazard {
  ElectricSpark({
    required super.position,
    required super.velocity,
    required super.bounds,
  }) : super(diameter: 24);

  @override
  HazardType get type => HazardType.electricSpark;
  @override
  double get hitboxScale => .36;

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..moveTo(size.x * .1, size.y * .55)
      ..lineTo(size.x * .48, size.y * .1)
      ..lineTo(size.x * .4, size.y * .45)
      ..lineTo(size.x * .9, size.y * .35)
      ..lineTo(size.x * .42, size.y * .9);
    canvas.drawPath(
      path,
      Paint()
        ..color = GameplayConfig.danger
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }
}

class OverheatedChip extends Hazard {
  OverheatedChip({
    required super.position,
    required super.velocity,
    required super.bounds,
  }) : super(diameter: 62);

  @override
  HazardType get type => HazardType.overheatedChip;
  @override
  double get hitboxScale => .45;

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & Size(size.x, size.y),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = GameplayConfig.warning);
    canvas.drawRRect(
      rect.deflate(7),
      Paint()
        ..color = const Color(0xFF521612)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    for (var i = 0; i < 4; i++) {
      final offset = 10.0 + i * 14;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, 6),
        Paint()
          ..color = const Color(0xFFFFC17D)
          ..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(offset, size.y - 6),
        Offset(offset, size.y),
        Paint()
          ..color = const Color(0xFFFFC17D)
          ..strokeWidth = 3,
      );
    }
  }
}

Hazard createHazard({
  required HazardType type,
  required Vector2 position,
  required Vector2 velocity,
  required PlayfieldBounds Function() bounds,
}) =>
    switch (type) {
      HazardType.shortCircuit => ShortCircuit(
          position: position,
          velocity: velocity,
          bounds: bounds,
        ),
      HazardType.electricSpark => ElectricSpark(
          position: position,
          velocity: velocity,
          bounds: bounds,
        ),
      HazardType.overheatedChip => OverheatedChip(
          position: position,
          velocity: velocity,
          bounds: bounds,
        ),
    };

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
