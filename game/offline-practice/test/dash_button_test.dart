import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/input/dash_button.dart';
import 'package:offline_practice/src/input/joystick.dart';
import 'package:offline_practice/src/simulation/practice.dart';

void elapse(Practice g, double seconds) {
  var left = seconds;
  while (left > 1e-9) {
    final dt = math.min(0.05, left);
    g.advance(dt);
    left -= dt;
  }
}

class DashFixture extends StatefulWidget {
  const DashFixture({super.key});
  @override
  State<DashFixture> createState() => DashFixtureState();
}

class DashFixtureState extends State<DashFixture> {
  final game = Practice();
  Offset axis = Offset.zero;
  int epoch = 0, edges = 0;
  bool enabled = true;

  void reset() {
    setState(() {
      epoch++;
      axis = Offset.zero;
      game.setMove(0, 0);
      game.newRound();
    });
  }

  void pause(bool value) {
    setState(() {
      epoch++;
      axis = Offset.zero;
      enabled = !value;
      game.setMove(0, 0);
      game.setPaused(value);
    });
  }

  @override
  void dispose() {
    game.setMove(0, 0);
    game.setPaused(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final captured = epoch;
    return MaterialApp(
      home: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PracticeJoystick(
              key: const ValueKey('stick'),
              enabled: enabled,
              resetToken: epoch,
              onChanged: (value) {
                if (!mounted || !enabled || captured != epoch) return;
                axis = value;
                game.setMove(-value.dx, value.dy);
              },
            ),
            const SizedBox(width: 80),
            PracticeDashButton(
              key: const ValueKey('dash'),
              enabled: enabled,
              resetToken: epoch,
              onDash: () {
                if (!mounted || !enabled || captured != epoch) return;
                edges++;
                game.dash();
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Hold beyond cooldown does not repeat or accept pointer2', (
    tester,
  ) async {
    final key = GlobalKey<DashFixtureState>();
    await tester.pumpWidget(DashFixture(key: key));
    final s = key.currentState!;
    final center = tester.getCenter(find.byKey(const ValueKey('dash')));
    final first = await tester.startGesture(center, pointer: 81);
    expect(s.edges, 1);
    elapse(s.game, 1.2);
    expect(s.game.dashStatus, 'ready');
    final other = await tester.startGesture(center, pointer: 82);
    await other.up();
    expect(s.edges, 1);
    await first.up();
    final fresh = await tester.startGesture(center, pointer: 83);
    expect(s.edges, 2);
    await fresh.cancel();
    expect(s.game.dashing, isTrue); // Edge action continues on local cancel.
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Joystick and Dash owners remain independent', (tester) async {
    final key = GlobalKey<DashFixtureState>();
    await tester.pumpWidget(DashFixture(key: key));
    final s = key.currentState!;
    final center = tester.getCenter(find.byKey(const ValueKey('stick')));
    final move = await tester.startGesture(center, pointer: 91);
    await move.moveTo(center + const Offset(44, 0));
    final dash = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('dash'))),
      pointer: 92,
    );
    expect(s.game.dashDirection.x, closeTo(-1, 1e-9));
    expect(s.axis.dx, closeTo(1, 1e-9));
    await dash.cancel();
    expect(s.axis.dx, closeTo(1, 1e-9));
    expect(s.game.dashing, isTrue);
    await move.cancel();
    expect(s.axis, Offset.zero);
    // Releasing joystick does not cancel the cached Dash either.
    expect(s.game.dashing, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reset/background invalidates old held edges', (tester) async {
    final key = GlobalKey<DashFixtureState>();
    await tester.pumpWidget(DashFixture(key: key));
    final s = key.currentState!;
    final center = tester.getCenter(find.byKey(const ValueKey('dash')));
    final first = await tester.startGesture(center, pointer: 101);
    elapse(s.game, 0.05);
    s.reset();
    await tester.pump();
    expect(s.game.dashing, isFalse);
    await first.moveTo(center);
    await first.up();
    expect(s.edges, 1);
    elapse(s.game, 1.1);
    final second = await tester.startGesture(center, pointer: 102);
    expect(s.edges, 2);
    elapse(s.game, 0.05);
    s.pause(true);
    await tester.pump();
    final cooldown = s.game.dashCooldownRemaining;
    elapse(s.game, 2);
    expect(s.game.dashCooldownRemaining, cooldown);
    s.pause(false);
    await tester.pump();
    await second.up();
    expect(s.edges, 2);
    expect(s.game.dashing, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
