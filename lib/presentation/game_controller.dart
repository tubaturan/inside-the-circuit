import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inside_the_circuit/services/app_preferences.dart';

final appPreferencesProvider =
    Provider<AppPreferences>((ref) => AppPreferences());

final highScoreProvider = AsyncNotifierProvider<HighScoreController, int>(
  HighScoreController.new,
);

class HighScoreController extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.read(appPreferencesProvider).readHighScore();

  Future<void> submit(int score) async {
    final value =
        await ref.read(appPreferencesProvider).saveHighScoreIfGreater(score);
    state = AsyncData(value);
  }
}

final soundEnabledProvider = AsyncNotifierProvider<SoundController, bool>(
  SoundController.new,
);

class SoundController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(appPreferencesProvider).readSoundEnabled();

  Future<void> setEnabled(bool enabled) async {
    state = AsyncData(enabled);
    await ref.read(appPreferencesProvider).setSoundEnabled(enabled);
  }
}
