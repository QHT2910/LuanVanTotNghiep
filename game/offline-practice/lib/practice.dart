import 'dart:math' as math;

import 'config.dart';

class V3 {
  const V3(this.x, this.y, this.z);
  final double x, y, z;
}

enum PracticePhase { ready, charging, flying, waiting }

V3 ballistic(V3 origin, V3 velocity, double gravity, double time) {
  return V3(
    origin.x + velocity.x * time,
    origin.y + velocity.y * time - 0.5 * gravity * time * time,
    origin.z + velocity.z * time,
  );
}

// Exact descending plane crossing over a time interval.
// This does not test overlap only at the end of a rendered frame.
V3? descendingCrossing({
  required V3 origin,
  required V3 velocity,
  required double gravity,
  required double planeY,
  required double from,
  required double to,
}) {
  final values = [
    origin.x, origin.y, origin.z, velocity.x, velocity.y, velocity.z,
    gravity, planeY, from, to,
  ];
  if (values.any((v) => !v.isFinite) ||
      gravity <= 0 || from < 0 || to <= from) {
    return null;
  }
  final discriminant =
      velocity.y * velocity.y - 2 * gravity * (planeY - origin.y);
  if (discriminant <= 0) return null; // Tangency is not descent.
  final time = (velocity.y + math.sqrt(discriminant)) / gravity;
  if (time <= from || time > to ||
      velocity.y - gravity * time >= 0) {
    return null;
  }
  final p = ballistic(origin, velocity, gravity, time);
  return V3(p.x, planeY, p.z);
}

class Shot {
  Shot({
    required this.id,
    required this.releaseFeet,
    required this.origin,
    required this.velocity,
    required this.pointValue,
    required this.normalizedCharge,
  });

  final int id, pointValue;
  final V3 releaseFeet, origin, velocity;
  final double normalizedCharge;
  double _time = 0;
  bool _crossed = false;
  bool _scored = false;

  double get elapsed => _time;
  bool get scored => _scored;
}

class Practice {
  Practice({
    this.config = const PracticeConfig(),
    this.onEvent,
  }) {
    config.validate();
    _player = V3(config.spawnX, 0, config.spawnZ);
    _ball = _held;
  }

  final PracticeConfig config;
  final void Function(Map<String, Object?> event)? onEvent;
  late V3 _player, _ball;
  PracticePhase _phase = PracticePhase.ready;
  Shot? _shot;
  int _score = 0, _shotSerial = 0, _eventSerial = 0, _round = 1;
  double _charge = 0, _axisX = 0, _axisZ = 0;
  double _accumulator = 0, _wait = 0, _simTime = 0;
  bool _paused = false;

  V3 get player => _player;
  V3 get ball => _ball;
  V3 get _held => V3(_player.x, config.releaseY, _player.z);
  int get score => _score;
  int get round => _round;
  Shot? get shot => _shot;
  PracticePhase get phase => _phase;
  bool get paused => _paused;
  double get charge =>
      (_charge / config.chargeSeconds).clamp(0.0, 1.0).toDouble();

  int pointsAt(V3 feet) {
    final dx = feet.x - config.hoopX;
    final dz = feet.z - config.hoopZ;
    // A circular foot footprint touching the line is worth two.
    final threshold = config.arcRadius + config.footRadius;
    // A numerical tolerance preserves tangency after coordinate subtraction.
    return math.sqrt(dx * dx + dz * dz) - threshold > config.lineTolerance
        ? 3 : 2;
  }

  void _emit(String name, [Map<String, Object?> data = const {}]) {
    onEvent?.call(Map<String, Object?>.unmodifiable({
      'event': name,
      'eventId': ++_eventSerial,
      'simTime': _simTime,
      'round': _round,
      'shotId': _shot?.id ?? _shotSerial,
      ...data,
    }));
  }

  void setMove(double x, double z) {
    if (_paused || !x.isFinite || !z.isFinite) {
      _axisX = 0;
      _axisZ = 0;
      return;
    }
    x = x.clamp(-1.0, 1.0).toDouble();
    z = z.clamp(-1.0, 1.0).toDouble();
    final length = math.sqrt(x * x + z * z);
    _axisX = length > 1 ? x / length : x;
    _axisZ = length > 1 ? z / length : z;
  }

  bool startCharge() {
    if (_paused || _phase != PracticePhase.ready) return false;
    _charge = 0;
    _phase = PracticePhase.charging;
    _emit('charge_start');
    return true;
  }

  void cancelCharge([String reason = 'cancel']) {
    if (_phase != PracticePhase.charging) return;
    _charge = 0;
    _phase = PracticePhase.ready;
    _ball = _held;
    _emit('charge_cancel', {'reason': reason});
  }

  bool release() {
    if (_paused || _phase != PracticePhase.charging) return false;
    final q = charge;
    final feet = _player; // V3 is immutable.
    final origin = _held;
    final dx = config.hoopX - origin.x;
    final dz = config.hoopZ - origin.z;
    final distance = math.sqrt(dx * dx + dz * dz);
    final ux = distance > 1e-9 ? dx / distance : 0.0;
    final uz = distance > 1e-9 ? dz / distance : -1.0;
    final error = (q - config.idealCharge) * config.missScale;
    final targetX = config.hoopX + ux * error;
    final targetZ = config.hoopZ + uz * error;
    final t = config.flightSeconds;
    final vy = (config.rimY - origin.y + 0.5 * config.gravity * t * t) / t;
    final velocity = V3(
      (targetX - origin.x) / t,
      vy,
      (targetZ - origin.z) / t,
    );
    _shot = Shot(
      id: ++_shotSerial,
      releaseFeet: feet,
      origin: origin,
      velocity: velocity,
      pointValue: pointsAt(feet),
      normalizedCharge: q,
    );
    _phase = PracticePhase.flying;
    _emit('shot_release', {
      'charge': q, 'pointValue': _shot!.pointValue,
      'feetX': feet.x, 'feetZ': feet.z,
      'originX': origin.x, 'originY': origin.y, 'originZ': origin.z,
    });
    return true;
  }

  void setPaused(bool value) {
    if (_paused == value) return;
    _paused = value;
    _accumulator = 0;
    if (value) {
      cancelCharge('background');
      _axisX = 0;
      _axisZ = 0;
    }
    _emit(value ? 'paused' : 'resumed');
  }

  void newRound([String reason = 'manual']) {
    cancelCharge('new_round');
    _shot = null;
    _phase = PracticePhase.ready;
    _charge = 0;
    _wait = 0;
    _axisX = 0;
    _axisZ = 0;
    _ball = _held;
    _round++;
    _emit('round_reset', {'reason': reason, 'score': _score});
  }

  void advance(double frameDt) {
    if (_paused) return;
    if (!frameDt.isFinite || frameDt <= 0) {
      _emit('dt_rejected');
      return;
    }
    final accepted = math.min(frameDt, config.maxFrame);
    if (frameDt > config.maxFrame) {
      _emit('dt_clamped', {'accepted': accepted});
    }
    _accumulator += accepted;
    while (_accumulator + 1e-12 >= config.step) {
      _accumulator = math.max(0.0, _accumulator - config.step);
      _step(config.step);
    }
  }

  void _step(double dt) {
    _simTime += dt;
    if (_phase != PracticePhase.waiting) {
      _player = V3(
        (_player.x + _axisX * config.moveSpeed * dt)
            .clamp(config.minX + config.footRadius,
                config.maxX - config.footRadius).toDouble(),
        0,
        (_player.z + _axisZ * config.moveSpeed * dt)
            .clamp(config.minZ + config.footRadius,
                config.maxZ - config.footRadius).toDouble(),
      );
    }

    if (_phase == PracticePhase.charging) {
      _charge = math.min(config.chargeSeconds, _charge + dt);
    }
    if (_phase == PracticePhase.ready ||
        _phase == PracticePhase.charging) {
      _ball = _held;
      return;
    }
    if (_phase == PracticePhase.waiting) {
      _wait += dt;
      if (_wait >= config.resetDelay) newRound('auto');
      return;
    }

    final shot = _shot!;
    final oldTime = shot._time;
    shot._time += dt;
    final crossing = descendingCrossing(
      origin: shot.origin,
      velocity: shot.velocity,
      gravity: config.gravity,
      planeY: config.rimY,
      from: oldTime,
      to: shot._time,
    );
    if (!shot._crossed && crossing != null) {
      shot._crossed = true;
      final dx = crossing.x - config.hoopX;
      final dz = crossing.z - config.hoopZ;
      final clearance = config.rimInnerRadius - config.ballRadius;
      final inside = dx * dx + dz * dz <= clearance * clearance + 1e-9;
      if (inside && !shot._scored) {
        shot._scored = true;
        _score += shot.pointValue;
        _emit('score', {'points': shot.pointValue, 'score': _score});
      }
      _emit('rim_crossing', {
        'inside': inside, 'x': crossing.x, 'z': crossing.z,
      });
    }
    final p = ballistic(
      shot.origin, shot.velocity, config.gravity, shot._time,
    );
    _ball = p;
    if (p.y <= config.ballRadius || shot._time >= config.maxFlight) {
      _ball = V3(p.x, config.ballRadius, p.z);
      _phase = PracticePhase.waiting;
      _wait = 0;
      _emit('shot_end', {'scored': shot._scored, 'score': _score});
    }
  }
}
