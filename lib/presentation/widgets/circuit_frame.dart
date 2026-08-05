import 'package:flutter/material.dart';

class CircuitFrame extends StatelessWidget {
  const CircuitFrame({required this.child, super.key});

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
