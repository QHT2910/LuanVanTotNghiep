import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Native console diagnostic peer, not an Android/Scene renderer.
Future<void> main(List<String> args) async {
  final socket = await WebSocket.connect(
    args.isEmpty ? 'ws://127.0.0.1:8091/room/stage1' : args.single,
  );
  final done = Completer<void>(), clock = Stopwatch()..start();
  String? epoch, session;
  int seq = 0, tick = 0;
  double x = 0, z = 0;
  final sent = <int, int>{};
  void send(String op) {
    if (session == null || done.isCompleted) return;
    final q = ++seq;
    sent[q] = clock.elapsedMicroseconds;
    if (sent.length > 256) sent.remove(sent.keys.first);
    socket.add(
      jsonEncode({
        'v': 1,
        'epoch': epoch,
        'session': session,
        'seq': q,
        'seen': tick,
        'op': op,
        if (op == 'move') 'x': x,
        if (op == 'move') 'z': z,
      }),
    );
  }

  final subscription = socket.listen(
    (dynamic raw) {
      try {
        if (raw is! String || raw.length > 65536)
          throw FormatException('Invalid snapshot');
        final d = jsonDecode(raw) as Map;
        if (d['type'] == 'welcome') {
          epoch = d['epoch'] as String;
          session = d['session'] as String;
          stdout.writeln('diagnostic slot ${d['slot']}');
          return;
        }
        if (d['type'] != 'snapshot' || d['epoch'] != epoch || d['tick'] is! int)
          return;
        final next = d['tick'] as int;
        if (next < tick) return;
        tick = next;
        final ack = d['ack'] as int, start = sent.remove(ack);
        stdout.writeln(
          jsonEncode({
            'recvMonoUs': clock.elapsedMicroseconds,
            'ackObservedUs': start == null
                ? null
                : clock.elapsedMicroseconds - start,
            'snapshot': d,
          }),
        );
        sent.removeWhere((q, _) => q <= ack);
      } catch (_) {
        if (!done.isCompleted) done.complete();
      }
    },
    onDone: () {
      if (!done.isCompleted) done.complete();
    },
    onError: (Object _) {
      if (!done.isCompleted) done.complete();
    },
  );
  final keep = Timer.periodic(
    const Duration(milliseconds: 100),
    (_) => send(x == 0 && z == 0 ? 'keep' : 'move'),
  );
  final input = stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(
        (line) {
          try {
            final a = line.trim().split(RegExp(r'\s+'));
            if (a.first == 'quit') {
              if (!done.isCompleted) done.complete();
              return;
            }
            if (a.first == 'move' && a.length == 3) {
              final nx = double.parse(a[1]), nz = double.parse(a[2]);
              if (!nx.isFinite || !nz.isFinite || nx.abs() > 1 || nz.abs() > 1)
                throw FormatException();
              x = nx;
              z = nz;
              send('move');
            } else if (a.first == 'stop') {
              x = 0;
              z = 0;
              send('move');
            } else if ({
              'charge',
              'release',
              'cancel',
              'jump',
              'dash',
            }.contains(a.first)) {
              send(a.first);
            } else {
              stderr.writeln(
                'Use move x z, stop, charge, release, cancel, jump, dash, quit',
              );
            }
          } catch (_) {
            stderr.writeln('Invalid diagnostic command');
          }
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );
  try {
    await done.future;
  } finally {
    keep.cancel();
    await input.cancel();
    await socket.close();
    await subscription.cancel();
  }
}
