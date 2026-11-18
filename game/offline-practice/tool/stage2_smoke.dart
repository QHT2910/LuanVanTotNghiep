import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../lib/src/network/stage1_server.dart';
import '../lib/src/network/stage2_client.dart';
import '../lib/src/network/network_snapshot.dart';

Future<void> until(bool Function() p) async {
  final clock = Stopwatch()..start();
  while (!p()) {
    if (clock.elapsedMilliseconds > 6000)
      throw StateError('Bounded wait timeout');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<void> main() async {
  final server = Stage1Server();
  await server.start();
  final aStates = <SnapshotCommit>[], bStates = <SnapshotCommit>[];
  final logs = <Map<String, Object?>>[];
  final a = Stage2Client(
    onCommit: aStates.add,
    onStatus: (_) {},
    onLog: (e) => logs.add({'peer': 'a', ...e}),
  );
  final b = Stage2Client(
    onCommit: bStates.add,
    onStatus: (_) {},
    onLog: (e) => logs.add({'peer': 'b', ...e}),
  );
  try {
    await a.connect(server.uri.toString());
    await b.connect(server.uri.toString());
    await until(
      () =>
          aStates.isNotEmpty &&
          bStates.isNotEmpty &&
          aStates.last.snapshot.ready,
    );
    a.send('charge');
    await until(() => aStates.last.snapshot.players[0].charge >= .6);
    a.send('release');
    await until(
      () =>
          aStates.last.snapshot.scores[0] == 3 &&
          bStates.last.snapshot.scores[0] == 3,
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final afx = [for (final c in aStates) ...c.effects],
        bfx = [for (final c in bStates) ...c.effects];
    if (afx.length != 1 ||
        bfx.length != 1 ||
        afx.single.id != 1 ||
        bfx.single.id != 1)
      throw StateError('Effect dedupe');
    final bTicks = {for (final c in bStates) c.snapshot.tick: c.snapshot};
    var count = 0;
    for (final c in aStates) {
      final other = bTicks[c.snapshot.tick];
      if (other != null) {
        if (jsonEncode(c.snapshot.core()) != jsonEncode(other.core()))
          throw StateError('Snapshot mismatch');
        count++;
      }
    }
    if (count < 10) throw StateError('Too few matched ticks');
    a.close();
    await until(() => b.closed);
    final output = File.fromUri(
      Platform.script.resolve(
        '../../evidence-network-stage2/adapter-observations.json',
      ),
    );
    output.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(logs));
    stdout.writeln(
      jsonEncode({
        'pass': true,
        'scope': 'Two typed consumers over loopback, one process, not AVD',
        'matchedTicks': count,
        'scores': [3, 0],
        'effectsPerClient': [afx.length, bfx.length],
        'disconnectClosesPeer': b.closed,
        'observationFile': 'adapter-observations.json',
      }),
    );
  } finally {
    a.close();
    b.close();
    await server.close();
  }
}
