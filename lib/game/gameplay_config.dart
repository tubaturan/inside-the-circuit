import 'package:flutter/material.dart';

abstract final class GameplayConfig {
  static const double hudHeight = 76;
  static const double sidePadding = 12;
  static const double bottomPadding = 12;

  static const double playerDiameter = 46;
  static const double playerFollowSpeed = 18;
  static const double playerArrivalTolerance = 2;
  static const double shieldDuration = 5;

  static const int electronScore = 10;
  static const int maxElectrons = 5;
  static const int maxCapacitors = 1;
  static const double electronLifetime = 8;
  static const double capacitorLifetime = 6;

  static const double difficultyPeriod = 15;
  static const int initialEnemyLimit = 4;
  static const int maximumEnemyLimit = 12;
  static const double initialEnemyInterval = 1.35;
  static const double initialEnemyDelay = 1.8;
  static const double minimumEnemySpawnDistance = 220;
  static const double minimumEnemyInterval = 0.42;
  static const double intervalStep = 0.09;
  static const double initialSpeedMultiplier = 1;
  static const double speedStep = 0.075;
  static const double maximumSpeedMultiplier = 2.1;

  static const double electronInterval = 2.2;
  static const double capacitorInterval = 11;

  static const Color background = Color(0xFF040914);
  static const Color cyan = Color(0xFF39F5FF);
  static const Color danger = Color(0xFFFF4D43);
  static const Color warning = Color(0xFFFF9A3C);
}
