import 'package:flutter/material.dart';

class OverlayPanel extends StatelessWidget {
  const OverlayPanel({
    required this.title,
    required this.children,
    super.key,
  });
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

class NeonButton extends StatelessWidget {
  const NeonButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

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

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
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
