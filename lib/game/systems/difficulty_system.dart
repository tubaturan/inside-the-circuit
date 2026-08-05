import 'dart:math' as math;

import 'package:inside_the_circuit/game/gameplay_config.dart';

class DifficultySnapshot {
  const DifficultySnapshot({
    required this.level,
    required this.enemyLimit,
    required this.enemyInterval,
    required this.speedMultiplier,
  });

  factory DifficultySnapshot.forLevel(int level) => DifficultySnapshot(
        level: level,
        enemyLimit: math.min(
          GameplayConfig.maximumEnemyLimit,
          GameplayConfig.initialEnemyLimit + level,
        ),
        enemyInterval: math.max(
          GameplayConfig.minimumEnemyInterval,
          GameplayConfig.initialEnemyInterval -
              GameplayConfig.intervalStep * level,
        ),
        speedMultiplier: math.min(
          GameplayConfig.maximumSpeedMultiplier,
          GameplayConfig.initialSpeedMultiplier +
              GameplayConfig.speedStep * level,
        ),
      );

  final int level;
  final int enemyLimit;
  final double enemyInterval;
  final double speedMultiplier;
}
