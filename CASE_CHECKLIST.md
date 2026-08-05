# Case Acceptance Checklist

## Gameplay

- [x] Flame game loop and component system are used (`CircuitGame`, `PositionComponent`).
- [x] Touch and drag move `PlayerSignal` smoothly inside dynamic playfield bounds.
- [x] Player, hazards and collectibles use Flame collision detection and circle hitboxes.
- [x] Electron grants 10 points and creates a collection effect.
- [x] Capacitor activates a non-stacking five-second shield; recollection refreshes it.
- [x] Shield expires on timeout or after blocking the first hazard, whichever happens first.
- [x] Score is `floor(survivalSeconds) + electronCount * 10` and is displayed as an integer.
- [x] Gameplay time and score advance only while the phase is `playing`.
- [x] ShortCircuit, ElectricSpark and OverheatedChip have distinct movement, size and speed behavior.
- [x] Enemy weights start at 60% / 25% / 15% and change gradually with difficulty.
- [x] Difficulty increases every 15 seconds; speed, interval and enemy cap remain configured and bounded.
- [x] Enemy and collectible spawns respect the HUD, safe area, padding and fairness clearances.
- [x] Maximum active counts and collectible lifetimes are enforced before spawning.

## Game flow and persistence

- [x] Main Menu, Playing, Paused and Game Over phases are implemented.
- [x] Pause freezes the Flame engine, gameplay timers and score.
- [x] Backgrounding an active game pauses it; returning requires explicit Continue.
- [x] Main Menu and new game use one central session reset path for gameplay components and state.
- [x] High score and sound preference survive session resets through SharedPreferences.
- [x] Riverpod owns UI-facing high score and sound preference state.
- [x] Audio calls are connected through a small service interface and safely remain silent without assets.

## Presentation and performance

- [x] Flutter overlays provide the menu, HUD, pause and game-over UI.
- [x] Responsive game bounds are calculated from the viewport; no fixed device resolution is assumed.
- [x] Programmatic PCB background, hazard telegraphs, trails, particles and shield feedback are lightweight.
- [x] Android, iOS and web launcher icons use the Inside the Circuit artwork.
- [x] No Flutter `Timer` drives gameplay.
- [x] All tuning values live in `lib/game/gameplay_config.dart`.
- [x] No runtime sprite or audio assets are currently required; the audio preload hook is ready for licensed assets.

## Automated checks

- [x] `flutter analyze` passes.
- [x] `flutter test` passes: 23 tests.
- [x] Score, pause/freeze, shield, reset and state behavior are covered.
- [x] Difficulty growth, hazard weights and enemy limits are covered.
- [x] High score and sound persistence are covered.
- [x] Spawn timing, bounds and fairness are covered by automated tests.
- [x] Active enemy and collectible limits are enforced by pre-spawn component counts.
- [x] App lifecycle pause behavior and a 320x640 mobile viewport are covered.

## Platform builds

- [x] Web release build verified with `flutter build web --release`.
- [x] Android release build verified locally with `flutter build apk --release`.
- [x] Android APK produced at `build/app/outputs/flutter-apk/app-release.apk` (19.5 MB).
- [ ] iOS build requires final verification on macOS with Xcode; it was not claimed as successful on Windows.
