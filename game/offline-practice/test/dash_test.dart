import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/simulation/config.dart';
import 'package:offline_practice/src/simulation/practice.dart';

void elapse(Practice g, double seconds, [double frame = 0.05]) {
  var left = seconds;
  while (left > 1e-9) {
    final dt = math.min(frame, left);
    g.advance(dt);
    left -= dt;
  }
}

void shot(Practice g) {
  expect(g.startCharge(), isTrue);
  elapse(g, g.config.chargeSeconds * g.config.idealCharge);
  expect(g.release(), isTrue);
}

void main() {
  test('Default idle heading faces rim and Dash has bounded duration', () {
    final g = Practice();
    expect(g.dash(), isTrue);
    expect(g.dashDirection.z, closeTo(-1, 1e-9));
    final start = g.player;
    elapse(g, g.config.dashDuration);
    expect(g.dashing, isFalse);
    expect(
      g.player.z,
      closeTo(start.z - g.config.dashSpeed * g.config.dashDuration, 1e-8),
    );
    expect(g.player.y, 0);
    expect(g.dash(), isFalse);
    elapse(g, g.config.dashCooldown);
    expect(g.dashCooldownRemaining, 0);
    expect(g.dash(), isTrue);
  });

  test('Analog direction is cached; speed does not add walk or steering', () {
    final g = Practice();
    g.setMove(0.2, 0);
    expect(g.dash(), isTrue);
    g.setMove(-1, 1);
    elapse(g, g.config.dashDuration);
    expect(
      g.player.x,
      closeTo(g.config.dashSpeed * g.config.dashDuration, 1e-8),
    );
    expect(g.player.z, g.config.spawnZ);
    expect(g.dashDirection.x, closeTo(1, 1e-9));
    g.setMove(0, 0);
    elapse(g, g.config.dashCooldown);
    expect(g.dash(), isTrue);
    expect(g.dashDirection.x, closeTo(1, 1e-9));
  });

  test('Diagonal unit distance is not faster', () {
    final g = Practice();
    final start = g.player;
    g.setMove(1, 1);
    g.dash();
    elapse(g, g.config.dashDuration);
    final dx = g.player.x - start.x, dz = g.player.z - start.z;
    expect(
      math.sqrt(dx * dx + dz * dz),
      closeTo(g.config.dashSpeed * g.config.dashDuration, 1e-8),
    );
    expect(dx, closeTo(dz, 1e-8));
  });

  test('Ray bounds ends Dash without tunneling and reserves cooldown', () {
    final events = <Map<String, Object?>>[];
    final g = Practice(
      config: const PracticeConfig(spawnX: 3.73),
      onEvent: events.add,
    );
    g.setMove(1, 0);
    expect(g.dash(), isTrue);
    g.advance(g.config.step);
    expect(g.player.x, g.config.maxX - g.config.footRadius);
    expect(g.dashing, isFalse);
    final ends = events.where((e) => e['event'] == 'dash_end').toList();
    expect(ends.single['reason'], 'bounds');
    expect(g.dash(), isFalse);
    elapse(g, 1);
    expect(g.player.x, lessThanOrEqualTo(g.config.maxX - g.config.footRadius));
  });

  test('Air, waiting, paused and double Dash are rejected', () {
    final events = <Map<String, Object?>>[];
    final g = Practice(onEvent: events.add);
    g.jump();
    expect(g.dash(), isFalse);
    elapse(g, 1.2);
    g.setPaused(true);
    expect(g.dash(), isFalse);
    g.setPaused(false);
    expect(g.dash(), isTrue);
    expect(g.dash(), isFalse);
    g.cancelDash('fixture');
    elapse(g, 1.1);
    shot(g);
    elapse(g, 1.9);
    expect(g.phase, PracticePhase.waiting);
    expect(g.dash(), isFalse);
    final reasons = events
        .where((e) => e['event'] == 'dash_rejected')
        .map((e) => e['reason'])
        .toList();
    expect(
      reasons,
      containsAll(['airborne', 'paused', 'already_dashing', 'waiting']),
    );
  });

  test('Dash cancels charge and blocks shoot/jump without a queue', () {
    final g = Practice();
    g.startCharge();
    elapse(g, 0.3);
    expect(g.dash(), isTrue);
    expect(g.charge, 0);
    expect(g.phase, PracticePhase.ready);
    expect(g.release(), isFalse);
    expect(g.startCharge(), isFalse);
    expect(g.jump(), isFalse);
    elapse(g, 0.3);
    expect(g.grounded, isTrue);
    expect(g.shot, isNull);
    expect(g.release(), isFalse);
    expect(g.startCharge(), isTrue);
    g.cancelCharge('fixture');
  });

  test('Background cancels Dash and freezes cooldown, no auto resume', () {
    final g = Practice();
    g.setMove(1, 0);
    g.dash();
    elapse(g, 0.05);
    final p = g.player;
    final cooldown = g.dashCooldownRemaining;
    g.setPaused(true);
    expect(g.dashing, isFalse);
    elapse(g, 2);
    expect(g.player.x, p.x);
    expect(g.dashCooldownRemaining, cooldown);
    g.setPaused(false);
    elapse(g, 0.1);
    expect(g.player.x, p.x);
    expect(g.dash(), isFalse);
    elapse(g, 1);
    expect(g.dashing, isFalse);
    expect(g.dash(), isTrue);
  });

  test('Round reset cancels Dash and preserves cooldown/score', () {
    final g = Practice();
    shot(g);
    elapse(g, 2.2);
    g.newRound();
    expect(g.score, 3);
    g.dash();
    elapse(g, 0.05);
    final cooldown = g.dashCooldownRemaining;
    g.newRound();
    expect(g.score, 3);
    expect(g.dashing, isFalse);
    expect(g.grounded, isTrue);
    expect(g.dashCooldownRemaining, cooldown);
    expect(g.dash(), isFalse);
    expect(g.release(), isFalse);
  });

  test('Old flying shot keeps cached three even after Dash moves inside', () {
    final events = <Map<String, Object?>>[];
    final g = Practice(onEvent: events.add);
    shot(g);
    final previous = g.shot!;
    expect(previous.pointValue, 3);
    expect(g.dash(), isTrue);
    elapse(g, 0.2);
    expect(g.pointsAt(g.player), 2);
    elapse(g, 2);
    expect(g.score, 3);
    expect(previous.pointValue, 3);
    expect(events.where((e) => e['event'] == 'score').length, 1);
  });

  test('Input partition and finite settings retain deterministic bounds', () {
    final a = Practice(), b = Practice();
    a.setMove(1, 0);
    b.setMove(1, 0);
    a.dash();
    b.dash();
    elapse(a, 0.2, 0.05);
    elapse(b, 0.2, 0.01);
    expect(a.player.x, closeTo(b.player.x, 1e-9));
    expect(a.dashCooldownRemaining, closeTo(b.dashCooldownRemaining, 1e-9));
    for (final c in [
      const PracticeConfig(dashSpeed: double.nan),
      const PracticeConfig(dashDuration: 0),
      const PracticeConfig(dashCooldown: -1),
      const PracticeConfig(dashSpeed: 1e308, dashDuration: 10),
    ]) {
      expect(() => Practice(config: c), throwsArgumentError);
    }
  });
}
