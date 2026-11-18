import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'stage1_room.dart';

/// Loopback diagnostic transport; no authentication, TLS, persistence or deployment.
class Stage1Server {
  Stage1Server() {
    room = Stage1Room(_token());
  }
  final _random = Random.secure();
  final clock = Stopwatch()..start();
  late Stage1Room room;
  final sockets = <int, WebSocket>{};
  final counts = <int, int>{};
  final _waitingSent = <int>{};
  HttpServer? _http;
  Timer? _timer, _limiter;
  bool closed = false;
  int previousTimerUs = 0, maxTimerGapUs = 0;
  String _token() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  Uri get uri => Uri.parse('ws://127.0.0.1:${_http!.port}/room/stage1');

  Future<void> start({int port = 0}) async {
    if (_http != null || closed) throw StateError('Already started/closed');
    _http = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final now = clock.elapsedMicroseconds;
      final gap = now - previousTimerUs;
      previousTimerUs = now;
      if (gap > maxTimerGapUs) maxTimerGapUs = gap;
      if (room.ready) {
        for (var i = 0; i < 3; i++) {
          room.advance(1 / 60);
        }
        if (sockets.keys.any((k) => room.tick - room.peers[k]!.seen > 120)) {
          _teardown();
          return;
        }
      }
      for (final e in List.of(sockets.entries)) {
        // A lone waiting peer receives one state, not an endless queued stream.
        if (!room.ready && !_waitingSent.add(e.key)) continue;
        try {
          e.value.add(
            jsonEncode({
              ...room.snapshot(),
              'recipientSession': room.peers[e.key]!.session,
              'ack': room.peers[e.key]!.ack,
              'result': room.peers[e.key]!.result,
              'serverMonoUs': now,
              'maxTimerGapUs': maxTimerGapUs,
            }),
          );
        } catch (_) {
          _teardown();
          return;
        }
      }
    });
    _limiter = Timer.periodic(
      const Duration(seconds: 1),
      (_) => counts.clear(),
    );
    unawaited(_serve());
  }

  Future<void> _serve() async {
    await for (final req in _http!) {
      if (closed) {
        await req.response.close();
        continue;
      }
      if (req.uri.path != '/room/stage1' ||
          !WebSocketTransformer.isUpgradeRequest(req)) {
        req.response.statusCode = 400;
        await req.response.close();
        continue;
      }
      if (sockets.length >= 2) {
        req.response.statusCode = 409;
        await req.response.close();
        continue;
      }
      WebSocket s;
      try {
        s = await WebSocketTransformer.upgrade(req);
      } catch (_) {
        continue;
      }
      if (closed) {
        await s.close();
        continue;
      }
      final slot = sockets.containsKey(0) ? 1 : 0;
      final session = _token(), epoch = room.epoch;
      sockets[slot] = s;
      room.join(slot, session);
      s.pingInterval = const Duration(seconds: 5);
      s.add(
        jsonEncode({
          'v': 1,
          'type': 'welcome',
          'slot': slot,
          'epoch': epoch,
          'session': session,
        }),
      );
      s.listen(
        (dynamic raw) {
          if (room.epoch != epoch || sockets[slot] != s) return;
          counts[slot] = (counts[slot] ?? 0) + 1;
          if (counts[slot]! > 100 ||
              raw is! String ||
              utf8.encode(raw).length > 4096) {
            _teardown();
            return;
          }
          try {
            final result = room.input(slot, jsonDecode(raw));
            if (result == 'invalid' || result == 'gap') _teardown();
          } catch (_) {
            _teardown();
          }
        },
        onError: (Object _) {
          if (room.epoch == epoch) _teardown();
        },
        onDone: () {
          if (room.epoch == epoch) _teardown();
        },
      );
    }
  }

  void _teardown() {
    final old = List<WebSocket>.of(sockets.values);
    sockets.clear();
    counts.clear();
    _waitingSent.clear();
    room.close();
    room = Stage1Room(_token());
    for (final s in old) {
      unawaited(s.close(1001, 'room ended'));
    }
  }

  Future<void> close() async {
    if (closed) return;
    closed = true;
    _timer?.cancel();
    _limiter?.cancel();
    _teardown();
    room.close();
    await _http?.close(force: true);
  }
}
