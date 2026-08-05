import 'package:flutter/material.dart';
import 'package:inside_the_circuit/presentation/widgets/shared_controls.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
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
                    StatusPill(
                      icon: Icons.insights_rounded,
                      label: 'BEST SIGNAL',
                      value: '$highScore',
                    ),
                    const SizedBox(height: 22),
                    NeonButton(label: 'START SYSTEM', onPressed: onStart),
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
