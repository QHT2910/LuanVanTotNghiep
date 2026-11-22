// Asset-specific feasibility sampler. No Flutter/Scene or server dependency.
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' as v;

const bases = [
  'Idle_Loop',
  'Jog_Fwd_Loop',
  'Jump_Start',
  'Jump_Loop',
  'Jump_Land',
];
const four = ['upperarm_l', 'upperarm_r', 'lowerarm_l', 'lowerarm_r'];
const shot = 'Authored_Basketball_v1';
v.Quaternion blend(v.Quaternion a, v.Quaternion b, double w) {
  var c = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
  if (c < 0) {
    b = b.scaled(-1);
    c = -c;
  }
  if (c < .999) {
    final s = math.sqrt(1 - c * c), t = math.atan2(s, c);
    return a.scaled(math.sin((1 - w) * t) / s) + b.scaled(math.sin(w * t) / s);
  }
  return (a.scaled(1 - w) + b.scaled(w)).normalized();
}

class Trs {
  Trs(this.t, this.q, this.s);
  v.Vector3 t, s;
  v.Quaternion q;
  Trs copy() => Trs(t.clone(), q.clone(), s.clone());
  List<List<double>> json() => [
    t.storage.toList(),
    q.storage.toList(),
    s.storage.toList(),
  ];
  v.Matrix4 matrix() => v.Matrix4.compose(t, q, s);
}

class HandCpu {
  HandCpu(Uint8List bytes) {
    final bd = ByteData.sublistView(bytes);
    if (bd.getUint32(0, Endian.little) != 0x46546c67 ||
        bd.getUint32(4, Endian.little) != 2)
      throw FormatException('GLB2 required');
    final len = bd.getUint32(12, Endian.little);
    j = jsonDecode(
      utf8.decode(bytes.sublist(20, 20 + len)),
    ) as Map<String, dynamic>;
    bin = ByteData.sublistView(bytes, 28 + len);
    nodes = (j['nodes'] as List<dynamic>).cast<Map<String, dynamic>>();
    parent = List.filled(nodes.length, -1);
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      if (n.containsKey('matrix')) throw FormatException('matrix unsupported');
      for (final c in (n['children'] as List<dynamic>? ?? []))
        parent[c as int] = i;
      bind.add(
        Trs(
          vec((n['translation'] ?? [0, 0, 0]) as List<dynamic>),
          quat((n['rotation'] ?? [0, 0, 0, 1]) as List<dynamic>),
          vec((n['scale'] ?? [1, 1, 1]) as List<dynamic>),
        ),
      );
      if (bind.last.s.storage.any((x) => x <= 0))
        throw FormatException('nonpositive authored scale unsupported');
    }
    hand = nodes.indexWhere((n) => n['name'] == 'hand_r');
    joints = (j['skins'][0]['joints'] as List<dynamic>).cast<int>();
    if (nodes.length != 67 || joints.length != 65 || hand < 0)
      throw FormatException('asset shape');
    animations = {
      for (final a in j['animations'] as List<dynamic>)
        a['name'] as String: a as Map<String, dynamic>,
    };
    for (final name in [
      ...bases.map((n) => 'Body_$n'),
      ...[...bases, shot].map((n) => 'Arms_$n'),
    ]) {
      final a = animations[name]!;
      if ((a['channels'] as List<dynamic>).length !=
          (name.startsWith('Body_') ? 191 : 4))
        throw FormatException('mask');
      for (final sam in a['samplers'] as List<dynamic>) {
        if ((sam['interpolation'] ?? 'LINEAR') != 'LINEAR')
          throw FormatException('LINEAR only');
        final ts = access(sam['input'] as int);
        for (var k = 1; k < ts.length; k++) {
          if (ts[k] <= ts[k - 1]) throw FormatException('timeline');
        }
        access(sam['output'] as int);
      }
    }
  }
  late final Map<String, dynamic> j;
  late final ByteData bin;
  late final List<Map<String, dynamic>> nodes;
  late final List<int> parent, joints;
  late final int hand;
  late final Map<String, Map<String, dynamic>> animations;
  final bind = <Trs>[];
  static v.Vector3 vec(List<dynamic> a) => v.Vector3(
    (a[0] as num).toDouble(),
    (a[1] as num).toDouble(),
    (a[2] as num).toDouble(),
  );
  static v.Quaternion quat(List<dynamic> a) => v.Quaternion(
    (a[0] as num).toDouble(),
    (a[1] as num).toDouble(),
    (a[2] as num).toDouble(),
    (a[3] as num).toDouble(),
  );
  List<double> access(int id) {
    final a = j['accessors'][id], bv = j['bufferViews'][a['bufferView']];
    if (a['componentType'] != 5126 || a['sparse'] != null || bv['buffer'] != 0)
      throw FormatException('accessor subset');
    final size = {'SCALAR': 1, 'VEC3': 3, 'VEC4': 4}[a['type']];
    if (size == null) throw FormatException('type');
    final offset =
            ((a['byteOffset'] ?? 0) as int) + ((bv['byteOffset'] ?? 0) as int),
        stride = (bv['byteStride'] ?? size * 4) as int;
    return [
      for (var k = 0; k < (a['count'] as int); k++)
        for (var c = 0; c < size; c++)
          bin.getFloat32(offset + k * stride + c * 4, Endian.little),
    ];
  }

  final times = <String, double>{};
  List<Trs> proxy(String prefix, String selected, double time) {
    times['$prefix$selected'] = time;
    final out = bind.map((b) => b.copy()).toList();
    for (final name in prefix == 'Body_' ? bases : [...bases, shot]) {
      final a = animations['$prefix$name']!, w = name == selected ? 1.0 : 0.0;
      final end = (a['samplers'] as List<dynamic>)
          .map((s) => access(s['input'] as int).last)
          .reduce(math.max);
      final t = (times['$prefix$name'] ?? 0).clamp(0.0, end);
      for (final ch in a['channels'] as List<dynamic>) {
        final sam = a['samplers'][ch['sampler']],
            ts = access(sam['input'] as int),
            vs = access(sam['output'] as int);
        final id = ch['target']['node'] as int, path = ch['target']['path'];
        final size = path == 'rotation' ? 4 : 3;
        var k = ts.indexWhere((x) => x >= t);
        if (k < 0) k = ts.length - 1;
        var u = 1.0;
        if (k > 0 && t < ts.last) u = (t - ts[k - 1]) / (ts[k] - ts[k - 1]);
        final cur = vs.sublist(k * size, (k + 1) * size);
        if (path == 'rotation') {
          var q = quat(cur);
          if (u < 1)
            q = blend(quat(vs.sublist((k - 1) * size, k * size)), q, u);
          out[id].q = blend(out[id].q, q, w);
        } else {
          var x = vec(cur);
          if (u < 1) {
            final p = vec(vs.sublist((k - 1) * size, k * size));
            x = v.Vector3(
              p.x + (x.x - p.x) * u,
              p.y + (x.y - p.y) * u,
              p.z + (x.z - p.z) * u,
            );
          }
          if (path == 'translation') {
            out[id].t += (x - bind[id].t) * w;
          } else if (path == 'scale') {
            final b = bind[id].s, s = out[id].s;
            out[id].s = v.Vector3(
              s.x * (1 + (x.x / b.x - 1) * w),
              s.y * (1 + (x.y / b.y - 1) * w),
              s.z * (1 + (x.z / b.z - 1) * w),
            );
          } else {
            throw FormatException('property');
          }
        }
      }
    }
    return out;
  }

  List<Trs>? submitted, frozen;
  bool frozenGround = true;
  String? mode;
  double age = .12, alpha = 1;
  Map<int, v.Quaternion> from = {};
  List<Trs> step(Map<String, dynamic> f) {
    if (f['begin'] == true) frozen = null;
    final reset = f['reset'] == true, ground = f['grounded'] == true;
    if (reset ||
        f['ready'] == true ||
        (frozen != null && ground != frozenGround))
      frozen = null;
    List<Trs> out;
    if (frozen != null) {
      out = frozen!.map((b) => b.copy()).toList();
    } else {
      if (reset) {
        mode = null;
        age = .12;
      }
      final next = f['shooting'] == true ? 'shot:${f['generation']}' : 'base';
      if (next != mode && !reset && submitted != null) {
        from = {
          for (final id in joints.where(
            (id) => four.contains(nodes[id]['name']),
          ))
            id: submitted![id].q.clone(),
        };
        age = 0;
      } else if (next == mode) {
        age = math.min(.12, age + (f['accepted'] as num).toDouble());
      }
      mode = next;
      if (reset) age = .12;
      alpha = (age / .12).clamp(0.0, 1.0);
      out = proxy(
        'Body_',
        f['base'] as String,
        (f['baseTime'] as num).toDouble(),
      );
      final arms = proxy(
        'Arms_',
        f['shooting'] == true ? shot : f['base'] as String,
        (f[f['shooting'] == true ? 'shotTime' : 'baseTime'] as num).toDouble(),
      );
      for (final id in joints.where((id) => four.contains(nodes[id]['name']))) {
        out[id].q = alpha < 1 && from.containsKey(id)
            ? blend(from[id]!, arms[id].q, alpha)
            : arms[id].q.clone();
      }
    }
    submitted = out.map((b) => b.copy()).toList();
    if (f['freeze'] == true) {
      frozen = out.map((b) => b.copy()).toList();
      frozenGround = ground;
    }
    return out;
  }

  v.Vector3 world(List<Trs> pose, Map<String, dynamic> f) {
    var m = v.Matrix4.compose(
      vec(f['feet'] as List<dynamic>),
      v.Quaternion.axisAngle(v.Vector3(0, 1, 0), (f['yaw'] as num).toDouble()),
      v.Vector3.all(1),
    );
    m.multiply(v.Matrix4.diagonal3Values(1, 1, -1));
    final chain = <int>[];
    for (var i = hand; i >= 0; i = parent[i]) {
      chain.insert(0, i);
    }
    for (final i in chain) {
      m.multiply(pose[i].matrix());
    }
    return m.transform3(v.Vector3(0, .07, 0));
  }
}

List<Map<String, dynamic>> fixtures() {
  final out = <Map<String, dynamic>>[];
  void add(
    String label, {
    String base = 'Idle_Loop',
    double bt = 0,
    bool shooting = false,
    int gen = 1,
    double st = 1,
    double dt = .06,
    bool ground = true,
    bool reset = false,
    bool freeze = false,
    bool begin = false,
    double y = 0,
    double yaw = math.pi,
  }) {
    out.add({
      'id': label,
      'tick': out.length,
      'base': base,
      'baseTime': bt,
      'shooting': shooting,
      'generation': gen,
      'shotTime': st,
      'accepted': dt,
      'grounded': ground,
      'reset': reset,
      'freeze': freeze,
      'begin': begin,
      'ready': false,
      'feet': [.4, y, -.7],
      'yaw': yaw,
    });
  }

  for (final yaw in [0.0, math.pi]) {
    add('idle-$yaw', reset: true, yaw: yaw);
    add('idle-mid-$yaw', bt: .37, yaw: yaw);
    add('charge-alpha0-$yaw', shooting: true, yaw: yaw);
    add('charge-alphaMid-$yaw', shooting: true, yaw: yaw);
    add('fullcharge-releaseT-$yaw', shooting: true, yaw: yaw);
    add(
      'air-start-$yaw',
      base: 'Jump_Start',
      bt: .08,
      shooting: true,
      ground: false,
      y: .65,
      yaw: yaw,
    );
    add(
      'air-loop-releaseT-$yaw',
      base: 'Jump_Loop',
      bt: .19,
      shooting: true,
      ground: false,
      y: .9,
      yaw: yaw,
    );
    add(
      'cancel-alpha0-$yaw',
      base: 'Jump_Loop',
      bt: .21,
      ground: false,
      y: .85,
      yaw: yaw,
    );
    add(
      'cancel-mid-$yaw',
      base: 'Jump_Loop',
      bt: .23,
      ground: false,
      y: .8,
      yaw: yaw,
    );
    add(
      'recharge-generation2-alpha0-$yaw',
      shooting: true,
      gen: 2,
      st: .3,
      ground: false,
      y: .7,
      begin: true,
      yaw: yaw,
    );
    add(
      'recharge-generation2-mid-$yaw',
      shooting: true,
      gen: 2,
      st: .6,
      ground: false,
      y: .6,
      yaw: yaw,
    );
    add(
      'recharge-generation2-end-$yaw',
      shooting: true,
      gen: 2,
      ground: false,
      y: .5,
      yaw: yaw,
    );
    add('cancel-freeze-$yaw', ground: false, y: .4, freeze: true, yaw: yaw);
    add('frozen-moving-parent-$yaw', bt: .9, ground: false, y: .2, yaw: yaw);
    add('ground-change-clear-$yaw', base: 'Jump_Land', bt: .1, yaw: yaw);
    add('reset-$yaw', reset: true, yaw: yaw);
  }
  return out;
}
