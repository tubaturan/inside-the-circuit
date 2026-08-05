import 'package:flutter/material.dart';
import 'package:inside_the_circuit/presentation/widgets/shared_controls.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.onContinue,
    required this.onMenu,
    super.key,
  });
  final VoidCallback onContinue;
  final VoidCallback onMenu;
  @override
  Widget build(BuildContext context) =>
      OverlayPanel(title: 'SYSTEM PAUSED', children: [
        NeonButton(label: 'CONTINUE', onPressed: onContinue),
        TextButton(onPressed: onMenu, child: const Text('MAIN MENU')),
      ]);
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay(
      {super.key,
      required this.score,
      required this.highScore,
      required this.onRestart,
      required this.onMenu});
  final int score;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback onMenu;
  @override
  Widget build(BuildContext context) =>
      OverlayPanel(title: 'SIGNAL LOST', children: [
        StatusPill(icon: Icons.bolt_rounded, label: 'SCORE', value: '$score'),
        StatusPill(
          icon: Icons.insights_rounded,
          label: 'BEST SIGNAL',
          value: '$highScore',
        ),
        const SizedBox(height: 12),
        NeonButton(label: 'REBOOT SYSTEM', onPressed: onRestart),
        TextButton(onPressed: onMenu, child: const Text('MAIN MENU')),
      ]);
}
