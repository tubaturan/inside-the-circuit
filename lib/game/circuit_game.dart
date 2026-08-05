import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/components/circuit_background.dart';
import 'package:inside_the_circuit/game/components/collection_particle.dart';
import 'package:inside_the_circuit/game/components/collectibles.dart';
import 'package:inside_the_circuit/game/components/hazards.dart';
import 'package:inside_the_circuit/game/components/player_signal.dart';
import 'package:inside_the_circuit/game/game_session.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';
import 'package:inside_the_circuit/game/systems/difficulty_system.dart';
import 'package:inside_the_circuit/game/systems/spawn_schedule.dart';

class CircuitGame extends FlameGame with HasCollisionDetection, PanDetector {
  CircuitGame({
    required this.onSessionChanged,
    required this.onGameOver,
    Random? random,
  }) : random = random ?? Random();

  final void Function(GameSession session) onSessionChanged;
  final void Function(int score) onGameOver;
  final Random random;
  final GameSession session = GameSession();
  late final SpawnSchedule _spawnSchedule = SpawnSchedule(random: random);

  PlayerSignal? _player;
  int _lastDisplayedScore = -1;
  bool _lastShielded = false;

  PlayfieldBounds get playfield => PlayfieldBounds.fromGameSize(size);
  Iterable<Hazard> get hazards => children.whereType<Hazard>();
  Iterable<Collectible> get collectibles => children.whereType<Collectible>();

  @override
  Color backgroundColor() => GameplayConfig.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircuitBackground(gameSize: () => size));
    _startFreshSession();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (session.phase != GamePhase.playing) return;

    session.update(dt);
    final difficulty = DifficultySnapshot.forLevel(session.difficultyLevel);
    final spawn = _spawnSchedule.update(dt, difficulty);

    if (spawn.enemy) {
      if (hazards.length < difficulty.enemyLimit) _spawnHazard(difficulty);
    }
    if (spawn.electron) {
      if (_countCollectibles(CollectibleType.electron) <
          GameplayConfig.maxElectrons) {
        _spawnCollectible(CollectibleType.electron);
      }
    }
    if (spawn.capacitor) {
      if (_countCollectibles(CollectibleType.capacitor) <
          GameplayConfig.maxCapacitors) {
        _spawnCollectible(CollectibleType.capacitor);
      }
    }

    if (session.score != _lastDisplayedScore ||
        session.hasShield != _lastShielded) {
      _notify();
    }
  }

  @override
  void onPanDown(DragDownInfo info) {
    _player?.setTarget(info.eventPosition.widget);
  }

  @override
  void onPanStart(DragStartInfo info) {
    _player?.setTarget(info.eventPosition.widget);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _player?.setTarget(info.eventPosition.widget);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    // Keep the last target so a quick tap is enough to dodge.
  }

  @override
  void onPanCancel() {
    _player?.clearTarget();
  }

  void startNewGame() {
    resumeEngine();
    _startFreshSession();
  }

  void pauseGame() {
    if (session.phase != GamePhase.playing) return;
    session.phase = GamePhase.paused;
    pauseEngine();
    _notify();
  }

  void continueGame() {
    if (session.phase != GamePhase.paused) return;
    session.phase = GamePhase.playing;
    resumeEngine();
    _notify();
  }

  void returnToMenu() {
    _clearGameplayComponents();
    session.reset(nextPhase: GamePhase.mainMenu);
    pauseEngine();
    _notify();
  }

  void _startFreshSession() {
    _clearGameplayComponents();
    session.reset();
    _spawnSchedule.reset();
    final player = PlayerSignal(
      position:
          Vector2(playfield.left + playfield.width / 2, playfield.bottom - 45),
      bounds: () => playfield,
      hasShield: () => session.hasShield,
      onHazardCollision: _handleHazardCollision,
    );
    _player = player;
    add(player);
    _notify();
  }

  void _clearGameplayComponents() {
    final effects = children.whereType<CollectionBurst>();
    for (final component in [...hazards, ...collectibles, ...effects]) {
      component.removeFromParent();
    }
    _player?.removeFromParent();
    _player = null;
  }

  void _handleHazardCollision(PositionComponent component) {
    if (session.phase != GamePhase.playing || component is! Hazard) return;
    component.removeFromParent();
    if (session.hasShield) {
      session.consumeShield();
      _notify();
      return;
    }
    session.phase = GamePhase.gameOver;
    pauseEngine();
    _notify();
    onGameOver(session.score);
  }

  void _spawnHazard(DifficultySnapshot difficulty) {
    final type = weightedHazard(random, difficulty.level);
    final playerPosition =
        _player?.position ?? Vector2(playfield.left, playfield.top);
    final origin = fairEdgeSpawnPosition(
      bounds: playfield,
      playerPosition: playerPosition,
      random: random,
    );
    final target = type == HazardType.electricSpark
        ? _randomInteriorPosition()
        : playerPosition.clone();
    add(createHazard(
      type: type,
      position: origin,
      velocity: velocityToward(
        origin,
        target,
        hazardBaseSpeed(type) * difficulty.speedMultiplier,
      ),
      bounds: () => playfield,
    ));
  }

  void _spawnCollectible(CollectibleType type) {
    add(Collectible(
      type: type,
      position: _randomInteriorPosition(margin: 28),
      isPlaying: () => session.phase == GamePhase.playing,
      onCollected: (collectible) {
        add(CollectionBurst(
          position: collectible.position.clone(),
          color: collectible.type == CollectibleType.electron
              ? GameplayConfig.cyan
              : const Color(0xFFB7FF5A),
        ));
        if (collectible.type == CollectibleType.electron) {
          session.collectElectron();
        } else {
          session.activateShield();
        }
        _notify();
      },
    ));
  }

  int _countCollectibles(CollectibleType type) => collectibles
      .where((item) => item.type == type && !item.isRemoving)
      .length;

  Vector2 _randomInteriorPosition({double margin = 20}) => Vector2(
        playfield.left +
            margin +
            random.nextDouble() * (playfield.width - margin * 2),
        playfield.top +
            margin +
            random.nextDouble() * (playfield.height - margin * 2),
      );

  void _notify() {
    _lastDisplayedScore = session.score;
    _lastShielded = session.hasShield;
    onSessionChanged(session);
  }
}

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
