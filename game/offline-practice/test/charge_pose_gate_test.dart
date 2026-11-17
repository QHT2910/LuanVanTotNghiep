import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/presentation/charge_pose_gate.dart';
import 'package:offline_practice/src/presentation/shot_pose_clock.dart';
import 'package:offline_practice/src/simulation/practice.dart';

void main() {
  test(
    'only exact submitted frame may be frozen; sample time is preserved',
    () {
      final hold = UnpreparedPoseHold();
      expect(hold.freeze(8), isFalse);
      hold.record(clip: 'Jog_Fwd_Loop', time: .437, grounded: true, frame: 8);
      expect(hold.freeze(7), isFalse);
      expect(hold.freeze(8), isTrue);
      hold.record(clip: 'Idle_Loop', time: 0, grounded: true, frame: 9);
      final frozen = hold.sample(ready: false, reset: false, grounded: true)!;
      expect(frozen.clip, 'Jog_Fwd_Loop');
      expect(frozen.time, .437);
      expect(
        () => hold.record(
          clip: 'Idle_Loop',
          time: double.nan,
          grounded: true,
          frame: 10,
        ),
        throwsArgumentError,
      );
    },
  );
  test('Idle/Jog tap before evaluated frame releases exact origin once', () {
    for (final moving in [false, true]) {
      final game = Practice();
      if (moving) {
        game.setMove(1, 0);
        game.advance(.1);
      }
      final origin = game.ball;
      final gate = ChargePoseGate()..begin();
      final clock = ShotPoseClock()..charge();
      expect(game.startCharge(), isTrue);
      expect(game.release(displayedOrigin: origin), isTrue);
      expect(gate.consume(frame: 5, latchGeneration: 0), isFalse);
      clock.cancel();
      expect(clock.active, isFalse);
      expect(
        [game.shot!.origin.x, game.shot!.origin.y, game.shot!.origin.z],
        [origin.x, origin.y, origin.z],
      );
      final id = game.shot!.id;
      expect(game.release(displayedOrigin: origin), isFalse);
      expect(game.shot!.id, id);
    }
  });
  test('current submitted authored sample permits one recovery', () {
    final gate = ChargePoseGate()..begin();
    final clock = ShotPoseClock()..charge();
    final shown = clock.sample(.6);
    gate.record(
      evaluatedGeneration: gate.generation,
      frame: 7,
      latchGeneration: 2,
      authored: true,
    );
    expect(gate.consume(frame: 7, latchGeneration: 2), isTrue);
    clock.release();
    expect(clock.sample(0), shown);
    expect(gate.consume(frame: 7, latchGeneration: 2), isFalse);
  });
  test('cancel and new charge cannot reuse previous evaluated generation', () {
    final gate = ChargePoseGate()..begin();
    final old = gate.generation;
    gate.record(
      evaluatedGeneration: old,
      frame: 8,
      latchGeneration: 3,
      authored: true,
    );
    gate.cancel();
    gate.begin();
    gate.record(
      evaluatedGeneration: old,
      frame: 9,
      latchGeneration: 4,
      authored: true,
    );
    expect(gate.consume(frame: 9, latchGeneration: 4), isFalse);
  });
  test('base pose, changed frame or latch generation reject recovery', () {
    for (final variation in ['frame', 'generation', 'base']) {
      final gate = ChargePoseGate()..begin();
      gate.record(
        evaluatedGeneration: gate.generation,
        frame: 10,
        latchGeneration: 5,
        authored: variation != 'base',
      );
      expect(
        gate.consume(
          frame: variation == 'frame' ? 11 : 10,
          latchGeneration: variation == 'generation' ? 6 : 5,
        ),
        isFalse,
      );
    }
  });
  test(
    'unprepared flying phase retains exact Idle/Jog sample, not Idle zero',
    () {
      for (final clip in ['Idle_Loop', 'Jog_Fwd_Loop']) {
        final hold = UnpreparedPoseHold()
          ..latch(clip: clip, time: .437, grounded: true);
        for (var frame = 0; frame < 10; frame++) {
          final sample = hold.sample(
            ready: false,
            reset: false,
            grounded: true,
          )!;
          expect(sample.clip, clip);
          expect(sample.time, .437);
        }
      }
    },
  );
  test('explicit reset, ground change, ready and cancellation clear hold', () {
    for (final reason in ['reset', 'landing', 'ready', 'cancel']) {
      final hold = UnpreparedPoseHold()
        ..latch(clip: 'Jog_Fwd_Loop', time: .437, grounded: false);
      if (reason == 'cancel') hold.clear();
      expect(
        hold.sample(
          ready: reason == 'ready',
          reset: reason == 'reset',
          grounded: reason == 'landing',
        ),
        isNull,
      );
    }
  });
}
