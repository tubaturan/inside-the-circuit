import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/circuit_game.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';

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
}
