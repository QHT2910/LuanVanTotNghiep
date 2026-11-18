import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../lib/src/network/stage1_server.dart';

Future<void> main(List<String> args) async {
  final server = Stage1Server();
  await server.start(port: args.isEmpty ? 8091 : int.parse(args.single));
  stdout.writeln(
    jsonEncode({
      'event': 'server_ready',
      'uri': server.uri.toString(),
      'pid': pid,
    }),
  );
  final done = Completer<void>();
  void stop() {
    if (!done.isCompleted) done.complete();
  }

  final signal = ProcessSignal.sigint.watch().listen((_) => stop());
  final input = stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
        if (line == 'quit') stop();
        if (line == 'invalid-snapshot') {
          // Explicit local fault injection, never part of normal broadcasts.
          for (final e in server.sockets.entries) {
            e.value.add(
              jsonEncode({
                ...server.room.snapshot(),
                'recipientSession': server.room.peers[e.key]!.session,
                'ack': server.room.peers[e.key]!.ack,
                'result': 'accepted',
                'serverMonoUs': server.clock.elapsedMicroseconds,
                'maxTimerGapUs': server.maxTimerGapUs,
                'ball': ['invalid', 0, 0],
              }),
            );
          }
          stdout.writeln(
            jsonEncode({
              'event': 'fault_injected',
              'kind': 'invalid_ball',
              'epoch': server.room.epoch,
            }),
          );
        }
      }, onDone: stop);
  try {
    await done.future;
  } finally {
    await input.cancel();
    await signal.cancel();
    await server.close();
    stdout.writeln(jsonEncode({'event': 'server_closed', 'pid': pid}));
  }
}
