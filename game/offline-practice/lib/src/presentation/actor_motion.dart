enum ActorPose { idle, jog, held }

ActorPose actorPose({
  required double accepted,
  required double dx,
  required double dz,
  required bool grounded,
  required bool ready,
  required bool reset,
}) {
  if (!accepted.isFinite || accepted <= 0 || reset || !grounded || !ready) {
    return ActorPose.held;
  }
  return dx.isFinite && dz.isFinite && dx * dx + dz * dz > 1e-12
      ? ActorPose.jog
      : ActorPose.idle;
}

double actorClipTime(double previous, double accepted, double duration) {
  if (!previous.isFinite ||
      !accepted.isFinite ||
      accepted < 0 ||
      !duration.isFinite ||
      duration <= 0) {
    throw ArgumentError('Invalid actor clip time');
  }
  return (previous + accepted) % duration;
}
