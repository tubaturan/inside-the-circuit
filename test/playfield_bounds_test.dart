import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/playfield_bounds.dart';

void main() {
  test('clamps component below HUD and inside padded edges', () {
    final bounds = PlayfieldBounds.fromGameSize(Vector2(300, 600));
    final point = bounds.clampCenter(Vector2(-100, -100), Vector2.all(40));
    expect(point.x, bounds.left + 20);
    expect(point.y, bounds.top + 20);
  });

  test('centers a component when the viewport is unusually small', () {
    final bounds = PlayfieldBounds.fromGameSize(Vector2(80, 100));
    final point = bounds.clampCenter(Vector2.zero(), Vector2.all(46));
    expect(point.x, bounds.left + 23);
    expect(point.y, (bounds.top + bounds.bottom) / 2);
  });
}
