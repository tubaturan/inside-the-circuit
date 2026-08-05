import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/components/hazards.dart';

void main() {
  test('initial hazard weights approximate 60/25/15 distribution', () {
    final random = Random(7);
    final counts = <HazardType, int>{};
    for (var i = 0; i < 20000; i++) {
      final type = weightedHazard(random, 0);
      counts[type] = (counts[type] ?? 0) + 1;
    }
    expect(counts[HazardType.shortCircuit]! / 20000, closeTo(.60, .015));
    expect(counts[HazardType.electricSpark]! / 20000, closeTo(.25, .015));
    expect(counts[HazardType.overheatedChip]! / 20000, closeTo(.15, .015));
  });

  test('difficulty shifts weight away from short circuits', () {
    int shortCircuitCount(int level) {
      final random = Random(4);
      return List.generate(10000, (_) => weightedHazard(random, level))
          .where((type) => type == HazardType.shortCircuit)
          .length;
    }

    expect(shortCircuitCount(8), lessThan(shortCircuitCount(0)));
  });
}
