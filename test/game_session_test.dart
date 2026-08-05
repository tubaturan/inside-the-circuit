import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/game/game_session.dart';

void main() {
  test('score combines whole survival seconds and electrons', () {
    final session = GameSession()..reset();
    session.update(.99);
    session.collectElectron();
    expect(session.score, 10);
    session.update(.02);
    expect(session.score, 11);
  });

  test('pause and game over freeze session time', () {
    final session = GameSession()..reset();
    session.update(2);
    session.phase = GamePhase.paused;
    session.update(5);
    expect(session.survivalSeconds, 2);
    session.phase = GamePhase.gameOver;
    session.update(5);
    expect(session.score, 2);
  });

  test('shield refreshes, expires, and does not stack', () {
    final session = GameSession()..reset();
    session.activateShield();
    session.update(3);
    session.activateShield();
    expect(session.shieldRemaining, 5);
    session.update(5);
    expect(session.hasShield, isFalse);
  });

  test('reset clears gameplay but selects requested phase', () {
    final session = GameSession()..reset();
    session.update(31);
    session.collectElectron();
    session.activateShield();
    session.reset(nextPhase: GamePhase.mainMenu);
    expect(session.phase, GamePhase.mainMenu);
    expect(session.score, 0);
    expect(session.difficultyLevel, 0);
    expect(session.hasShield, isFalse);
  });
}
