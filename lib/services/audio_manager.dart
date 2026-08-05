enum GameSound {
  gameStart,
  electronCollected,
  shieldActivated,
  shieldConsumed,
  gameOver,
}

abstract interface class AudioManager {
  Future<void> preload();

  void play(GameSound sound);
}

/// Keeps gameplay audio calls safe until licensed sound assets are added.
/// No audio dependency is needed while this implementation is in use.
class SilentAudioManager implements AudioManager {
  const SilentAudioManager();

  @override
  Future<void> preload() async {}

  @override
  void play(GameSound sound) {}
}
