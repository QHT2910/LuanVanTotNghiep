import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/jump_button.dart';
import 'package:offline_practice/practice.dart';

void elapse(Practice g, double seconds) {
  var left = seconds;
  while (left > 1e-9) {
    final dt = math.min(left, 0.05);
    g.advance(dt);
    left -= dt;
  }
}

void main() {
  testWidgets('Holding through landing does not autojump or accept pointer2', (
    tester,
  ) async {
    final g = Practice();
    var edges = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PracticeJumpButton(
            key: const ValueKey('jump'),
            resetToken: 0,
            onJump: () {
              edges++;
              g.jump();
            },
          ),
        ),
      ),
    );
    final center = tester.getCenter(find.byKey(const ValueKey('jump')));
    final first = await tester.startGesture(center, pointer: 51);
    expect(edges, 1);
    expect(g.grounded, isFalse);
    elapse(g, 2);
    expect(g.grounded, isTrue);
    await tester.pump();
    final other = await tester.startGesture(center, pointer: 52);
    await other.cancel();
    expect(edges, 1);
    expect(g.grounded, isTrue);
    await first.up();
    final fresh = await tester.startGesture(center, pointer: 53);
    expect(edges, 2);
    expect(g.grounded, isFalse);
    await fresh.cancel();
    // Pointer cancel does not rewind the already-started jump.
    expect(g.grounded, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reset/disable clears owner without generating an edge', (
    tester,
  ) async {
    final g = Practice();
    var edges = 0;
    Future<void> mount(int token, bool enabled) {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PracticeJumpButton(
              key: const ValueKey('jump'),
              resetToken: token,
              enabled: enabled,
              onJump: () {
                edges++;
                g.jump();
              },
            ),
          ),
        ),
      );
    }

    await mount(0, true);
    final center = tester.getCenter(find.byKey(const ValueKey('jump')));
    final old = await tester.startGesture(center, pointer: 61);
    expect(edges, 1);
    elapse(g, 0.2);
    g.newRound();
    await mount(1, true);
    await old.moveTo(center);
    await old.up();
    expect(edges, 1);
    expect(g.grounded, isTrue);
    final active = await tester.startGesture(center, pointer: 62);
    expect(edges, 2);
    elapse(g, 0.2);
    final height = g.player.y;
    g.setPaused(true);
    await mount(2, false);
    elapse(g, 2);
    expect(g.player.y, height);
    final ignored = await tester.startGesture(center, pointer: 63);
    await ignored.up();
    expect(edges, 2);
    g.setPaused(false);
    await mount(3, true);
    await active.up();
    expect(edges, 2);
    elapse(g, 2);
    expect(g.grounded, isTrue);
    final fresh = await tester.startGesture(center, pointer: 64);
    expect(edges, 3);
    await tester.pumpWidget(const SizedBox.shrink());
    await fresh.cancel();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
