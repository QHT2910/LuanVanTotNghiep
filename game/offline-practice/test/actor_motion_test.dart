import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/presentation/actor_motion.dart';
import 'package:offline_practice/src/simulation/practice.dart';

void main() {
  ActorPose pose({
    double t = .1,
    double dx = 0,
    bool ground = true,
    bool ready = true,
    bool reset = false,
  }) => actorPose(
    accepted: t,
    dx: dx,
    dz: 0,
    grounded: ground,
    ready: ready,
    reset: reset,
  );
  test('actual displacement selects locomotion, blocked movement idles', () {
    expect(pose(dx: .2), ActorPose.jog);
    expect(pose(), ActorPose.idle);
  });
  test('air, action lock and reset hold pose rather than fake clips', () {
    expect(pose(dx: .2, ground: false), ActorPose.held);
    expect(pose(dx: .2, ready: false), ActorPose.held);
    expect(pose(dx: 5, reset: true), ActorPose.held);
    expect(pose(t: double.nan), ActorPose.held);
  });
  test('animation accepts simulation time rather than raw long frame', () {
    final game = Practice();
    final before = game.simulatedTime;
    game.advance(10);
    final accepted = game.simulatedTime - before;
    expect(accepted, lessThanOrEqualTo(game.config.maxFrame + 1e-9));
    expect(actorClipTime(0, accepted, 1), closeTo(accepted, 1e-9));
    expect(actorClipTime(.9, .2, 1), closeTo(.1, 1e-12));
    expect(() => actorClipTime(0, double.nan, 1), throwsArgumentError);
    expect(() => actorClipTime(0, .1, 0), throwsArgumentError);
  });
}
