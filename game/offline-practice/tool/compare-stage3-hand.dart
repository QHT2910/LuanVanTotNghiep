// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import '../lib/diagnostics/hand_cpu.dart';

void main(List<String> args) {
  final cpu = HandCpu(
    File('assets/human-ual-standard/HumanBasketballLayered.glb')
        .readAsBytesSync(),
  );
  final golden =
      jsonDecode(File(args[0]).readAsStringSync()) as Map<String, dynamic>;
  final results = <Map<String, dynamic>>[];
  double maxError = 0;
  double maxLocalError = 0, maxBindError = 0;
  for (var id = 0; id < cpu.nodes.length; id++) {
    final expected = golden['bind'][cpu.nodes[id]['name']] as List<dynamic>;
    final actual = cpu.bind[id].json();
    for (var k = 0; k < 3; k++)
      for (var c = 0; c < actual[k].length; c++) {
        final e = (actual[k][c] - (expected[k][c] as num)).abs();
        if (e > maxBindError) maxBindError = e;
      }
  }
  for (final row in golden['rows'] as List<dynamic>) {
    final f = Map<String, dynamic>.from(row['input'] as Map<String, dynamic>),
        pose = cpu.step(f),
        p = cpu.world(pose, f),
        s = HandCpu.vec(row['hand'] as List<dynamic>),
        delta = p - s,
        error = delta.length;
    if (error > maxError) maxError = error;
    double localError = 0;
    for (final id in cpu.joints) {
      final expected = row['publicTRS'][cpu.nodes[id]['name']] as List<dynamic>;
      final actual = pose[id].json();
      for (var k = 0; k < 3; k++)
        for (var c = 0; c < actual[k].length; c++) {
          final e = (actual[k][c] - (expected[k][c] as num)).abs();
          if (e > localError) localError = e;
        }
    }
    if (localError > maxLocalError) maxLocalError = localError;
    results.add({
      'id': f['id'],
      'tick': f['tick'],
      'alphaScene': row['alpha'],
      'alphaCPU': cpu.alpha,
      'feet': f['feet'],
      'scene': s.storage.toList(),
      'cpu': p.storage.toList(),
      'deltaMetres': delta.storage.toList(),
      'distanceMetres': error,
      'maxLocalTRSComponentDelta': localError,
      'pass': error.isFinite && error <= 1e-4 && localError < 1e-5,
    });
  }
  final report = {
    'thresholdMetres': 1e-4,
    'maxErrorMetres': maxError,
    'maxLocalTRSComponentDelta': maxLocalError,
    'maxBindTRSComponentDelta': maxBindError,
    'cases': results,
    'pass': results.length == 32 && results.every((r) => r['pass'] == true),
  };
  File(args[1])
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  print('cases=${results.length} max=$maxError pass=${report['pass']}');
  if (report['pass'] != true) exitCode = 1;
}
