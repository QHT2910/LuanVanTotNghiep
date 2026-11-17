import '../simulation/config.dart';
import '../simulation/practice.dart';

class Stage1Peer {
  Stage1Peer(this.session);
  final String session;
  int ack = 0, seen = 0;
  double quiet = 0, moveAge = 0;
  String result = 'joined';
}

/// Ephemeral two-slot diagnostic room. Alternating turns are NOT final 1v1 rules.
class Stage1Room {
  Stage1Room(this.epoch) {
    for (var i = 0; i < 2; i++) {
      final slot = i;
      games.add(
        Practice(
          config: PracticeConfig(spawnX: i == 0 ? -1 : 1),
          onEvent: (e) {
            if (e['event'] == 'score') {
              events.add({
                'eventId': ++eventId,
                'slot': slot,
                'shotId': e['shotId'],
                'points': e['points'],
                'score': e['score'],
              });
              if (events.length > 32) events.removeAt(0);
            }
          },
        ),
      );
    }
  }
  final String epoch;
  final games = <Practice>[];
  final peers = <int, Stage1Peer>{};
  final events = <Map<String, Object?>>[];
  int owner = 0, tick = 0, eventId = 0;
  bool closed = false;
  bool get ready => peers.length == 2 && !closed;

  void join(int slot, String session) {
    if (closed || slot < 0 || slot > 1 || peers.containsKey(slot)) {
      throw StateError('Room unavailable');
    }
    peers[slot] = Stage1Peer(session);
  }

  String input(int slot, Object? raw) {
    final p = peers[slot];
    if (closed || p == null || raw is! Map) return 'invalid';
    const keys = {'v', 'epoch', 'session', 'seq', 'op', 'x', 'z', 'seen'};
    if (raw.keys.any((k) => !keys.contains(k)) ||
        raw['v'] != 1 ||
        raw['epoch'] != epoch ||
        raw['session'] != p.session)
      return 'invalid';
    final q = raw['seq'], seen = raw['seen'], op = raw['op'];
    if (q is! int ||
        q < 1 ||
        q > 2147483647 ||
        seen is! int ||
        seen < 0 ||
        seen > tick ||
        !{
          'move',
          'charge',
          'release',
          'cancel',
          'jump',
          'dash',
          'keep',
        }.contains(op)) {
      return 'invalid';
    }
    if (op == 'move') {
      final x = raw['x'], z = raw['z'];
      if (x is! num ||
          z is! num ||
          !x.isFinite ||
          !z.isFinite ||
          x.abs() > 1 ||
          z.abs() > 1)
        return 'invalid';
    } else if (raw.containsKey('x') || raw.containsKey('z')) {
      return 'invalid';
    }
    if (q <= p.ack) return 'duplicate';
    if (q != p.ack + 1) return 'gap';
    p.ack = q;
    if (seen > p.seen) p.seen = seen;
    p.quiet = 0;
    if (!ready) return p.result = 'waiting';
    final g = games[slot];
    var applied = true;
    switch (op) {
      case 'move':
        g.setMove((raw['x'] as num).toDouble(), (raw['z'] as num).toDouble());
        p.moveAge = 0;
      case 'charge':
        applied = slot == owner && g.startCharge();
      case 'release':
        applied = slot == owner && g.release();
      case 'cancel':
        g.cancelCharge('remote_cancel');
      case 'jump':
        applied = g.jump();
      case 'dash':
        applied = g.dash();
      case 'keep':
        break;
    }
    return p.result = applied ? 'accepted' : 'policy_rejected';
  }

  void advance(double dt) {
    if (!dt.isFinite || dt <= 0 || dt > .1) throw ArgumentError('server dt');
    if (!ready) return;
    final oldRound = games[owner].round;
    for (final e in peers.entries) {
      final p = e.value, g = games[e.key];
      p.quiet += dt;
      p.moveAge += dt;
      if (p.moveAge > .25) g.setMove(0, 0);
      if (p.quiet > 1) {
        g.setMove(0, 0);
        g.cancelCharge('input_timeout');
        g.cancelDash('input_timeout');
      }
      g.advance(dt);
    }
    if (games[owner].round != oldRound) {
      owner = 1 - owner;
      games[owner].newRound('stage1_turn');
    }
    tick++;
  }

  List<double> _xyz(V3 p) => [p.x, p.y, p.z];
  Map<String, Object?> snapshot() => {
    'v': 1,
    'type': 'snapshot',
    'epoch': epoch,
    'tick': tick,
    'ready': ready,
    'owner': owner,
    'ball': _xyz(games[owner].ball),
    'phase': games[owner].phase.name,
    'shotKey': games[owner].shot == null
        ? null
        : '$epoch:$owner:${games[owner].shot!.id}',
    'players': [
      for (var i = 0; i < 2; i++)
        {
          'slot': i,
          'position': _xyz(games[i].player),
          'facing': _xyz(games[i].facing),
          'grounded': games[i].grounded,
          'charge': i == owner ? games[i].charge : 0,
        },
    ],
    'scores': [for (final g in games) g.score],
    'eventId': eventId,
    'scoreEvents': List.of(events),
  };
  void close() {
    if (closed) return;
    closed = true;
    for (final g in games) {
      g.setPaused(true);
    }
    peers.clear();
  }
}
