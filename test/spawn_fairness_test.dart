import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';
import 'package:inside_the_circuit/game/systems/spawn_positions.dart';

void main() {
  test('edge spawns preserve a minimum reaction distance', () {
    final bounds = PlayfieldBounds.fromGameSize(Vector2(400, 800));
    final player = Vector2(200, 730);
    final random = Random(12);

    for (var i = 0; i < 200; i++) {
      final spawn = fairEdgeSpawnPosition(
        bounds: bounds,
        playerPosition: player,
        random: random,
      );
      expect(
        spawn.distanceTo(player),
        greaterThanOrEqualTo(GameplayConfig.minimumEnemySpawnDistance),
      );
    }
  });

  test('collectibles spawn clear of the player and gameplay objects', () {
    final bounds = PlayfieldBounds.fromGameSize(Vector2(400, 800));
    final player = Vector2(200, 700);
    final occupied = [Vector2(100, 300), Vector2(300, 450)];
    final random = Random(27);

    for (var i = 0; i < 100; i++) {
      final spawn = fairCollectiblePosition(
        bounds: bounds,
        playerPosition: player,
        occupiedPositions: occupied,
        random: random,
      );

      expect(
        spawn.distanceTo(player),
        greaterThanOrEqualTo(GameplayConfig.collectiblePlayerClearance),
      );
      for (final position in occupied) {
        expect(
          spawn.distanceTo(position),
          greaterThanOrEqualTo(GameplayConfig.collectibleObjectClearance),
        );
      }
      expect(spawn.x, inInclusiveRange(bounds.left, bounds.right));
      expect(spawn.y, inInclusiveRange(bounds.top, bounds.bottom));
    }
  });
}
