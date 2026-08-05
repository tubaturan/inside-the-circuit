import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _highScoreKey = 'inside_circuit_high_score';
  static const _soundEnabledKey = 'inside_circuit_sound_enabled';
  final SharedPreferencesAsync _preferences;

  Future<int> readHighScore() async =>
      await _preferences.getInt(_highScoreKey) ?? 0;

  Future<int> saveHighScoreIfGreater(int score) async {
    final current = await readHighScore();
    if (score <= current) return current;
    await _preferences.setInt(_highScoreKey, score);
    return score;
  }

  Future<bool> readSoundEnabled() async =>
      await _preferences.getBool(_soundEnabledKey) ?? true;

  Future<void> setSoundEnabled(bool enabled) =>
      _preferences.setBool(_soundEnabledKey, enabled);
}
