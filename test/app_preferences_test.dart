import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:inside_the_circuit/services/app_preferences.dart';

void main() {
  test('high score only increases and sound setting persists', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final preferences = AppPreferences(preferences: SharedPreferencesAsync());

    expect(await preferences.saveHighScoreIfGreater(12), 12);
    expect(await preferences.saveHighScoreIfGreater(8), 12);
    expect(await preferences.readHighScore(), 12);

    await preferences.setSoundEnabled(false);
    expect(await preferences.readSoundEnabled(), isFalse);
  });
}
