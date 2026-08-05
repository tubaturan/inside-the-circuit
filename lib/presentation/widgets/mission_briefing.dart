import 'package:flutter/material.dart';
import 'package:inside_the_circuit/presentation/widgets/shared_controls.dart';

class MissionBriefing extends StatelessWidget {
  const MissionBriefing({
    required this.onBack,
    required this.onStart,
    super.key,
  });

  final VoidCallback onBack;
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
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                      maxWidth: 460,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Back',
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'MISSION BRIEFING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.2,
                            color: Color(0xFF39F5FF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'THE CORE IS FAILING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFF9A3C),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'A corrupted surge has breached the circuit. You are '
                          'the last stable signal still moving through the system.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.78),
                            height: 1.45,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _CircuitMap(),
                        const SizedBox(height: 18),
                        const _MissionObjective(
                          icon: Icons.circle,
                          color: Color(0xFF39F5FF),
                          title: 'STABILIZE THE SIGNAL',
                          detail:
                              'Collect Electrons to keep the network alive.',
                        ),
                        const SizedBox(height: 8),
                        const _MissionObjective(
                          icon: Icons.shield_rounded,
                          color: Color(0xFFB7FF5A),
                          title: 'CHARGE YOUR DEFENSE',
                          detail:
                              'Capacitors block one incoming system failure.',
                        ),
                        const SizedBox(height: 8),
                        const _MissionObjective(
                          icon: Icons.warning_amber_rounded,
                          color: Color(0xFFFF6B43),
                          title: 'SURVIVE THE COLLAPSE',
                          detail: 'Faults accelerate as system load increases.',
                        ),
                        const SizedBox(height: 22),
                        NeonButton(label: 'ENTER CIRCUIT', onPressed: onStart),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _CircuitMap extends StatelessWidget {
  const _CircuitMap();

  @override
  Widget build(BuildContext context) => Container(
        height: 178,
        decoration: BoxDecoration(
          color: const Color(0xB309111D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x4439F5FF)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _MapPathPainter())),
              Positioned(
                left: constraints.maxWidth / 2 - 45,
                top: 13,
                child: const _MapNode(
                  icon: Icons.memory_rounded,
                  label: 'CORE',
                  color: Color(0xFFFF9A3C),
                ),
              ),
              const Positioned(
                left: 14,
                top: 72,
                child: _MapNode(
                  icon: Icons.bolt_rounded,
                  label: 'FAULTS',
                  color: Color(0xFFFF5A4F),
                ),
              ),
              const Positioned(
                right: 14,
                top: 72,
                child: _MapNode(
                  icon: Icons.device_thermostat_rounded,
                  label: 'THERMAL',
                  color: Color(0xFFFF9A3C),
                ),
              ),
              Positioned(
                left: constraints.maxWidth / 2 - 45,
                bottom: 12,
                child: const _MapNode(
                  icon: Icons.circle,
                  label: 'SIGNAL',
                  color: Color(0xFF39F5FF),
                ),
              ),
            ],
          ),
        ),
      );
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xF0121D29),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(.55)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
}

class _MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paths = Paint()
      ..color = const Color(0x8839F5FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final centerTop = Offset(size.width / 2, 55);
    final centerBottom = Offset(size.width / 2, size.height - 55);
    final left = Offset(58, size.height / 2);
    final right = Offset(size.width - 58, size.height / 2);

    canvas.drawLine(centerBottom, centerTop, paths);
    canvas.drawLine(centerBottom, left, paths);
    canvas.drawLine(centerBottom, right, paths);
    canvas.drawCircle(
        centerBottom, 5, Paint()..color = const Color(0xFF39F5FF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MissionObjective extends StatelessWidget {
  const _MissionObjective({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.035),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: Color(0xFF8097A2),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
