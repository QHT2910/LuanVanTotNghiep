class ArmTransition {
  ArmTransition({this.duration = .12}) {
    if (!duration.isFinite || duration <= 0) throw ArgumentError('duration');
  }
  final double duration;
  double _age = 0;
  bool active = false;
  double get alpha => active ? (_age / duration).clamp(0.0, 1.0) : 1;
  void begin() {
    _age = 0;
    active = true;
  }

  void advance(double accepted) {
    if (!accepted.isFinite || accepted < 0) throw ArgumentError('accepted');
    if (active) {
      _age = (_age + accepted).clamp(0.0, duration);
      if (_age >= duration) active = false;
    }
  }

  void reset() {
    active = false;
    _age = 0;
  }
}
