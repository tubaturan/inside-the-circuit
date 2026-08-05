import 'dart:math';

import 'package:flame/components.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';

Vector2 fairEdgeSpawnPosition({
  required PlayfieldBounds bounds,
  required Vector2 playerPosition,
  required Random random,
}) {
  Vector2 candidateFor(int edge) => switch (edge) {
        0 => Vector2(
            bounds.left - 32,
            bounds.top + random.nextDouble() * bounds.height,
          ),
        1 => Vector2(
            bounds.right + 32,
            bounds.top + random.nextDouble() * bounds.height,
          ),
        2 => Vector2(
            bounds.left + random.nextDouble() * bounds.width,
            bounds.top - 32,
          ),
        _ => Vector2(
            bounds.left + random.nextDouble() * bounds.width,
            bounds.bottom + 32,
          ),
      };

  for (var attempt = 0; attempt < 24; attempt++) {
    final candidate = candidateFor(random.nextInt(4));
    if (candidate.distanceTo(playerPosition) >=
        GameplayConfig.minimumEnemySpawnDistance) {
      return candidate;
    }
  }

  final topLeft = Vector2(bounds.left, bounds.top - 32);
  final topRight = Vector2(bounds.right, bounds.top - 32);
  return topLeft.distanceTo(playerPosition) >=
          topRight.distanceTo(playerPosition)
      ? topLeft
      : topRight;
}

Vector2 fairCollectiblePosition({
  required PlayfieldBounds bounds,
  required Vector2 playerPosition,
  required Iterable<Vector2> occupiedPositions,
  required Random random,
}) {
  final occupied = occupiedPositions.toList(growable: false);
  const margin = GameplayConfig.collectibleSpawnMargin;
  Vector2? bestCandidate;
  var bestClearance = -1.0;

  for (var attempt = 0;
      attempt < GameplayConfig.collectibleSpawnAttempts;
      attempt++) {
    final candidate = Vector2(
      bounds.left +
          margin +
          random.nextDouble() * max(0.0, bounds.width - margin * 2),
      bounds.top +
          margin +
          random.nextDouble() * max(0.0, bounds.height - margin * 2),
    );
    final playerClearance = candidate.distanceTo(playerPosition);
    final objectClearance = occupied.isEmpty
        ? double.infinity
        : occupied
            .map(candidate.distanceTo)
            .reduce((nearest, value) => min(nearest, value));
    final normalizedClearance = min(
      playerClearance / GameplayConfig.collectiblePlayerClearance,
      objectClearance / GameplayConfig.collectibleObjectClearance,
    );

    if (normalizedClearance > bestClearance) {
      bestCandidate = candidate;
      bestClearance = normalizedClearance;
    }
    if (playerClearance >= GameplayConfig.collectiblePlayerClearance &&
        objectClearance >= GameplayConfig.collectibleObjectClearance) {
      return candidate;
    }
  }

  return bestCandidate ?? Vector2(bounds.left + margin, bounds.top + margin);
}
