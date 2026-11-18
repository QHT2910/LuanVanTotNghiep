typedef NetVec = ({double x, double y, double z});
typedef NetPlayer = ({
  int slot,
  NetVec position,
  NetVec facing,
  bool grounded,
  double charge,
});
typedef ScoreEffect = ({int id, int slot, int shotId, int points, int score});
typedef Welcome = ({int slot, String epoch, String session});

Map<dynamic, dynamic> _map(Object? value) {
  if (value is! Map) throw const FormatException('map');
  return value;
}

void _keys(Map<dynamic, dynamic> m, Set<String> expected) {
  if (m.length != expected.length || m.keys.any((k) => !expected.contains(k))) {
    throw const FormatException('keys');
  }
}

int _int(Object? v, [int min = 0, int max = 2147483647]) {
  if (v is! int || v < min || v > max) throw const FormatException('integer');
  return v;
}

double _finite(Object? v, [double min = -1000000, double max = 1000000]) {
  if (v is! num || !v.isFinite || v < min || v > max)
    throw const FormatException('finite');
  return v.toDouble();
}

bool _bool(Object? v) {
  if (v is! bool) throw const FormatException('bool');
  return v;
}

List<dynamic> _list(Object? v, int max, {int? exact}) {
  if (v is! List || v.length > max || (exact != null && v.length != exact)) {
    throw const FormatException('list');
  }
  return v;
}

NetVec _vector(Object? v) {
  final a = _list(v, 3, exact: 3);
  return (x: _finite(a[0]), y: _finite(a[1]), z: _finite(a[2]));
}

Welcome decodeWelcome(Object? raw) {
  final d = _map(raw);
  _keys(d, {'v', 'type', 'slot', 'epoch', 'session'});
  final e = d['epoch'], s = d['session'];
  final token = RegExp(r'^[0-9a-f]{32}$');
  if (d['v'] != 1 ||
      d['type'] != 'welcome' ||
      e is! String ||
      s is! String ||
      !token.hasMatch(e) ||
      !token.hasMatch(s))
    throw const FormatException('welcome');
  return (slot: _int(d['slot'], 0, 1), epoch: e, session: s);
}

class NetworkSnapshot {
  NetworkSnapshot({
    required this.epoch,
    required this.tick,
    required this.ack,
    required this.result,
    required this.ready,
    required this.owner,
    required this.ball,
    required this.phase,
    required this.shotKey,
    required List<NetPlayer> players,
    required List<int> scores,
    required this.eventId,
    required List<ScoreEffect> events,
  }) : players = List.unmodifiable(players),
       scores = List.unmodifiable(scores),
       events = List.unmodifiable(events);
  final String epoch, result, phase;
  final String? shotKey;
  final int tick, ack, owner, eventId;
  final bool ready;
  final NetVec ball;
  final List<NetPlayer> players;
  final List<int> scores;
  final List<ScoreEffect> events;
  Map<String, Object?> core() => {
    'epoch': epoch,
    'tick': tick,
    'ready': ready,
    'owner': owner,
    'phase': phase,
    'shotKey': shotKey,
    'players': [
      for (final p in players)
        {
          'slot': p.slot,
          'position': [p.position.x, p.position.y, p.position.z],
          'facing': [p.facing.x, p.facing.y, p.facing.z],
          'grounded': p.grounded,
          'charge': p.charge,
        },
    ],
    'ball': [ball.x, ball.y, ball.z],
    'scores': scores,
    'eventId': eventId,
  };
}

NetworkSnapshot decodeSnapshot(
  Object? raw, {
  required String epoch,
  required String session,
  required int sentSeq,
}) {
  final m = _map(raw);
  _keys(m, {
    'v',
    'type',
    'epoch',
    'recipientSession',
    'tick',
    'ready',
    'owner',
    'ball',
    'phase',
    'shotKey',
    'players',
    'scores',
    'eventId',
    'scoreEvents',
    'ack',
    'result',
    'serverMonoUs',
    'maxTimerGapUs',
  });
  if (m['v'] != 1 ||
      m['type'] != 'snapshot' ||
      m['epoch'] != epoch ||
      m['recipientSession'] != session)
    throw const FormatException('context');
  final tick = _int(m['tick']), ack = _int(m['ack'], 0, sentSeq);
  _int(m['serverMonoUs'], 0, 9007199254740991);
  _int(m['maxTimerGapUs'], 0, 9007199254740991);
  final result = m['result'], phase = m['phase'];
  if (!{'joined', 'waiting', 'accepted', 'policy_rejected'}.contains(result))
    throw const FormatException('result');
  if (!{'ready', 'charging', 'flying', 'waiting'}.contains(phase))
    throw const FormatException('phase');
  final owner = _int(m['owner'], 0, 1), shot = m['shotKey'];
  if (shot != null) {
    if (shot is! String || shot.length > 128)
      throw const FormatException('shotKey');
    final parts = shot.split(':');
    if (parts.length != 3 ||
        parts[0] != epoch ||
        parts[1] != '$owner' ||
        !RegExp(r'^[1-9][0-9]*$').hasMatch(parts[2]) ||
        int.tryParse(parts[2]) == null)
      throw const FormatException('shotKey');
  }
  if ((phase == 'flying' || phase == 'waiting') != (shot != null))
    throw const FormatException('shot phase');
  final ps = <NetPlayer>[];
  for (final rawPlayer in _list(m['players'], 2, exact: 2)) {
    final p = _map(rawPlayer);
    _keys(p, {'slot', 'position', 'facing', 'grounded', 'charge'});
    ps.add((
      slot: _int(p['slot'], 0, 1),
      position: _vector(p['position']),
      facing: _vector(p['facing']),
      grounded: _bool(p['grounded']),
      charge: _finite(p['charge'], 0, 1),
    ));
  }
  ps.sort((a, b) => a.slot.compareTo(b.slot));
  if (ps[0].slot != 0 || ps[1].slot != 1) throw const FormatException('slots');
  final scores = [for (final s in _list(m['scores'], 2, exact: 2)) _int(s)];
  final id = _int(m['eventId']);
  final events = <ScoreEffect>[];
  var previous = 0;
  final shots = <String>{};
  for (final rawEvent in _list(m['scoreEvents'], 32)) {
    final e = _map(rawEvent);
    _keys(e, {'eventId', 'slot', 'shotId', 'points', 'score'});
    final eid = _int(e['eventId'], 1, id),
        slot = _int(e['slot'], 0, 1),
        shotId = _int(e['shotId'], 1),
        points = _int(e['points'], 2, 3);
    final score = _int(e['score'], points);
    if (score > scores[slot] ||
        (previous != 0 && eid != previous + 1) ||
        !shots.add('$slot:$shotId'))
      throw const FormatException('events');
    events.add((
      id: eid,
      slot: slot,
      shotId: shotId,
      points: points,
      score: score,
    ));
    previous = eid;
  }
  if ((id == 0 && events.isNotEmpty) ||
      (id > 0 && (events.isEmpty || events.last.id != id))) {
    throw const FormatException('event tail');
  }
  return NetworkSnapshot(
    epoch: epoch,
    tick: tick,
    ack: ack,
    result: result as String,
    ready: _bool(m['ready']),
    owner: owner,
    ball: _vector(m['ball']),
    phase: phase as String,
    shotKey: shot as String?,
    players: ps,
    scores: scores,
    eventId: id,
    events: events,
  );
}

class SnapshotCommit {
  SnapshotCommit(this.snapshot, List<ScoreEffect> effects, this.gap)
    : effects = List.unmodifiable(effects);
  final NetworkSnapshot snapshot;
  final List<ScoreEffect> effects;
  final bool gap;
}

class SnapshotConsumer {
  SnapshotConsumer(this.epoch, this.session);
  final String epoch, session;
  NetworkSnapshot? current;
  int effectWatermark = 0;
  SnapshotCommit? accept(Object? raw, {required int sentSeq}) {
    if (raw is Map &&
        (raw['epoch'] != epoch || raw['recipientSession'] != session))
      return null;
    final s = decodeSnapshot(
      raw,
      epoch: epoch,
      session: session,
      sentSeq: sentSeq,
    );
    final old = current;
    if (old != null && s.tick <= old.tick) return null;
    if (old != null &&
        (s.ack < old.ack ||
            s.eventId < old.eventId ||
            s.scores[0] < old.scores[0] ||
            s.scores[1] < old.scores[1]))
      throw const FormatException('regression');
    final unseen = s.events.where((e) => e.id > effectWatermark).toList();
    final gap =
        old != null &&
        s.eventId > effectWatermark &&
        (unseen.isEmpty || unseen.first.id != effectWatermark + 1);
    final effects = old == null || gap ? <ScoreEffect>[] : unseen;
    // Atomic commit; initial/gapped history suppresses old effects, never adds points.
    current = s;
    effectWatermark = s.eventId;
    return SnapshotCommit(s, effects, gap);
  }
}
