import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/simulation/config.dart';
import 'package:offline_practice/src/simulation/practice.dart';

void elapse(Practice g, double time, [double frame = 0.05]) {
  var remaining = time;
  while (remaining > 1e-9) {
    final dt = math.min(frame, remaining);
    g.advance(dt);
    remaining -= dt;
  }
}

void perfectShot(Practice g) {
  expect(g.startCharge(), isTrue);
  elapse(g, g.config.chargeSeconds * g.config.idealCharge);
  expect(g.release(), isTrue);
}

void main() {
  test('Jump latches before first step and lands exactly once', () {
    final events = <Map<String, Object?>>[];
    final g = Practice(onEvent: events.add);
    expect(g.jump(), isTrue);
    expect(g.grounded, isFalse);
    expect(g.player.y, 0);
    expect(g.jump(), isFalse); // Even before first dt.
    elapse(g, 0.5);
    expect(
      g.player.y,
      closeTo(g.config.jumpSpeed * 0.5 - 0.5 * g.config.gravity * 0.25, 1e-8),
    );
    expect(g.ball.y, closeTo(g.player.y + g.config.releaseY, 1e-9));
    expect(g.jump(), isFalse);
    elapse(g, 1);
    expect(g.grounded, isTrue);
    expect(g.player.y, 0);
    expect(g.jumpVelocity, 0);
    expect(events.where((e) => e['event'] == 'jump_start').length, 1);
    final lands = events.where((e) => e['event'] == 'jump_land').toList();
    expect(lands.length, 1);
    expect(
      lands.single['landingSimTime'],
      closeTo(g.config.jumpDuration, 1e-8),
    );
    elapse(g, 1);
    expect(events.where((e) => e['event'] == 'jump_land').length, 1);
    expect(g.jump(), isTrue);
  });

  test('Pause freezes jump and cancels charge without queued input', () {
    final g = Practice();
    expect(g.startCharge(), isTrue);
    expect(g.jump(), isTrue);
    g.setMove(1, 0);
    elapse(g, 0.2);
    final p = g.player;
    final velocity = g.jumpVelocity;
    final t = g.simulatedTime;
    g.setPaused(true);
    elapse(g, 3);
    expect(g.player.y, p.y);
    expect(g.player.x, p.x);
    expect(g.jumpVelocity, velocity);
    expect(g.simulatedTime, t);
    expect(g.release(), isFalse);
    expect(g.jump(), isFalse);
    g.setPaused(false);
    expect(g.release(), isFalse);
    expect(g.player.y, p.y);
    elapse(g, 2);
    expect(g.grounded, isTrue);
    expect(g.player.y, 0);
    expect(g.shot, isNull);
    final x = g.player.x;
    elapse(g, 1);
    expect(g.player.x, x);
    expect(g.grounded, isTrue);
  });

  test('Charge cancellation does not cancel a real jump or create shot', () {
    final g = Practice();
    g.jump();
    g.startCharge();
    elapse(g, 0.2);
    g.cancelCharge('pointer_cancel');
    expect(g.grounded, isFalse);
    expect(g.player.y, greaterThan(0));
    expect(g.release(), isFalse);
    elapse(g, 2);
    expect(g.grounded, isTrue);
    expect(g.shot, isNull);
    expect(g.score, 0);
  });

  for (final entry in <(double, int)>[(3.0, 3), (0.0, 2)]) {
    test(
      'Move jump shoot caches projected feet and ' + entry.$2.toString(),
      () {
        final events = <Map<String, Object?>>[];
        final g = Practice(
          config: PracticeConfig(spawnZ: entry.$1),
          onEvent: events.add,
        );
        g.setMove(-0.5, 0);
        expect(g.startCharge(), isTrue);
        elapse(g, 0.52);
        expect(g.jump(), isTrue);
        elapse(g, 0.2);
        final renderedHeldSample = g.ball;
        final releaseHeight = g.player.y;
        expect(releaseHeight, greaterThan(0));
        expect(g.release(), isTrue);
        final shot = g.shot!;
        expect(identical(shot.origin, renderedHeldSample), isTrue);
        expect(shot.origin.y, closeTo(releaseHeight + g.config.releaseY, 1e-9));
        expect(shot.releasePlayerY, releaseHeight);
        expect(shot.releaseFeet.y, 0);
        expect(shot.pointValue, entry.$2);
        final feetX = shot.releaseFeet.x;
        elapse(g, 2.2);
        expect(g.player.x, lessThan(feetX));
        expect(shot.releaseFeet.x, feetX);
        expect(g.score, entry.$2);
        elapse(g, 4);
        expect(g.score, entry.$2);
        expect(events.where((e) => e['event'] == 'score').length, 1);
      },
    );
  }

  test('Release above rim still crosses down at configured time', () {
    final g = Practice();
    expect(g.startCharge(), isTrue);
    elapse(g, 0.22);
    g.jump();
    elapse(g, 0.5); // Total charge about0.72.
    expect(g.ball.y, greaterThan(g.config.rimY));
    final sample = g.ball;
    expect(g.release(), isTrue);
    final shot = g.shot!;
    expect(identical(shot.origin, sample), isTrue);
    expect(
      shot.velocity.y - g.config.gravity * g.config.flightSeconds,
      lessThan(0),
    );
    final hit = descendingCrossing(
      origin: shot.origin,
      velocity: shot.velocity,
      gravity: g.config.gravity,
      planeY: g.config.rimY,
      from: 0,
      to: g.config.flightSeconds + 0.01,
    );
    expect(hit, isNotNull);
    elapse(g, 2.2);
    expect(g.score, 3);
  });

  test(
    'Manual reset midair grounds player, cancels shot and retains score',
    () {
      final g = Practice();
      perfectShot(g);
      elapse(g, 2.2);
      expect(g.score, 3);
      g.newRound();
      g.jump();
      g.startCharge();
      elapse(g, 0.2);
      g.newRound();
      expect(g.grounded, isTrue);
      expect(g.player.y, 0);
      expect(g.ball.y, g.config.releaseY);
      expect(g.release(), isFalse);
      expect(g.score, 3);
      elapse(g, 2);
      expect(g.grounded, isTrue);
      expect(g.shot, isNull);
    },
  );

  test('Automatic reset can cancel a late jump during shot flight', () {
    final events = <Map<String, Object?>>[];
    final g = Practice(
      config: const PracticeConfig(resetDelay: 0.05),
      onEvent: events.add,
    );
    perfectShot(g);
    elapse(g, 1.5);
    expect(g.phase, PracticePhase.flying);
    expect(g.jump(), isTrue);
    elapse(g, 0.5);
    expect(g.round, 2);
    expect(g.score, 3);
    expect(g.grounded, isTrue);
    expect(g.player.y, 0);
    expect(g.ball.y, g.config.releaseY);
    expect(g.shot, isNull);
    final resets = events.where((e) => e['event'] == 'round_reset').toList();
    expect(resets.single['reason'], 'auto');
    expect(resets.single['jumpCancelled'], isTrue);
    expect(events.where((e) => e['event'] == 'jump_land'), isEmpty);
  });

  test('Partitioned time gives same height and rejects invalid dt', () {
    final a = Practice(), b = Practice();
    a.jump();
    b.jump();
    elapse(a, 0.4, 0.05);
    elapse(b, 0.4, 0.01);
    expect(a.player.y, closeTo(b.player.y, 1e-9));
    final y = a.player.y;
    a.advance(double.nan);
    a.advance(-1);
    a.advance(double.infinity);
    expect(a.player.y, y);
  });

  test('Jump validation checks finite derived values and descending arc', () {
    for (final config in [
      const PracticeConfig(jumpSpeed: 0),
      const PracticeConfig(jumpSpeed: double.nan),
      const PracticeConfig(jumpSpeed: double.infinity),
      const PracticeConfig(jumpSpeed: 1e308),
      const PracticeConfig(jumpSpeed: 100),
      const PracticeConfig(flightSeconds: 0.1),
      const PracticeConfig(maxFlight: 1.41),
    ]) {
      expect(() => Practice(config: config), throwsArgumentError);
    }
  });
}
