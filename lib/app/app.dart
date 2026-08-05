import 'package:flutter/material.dart';
import 'package:inside_the_circuit/presentation/game_screen.dart';

class InsideCircuitApp extends StatelessWidget {
  const InsideCircuitApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Inside the Circuit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF39F5FF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const GameScreen(),
      );
}
