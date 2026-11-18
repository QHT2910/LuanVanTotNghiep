import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/network/network_snapshot.dart';
import 'package:offline_practice/src/network/stage1_room.dart';

Map<String, Object?> packet(
  int tick, {
  String epoch = 'e',
  String session = 'a',
  int id = 0,
  int first = 1,
}) => {
  ...Stage1Room(epoch).snapshot(),
  'tick': tick,
  'recipientSession': session,
  'ack': 0,
  'result': 'joined',
  'serverMonoUs': 0,
  'maxTimerGapUs': 0,
  'eventId': id,
  'scores': [id * 3, 0],
  'scoreEvents': [
    for (var i = first; i <= id; i++)
      <String, Object?>{
        'eventId': i,
        'slot': 0,
        'shotId': i,
        'points': 3,
        'score': i * 3,
      },
  ],
};
void main() {
  test('absolute scores, repeated/new events, duplicate tick and fresh epoch baseline', () {
    final c = SnapshotConsumer('e', 'a');
    expect(c.accept(packet(0), sentSeq: 0)!.effects, isEmpty);
    expect(c.accept(packet(1, id: 1), sentSeq: 0)!.effects.single.id, 1);
    final repeated = c.accept(packet(2, id: 1), sentSeq: 0)!;
    expect(repeated.effects, isEmpty);
    expect(repeated.snapshot.scores, [3, 0]);
    expect(c.accept(packet(2, id: 1), sentSeq: 0), isNull);
    expect(c.accept(packet(3, id: 2), sentSeq: 0)!.effects.single.id, 2);
    final fresh = SnapshotConsumer('new', 'b');
    final initial = fresh.accept(
      packet(0, epoch: 'new', session: 'b', id: 2),
      sentSeq: 0,
    )!;
    expect(initial.effects, isEmpty);
    expect(initial.snapshot.scores, [6, 0]);
    expect(fresh.accept(packet(9, id: 2), sentSeq: 0), isNull);
  });
  test(
    'bounded tail gap suppresses missing effects; next new event emits once',
    () {
      final c = SnapshotConsumer('e', 'a');
      c.accept(packet(0, id: 1), sentSeq: 0);
      final gap = c.accept(packet(1, id: 40, first: 9), sentSeq: 0)!;
      expect(gap.gap, isTrue);
      expect(gap.effects, isEmpty);
      expect(gap.snapshot.scores, [120, 0]);
      expect(c.effectWatermark, 40);
      final next = c.accept(packet(2, id: 41, first: 10), sentSeq: 0)!;
      expect(next.gap, isFalse);
      expect(next.effects.single.id, 41);
      expect(next.snapshot.scores, [123, 0]);
    },
  );
  test('late invalid field never commits state or calls writer', () {
    final c = SnapshotConsumer('e', 'a');
    var calls = 0;
    void apply(Object raw) {
      final value = c.accept(raw, sentSeq: 0);
      if (value != null) calls++;
    }

    apply(packet(0));
    final before = c.current;
    final bad = packet(1, id: 1);
    (bad['scoreEvents'] as List).last['score'] = double.nan;
    expect(() => apply(bad), throwsFormatException);
    expect(calls, 1);
    expect(identical(c.current, before), isTrue);
    expect(c.effectWatermark, 0);
  });
  test(
    'finite/schema/slots/phase/ack/tail/shot/session rejection is atomic',
    () {
      final c = SnapshotConsumer('e', 'a');
      c.accept(packet(0), sentSeq: 0);
      final before = c.current;
      final mutations = <void Function(Map<String, Object?>)>[
        (p) => p['ball'] = [0, 0, double.nan],
        (p) => p['owner'] = 2,
        (p) => p['phase'] = 'fake',
        (p) => p['ack'] = 1,
        (p) => p['tick'] = -1,
        (p) => p['extra'] = true,
        (p) => (p['players'] as List)[1]['slot'] = 0,
        (p) => p['eventId'] = 1,
        (p) => p['shotKey'] = 'e:0:1',
        (p) {
          p['phase'] = 'flying';
          p['shotKey'] = 'e:1:1';
        },
        (p) {
          p['phase'] = 'flying';
          p['shotKey'] = 'e:0:NaN';
        },
      ];
      for (final mutate in mutations) {
        final p = packet(1);
        mutate(p);
        expect(() => c.accept(p, sentSeq: 0), throwsFormatException);
        expect(identical(c.current, before), isTrue);
      }
      expect(c.accept(packet(1, session: 'old'), sentSeq: 0), isNull);
      expect(c.accept(packet(1, epoch: 'old'), sentSeq: 0), isNull);
    },
  );
  test('immutable DTO is detached from raw packet; score and ACK regression rejected', () {
    final c = SnapshotConsumer('e', 'a'), raw = packet(1, id: 1)..['ack'] = 1;
    final s = c.accept(raw, sentSeq: 1)!.snapshot;
    (raw['scores'] as List)[0] = 999;
    (raw['players'] as List)[0]['position'][0] = 999.0;
    expect(s.scores, [3, 0]);
    expect(s.players[0].position.x, -1);
    expect(() => s.scores[0] = 999, throwsUnsupportedError);
    expect(() => s.events.clear(), throwsUnsupportedError);
    expect(() => s.players.clear(), throwsUnsupportedError);
    expect(() => c.accept(packet(2, id: 1), sentSeq: 1), throwsFormatException);
    expect(() => c.accept(packet(2), sentSeq: 1), throwsFormatException);
    expect(identical(c.current, s), isTrue);
  });
}
