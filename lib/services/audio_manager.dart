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

  void startMusic();
  void pauseMusic();
  void resumeMusic();
  void stopMusic();
}

/// Keeps gameplay audio calls safe until licensed sound assets are added.
/// No audio dependency is needed while this implementation is in use.
class SilentAudioManager implements AudioManager {
  const SilentAudioManager();

  @override
  Future<void> preload() async {}

  @override
  void play(GameSound sound) {}

  @override
  void startMusic() {}

  @override
  void pauseMusic() {}

  @override
  void resumeMusic() {}

  @override
  void stopMusic() {}
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
  static const _musicAsset = 'circuit_pulse_loop.wav';
  static bool _bgmInitialized = false;

  @override
  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll([
        ..._assets.values,
        _musicAsset,
      ]);
    } catch (_) {
      // A missing audio backend must not prevent the game from loading.
    }
  }

  @override
  void play(GameSound sound) {
    unawaited(_playSafely(_assets[sound]!));
  }

  @override
  void startMusic() {
    unawaited(_startMusicSafely());
  }

  @override
  void pauseMusic() {
    unawaited(_runSafely(FlameAudio.bgm.pause));
  }

  @override
  void resumeMusic() {
    unawaited(_runSafely(FlameAudio.bgm.resume));
  }

  @override
  void stopMusic() {
    unawaited(_runSafely(FlameAudio.bgm.stop));
  }

  Future<void> _playSafely(String asset) async {
    try {
      await FlameAudio.play(asset, volume: .68);
    } catch (_) {
      // Audio must never interrupt gameplay on an unsupported device.
    }
  }

  Future<void> _startMusicSafely() async {
    try {
      if (!_bgmInitialized) {
        FlameAudio.bgm.initialize();
        _bgmInitialized = true;
      }
      await FlameAudio.bgm.play(_musicAsset, volume: .2);
    } catch (_) {
      // Music support is optional on the active platform.
    }
  }

  Future<void> _runSafely(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {
      // Music support is optional on the active platform.
    }
  }
}
