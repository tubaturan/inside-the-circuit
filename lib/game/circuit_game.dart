import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/components/circuit_background.dart';
import 'package:inside_the_circuit/game/components/collection_particle.dart';
import 'package:inside_the_circuit/game/components/collectibles.dart';
import 'package:inside_the_circuit/game/components/difficulty_pulse.dart';
import 'package:inside_the_circuit/game/components/hazards.dart';
import 'package:inside_the_circuit/game/components/player_signal.dart';
import 'package:inside_the_circuit/game/game_session.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';
import 'package:inside_the_circuit/game/systems/difficulty_system.dart';
import 'package:inside_the_circuit/game/systems/spawn_schedule.dart';
import 'package:inside_the_circuit/services/audio_manager.dart';

class CircuitGame extends FlameGame with HasCollisionDetection, PanDetector {
  CircuitGame({
    required this.onSessionChanged,
    required this.onGameOver,
    this.audioManager = const SilentAudioManager(),
    this.soundEnabled = _soundOn,
    Random? random,
  }) : random = random ?? Random();

  final void Function(GameSession session) onSessionChanged;
  final void Function(int score) onGameOver;
  final AudioManager audioManager;
  final bool Function() soundEnabled;
  final Random random;
  final GameSession session = GameSession();
  late final SpawnSchedule _spawnSchedule = SpawnSchedule(random: random);

  PlayerSignal? _player;
  int _lastDisplayedScore = -1;
  int _lastElectronCount = -1;
  bool _lastShielded = false;
  int _lastShieldSeconds = -1;
  int _lastAnnouncedDifficulty = 1;

  PlayfieldBounds get playfield => PlayfieldBounds.fromGameSize(size);
  Iterable<Hazard> get hazards => children.whereType<Hazard>();
  Iterable<Collectible> get collectibles => children.whereType<Collectible>();

  @override
  Color backgroundColor() => GameplayConfig.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(audioManager.preload());
    await add(CircuitBackground(gameSize: () => size));
    _startFreshSession();
    _play(GameSound.gameStart);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (session.phase != GamePhase.playing) return;

    session.update(dt);
    final difficulty = DifficultySnapshot.forLevel(session.difficultyLevel);
    if (difficulty.level > _lastAnnouncedDifficulty) {
      _lastAnnouncedDifficulty = difficulty.level;
      add(DifficultyPulse(level: difficulty.level, gameSize: () => size));
      _play(GameSound.levelUp);
    }
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
        session.electronCount != _lastElectronCount ||
        session.hasShield != _lastShielded ||
        session.shieldRemaining.ceil() != _lastShieldSeconds) {
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
    _play(GameSound.gameStart);
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
    _lastAnnouncedDifficulty = session.difficultyLevel;
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
    final effects = children.where(
      (component) =>
          component is CollectionBurst || component is DifficultyPulse,
    );
    for (final component in [...hazards, ...collectibles, ...effects]) {
      component.removeFromParent();
    }
    _player?.removeFromParent();
    _player = null;
  }

  void _handleHazardCollision(PositionComponent component) {
    if (session.phase != GamePhase.playing || component is! Hazard) return;
    final impactPosition = component.position.clone();
    component.removeFromParent();
    if (session.hasShield) {
      session.consumeShield();
      add(CollectionBurst(
        position: impactPosition,
        color: GameplayConfig.cyan,
      ));
      _play(GameSound.shieldConsumed);
      _notify();
      return;
    }
    session.phase = GamePhase.gameOver;
    _play(GameSound.gameOver);
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
    final playerPosition = _player?.position ??
        Vector2(playfield.left + playfield.width / 2, playfield.bottom);
    final occupiedPositions = <Vector2>[
      ...hazards.map((hazard) => hazard.position),
      ...collectibles.map((collectible) => collectible.position),
    ];
    add(Collectible(
      type: type,
      position: fairCollectiblePosition(
        bounds: playfield,
        playerPosition: playerPosition,
        occupiedPositions: occupiedPositions,
        random: random,
      ),
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
          _play(GameSound.electronCollected);
        } else {
          session.activateShield();
          _play(GameSound.shieldActivated);
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
    _lastElectronCount = session.electronCount;
    _lastShielded = session.hasShield;
    _lastShieldSeconds = session.shieldRemaining.ceil();
    onSessionChanged(session);
  }

  void _play(GameSound sound) {
    if (soundEnabled()) audioManager.play(sound);
  }
}

bool _soundOn() => true;

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
