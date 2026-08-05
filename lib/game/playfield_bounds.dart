import 'package:flame/components.dart';
import 'package:inside_the_circuit/game/gameplay_config.dart';

class PlayfieldBounds {
  const PlayfieldBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory PlayfieldBounds.fromGameSize(Vector2 size) => PlayfieldBounds(
        left: GameplayConfig.sidePadding,
        top: GameplayConfig.hudHeight,
        right: size.x - GameplayConfig.sidePadding,
        bottom: size.y - GameplayConfig.bottomPadding,
      );

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  Vector2 clampCenter(Vector2 point, Vector2 componentSize) {
    final halfWidth = componentSize.x / 2;
    final halfHeight = componentSize.y / 2;
    final minimumX = left + halfWidth;
    final maximumX = right - halfWidth;
    final minimumY = top + halfHeight;
    final maximumY = bottom - halfHeight;
    return Vector2(
      minimumX <= maximumX
          ? point.x.clamp(minimumX, maximumX).toDouble()
          : (left + right) / 2,
      minimumY <= maximumY
          ? point.y.clamp(minimumY, maximumY).toDouble()
          : (top + bottom) / 2,
    );
  }
}
