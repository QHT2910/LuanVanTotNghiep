import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

class SnapshotReplica {
  SnapshotReplica({
    required this.node,
    required this.session,
    this.entity = 'ball',
  }) {
    if (session.isEmpty) {
      throw ArgumentError.value(session, 'session');
    }
  }

  final fs.Node node;
  final String session;
  final String entity;
  int _lastTick = -1;
  bool _closed = false;

  int get lastTick => _lastTick;

  bool apply(Object? raw) {
    if (_closed || raw is! Map) return false;
    if (raw['schema'] != 1 ||
        raw['session'] != session ||
        raw['entity'] != entity) {
      return false;
    }

    final tick = raw['tick'];
    if (tick is! int || tick < 0 || tick <= _lastTick) {
      return false;
    }

    final x = raw['x'];
    final y = raw['y'];
    final z = raw['z'];
    if (x is! num || y is! num || z is! num) {
      return false;
    }

    final px = x.toDouble();
    final py = y.toDouble();
    final pz = z.toDouble();
    if (!px.isFinite || !py.isFinite || !pz.isFinite) {
      return false;
    }

    // Chỉ ghi sau khi toàn bộ envelope đã hợp lệ.
    node.position = vm.Vector3(px, py, pz);
    _lastTick = tick;
    return true;
  }

  void close() {
    _closed = true;
  }
}
