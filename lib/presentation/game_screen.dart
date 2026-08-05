import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inside_the_circuit/game/circuit_game.dart';
import 'package:inside_the_circuit/game/game_session.dart';
import 'package:inside_the_circuit/presentation/game_controller.dart';
import 'package:inside_the_circuit/presentation/widgets/circuit_frame.dart';
import 'package:inside_the_circuit/presentation/widgets/game_overlays.dart';
import 'package:inside_the_circuit/presentation/widgets/gameplay_hud.dart';
import 'package:inside_the_circuit/presentation/widgets/main_menu.dart';
import 'package:inside_the_circuit/presentation/widgets/mission_briefing.dart';
import 'package:inside_the_circuit/services/audio_manager.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  late final AudioManager _audioManager;
  CircuitGame? _game;
  bool _showBriefing = false;
  bool _audioPrepared = false;
  bool _preparingBriefing = false;
  GamePhase _phase = GamePhase.mainMenu;
  int _score = 0;
  int _electronCount = 0;
  int _difficultyLevel = 0;
  bool _shielded = false;
  int _shieldSeconds = 0;

  @override
  void initState() {
    super.initState();
    _audioManager = ref.read(audioManagerProvider);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_phase == GamePhase.playing && state != AppLifecycleState.resumed) {
      _game?.pauseGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final highScore = ref.watch(highScoreProvider).value ?? 0;
    final sound = ref.watch(soundEnabledProvider).value ?? true;
    final game = _game;

    if (game == null || _phase == GamePhase.mainMenu) {
      if (_showBriefing) {
        return MissionBriefing(
          onBack: () => setState(() => _showBriefing = false),
          onStart: _start,
        );
      }
      return MainMenu(
        highScore: highScore,
        soundEnabled: sound,
        onSoundChanged: (value) =>
            ref.read(soundEnabledProvider.notifier).setEnabled(value),
        onStart: _openBriefing,
      );
    }

    return Scaffold(
      body: CircuitFrame(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: game)),
            if (_phase == GamePhase.playing)
              GameplayHud(
                score: _score,
                electronCount: _electronCount,
                difficultyLevel: _difficultyLevel,
                shielded: _shielded,
                shieldSeconds: _shieldSeconds,
                onPause: game.pauseGame,
              ),
            if (_phase == GamePhase.paused)
              PauseOverlay(
                onContinue: game.continueGame,
                onMenu: _returnToMenu,
              ),
            if (_phase == GamePhase.gameOver)
              GameOverOverlay(
                score: _score,
                highScore: highScore,
                onRestart: game.startNewGame,
                onMenu: _returnToMenu,
              ),
          ],
        ),
      ),
    );
  }

  void _start() {
    final game = CircuitGame(
      onSessionChanged: _onSessionChanged,
      onGameOver: (score) => ref.read(highScoreProvider.notifier).submit(score),
      audioManager: _audioManager,
      soundEnabled: () => ref.read(soundEnabledProvider).value ?? true,
    );
    setState(() {
      _game = game;
      _showBriefing = false;
      _phase = GamePhase.playing;
    });
  }

  Future<void> _openBriefing() async {
    if (_preparingBriefing) return;
    _preparingBriefing = true;
    if (!_audioPrepared) {
      await _audioManager.preload();
      _audioPrepared = true;
    }
    if (!mounted) return;
    setState(() => _showBriefing = true);
    _preparingBriefing = false;
  }

  void _onSessionChanged(GameSession session) {
    if (!mounted) return;
    setState(() {
      _phase = session.phase;
      _score = session.score;
      _electronCount = session.electronCount;
      _difficultyLevel = session.difficultyLevel;
      _shielded = session.hasShield;
      _shieldSeconds = session.shieldRemaining.ceil();
    });
  }

  void _returnToMenu() {
    _game?.returnToMenu();
    setState(() {
      _game = null;
      _showBriefing = false;
      _phase = GamePhase.mainMenu;
      _score = 0;
      _electronCount = 0;
      _difficultyLevel = 0;
      _shielded = false;
      _shieldSeconds = 0;
    });
  }
}
