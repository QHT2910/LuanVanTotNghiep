import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/presentation/held_ball_latch.dart';
import 'package:offline_practice/src/simulation/practice.dart';

void main() {
  test('Dash invalidates origin without changing input owner epoch', () {
    final latch = HeldBallLatch();
    void sample() => latch.record(
      world: const V3(0, 1.3, 3),
      renderWorld: const V3(0, 1.3, 3),
      round: 1,
      epoch: 9,
      simTime: .5,
      frame: 10,
      acceptedDelta: .02,
      camera: 'side',
    );
    sample();
    expect(latch.current(round: 1, epoch: 9), isNotNull);
    latch.invalidate(); // Production accepted-Dash path calls this same operation.
    final game = Practice();
    game.startCharge();
    expect(latch.current(round: 1, epoch: 9), isNull);
    expect(
      game.shot,
      isNull,
    ); // A new charge alone must not revive the old origin.
    sample();
    expect(latch.current(round: 1, epoch: 9), isNotNull);
  });
  test(
    'late round and input epoch cannot release a previous render sample',
    () {
      final latch = HeldBallLatch()
        ..record(
          world: const V3(0, 1.3, 3),
          renderWorld: const V3(0, 1.3, 3),
          round: 1,
          epoch: 9,
          simTime: .5,
          frame: 10,
          acceptedDelta: .02,
          camera: 'front',
        );
      expect(latch.current(round: 2, epoch: 9), isNull);
      expect(latch.current(round: 1, epoch: 10), isNull);
      expect(latch.current(round: 1, epoch: 9)!.frame, 10);
    },
  );
}
