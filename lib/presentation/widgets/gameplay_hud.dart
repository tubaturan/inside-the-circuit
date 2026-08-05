import 'package:flutter/material.dart';

class GameplayHud extends StatelessWidget {
  const GameplayHud({
    super.key,
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
