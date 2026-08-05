import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:inside_the_circuit/game/components/collectibles.dart';
import 'package:inside_the_circuit/game/components/hazards.dart';
import 'package:inside_the_circuit/game/components/player_signal.dart';
import 'package:inside_the_circuit/game/game_session.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';
import 'package:inside_the_circuit/game/systems/difficulty_system.dart';

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

  PlayerSignal? _player;
  double _enemyCountdown = .7;
  double _electronCountdown = 1.2;
  double _capacitorCountdown = 7;
  int _lastDisplayedScore = -1;

  PlayfieldBounds get playfield => PlayfieldBounds.fromGameSize(size);
  Iterable<Hazard> get hazards => children.whereType<Hazard>();
  Iterable<Collectible> get collectibles => children.whereType<Collectible>();

  @override
  Color backgroundColor() => GameplayConfig.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(_CircuitBackground());
    _startFreshSession();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (session.phase != GamePhase.playing) return;

    session.update(dt);
    final difficulty = DifficultySnapshot.forLevel(session.difficultyLevel);
    _enemyCountdown -= dt;
    _electronCountdown -= dt;
    _capacitorCountdown -= dt;

    if (_enemyCountdown <= 0) {
      if (hazards.length < difficulty.enemyLimit) _spawnHazard(difficulty);
      _enemyCountdown +=
          difficulty.enemyInterval * (.82 + random.nextDouble() * .36);
    }
    if (_electronCountdown <= 0) {
      if (_countCollectibles(CollectibleType.electron) <
          GameplayConfig.maxElectrons) {
        _spawnCollectible(CollectibleType.electron);
      }
      _electronCountdown += GameplayConfig.electronInterval;
    }
    if (_capacitorCountdown <= 0) {
      if (_countCollectibles(CollectibleType.capacitor) <
          GameplayConfig.maxCapacitors) {
        _spawnCollectible(CollectibleType.capacitor);
      }
      _capacitorCountdown += GameplayConfig.capacitorInterval;
    }

    if (session.score != _lastDisplayedScore) _notify();
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
    _player?.clearTarget();
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
    _enemyCountdown = .7;
    _electronCountdown = 1.2;
    _capacitorCountdown = 7;
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
    for (final component in [...hazards, ...collectibles]) {
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
    final origin = _randomEdgePosition();
    final playerPosition =
        _player?.position ?? Vector2(playfield.left, playfield.top);
    final target = type == HazardType.electricSpark
        ? _randomInteriorPosition()
        : playerPosition.clone();
    add(Hazard(
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

  Vector2 _randomEdgePosition() {
    final edge = random.nextInt(4);
    return switch (edge) {
      0 => Vector2(playfield.left - 32,
          playfield.top + random.nextDouble() * playfield.height),
      1 => Vector2(playfield.right + 32,
          playfield.top + random.nextDouble() * playfield.height),
      2 => Vector2(playfield.left + random.nextDouble() * playfield.width,
          playfield.top - 32),
      _ => Vector2(playfield.left + random.nextDouble() * playfield.width,
          playfield.bottom + 32),
    };
  }

  void _notify() {
    _lastDisplayedScore = session.score;
    onSessionChanged(session);
  }
}

class _CircuitBackground extends Component {
  final Paint _linePaint = Paint()
    ..color = GameplayConfig.cyan.withOpacity(.08)
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    for (var x = 20.0; x < 800; x += 64) {
      canvas.drawLine(Offset(x, 0), Offset(x, 1600), _linePaint);
    }
    for (var y = 100.0; y < 1600; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(800, y), _linePaint);
    }
  }
}
