import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'network_snapshot.dart';

class Stage2Client {
  Stage2Client({
    required this.onCommit,
    required this.onStatus,
    required this.onLog,
  });
  final void Function(SnapshotCommit) onCommit;
  final void Function(String) onStatus;
  final void Function(Map<String, Object?>) onLog;
  WebSocket? socket;
  StreamSubscription<dynamic>? subscription;
  Timer? keep;
  SnapshotConsumer? consumer;
  String? epoch, session;
  int seq = 0, slot = -1;
  double x = 0, z = 0;
  bool closed = false, started = false;
  Future<void> connect(String url) async {
    if (closed || started) throw StateError('Client unavailable');
    started = true;
    final pending = WebSocket.connect(url);
    unawaited(
      pending.then<void>((s) {
        if (closed) unawaited(s.close());
      }, onError: (Object _, StackTrace __) {}),
    );
    try {
      final s = await pending.timeout(const Duration(seconds: 5));
      if (closed) {
        await s.close();
        return;
      }
      socket = s;
      s.pingInterval = const Duration(seconds: 5);
      subscription = s.listen(
        _message,
        onDone: () => close('disconnected'),
        onError: (Object _) => close('connection error'),
      );
      keep = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => send(x == 0 && z == 0 ? 'keep' : 'move'),
      );
    } catch (_) {
      close('connection error');
    }
  }

  void _message(dynamic raw) {
    if (closed) return;
    try {
      if (raw is! String || utf8.encode(raw).length > 65536)
        throw const FormatException('message');
      final d = jsonDecode(raw);
      if (d is! Map) throw const FormatException('map');
      if (d['type'] == 'welcome') {
        if (session != null) throw const FormatException('repeat welcome');
        final w = decodeWelcome(d);
        slot = w.slot;
        epoch = w.epoch;
        session = w.session;
        consumer = SnapshotConsumer(w.epoch, w.session);
        onStatus('connected');
        onLog({'event': 'welcome', 'epoch': epoch, 'slot': slot});
        return;
      }
      if (d['type'] != 'snapshot' || consumer == null)
        throw const FormatException('type');
      final commit = consumer!.accept(d, sentSeq: seq);
      if (commit == null) return;
      onCommit(commit);
      onLog({
        'event': 'snapshot_core',
        ...commit.snapshot.core(),
        'effectIds': [for (final e in commit.effects) e.id],
        'effectGap': commit.gap,
        'ack': commit.snapshot.ack,
        'result': commit.snapshot.result,
      });
    } catch (_) {
      close('invalid snapshot');
    }
  }

  bool send(String op) {
    if (!{
      'move',
      'charge',
      'release',
      'cancel',
      'jump',
      'dash',
      'keep',
    }.contains(op))
      return false;
    final s = socket, e = epoch, token = session;
    if (closed || s == null || e == null || token == null) return false;
    try {
      s.add(
        jsonEncode({
          'v': 1,
          'epoch': e,
          'session': token,
          'seq': ++seq,
          'seen': consumer?.current?.tick ?? 0,
          'op': op,
          if (op == 'move') 'x': x,
          if (op == 'move') 'z': z,
        }),
      );
      return true;
    } catch (_) {
      close('connection error');
      return false;
    }
  }

  void move(double nx, double nz) {
    if (!nx.isFinite || !nz.isFinite || nx.abs() > 1 || nz.abs() > 1) return;
    x = nx;
    z = nz;
    send('move');
  }

  void close([String reason = 'closed']) {
    if (closed) return;
    closed = true;
    x = 0;
    z = 0;
    keep?.cancel();
    keep = null;
    final s = socket;
    socket = null;
    if (s != null) unawaited(s.close());
    final sub = subscription;
    subscription = null;
    if (sub != null) unawaited(sub.cancel());
    session = null;
    epoch = null;
    consumer = null;
    onStatus(reason);
  }
}
