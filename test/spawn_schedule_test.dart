import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/systems/difficulty_system.dart';
import 'package:inside_the_circuit/game/systems/spawn_schedule.dart';

void main() {
  test('schedule respects initial delays and resets deterministically', () {
    final schedule = SpawnSchedule(random: Random(4));
    final difficulty = DifficultySnapshot.forLevel(0);

    expect(schedule.update(.69, difficulty).enemy, isFalse);
    expect(schedule.update(.02, difficulty).enemy, isTrue);

    schedule.reset();
    expect(schedule.update(.69, difficulty).enemy, isFalse);
    expect(schedule.update(.02, difficulty).enemy, isTrue);
  });

  test('collectible channels have independent gameplay-time delays', () {
    final schedule = SpawnSchedule(random: Random(2));
    final difficulty = DifficultySnapshot.forLevel(0);

    final first = schedule.update(1.2, difficulty);
    expect(first.enemy, isTrue);
    expect(first.electron, isTrue);
    expect(first.capacitor, isFalse);

    final later = schedule.update(5.8, difficulty);
    expect(later.capacitor, isTrue);
  });
}
