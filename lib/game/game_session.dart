import 'dart:math' as math;

import 'package:inside_the_circuit/game/gameplay_config.dart';

enum GamePhase { mainMenu, playing, paused, gameOver }

class GameSession {
  GamePhase phase = GamePhase.mainMenu;
  double survivalSeconds = 0;
  int electronCount = 0;
  int difficultyLevel = 0;
  double shieldRemaining = 0;

  int get score =>
      survivalSeconds.floor() + electronCount * GameplayConfig.electronScore;
  bool get hasShield => shieldRemaining > 0;

  void update(double dt) {
    if (phase != GamePhase.playing) return;
    survivalSeconds += dt;
    difficultyLevel =
        (survivalSeconds / GameplayConfig.difficultyPeriod).floor();
    shieldRemaining = math.max(0, shieldRemaining - dt);
  }

  void collectElectron() => electronCount++;
  void activateShield() => shieldRemaining = GameplayConfig.shieldDuration;
  void consumeShield() => shieldRemaining = 0;

  void reset({GamePhase nextPhase = GamePhase.playing}) {
    survivalSeconds = 0;
    electronCount = 0;
    difficultyLevel = 0;
    shieldRemaining = 0;
    phase = nextPhase;
  }
}
