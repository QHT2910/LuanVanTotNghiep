import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../lib/src/network/stage1_server.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

class Client {
  Client(this.socket) {
    socket.listen(
      (dynamic raw) {
        final d = Map<String, dynamic>.from(jsonDecode(raw as String) as Map);
        if (d['type'] == 'welcome') {
          welcome = d;
        } else if (d['type'] == 'snapshot') {
          snapshots.add(d);
        }
      },
      onDone: () => closed = true,
      onError: (Object _) => closed = true,
    );
  }
  final WebSocket socket;
  Map<String, dynamic>? welcome;
  final snapshots = <Map<String, dynamic>>[];
  bool closed = false;
  int seq = 0;
  final clock = Stopwatch()..start();
  final sent = <int, int>{};
  final ackUs = <int>[];
  final commands = <Map<String, Object?>>[];
  Timer? keep;
  Map<String, dynamic> get last => snapshots.last;
  Map<String, Object?> send(String op, {double? x, double? z}) {
    final d = <String, Object?>{
      'v': 1,
      'epoch': welcome!['epoch'],
      'session': welcome!['session'],
      'seq': ++seq,
      'op': op,
      'seen': snapshots.isEmpty ? 0 : last['tick'],
      if (x != null) 'x': x,
      if (z != null) 'z': z,
    };
    sent[seq] = clock.elapsedMicroseconds;
    commands.add({
      'seq': seq,
      'op': op,
      'seen': d['seen'],
      'sentMonoUs': sent[seq],
      if (x != null) 'x': x,
      if (z != null) 'z': z,
    });
    socket.add(jsonEncode(d));
    return d;
  }

  void heartbeat() {
    keep = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!closed) send('keep');
      if (snapshots.isNotEmpty) {
        final ack = last['ack'] as int, start = sent.remove(ack);
        if (start != null) ackUs.add(clock.elapsedMicroseconds - start);
        sent.removeWhere((q, _) => q <= ack);
      }
    });
  }

  Future<void> close() async {
    keep?.cancel();
    await socket.close();
  }
}

Future<void> until(bool Function() predicate, {int milliseconds = 6000}) async {
  final clock = Stopwatch()..start();
  while (!predicate()) {
    if (clock.elapsedMilliseconds > milliseconds)
      throw StateError('Bounded wait timed out');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

String shared(Map<String, dynamic> d) => jsonEncode({
  for (final k in [
    'epoch',
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
  ])
    k: d[k],
});
Future<void> main() async {
  final server = Stage1Server();
  await server.start();
  final clients = <Client>[];
  Future<Client> connect() async {
    final c = Client(await WebSocket.connect(server.uri.toString()));
    clients.add(c);
    await until(() => c.welcome != null);
    return c;
  }

  try {
    final a = await connect(), b = await connect();
    a.heartbeat();
    b.heartbeat();
    await until(
      () =>
          a.snapshots.isNotEmpty &&
          b.snapshots.isNotEmpty &&
          a.last['ready'] == true &&
          b.last['ready'] == true,
    );
    check(a.welcome!['epoch'] == b.welcome!['epoch'], 'Different room epochs');
    var thirdRejected = false;
    try {
      final extra = await WebSocket.connect(server.uri.toString());
      await extra.close();
    } on WebSocketException {
      thirdRejected = true;
    }
    check(thirdRejected, 'Third peer was admitted');
    a.send('move', x: 1, z: 0);
    await until(
      () => ((a.last['players'] as List)[0]['position'][0] as num) > -.8,
    );
    a.send('move', x: 0, z: 0);
    a.send('charge');
    await until(() => ((a.last['players'] as List)[0]['charge'] as num) >= .6);
    final release = a.send('release');
    a.socket.add(jsonEncode(release));
    await until(
      () =>
          (a.last['scores'] as List)[0] == 3 &&
          (b.last['scores'] as List)[0] == 3,
    );
    await until(() => server.room.owner == 1);
    final byTick = {for (final s in b.snapshots) s['tick']: s};
    var comparisons = 0;
    for (final s in a.snapshots) {
      final other = byTick[s['tick']];
      if (other != null) {
        check(shared(s) == shared(other), 'Divergent same-tick snapshot');
        comparisons++;
      }
    }
    check(comparisons > 10, 'Not enough shared snapshots');
    check(
      server.room.eventId == 1 && server.room.events.length == 1,
      'Duplicate score event',
    );
    check((a.last['scoreEvents'] as List).length == 1, 'Client score events');
    final observations = {
      'scope': 'Two real loopback socket clients in one diagnostic process',
      'clientA': [
        for (final s in a.snapshots) Map.of(s)..remove('recipientSession'),
      ],
      'clientB': [
        for (final s in b.snapshots) Map.of(s)..remove('recipientSession'),
      ],
      'commandsA': a.commands,
      'commandsB': b.commands,
      'duplicateReleaseSequence': release['seq'],
      'timestampScope':
          'Client monotonic clocks are separate; no one-way timing inference',
    };
    File.fromUri(
      Platform.script.resolve(
        const String.fromEnvironment(
          'SMOKE_TRACE',
          defaultValue:
              '../../evidence-network-stage1/transport-observations.json',
        ),
      ),
    ).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(observations),
    );
    final oldEpoch = a.welcome!['epoch'];
    await a.close();
    await until(() => b.closed);
    final c = await connect(), d = await connect();
    c.heartbeat();
    d.heartbeat();
    check(c.welcome!['epoch'] != oldEpoch, 'Old room epoch reused');
    await until(() => c.snapshots.isNotEmpty && d.snapshots.isNotEmpty);
    c.socket.add(jsonEncode({...release, 'seq': c.seq + 1}));
    await until(() => c.closed && d.closed);
    final attacks = <Object>[
      '{bad json',
      [1, 2, 3],
      'x' * 4097,
    ];
    for (final attack in attacks) {
      final x = await connect(), y = await connect();
      x.socket.add(attack);
      await until(() => x.closed && y.closed);
    }
    final gap = await connect(), peer = await connect();
    gap.socket.add(
      jsonEncode({
        'v': 1,
        'epoch': gap.welcome!['epoch'],
        'session': gap.welcome!['session'],
        'seq': 2,
        'op': 'keep',
        'seen': 0,
      }),
    );
    await until(() => gap.closed && peer.closed);
    stdout.writeln(
      jsonEncode({
        'pass': true,
        'scope': 'Two real loopback WebSocket clients; no Android rendering/Internet',
        'sameTickComparisons': comparisons,
        'scoreEvents': 1,
        'scores': [3, 0],
        'thirdPeerRejected': true,
        'duplicateReleaseOnce': true,
        'freshEpochAfterLeave': true,
        'staleSessionMalformedBinaryOversizeGapCloseRoom': true,
        'ackObservedUpperBoundUs': a.ackUs.isEmpty
            ? null
            : a.ackUs.reduce((x, y) => x > y ? x : y),
        'maxServerTimerGapUs': server.maxTimerGapUs,
        'timingLimit': 'ACK observation includes polling/broadcast/queue; no one-way latency or physical-device FPS',
      }),
    );
  } finally {
    for (final c in clients) {
      await c.close();
    }
    await server.close();
  }
}
