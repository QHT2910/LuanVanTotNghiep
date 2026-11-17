import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' as vm;

// Derivative CC0 animation, authored locally. Does not modify the source GLB.
void main(List<String> args) {
  final original = File('assets/human-ual-standard/HumanDiagnostic.glb')
      .readAsBytesSync();
  final header = ByteData.sublistView(original),
      jsonLength = header.getUint32(12, Endian.little);
  final j = jsonDecode(
    utf8.decode(original.sublist(20, 20 + jsonLength)),
  ) as Map<String, dynamic>;
  final nodes = (j['nodes'] as List).cast<Map<String, dynamic>>();
  final poseNodes = (jsonDecode(jsonEncode(nodes)) as List)
      .cast<Map<String, dynamic>>();
  final sourceBinStart = 20 + jsonLength + 8;
  final idleSource = (j['animations'] as List).singleWhere(
    (a) => a['name'] == 'Idle_Loop',
  ) as Map;
  // Solve against the same Idle body basis used by the authored animation.
  // Original j.nodes remains untouched: this is not a bind-pose/rig edit.
  for (final channel in idleSource['channels'] as List) {
    final sampler = idleSource['samplers'][channel['sampler']];
    final ac = j['accessors'][sampler['output']],
        view = j['bufferViews'][ac['bufferView']];
    if (ac['componentType'] != 5126 ||
        view['buffer'] != 0 ||
        ac['sparse'] != null) {
      throw StateError('Unsupported Idle pose accessor');
    }
    final components = ac['type'] == 'VEC4' ? 4 : 3;
    final offset =
        sourceBinStart +
        ((view['byteOffset'] as int?) ?? 0) +
        ((ac['byteOffset'] as int?) ?? 0);
    poseNodes[channel['target']['node'] as int][channel['target']['path']
        as String] = [
      for (var k = 0; k < components; k++)
        header.getFloat32(offset + k * 4, Endian.little),
    ];
  }
  final parent = <int, int>{};
  for (var i = 0; i < nodes.length; i++) {
    for (final c in (nodes[i]['children'] as List? ?? [])) {
      parent[c as int] = i;
    }
  }
  vm.Quaternion rotation(Map<String, dynamic> n) {
    final a = ((n['rotation'] as List?) ?? [0, 0, 0, 1])
        .map((x) => (x as num).toDouble())
        .toList();
    return vm.Quaternion(a[0], a[1], a[2], a[3]);
  }

  final rotations = [for (final n in poseNodes) rotation(n)];
  final initial = rotations.map((q) => q.clone()).toList();
  vm.Vector3 vector(
    Map<String, dynamic> n,
    String name,
    List<double> fallback,
  ) => vm.Vector3.array(
    ((n[name] as List?) ?? fallback).map((x) => (x as num).toDouble()).toList(),
  );
  vm.Matrix4 world(int i) {
    final n = poseNodes[i];
    final local = vm.Matrix4.compose(
      vector(n, 'translation', [0, 0, 0]),
      rotations[i],
      vector(n, 'scale', [1, 1, 1]),
    );
    return parent.containsKey(i) ? (world(parent[i]!)..multiply(local)) : local;
  }

  int index(String name) => nodes.indexWhere((n) => n['name'] == name);
  if (args.contains('--inspect-forward')) {
    stdout.writeln(jsonEncode({for (var i=0;i<nodes.length;i++)
      if (RegExp('foot|ball_|toe',caseSensitive:false).hasMatch(nodes[i]['name'] as String))
        nodes[i]['name'] as String: world(i).getTranslation().storage.toList()}));
    return;
  }
  final names = ['upperarm_l', 'upperarm_r', 'lowerarm_l', 'lowerarm_r'];
  final keys = {for (final name in names) name: <vm.Quaternion>[]};
  void solve(String side, vm.Vector3 target) {
    final hand = index('hand_$side');
    for (var iteration = 0; iteration < 20; iteration++) {
      for (final name in ['lowerarm_$side', 'upperarm_$side']) {
        final i = index(name), inverse = vm.Matrix4.inverted(world(parent[i]!));
        final from =
            inverse.transform3(world(hand).getTranslation()) -
            vector(poseNodes[i], 'translation', [0, 0, 0]);
        final to =
            inverse.transform3(target.clone()) -
            vector(poseNodes[i], 'translation', [0, 0, 0]);
        if (from.length2 > 1e-12 && to.length2 > 1e-12)
          rotations[i] = vm.Quaternion.fromTwoVectors(from, to) * rotations[i];
      }
    }
  }

  final authored = <Map<String, Object?>>[];
  for (final pose in [
    (y: 1.15, z: .35),
    (y: 1.72, z: .30),
    (y: 1.98, z: .42),
    (y: 1.15, z: .35),
  ]) {
    for (var i = 0; i < rotations.length; i++) {
      rotations[i] = initial[i].clone();
    }
    solve('r', vm.Vector3(-.13, pose.y, pose.z));
    solve('l', vm.Vector3(.13, pose.y, pose.z));
    for (final name in names) {
      keys[name]!.add(rotations[index(name)].clone());
    }
    authored.add({
      'right': world(index('hand_r')).getTranslation().storage.toList(),
      'left': world(index('hand_l')).getTranslation().storage.toList(),
    });
  }
  final binOffset = 20 + jsonLength + 8,
      binLength = header.getUint32(20 + jsonLength, Endian.little);
  final bin = <int>[...original.sublist(binOffset, binOffset + binLength)];
  final views = j['bufferViews'] as List, accessors = j['accessors'] as List;
  int append(List<double> values, String type, int components) {
    while (bin.length % 4 != 0) {
      bin.add(0);
    }
    final data = ByteData(values.length * 4);
    for (var i = 0; i < values.length; i++) {
      data.setFloat32(i * 4, values[i], Endian.little);
    }
    final view = views.length;
    views.add({
      'buffer': 0,
      'byteOffset': bin.length,
      'byteLength': data.lengthInBytes,
    });
    bin.addAll(data.buffer.asUint8List());
    final result = accessors.length;
    accessors.add({
      'bufferView': view,
      'componentType': 5126,
      'count': values.length ~/ components,
      'type': type,
      if (type == 'SCALAR') 'min': [values.first],
      if (type == 'SCALAR') 'max': [values.last],
    });
    return result;
  }

  final animations = j['animations'] as List;
  final idle = animations.singleWhere((a) => a['name'] == 'Idle_Loop') as Map;
  final channels = [
    for (final c in idle['channels'] as List)
      if (!(names.contains(nodes[c['target']['node'] as int]['name']) &&
          c['target']['path'] == 'rotation'))
        c,
  ];
  final samplers = [...idle['samplers'] as List];
  final times = append([0, 1, 1.15, 2], 'SCALAR', 1);
  for (final name in names) {
    final output = append(
      [for (final q in keys[name]!) ...q.storage],
      'VEC4',
      4,
    );
    channels.add({
      'sampler': samplers.length,
      'target': {'node': index(name), 'path': 'rotation'},
    });
    samplers.add({'input': times, 'output': output, 'interpolation': 'LINEAR'});
  }
  animations.add({
    'name': 'Authored_Basketball_v1',
    'channels': channels,
    'samplers': samplers,
  });
  (j['buffers'] as List)[0]['byteLength'] = bin.length;
  final jsonBytes = utf8.encode(jsonEncode(j)).toList(growable: true);
  while (jsonBytes.length % 4 != 0) {
    jsonBytes.add(32);
  }
  while (bin.length % 4 != 0) {
    bin.add(0);
  }
  final result = ByteData(12 + 8 + jsonBytes.length + 8 + bin.length);
  result.setUint32(0, 0x46546c67, Endian.little);
  result.setUint32(4, 2, Endian.little);
  result.setUint32(8, result.lengthInBytes, Endian.little);
  result.setUint32(12, jsonBytes.length, Endian.little);
  result.setUint32(16, 0x4e4f534a, Endian.little);
  result.buffer.asUint8List().setRange(20, 20 + jsonBytes.length, jsonBytes);
  final off = 20 + jsonBytes.length;
  result.setUint32(off, bin.length, Endian.little);
  result.setUint32(off + 4, 0x004e4942, Endian.little);
  result.buffer.asUint8List().setRange(off + 8, result.lengthInBytes, bin);
  File('assets/human-ual-standard/HumanBasketball.glb')
      .writeAsBytesSync(result.buffer.asUint8List());
  File('../evidence-m2-hand-action/authored-pose-data.json').writeAsStringSync(
    jsonEncode({
      'method': 'Offline CCD authored local rotations on original CC0 rig',
      'times': [0, 1, 1.15, 2],
      'handTargetsResult': authored,
    }),
  );
  stdout.writeln(
    'PASS authored GLB generated, original unchanged; visual acceptance pending',
  );
}
