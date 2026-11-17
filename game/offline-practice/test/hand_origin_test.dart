import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/simulation/config.dart';
import 'package:offline_practice/src/simulation/practice.dart';
import 'package:offline_practice/src/presentation/shot_pose_clock.dart';

void elapse(Practice g, double seconds) {
  for (var left = seconds; left > 1e-9;) {
    final dt = math.min(.05, left);
    g.advance(dt);
    left -= dt;
  }
}

void main() {
  test('displayed world sample is the exact release origin, once', () {
    final g = Practice();
    g.startCharge();
    elapse(g, .72);
    const w = V3(.2, 1.3, 2.9);
    expect(g.acceptHeldWorld(w), isTrue);
    expect(g.release(displayedOrigin: w), isTrue);
    expect(g.shot!.origin.x, w.x);
    expect(g.shot!.origin.y, w.y);
    expect(g.shot!.origin.z, w.z);
    expect(g.ball.y, w.y);
    expect(g.release(displayedOrigin: w), isFalse);
    expect(
      ballistic(g.shot!.origin, g.shot!.velocity, g.config.gravity, 0).y,
      w.y,
    );
  });
  test(
    'hand origin does not alter feet 2/3 scoring or score more than once',
    () {
      for (final pair in [(z: 3.0, points: 3), (z: 1.5, points: 2)]) {
        final events = <Map<String, Object?>>[];
        final g = Practice(
          config: PracticeConfig(spawnZ: pair.z),
          onEvent: events.add,
        );
        g.startCharge();
        elapse(g, .72);
        expect(g.release(displayedOrigin: V3(.25, 1.4, pair.z - .1)), isTrue);
        expect(g.shot!.pointValue, pair.points);
        g.setMove(1, 0);
        elapse(g, 3);
        expect(g.score, pair.points);
        expect(events.where((e) => e['event'] == 'score').length, 1);
      }
    },
  );
  test(
    'airborne world origin preserves player height and round clears offset',
    () {
      final g = Practice();
      g.jump();
      elapse(g, .1);
      g.startCharge();
      final y = g.player.y, w = V3(.1, g.player.y + 1.4, g.player.z);
      expect(g.release(displayedOrigin: w), isTrue);
      expect(g.shot!.releasePlayerY, y);
      expect(g.shot!.releaseFeet.y, 0);
      g.newRound();
      expect(g.ball.y, g.config.releaseY);
      g.startCharge();
      g.cancelCharge();
      expect(g.release(displayedOrigin: w), isFalse);
    },
  );
  test(
    'invalid or paused samples are rejected without replacing held ball',
    () {
      final g = Practice();
      final old = g.ball;
      for (final w in [
        const V3(double.nan, 1, 0),
        const V3(0, 0, 3),
        const V3(10, 1, 3),
      ]) {
        expect(g.acceptHeldWorld(w), isFalse);
        expect(g.ball, same(old));
      }
      g.startCharge();
      expect(g.release(displayedOrigin: const V3(10, 1, 3)), isFalse);
      expect(g.shot, isNull);
      g.setPaused(true);
      expect(g.acceptHeldWorld(const V3(0, 1.4, 3)), isFalse);
      expect(g.release(displayedOrigin: const V3(0, 1.4, 3)), isFalse);
    },
  );
  test(
    'cancelled pose clock cannot release gameplay and freezes at zero delta',
    () {
      final p = ShotPoseClock()..charge();
      expect(p.sample(.6), .6);
      p.cancel();
      p.advance(.1);
      expect(p.active, isFalse);
      p.charge();
      p.release();
      expect(p.sample(0), 0);
      p.advance(0);
      expect(p.sample(0), 0);
      p.advance(.15);
      expect(p.sample(0), closeTo(1, 1e-9));
      p.advance(.15);
      expect(p.active, isFalse);
      expect(() => p.advance(double.nan), throwsArgumentError);
    },
  );
  test(
    'visual jump mapping follows analytic velocity without delaying jump',
    () {
      expect(
        jumpPose(
          velocity: 5,
          speed: 5,
          gravity: 9.81,
          startDuration: 1.33333337,
          loopDuration: 2.5,
        ).time,
        0,
      );
      expect(
        jumpPose(
          velocity: 0,
          speed: 5,
          gravity: 9.81,
          startDuration: 1.33333337,
          loopDuration: 2.5,
        ).name,
        'Jump_Loop',
      );
    },
  );
}
