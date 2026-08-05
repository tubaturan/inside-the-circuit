import 'package:flutter_test/flutter_test.dart';
import 'package:inside_the_circuit/services/audio_manager.dart';

void main() {
  test('silent audio manager accepts every gameplay cue', () async {
    const manager = SilentAudioManager();

    await manager.preload();
    for (final sound in GameSound.values) {
      manager.play(sound);
    }
    manager.startMusic();
    manager.pauseMusic();
    manager.resumeMusic();
    manager.stopMusic();
  });
}
