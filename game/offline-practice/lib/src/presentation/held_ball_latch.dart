import '../simulation/practice.dart';

class HeldBallSample {
  const HeldBallSample({
    required this.world,
    required this.renderWorld,
    required this.round,
    required this.epoch,
    required this.generation,
    required this.simTime,
    required this.frame,
    required this.acceptedDelta,
    required this.camera,
  });
  final V3 world, renderWorld;
  final int round, epoch, generation, frame;
  final double simTime, acceptedDelta;
  final String camera;
}

// A separate generation invalidates Dash samples without resetting joystick ownership.
class HeldBallLatch {
  int _generation = 0;
  HeldBallSample? _sample;
  void invalidate() {
    _generation++;
    _sample = null;
  }

  void record({
    required V3 world,
    required V3 renderWorld,
    required int round,
    required int epoch,
    required double simTime,
    required int frame,
    required double acceptedDelta,
    required String camera,
  }) {
    _sample = HeldBallSample(
      world: world,
      renderWorld: renderWorld,
      round: round,
      epoch: epoch,
      generation: _generation,
      simTime: simTime,
      frame: frame,
      acceptedDelta: acceptedDelta,
      camera: camera,
    );
  }

  HeldBallSample? current({required int round, required int epoch}) {
    final s = _sample;
    return s != null &&
            s.round == round &&
            s.epoch == epoch &&
            s.generation == _generation
        ? s
        : null;
  }
}
