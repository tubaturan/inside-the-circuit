import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

enum GameSound {
  gameStart,
  electronCollected,
  shieldActivated,
  shieldConsumed,
  levelUp,
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

class FlameGameAudioManager implements AudioManager {
  const FlameGameAudioManager();

  static const _assets = <GameSound, String>{
    GameSound.gameStart: 'game_start.wav',
    GameSound.electronCollected: 'electron_collected.wav',
    GameSound.shieldActivated: 'shield_activated.wav',
    GameSound.shieldConsumed: 'shield_consumed.wav',
    GameSound.levelUp: 'level_up.wav',
    GameSound.gameOver: 'game_over.wav',
  };

  @override
  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll(_assets.values.toList());
    } catch (_) {
      // A missing audio backend must not prevent the game from loading.
    }
  }

  @override
  void play(GameSound sound) {
    unawaited(_playSafely(_assets[sound]!));
  }

  Future<void> _playSafely(String asset) async {
    try {
      await FlameAudio.play(asset, volume: .68);
    } catch (_) {
      // Audio must never interrupt gameplay on an unsupported device.
    }
  }
}
