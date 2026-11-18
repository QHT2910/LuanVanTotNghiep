import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../lib/src/network/stage2_client.dart';

Future<void> main(List<String> args) async {
  final done = Completer<void>();
  void finish() {
    if (!done.isCompleted) done.complete();
  }

  final client = Stage2Client(
    onCommit: (_) {},
    onStatus: (s) {
      stdout.writeln(jsonEncode({'event': 'status', 'status': s, 'pid': pid}));
      if (!{'connected', 'connecting'}.contains(s)) finish();
    },
    onLog: (e) => stdout.writeln(jsonEncode({...e, 'pid': pid})),
  );
  await client.connect(
    args.isEmpty ? 'ws://127.0.0.1:8091/room/stage1' : args.single,
  );
  final input = stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
        try {
          final a = line.trim().split(RegExp(r'\s+'));
          if (a.first == 'quit') {
            finish();
            return;
          }
          if (a.first == 'move' && a.length == 3) {
            client.move(double.parse(a[1]), double.parse(a[2]));
          } else if (a.first == 'stop') {
            client.move(0, 0);
          } else {
            client.send(a.first);
          }
        } catch (_) {
          stderr.writeln('Invalid diagnostic command');
        }
      }, onDone: finish);
  try {
    await done.future;
  } finally {
    await input.cancel();
    client.close();
  }
}
