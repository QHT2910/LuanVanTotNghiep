import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/simulation/config.dart';
import 'package:offline_practice/src/input/joystick.dart';
import 'package:offline_practice/src/simulation/practice.dart';

void elapse(Practice game, double seconds) {
  var left = seconds;
  while (left > 1e-9) {
    final dt = math.min(0.05, left);
    game.advance(dt);
    left -= dt;
  }
}

class CoordinationFixture extends StatefulWidget {
  const CoordinationFixture({super.key, this.config = const PracticeConfig()});
  final PracticeConfig config;

  @override
  State<CoordinationFixture> createState() => CoordinationFixtureState();
}

class CoordinationFixtureState extends State<CoordinationFixture> {
  late final Practice game;
  int epoch = 0;
  int? shootPointer;
  bool enabled = true;
  Offset axis = Offset.zero;

  @override
  void initState() {
    super.initState();
    game = Practice(config: widget.config);
  }

  void resetInputs(String reason) {
    epoch++;
    shootPointer = null;
    axis = Offset.zero;
    game.setMove(0, 0);
    game.cancelCharge(reason);
  }

  void resetRound() {
    setState(() {
      resetInputs('round');
      game.newRound();
    });
  }

  void setEnabled(bool value) {
    setState(() {
      resetInputs('background_fixture');
      enabled = value;
      game.setPaused(!value);
    });
  }

  @override
  void dispose() {
    resetInputs('dispose_fixture');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capturedEpoch = epoch;
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PracticeJoystick(
                key: const ValueKey('stick'),
                enabled: enabled,
                resetToken: epoch,
                onChanged: (value) {
                  if (!mounted || !enabled || capturedEpoch != epoch) return;
                  axis = value;
                  game.setMove(-value.dx, value.dy);
                },
              ),
              const SizedBox(width: 80),
              Listener(
                key: const ValueKey('shoot'),
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (shootPointer == null && game.startCharge()) {
                    shootPointer = event.pointer;
                  }
                },
                onPointerUp: (event) {
                  if (shootPointer != event.pointer) return;
                  shootPointer = null;
                  game.release();
                },
                onPointerCancel: (event) {
                  if (shootPointer != event.pointer) return;
                  shootPointer = null;
                  game.cancelCharge('shoot_cancel_fixture');
                },
                child: const SizedBox(
                  width: 120,
                  height: 80,
                  child: ColoredBox(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  for (final entry in <(double, int)>[(3.0, 3), (0.0, 2)]) {
    testWidgets('Two pointers keep release value ' + entry.$2.toString(), (
      tester,
    ) async {
      final key = GlobalKey<CoordinationFixtureState>();
      await tester.pumpWidget(
        CoordinationFixture(
          key: key,
          config: PracticeConfig(spawnZ: entry.$1),
        ),
      );
      final state = key.currentState!;
      final center = tester.getCenter(find.byKey(const ValueKey('stick')));
      final move = await tester.startGesture(center, pointer: 21);
      await move.moveTo(center + const Offset(44, 0));
      final shoot = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('shoot'))),
        pointer: 22,
      );
      elapse(state.game, 0.72);
      expect(state.game.phase, PracticePhase.charging);
      expect(state.axis.dx, closeTo(1, 1e-9));
      expect(state.game.player.x, lessThan(0));
      await shoot.up();
      final shot = state.game.shot!;
      final feet = shot.releaseFeet;
      expect(shot.pointValue, entry.$2);
      expect(state.axis.dx, closeTo(1, 1e-9));
      expect(state.game.phase, PracticePhase.flying);
      elapse(state.game, 2.2);
      expect(state.game.score, entry.$2);
      expect(identical(shot.releaseFeet, feet), isTrue);
      expect(state.game.player.x, lessThan(feet.x));
      await move.up();
      await tester.pump();
      expect(state.axis, Offset.zero);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Cancel shoot leaves move active; cancel move leaves charge', (
    tester,
  ) async {
    final key = GlobalKey<CoordinationFixtureState>();
    await tester.pumpWidget(CoordinationFixture(key: key));
    final state = key.currentState!;
    final center = tester.getCenter(find.byKey(const ValueKey('stick')));
    final shootCenter = tester.getCenter(find.byKey(const ValueKey('shoot')));

    final move = await tester.startGesture(center, pointer: 31);
    await move.moveTo(center + const Offset(44, 0));
    final shoot = await tester.startGesture(shootCenter, pointer: 32);
    elapse(state.game, 0.2);
    await shoot.cancel();
    expect(state.game.phase, PracticePhase.ready);
    expect(state.axis.dx, closeTo(1, 1e-9));

    final shootAgain = await tester.startGesture(shootCenter, pointer: 33);
    await move.cancel();
    expect(state.axis, Offset.zero);
    expect(state.game.phase, PracticePhase.charging);
    elapse(state.game, 0.72);
    await shootAgain.up();
    expect(state.game.shot, isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Round reset and disable neutralize old pointers and knob', (
    tester,
  ) async {
    final key = GlobalKey<CoordinationFixtureState>();
    await tester.pumpWidget(CoordinationFixture(key: key));
    final state = key.currentState!;
    final center = tester.getCenter(find.byKey(const ValueKey('stick')));
    final shootCenter = tester.getCenter(find.byKey(const ValueKey('shoot')));
    final move = await tester.startGesture(center, pointer: 41);
    await move.moveTo(center + const Offset(44, 0));
    final shoot = await tester.startGesture(shootCenter, pointer: 42);
    elapse(state.game, 0.2);
    state.resetRound();
    // Synchronous game reset, before the widget rebuild.
    expect(state.axis, Offset.zero);
    expect(state.game.phase, PracticePhase.ready);
    await tester.pump();
    expect(
      tester.getCenter(find.byKey(const ValueKey('joystick_thumb'))),
      center,
    );
    await move.moveTo(center + const Offset(44, 0));
    await shoot.up();
    expect(state.axis, Offset.zero);
    expect(state.game.shot, isNull);
    await move.up();

    final move2 = await tester.startGesture(center, pointer: 43);
    await move2.moveTo(center + const Offset(44, 0));
    final shoot2 = await tester.startGesture(shootCenter, pointer: 44);
    state.setEnabled(false);
    expect(state.axis, Offset.zero);
    expect(state.game.paused, isTrue);
    await tester.pump();
    expect(
      tester.getCenter(find.byKey(const ValueKey('joystick_thumb'))),
      center,
    );
    state.setEnabled(true);
    await tester.pump();
    await move2.moveTo(center + const Offset(44, 0));
    await shoot2.up();
    expect(state.axis, Offset.zero);
    expect(state.game.shot, isNull);
    await move2.up();

    // A fresh down is required after reset/disable.
    final fresh = await tester.startGesture(center, pointer: 45);
    await fresh.moveTo(center + const Offset(44, 0));
    expect(state.axis.dx, closeTo(1, 1e-9));
    // Remove with a live pointer: no child dispose notification into parent.
    await tester.pumpWidget(const SizedBox.shrink());
    await fresh.cancel();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
