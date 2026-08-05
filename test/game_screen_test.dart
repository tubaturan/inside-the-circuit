import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:inside_the_circuit/app/app.dart';
import 'package:inside_the_circuit/game/circuit_game.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('starts the Flame game from the main menu', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: InsideCircuitApp()));
    await tester.pump();

    expect(find.text('INSIDE THE\nCIRCUIT'), findsOneWidget);
    expect(find.text('START SYSTEM'), findsOneWidget);

    await tester.tap(find.text('START SYSTEM'));
    await tester.pump();

    expect(find.byType(GameWidget<CircuitGame>), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(
      tester.getSize(find.byType(GameWidget<CircuitGame>)).width,
      closeTo(520, 2),
    );
  });

  testWidgets('backgrounding a playing game requires explicit continue',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: InsideCircuitApp()));
    await tester.pump();
    await tester.tap(find.text('START SYSTEM'));
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(find.text('SYSTEM PAUSED'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('SYSTEM PAUSED'), findsOneWidget);

    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    expect(find.text('SYSTEM PAUSED'), findsNothing);
  });

  testWidgets('gameplay HUD fits a narrow mobile viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ProviderScope(child: InsideCircuitApp()));
    await tester.pump();

    await tester.tap(find.text('START SYSTEM'));
    await tester.pump();

    expect(find.byType(GameWidget<CircuitGame>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
