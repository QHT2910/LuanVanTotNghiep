import 'dart:math' as math;

// Accepted simulation time only. This clock never emits a gameplay release.
class ShotPoseClock {
  double recover = 0;
  bool charging = false;
  double _lastSample = 0, _releaseFrom = 0;
  void charge() {
    charging = true;
    recover = 0;
    _lastSample = 0;
  }

  void release() {
    _releaseFrom = _lastSample;
    charging = false;
    recover = .3;
  }

  void cancel() {
    charging = false;
    recover = 0;
  }

  void advance(double accepted) {
    if (!accepted.isFinite || accepted < 0) {
      throw ArgumentError('Invalid accepted time');
    }
    recover = math.max(0, recover - accepted);
  }

  bool get active => charging || recover > 0;
  double sample(double charge) {
    if (charging) _lastSample = charge.clamp(0.0, 1.0).toDouble();
    return charging
        ? _lastSample
        : _releaseFrom +
              (2 - _releaseFrom) *
                  (1 - recover / .3).clamp(0.0, 1.0).toDouble();
  }
}

({String name, double time}) jumpPose({
  required double velocity,
  required double speed,
  required double gravity,
  required double startDuration,
  required double loopDuration,
}) {
  if (![
        velocity,
        speed,
        gravity,
        startDuration,
        loopDuration,
      ].every((v) => v.isFinite) ||
      speed <= 0 ||
      gravity <= 0 ||
      startDuration <= 0 ||
      loopDuration <= 0) {
    throw ArgumentError('Invalid visual jump timing');
  }
  final elapsed = ((speed - velocity) / gravity).clamp(
    0.0,
    2 * speed / gravity,
  );
  return elapsed < .18
      ? (name: 'Jump_Start', time: elapsed / .18 * startDuration)
      : (name: 'Jump_Loop', time: (elapsed - .18) % loopDuration);
}
