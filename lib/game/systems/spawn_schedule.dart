import 'dart:math';

import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/systems/difficulty_system.dart';

class SpawnTick {
  const SpawnTick({
    required this.enemy,
    required this.electron,
    required this.capacitor,
  });

  final bool enemy;
  final bool electron;
  final bool capacitor;
}

class SpawnSchedule {
  SpawnSchedule({required this.random});

  final Random random;
  double _enemyCountdown = GameplayConfig.initialEnemyDelay;
  double _electronCountdown = 1.2;
  double _capacitorCountdown = 7;

  void reset() {
    _enemyCountdown = GameplayConfig.initialEnemyDelay;
    _electronCountdown = 1.2;
    _capacitorCountdown = 7;
  }

  SpawnTick update(double dt, DifficultySnapshot difficulty) {
    _enemyCountdown -= dt;
    _electronCountdown -= dt;
    _capacitorCountdown -= dt;

    final spawnEnemy = _enemyCountdown <= 0;
    final spawnElectron = _electronCountdown <= 0;
    final spawnCapacitor = _capacitorCountdown <= 0;

    if (spawnEnemy) {
      _enemyCountdown +=
          difficulty.enemyInterval * (.82 + random.nextDouble() * .36);
    }
    if (spawnElectron) {
      _electronCountdown += GameplayConfig.electronInterval;
    }
    if (spawnCapacitor) {
      _capacitorCountdown += GameplayConfig.capacitorInterval;
    }

    return SpawnTick(
      enemy: spawnEnemy,
      electron: spawnElectron,
      capacitor: spawnCapacitor,
    );
  }
}
