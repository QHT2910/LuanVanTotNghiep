import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Local loopback smoke check only. Does not choose the game's final transport.
Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final sockets = <WebSocket>[];
  final lastSeq = <WebSocket, int>{};
  var x = 0;
  var tick = 0;
  final served = Completer<void>();
  final subscription = server.listen((request) async {
    final socket = await WebSocketTransformer.upgrade(request);
    sockets.add(socket);
    lastSeq[socket] = 0;
    socket.listen((dynamic message) {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final seq = data['seq'] as int;
      if (seq > lastSeq[socket]!) {
        lastSeq[socket] = seq;
        x += data['dx'] as int;
        tick++;
      }
      for (final peer in sockets) {
        peer.add(jsonEncode({'x': x, 'tick': tick, 'ack': lastSeq[peer]}));
      }
    });
    if (sockets.length == 2) served.complete();
  });
  WebSocket? a;
  WebSocket? b;
  StreamSubscription<dynamic>? aSub;
  StreamSubscription<dynamic>? bSub;
  try {
    final uri = 'ws://127.0.0.1:${server.port}';
    a = await WebSocket.connect(uri);
    b = await WebSocket.connect(uri);
    await served.future.timeout(const Duration(seconds: 5));
    final firstA = Completer<void>();
    final firstB = Completer<void>();
    final duplicateSeenA = Completer<void>();
    final duplicateSeenB = Completer<void>();
    var tickOneA = 0;
    var tickOneB = 0;
    final doneA = Completer<void>();
    final doneB = Completer<void>();
    Map<String, dynamic>? finalA;
    Map<String, dynamic>? finalB;
    aSub = a.listen((dynamic message) {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      if (data['tick'] == 1 && !firstA.isCompleted) firstA.complete();
      if (data['tick'] == 1 && ++tickOneA == 2) duplicateSeenA.complete();
      if (data['tick'] == 2 && !doneA.isCompleted) {
        finalA = data;
        doneA.complete();
      }
    });
    bSub = b.listen((dynamic message) {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      if (data['tick'] == 1 && !firstB.isCompleted) firstB.complete();
      if (data['tick'] == 1 && ++tickOneB == 2) duplicateSeenB.complete();
      if (data['tick'] == 2 && !doneB.isCompleted) {
        finalB = data;
        doneB.complete();
      }
    });
    a.add(jsonEncode({'seq': 1, 'dx': 1}));
    await Future.wait([firstA.future, firstB.future])
      .timeout(const Duration(seconds: 5));
    a.add(jsonEncode({'seq': 1, 'dx': 100})); // Duplicate must be ignored.
    await Future.wait([duplicateSeenA.future, duplicateSeenB.future])
      .timeout(const Duration(seconds: 5));
    b.add(jsonEncode({'seq': 1, 'dx': 2}));
    await Future.wait([doneA.future, doneB.future])
      .timeout(const Duration(seconds: 5));
    if (finalA!['x'] != 3 || finalB!['x'] != 3 ||
        finalA!['tick'] != 2 || finalB!['tick'] != 2 ||
        finalA!['ack'] != 1 || finalB!['ack'] != 1) {
      throw StateError('State/sequence mismatch');
    }
    stdout.writeln('PASS: two loopback clients share x=3/tick=2; duplicate input ignored; per-client ack=1.');
    stdout.writeln('Not tested: Scene rendering, Android, Internet, latency tolerance, authentication, production reconnect.');
  } finally {
    await aSub?.cancel();
    await bSub?.cancel();
    await a?.close();
    await b?.close();
    for (final peer in sockets) {
      await peer.close();
    }
    await subscription.cancel();
    await server.close(force: true);
  }
}
