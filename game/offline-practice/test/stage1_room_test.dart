import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/network/stage1_room.dart';

void main() {
  Stage1Room room() => Stage1Room('e')
    ..join(0, 'a')
    ..join(1, 'b');
  Map<String, Object> cmd(
    Stage1Room r,
    int seq,
    String op, {
    String session = 'a',
  }) => {
    'v': 1,
    'epoch': 'e',
    'session': session,
    'seq': seq,
    'op': op,
    'seen': r.tick,
  };
  test('server moves correct slot; duplicate cannot replay; stale session rejected', () {
    final r = room(), x0 = r.games[0].player.x, x1 = r.games[1].player.x;
    final m = cmd(r, 1, 'move')..addAll({'x': 1, 'z': 0});
    expect(r.input(0, m), 'accepted');
    r.advance(.05);
    expect(r.games[0].player.x, greaterThan(x0));
    expect(r.games[1].player.x, x1);
    expect(r.input(0, m), 'duplicate');
    expect(r.peers[0]!.ack, 1);
    expect(r.input(0, cmd(r, 2, 'keep', session: 'old')), 'invalid');
    expect(r.peers[0]!.ack, 1);
  });
  test('untrusted score/origin/nonfinite/sequence gap rejected before ack', () {
    final r = room();
    for (final field in ['score', 'origin']) {
      expect(r.input(0, cmd(r, 1, 'keep')..[field] = 999), 'invalid');
    }
    expect(
      r.input(0, cmd(r, 1, 'move')..addAll({'x': double.nan, 'z': 0})),
      'invalid',
    );
    expect(r.input(0, cmd(r, 2, 'keep')), 'gap');
    expect(r.peers[0]!.ack, 0);
  });
  test(
    'nonowner release rejected; canonical shot scores once and changes turn',
    () {
      final r = room();
      expect(r.input(1, cmd(r, 1, 'charge', session: 'b')), 'policy_rejected');
      expect(r.input(0, cmd(r, 1, 'charge')), 'accepted');
      for (var i = 0; i < 72; i++) {
        r.advance(.01);
      }
      expect(r.input(0, cmd(r, 2, 'release')), 'accepted');
      final id = r.games[0].shot!.id;
      expect(r.input(0, cmd(r, 2, 'release')), 'duplicate');
      expect(r.games[0].shot!.id, id);
      for (var i = 0; i < 500 && r.owner == 0; i++) {
        r.advance(.01);
      }
      expect(r.events.length, 1);
      expect(r.games[0].score, 3);
      expect(r.owner, 1);
      expect((r.snapshot()['scores'] as List).first, 3);
    },
  );
  test(
    'movement lease and quiet charge timeout neutralize without release',
    () {
      final r = room();
      r.input(0, cmd(r, 1, 'move')..addAll({'x': 1, 'z': 0}));
      for (var i = 0; i < 30; i++) {
        r.advance(.01);
      }
      final x = r.games[0].player.x;
      for (var i = 0; i < 30; i++) {
        r.advance(.01);
      }
      expect(r.games[0].player.x, x);
      r.input(0, cmd(r, 2, 'charge'));
      for (var i = 0; i < 110; i++) {
        r.advance(.01);
      }
      expect(r.games[0].shot, isNull);
      r.close();
      expect(r.input(0, cmd(r, 3, 'release')), 'invalid');
    },
  );
}
