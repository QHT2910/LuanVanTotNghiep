import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_practice/config.dart';
import 'package:offline_practice/practice.dart';

void advanceFor(Practice game, double seconds, [double frame = 0.05]) {
  var remaining = seconds;
  while (remaining > 1e-9) {
    final dt = math.min(frame, remaining);
    game.advance(dt);
    remaining -= dt;
  }
}

void shoot(Practice game, {double? hold}) {
  expect(game.startCharge(), isTrue);
  advanceFor(game, hold ?? game.config.chargeSeconds * game.config.idealCharge);
  expect(game.release(), isTrue);
}

void main() {
  test('Outer footprint tangency and either side of the line', () {
    final g = Practice();
    final boundary = g.config.hoopZ + g.config.arcRadius + g.config.footRadius;
    expect(g.pointsAt(V3(0, 0, boundary)), 2);
    expect(g.pointsAt(V3(0, 0, boundary - 1e-6)), 2);
    expect(g.pointsAt(V3(0, 0, boundary + 1e-6)), 3);
  });

  test('Reset during charge or flight invalidates old action', () {
    final g = Practice();
    g.startCharge();
    advanceFor(g, 0.4);
    g.newRound();
    expect(g.release(), isFalse);
    shoot(g);
    advanceFor(g, 0.4);
    g.newRound();
    advanceFor(g, 5);
    expect(g.score, 0);
    expect(g.phase, PracticePhase.ready);
    shoot(g);
    advanceFor(g, 2.2);
    expect(g.score, 3);
  });
  test('Swept crossing detects descent but not ascent or replay', () {
    V3? hit(double a, double b) => descendingCrossing(
      origin: const V3(0, 1, 0), velocity: const V3(2, 6, 0),
      gravity: 10, planeY: 2, from: a, to: b,
    );
    expect(hit(0, 0.3), isNull); // Upward crossing at t=0.2.
    final p = hit(0.9, 1.1)!; // Downward crossing at t=1.
    expect(p.x, closeTo(2, 1e-9));
    expect(p.y, 2);
    expect(hit(1, 1.2), isNull);
    expect(hit(0, double.nan), isNull);
    expect(descendingCrossing(
      origin: const V3(0, 1, 0), velocity: const V3(0, 0, 0),
      gravity: 10, planeY: 2, from: 0, to: 1,
    ), isNull);
  });

  test('Perfect charge scores once, preserves release point and value', () {
    final events = <Map<String, Object?>>[];
    final g = Practice(onEvent: events.add);
    shoot(g);
    final shot = g.shot!;
    expect(shot.pointValue, 3);
    expect(shot.releaseFeet.z, 3);
    g.setMove(0, -1); // Move inside the line after release.
    advanceFor(g, 2.2);
    expect(g.pointsAt(g.player), 2);
    expect(g.score, 3);
    expect(shot.releaseFeet.z, 3);
    advanceFor(g, 5);
    expect(g.score, 3);
    expect(events.where((e) => e['event'] == 'score').length, 1);
    expect(g.release(), isFalse);
  });

  test('Inside/on-line gives two; completely outside gives three', () {
    final g = Practice(config: const PracticeConfig(spawnZ: 0));
    final c = g.config;
    expect(g.pointsAt(V3(0, 0, c.hoopZ + c.arcRadius)), 2);
    expect(g.pointsAt(V3(
      0, 0, c.hoopZ + c.arcRadius + c.footRadius + 0.01,
    )), 3);
    shoot(g);
    advanceFor(g, 2.2);
    expect(g.score, 2);
  });

  test('Too little or too much charge misses instead of forcing score', () {
    for (final hold in [0.0, 2.0]) {
      final g = Practice();
      shoot(g, hold: hold);
      advanceFor(g, 3);
      expect(g.score, 0);
    }
  });

  test('Pointer cancel/background cannot release a shot', () {
    final g = Practice();
    expect(g.startCharge(), isTrue);
    advanceFor(g, 0.4);
    g.cancelCharge('pointer_cancel');
    expect(g.charge, 0);
    expect(g.phase, PracticePhase.ready);
    expect(g.release(), isFalse);
    expect(g.shot, isNull);

    expect(g.startCharge(), isTrue);
    g.setMove(1, 1);
    g.setPaused(true);
    final p = g.player;
    advanceFor(g, 1);
    expect(g.player.x, p.x);
    expect(g.player.z, p.z);
    expect(g.phase, PracticePhase.ready);
    expect(g.startCharge(), isFalse);
    g.setPaused(false);
    expect(g.release(), isFalse);
  });

  test('Manual and automatic reset retain score and permit next shot', () {
    final g = Practice();
    shoot(g);
    advanceFor(g, 2.2);
    expect(g.score, 3);
    g.newRound();
    expect(g.score, 3);
    expect(g.shot, isNull);
    expect(g.phase, PracticePhase.ready);
    expect(g.charge, 0);

    shoot(g);
    advanceFor(g, 4);
    expect(g.score, 6);
    expect(g.phase, PracticePhase.ready);
    expect(g.shot, isNull);
    expect(g.startCharge(), isTrue);
  });

  test('Bounds, diagonal normalization and invalid dt are enforced', () {
    final g = Practice();
    g.setMove(1, 1);
    g.advance(0.05);
    final dx = g.player.x;
    final dz = g.player.z - g.config.spawnZ;
    expect(math.sqrt(dx * dx + dz * dz),
        closeTo(g.config.moveSpeed * 0.05, 1e-8));
    advanceFor(g, 20);
    expect(g.player.x, lessThanOrEqualTo(g.config.maxX - g.config.footRadius));
    expect(g.player.z, lessThanOrEqualTo(g.config.maxZ - g.config.footRadius));
    final before = g.player;
    g.advance(double.nan);
    g.advance(double.infinity);
    g.advance(-1);
    expect(g.player.x, before.x);
    expect(g.player.z, before.z);
    g.setMove(double.nan, 1);
    advanceFor(g, 0.1);
    expect(g.player.z, before.z);
  });

  test('Large frame dt is capped, not simulated as an unbounded jump', () {
    final g = Practice();
    g.setMove(1, 0);
    g.advance(20);
    expect(g.player.x,
        closeTo(g.config.moveSpeed * g.config.maxFrame, 1e-8));
  });

  test('Equivalent accepted time yields the same deterministic shot', () {
    final a = Practice(), b = Practice();
    shoot(a);
    shoot(b);
    advanceFor(a, 1.6, 0.05);
    advanceFor(b, 1.6, 0.01);
    expect(a.score, b.score);
    expect(a.ball.x, closeTo(b.ball.x, 1e-8));
    expect(a.ball.y, closeTo(b.ball.y, 1e-8));
    expect(a.ball.z, closeTo(b.ball.z, 1e-8));
  });

  test('Invalid configuration fails before simulation', () {
    expect(() => Practice(config: const PracticeConfig(gravity: 0)),
        throwsArgumentError);
    expect(() => Practice(config: const PracticeConfig(step: 0)),
        throwsArgumentError);
  });
}
