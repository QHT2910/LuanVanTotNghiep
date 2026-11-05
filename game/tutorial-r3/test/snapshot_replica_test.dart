import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scene/scene.dart' as fs;

import '../lib/snapshot_replica.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Hai client ap snapshot va bo packet cu/sai phien', () async {
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final peers = <WebSocket>[];
    final clients = <WebSocket>[];
    final subscriptions = <StreamSubscription<dynamic>>[];
    final connected = Completer<void>();

    final serverSubscription = server.listen((request) async {
      final peer = await WebSocketTransformer.upgrade(request);
      peers.add(peer);
      // Tiêu thụ stream để xử lý vòng đời socket.
      subscriptions.add(peer.listen((dynamic _) {}));
      if (peers.length == 2 && !connected.isCompleted) {
        connected.complete();
      }
    });

    final nodes = [fs.Node(), fs.Node()];
    final replicas = [
      for (final node in nodes)
        SnapshotReplica(node: node, session: 's1'),
    ];

    Map<String, Object> packet(
      int tick,
      double x, {
      String session = 's1',
    }) => {
      'schema': 1,
      'session': session,
      'entity': 'ball',
      'tick': tick,
      'x': x,
      'y': 0.35,
      'z': 0.0,
    };

    final packets = [
      packet(1, 1),
      packet(1, 99),                  // Trùng.
      packet(99, 99, session: 's0'), // Sai phiên.
      packet(3, 3),
      packet(2, 2),                  // Đến muộn.
    ];

    final positions = [<double>[], <double>[]];
    final ticks = [<int>[], <int>[]];
    final accepted = [<bool>[], <bool>[]];
    final done = [Completer<void>(), Completer<void>()];

    try {
      final uri = 'ws://127.0.0.1:${server.port}';
      clients.add(await WebSocket.connect(uri));
      clients.add(await WebSocket.connect(uri));
      await connected.future.timeout(const Duration(seconds: 5));

      for (var i = 0; i < clients.length; i++) {
        final index = i;
        subscriptions.add(clients[index].listen(
          (dynamic message) {
            try {
              final raw = jsonDecode(message as String);
              accepted[index].add(replicas[index].apply(raw));
              positions[index].add(nodes[index].position.x);
              ticks[index].add(replicas[index].lastTick);
              if (positions[index].length == packets.length &&
                  !done[index].isCompleted) {
                done[index].complete();
              }
            } catch (error, stack) {
              if (!done[index].isCompleted) {
                done[index].completeError(error, stack);
              }
            }
          },
          onError: (Object error, StackTrace stack) {
            if (!done[index].isCompleted) {
              done[index].completeError(error, stack);
            }
          },
          onDone: () {
            if (!done[index].isCompleted) {
              done[index].completeError(
                StateError('Socket dong truoc khi du snapshot'),
              );
            }
          },
        ));
      }

      for (final packet in packets) {
        final encoded = jsonEncode(packet);
        for (final peer in peers) {
          peer.add(encoded);
        }
      }

      await Future.wait(done.map((item) => item.future))
          .timeout(const Duration(seconds: 5));

      for (var i = 0; i < replicas.length; i++) {
        expect(accepted[i], [true, false, false, true, false]);
        expect(positions[i], [1.0, 1.0, 1.0, 3.0, 3.0]);
        expect(ticks[i], [1, 1, 1, 3, 3]);
        // Scene transform storage rounds this value to Float32 precision.
        expect(nodes[i].position.y, closeTo(0.35, 1e-6));

        final invalid = packet(4, 4)..['z'] = double.nan;
        expect(replicas[i].apply(invalid), isFalse);
        expect(replicas[i].lastTick, 3);
        expect(nodes[i].position.x, 3.0);

        final wrongEntity = packet(4, 4)..['entity'] = 'other';
        expect(replicas[i].apply(wrongEntity), isFalse);
        expect(replicas[i].lastTick, 3);

        replicas[i].close();
        expect(replicas[i].apply(packet(4, 4)), isFalse);
      }
    } finally {
      for (final replica in replicas) {
        replica.close();
      }
      await Future.wait([
        for (final socket in [...clients, ...peers])
          socket.close(),
      ]).timeout(const Duration(seconds: 5));
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await serverSubscription.cancel();
      await server.close(force: true);
    }
  });
}
