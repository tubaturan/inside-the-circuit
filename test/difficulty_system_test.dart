import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/systems/difficulty_system.dart';

void main() {
  test('difficulty grows within configured caps', () {
    final initial = DifficultySnapshot.forLevel(0);
    final advanced = DifficultySnapshot.forLevel(100);
    expect(initial.enemyLimit, 4);
    expect(advanced.enemyLimit, 12);
    expect(advanced.enemyInterval, greaterThan(0));
    expect(advanced.speedMultiplier, 2.1);
  });
}
