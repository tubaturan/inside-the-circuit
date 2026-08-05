import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inside_the_circuit/game/circuit_game.dart';
import 'package:inside_the_circuit/game/game_session.dart';
import 'package:inside_the_circuit/presentation/game_controller.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  CircuitGame? _game;
  GamePhase _phase = GamePhase.mainMenu;
  int _score = 0;
  bool _shielded = false;

  @override
  void initState() {
    super.initState();
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
      return _MainMenu(
        highScore: highScore,
        soundEnabled: sound,
        onSoundChanged: (value) =>
            ref.read(soundEnabledProvider.notifier).setEnabled(value),
        onStart: _start,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),
          if (_phase == GamePhase.playing)
            _Hud(score: _score, shielded: _shielded, onPause: game.pauseGame),
          if (_phase == GamePhase.paused)
            _PauseOverlay(onContinue: game.continueGame, onMenu: _returnToMenu),
          if (_phase == GamePhase.gameOver)
            _GameOverOverlay(
              score: _score,
              highScore: highScore,
              onRestart: game.startNewGame,
              onMenu: _returnToMenu,
            ),
        ],
      ),
    );
  }

  void _start() {
    final game = CircuitGame(
      onSessionChanged: _onSessionChanged,
      onGameOver: (score) => ref.read(highScoreProvider.notifier).submit(score),
    );
    setState(() {
      _game = game;
      _phase = GamePhase.playing;
    });
  }

  void _onSessionChanged(GameSession session) {
    if (!mounted) return;
    setState(() {
      _phase = session.phase;
      _score = session.score;
      _shielded = session.hasShield;
    });
  }

  void _returnToMenu() {
    _game?.returnToMenu();
    setState(() {
      _game = null;
      _phase = GamePhase.mainMenu;
      _score = 0;
      _shielded = false;
    });
  }
}

class _MainMenu extends StatelessWidget {
  const _MainMenu(
      {required this.highScore,
      required this.soundEnabled,
      required this.onSoundChanged,
      required this.onStart});
  final int highScore;
  final bool soundEnabled;
  final ValueChanged<bool> onSoundChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF040914),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.electric_bolt,
                    size: 74, color: Color(0xFF39F5FF)),
                const SizedBox(height: 16),
                const Text('INSIDE THE CIRCUIT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
                const SizedBox(height: 20),
                Text('BEST SIGNAL  $highScore',
                    style: const TextStyle(
                        color: Color(0xFF39F5FF), fontSize: 18)),
                const SizedBox(height: 28),
                FilledButton(
                    onPressed: onStart, child: const Text('START SYSTEM')),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                    value: soundEnabled,
                    onChanged: onSoundChanged,
                    title: const Text('Sound enabled'),
                    contentPadding: EdgeInsets.zero),
              ]),
            ),
          ),
        ),
      );
}

class _Hud extends StatelessWidget {
  const _Hud(
      {required this.score, required this.shielded, required this.onPause});
  final int score;
  final bool shielded;
  final VoidCallback onPause;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: SizedBox(
            height: 70,
            child: Row(children: [
              const SizedBox(width: 16),
              Text('SIGNAL $score',
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold)),
              if (shielded)
                const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Icon(Icons.shield, color: Color(0xFF39F5FF))),
              const Spacer(),
              IconButton(onPressed: onPause, icon: const Icon(Icons.pause)),
              const SizedBox(width: 8),
            ])),
      );
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onContinue, required this.onMenu});
  final VoidCallback onContinue;
  final VoidCallback onMenu;
  @override
  Widget build(BuildContext context) =>
      _Panel(title: 'SYSTEM PAUSED', children: [
        FilledButton(onPressed: onContinue, child: const Text('CONTINUE')),
        TextButton(onPressed: onMenu, child: const Text('MAIN MENU')),
      ]);
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay(
      {required this.score,
      required this.highScore,
      required this.onRestart,
      required this.onMenu});
  final int score;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback onMenu;
  @override
  Widget build(BuildContext context) => _Panel(title: 'SIGNAL LOST', children: [
        Text('SCORE  $score'),
        Text('BEST SIGNAL  $highScore'),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRestart, child: const Text('REBOOT SYSTEM')),
        TextButton(onPressed: onMenu, child: const Text('MAIN MENU')),
      ]);
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: const Color(0xDD040914),
        child: Center(
            child: Card(
                child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF5C4D))),
            const SizedBox(height: 20),
            ...children.map((child) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: child)),
          ]),
        ))),
      );
}
