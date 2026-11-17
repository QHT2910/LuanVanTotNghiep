// Readiness belongs to one charge and one submitted hand/ball sample.
class ChargePoseGate {
  int _generation = 0;
  bool _charging = false;
  ({int frame, int latchGeneration})? _prepared;
  int get generation => _generation;
  void begin() {
    _generation++;
    _charging = true;
    _prepared = null;
  }

  void cancel() {
    _generation++;
    _charging = false;
    _prepared = null;
  }

  void record({
    required int evaluatedGeneration,
    required int frame,
    required int latchGeneration,
    required bool authored,
  }) {
    if (!_charging) return;
    _prepared = authored && evaluatedGeneration == _generation
        ? (frame: frame, latchGeneration: latchGeneration)
        : null;
  }

  bool consume({required int frame, required int latchGeneration}) {
    final p = _prepared;
    final result =
        _charging &&
        p != null &&
        p.frame == frame &&
        p.latchGeneration == latchGeneration;
    _charging = false;
    _prepared = null;
    return result;
  }
}

// A zero-frame tap has no shooting pose to recover from. Preserve its exact
// submitted base pose during flight, until an explicit reset/ground-state change.
class UnpreparedPoseHold {
  ({String clip, double time, bool grounded})? _held;
  ({String clip, double time, bool grounded})? submitted;
  int? submittedFrame;
  void record({
    required String clip,
    required double time,
    required bool grounded,
    required int frame,
  }) {
    if (clip.isEmpty || !time.isFinite || time < 0 || frame < 0) {
      throw ArgumentError('Invalid submitted pose');
    }
    submitted = (clip: clip, time: time, grounded: grounded);
    submittedFrame = frame;
  }

  bool freeze(int frame) {
    if (submitted == null || submittedFrame != frame) return false;
    _held = submitted;
    return true;
  }

  void latch({
    required String clip,
    required double time,
    required bool grounded,
  }) {
    _held = (clip: clip, time: time, grounded: grounded);
  }

  void clear() => _held = null;
  ({String clip, double time, bool grounded})? sample({
    required bool ready,
    required bool reset,
    required bool grounded,
  }) {
    if (ready || reset || (_held != null && _held!.grounded != grounded))
      clear();
    return _held;
  }
}
