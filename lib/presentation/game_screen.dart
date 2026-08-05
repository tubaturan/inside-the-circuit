import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inside_the_circuit/game/circuit_game.dart';
import 'package:inside_the_circuit/game/game_session.dart';
import 'package:inside_the_circuit/presentation/game_controller.dart';
import 'package:inside_the_circuit/services/audio_manager.dart';

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
  int _electronCount = 0;
  int _difficultyLevel = 0;
  bool _shielded = false;
  int _shieldSeconds = 0;

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
      body: _CircuitFrame(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: game)),
            if (_phase == GamePhase.playing)
              _Hud(
                score: _score,
                electronCount: _electronCount,
                difficultyLevel: _difficultyLevel,
                shielded: _shielded,
                shieldSeconds: _shieldSeconds,
                onPause: game.pauseGame,
              ),
            if (_phase == GamePhase.paused)
              _PauseOverlay(
                onContinue: game.continueGame,
                onMenu: _returnToMenu,
              ),
            if (_phase == GamePhase.gameOver)
              _GameOverOverlay(
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
      audioManager: const FlameGameAudioManager(),
      soundEnabled: () => ref.read(soundEnabledProvider).value ?? true,
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
      _phase = GamePhase.mainMenu;
      _score = 0;
      _electronCount = 0;
      _difficultyLevel = 0;
      _shielded = false;
      _shieldSeconds = 0;
    });
  }
}

class _CircuitFrame extends StatelessWidget {
  const _CircuitFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.15,
            colors: [Color(0xFF102B3A), Color(0xFF02050C)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  constraints.maxWidth > 620 ? 520.0 : constraints.maxWidth;
              return Center(
                child: Container(
                  width: width,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: const Color(0xFF39F5FF).withOpacity(.28),
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x6600DDE8),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRect(child: child),
                ),
              );
            },
          ),
        ),
      );
}

class _MainMenu extends StatelessWidget {
  const _MainMenu({
    required this.highScore,
    required this.soundEnabled,
    required this.onSoundChanged,
    required this.onStart,
  });
  final int highScore;
  final bool soundEnabled;
  final ValueChanged<bool> onSoundChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF102B3A), Color(0xFF040914)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF39F5FF).withOpacity(.1),
                        border: Border.all(
                          color: const Color(0xFF39F5FF).withOpacity(.65),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x6639F5FF), blurRadius: 28),
                        ],
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        size: 58,
                        color: Color(0xFF39F5FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'INSIDE THE\nCIRCUIT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        height: .95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'KEEP THE SIGNAL ALIVE',
                      style: TextStyle(
                        color: Color(0xFF8CA8B6),
                        fontSize: 12,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _StatusPill(
                      icon: Icons.insights_rounded,
                      label: 'BEST SIGNAL',
                      value: '$highScore',
                    ),
                    const SizedBox(height: 22),
                    _NeonButton(label: 'START SYSTEM', onPressed: onStart),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.035),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SwitchListTile.adaptive(
                        value: soundEnabled,
                        onChanged: onSoundChanged,
                        secondary: const Icon(Icons.volume_up_outlined),
                        title: const Text('SYSTEM AUDIO'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'TAP OR DRAG TO MOVE  •  COLLECT ELECTRONS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF637B88),
                        fontSize: 10,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.score,
    required this.electronCount,
    required this.difficultyLevel,
    required this.shielded,
    required this.shieldSeconds,
    required this.onPause,
  });
  final int score;
  final int electronCount;
  final int difficultyLevel;
  final bool shielded;
  final int shieldSeconds;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xE6101824),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x4439F5FF)),
            ),
            child: Row(children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFF39F5FF)),
              const SizedBox(width: 6),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'LEVEL ${difficultyLevel + 1}',
                style: const TextStyle(
                  color: Color(0xFF91A8B3),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.circle,
                color: Color(0xFF39F5FF),
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                '$electronCount',
                style: const TextStyle(
                  color: Color(0xFFBCEEF2),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedOpacity(
                opacity: shielded ? 1 : .18,
                duration: const Duration(milliseconds: 180),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: Color(0xFF39F5FF),
                      size: 21,
                    ),
                    if (shielded) ...[
                      const SizedBox(width: 3),
                      Text(
                        '${shieldSeconds}s',
                        style: const TextStyle(
                          color: Color(0xFFB7FF5A),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Pause',
                onPressed: onPause,
                icon: const Icon(Icons.pause_rounded),
              ),
            ]),
          ),
        ),
      );
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onContinue, required this.onMenu});
  final VoidCallback onContinue;
  final VoidCallback onMenu;
  @override
  Widget build(BuildContext context) =>
      _Panel(title: 'SYSTEM PAUSED', children: [
        _NeonButton(label: 'CONTINUE', onPressed: onContinue),
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
        _StatusPill(icon: Icons.bolt_rounded, label: 'SCORE', value: '$score'),
        _StatusPill(
          icon: Icons.insights_rounded,
          label: 'BEST SIGNAL',
          value: '$highScore',
        ),
        const SizedBox(height: 12),
        _NeonButton(label: 'REBOOT SYSTEM', onPressed: onRestart),
        TextButton(onPressed: onMenu, child: const Text('MAIN MENU')),
      ]);
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: const Color(0xE6040914),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: .92, end: 1),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF101824),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x6639F5FF)),
                boxShadow: const [
                  BoxShadow(color: Color(0x5539F5FF), blurRadius: 28),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Color(0xFFFF5C4D),
                  ),
                ),
                const SizedBox(height: 20),
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: child,
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _NeonButton extends StatelessWidget {
  const _NeonButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF39F5FF),
            foregroundColor: const Color(0xFF031014),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          child: Text(label),
        ),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF39F5FF).withOpacity(.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x4439F5FF)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: const Color(0xFF39F5FF), size: 19),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF91A8B3),
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ]),
      );
}
