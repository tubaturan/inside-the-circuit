import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/components/collection_particle.dart';
import 'package:inside_the_circuit/game/components/hazards.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';

void main() {
  PlayfieldBounds bounds() => PlayfieldBounds.fromGameSize(Vector2(400, 800));

  test('hazard types use distinct sizes and intended speed order', () {
    final shortCircuit = createHazard(
      type: HazardType.shortCircuit,
      position: Vector2.zero(),
      velocity: Vector2.zero(),
      bounds: bounds,
    );
    final spark = createHazard(
      type: HazardType.electricSpark,
      position: Vector2.zero(),
      velocity: Vector2.zero(),
      bounds: bounds,
    );
    final chip = createHazard(
      type: HazardType.overheatedChip,
      position: Vector2.zero(),
      velocity: Vector2.zero(),
      bounds: bounds,
    );

    expect(shortCircuit, isA<ShortCircuit>());
    expect(spark, isA<ElectricSpark>());
    expect(chip, isA<OverheatedChip>());
    expect(spark.size.x, lessThan(shortCircuit.size.x));
    expect(chip.size.x, greaterThan(shortCircuit.size.x));
    expect(
      hazardBaseSpeed(HazardType.electricSpark),
      greaterThan(hazardBaseSpeed(HazardType.shortCircuit)),
    );
    expect(
      hazardBaseSpeed(HazardType.overheatedChip),
      lessThan(hazardBaseSpeed(HazardType.shortCircuit)),
    );
  });

  test('collection burst removes itself after its short lifetime', () {
    final burst = CollectionBurst(
      position: Vector2.zero(),
      color: GameplayConfig.cyan,
    );
    burst.update(.4);
    expect(burst.isExpired, isTrue);
  });
}
