import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import 'actor_motion.dart';

class HumanActor {
  HumanActor._(this.model, this.log);
  static const asset = 'assets/human-ual-standard/HumanDiagnostic.glb';
  static const idle = 'Idle_Loop', jog = 'Jog_Fwd_Loop';
  // Mannequin forward is -Z; AVD initial +Z assumption faced away from rim.
  static const yawOffset = math.pi;
  final fs.Node model;
  final void Function(Map<String, Object?>) log;
  final node = fs.Node(name: 'simulation_owned_human');
  final clips = <String, fs.AnimationClip>{};
  final durations = <String, double>{};
  String selected = idle;
  ActorPose? previousPose;
  double time = 0;
  bool closed = false;

  static Iterable<fs.Node> walk(fs.Node n) sync* {
    yield n;
    for (final child in n.children) {
      yield* walk(child);
    }
  }

  static Future<HumanActor?> load({
    required bool Function() alive,
    required void Function(Map<String, Object?>) log,
  }) async {
    if (!alive()) return null;
    final data = await rootBundle.load(asset);
    if (!alive()) return null;
    final warnings = <String>[];
    final model = await fs.Node.fromGlbBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      maxTextureSize: 1024,
      onWarning: (w) => warnings.add(w.toString()),
    );
    if (!alive()) return null;
    final nodes = walk(model).toList(), audit = <Map<String, Object?>>[];
    for (final name in [idle, jog]) {
      final found = model.parsedAnimations
          .where((a) => a.name == name)
          .toList();
      if (found.length != 1 ||
          !found.single.endTime.isFinite ||
          found.single.endTime <= 0) {
        throw StateError('Human clip missing/duplicate/invalid: $name');
      }
      final targets = found.single.channels
          .map((c) => c.bindTarget.nodeName)
          .toSet();
      final matches = {
        for (final t in targets)
          t: nodes.where((n) => !identical(n, model) && n.name == t).length,
      };
      if (matches.length != 65 || matches.values.any((n) => n != 1)) {
        throw StateError('Human binding differs from baseline');
      }
      audit.add({
        'clip': name,
        'targets': matches.length,
        'uniqueMatches': true,
      });
    }
    final skins = [
      for (final n in nodes)
        if (n.skin != null)
          {
            'node': n.name,
            'joints': n.skin!.joints.length,
            'nullJoints': n.skin!.joints.where((j) => j == null).length,
          },
    ];
    if (skins.length != 1 ||
        skins.single['joints'] != 65 ||
        skins.single['nullJoints'] != 0) {
      throw StateError('Human skin differs from baseline');
    }
    final a = HumanActor._(model, log);
    a.node.add(model);
    for (final name in [idle, jog]) {
      final animation = model.findAnimationByName(name)!;
      final clip = model.createAnimationClip(animation)
        ..loop = true
        ..weight = 0;
      clip.pause();
      clip.seek(0);
      a.clips[name] = clip;
      a.durations[name] = animation.endTime;
    }
    a.clips[idle]!.weight = 1;
    log({
      'event': 'actor_asset',
      'asset': asset,
      'bytes': data.lengthInBytes,
      'binding': audit,
      'skins': skins,
      'warnings': warnings,
      'playback': 'manual_seek_accepted_simulation_delta',
      'yawOffset': yawOffset,
      'yawCalibration': 'minus_Z_visual_offset_pi; verify directional captures',
    });
    return a;
  }

  void setPose({
    required double x,
    required double y,
    required double z,
    required double facingX,
    required double facingZ,
    required double accepted,
    required double dx,
    required double dz,
    required bool grounded,
    required bool ready,
    required bool reset,
  }) {
    if (closed) return;
    node.position = vm.Vector3(x, y, z);
    node.rotation = vm.Quaternion.axisAngle(
      vm.Vector3(0, 1, 0),
      math.atan2(facingX, facingZ) + yawOffset,
    );
    final pose = actorPose(
      accepted: accepted,
      dx: dx,
      dz: dz,
      grounded: grounded,
      ready: ready,
      reset: reset,
    );
    final next = pose == ActorPose.jog ? jog : idle;
    final changed = next != selected || pose != previousPose;
    if (changed) time = 0;
    selected = next;
    for (final e in clips.entries) {
      e.value.pause();
      e.value.weight = e.key == selected ? 1 : 0;
    }
    time = pose == ActorPose.held
        ? 0
        : actorClipTime(time, accepted, durations[selected]!);
    clips[selected]!.seek(time);
    if (changed)
      log({
        'event': 'actor_state',
        'pose': pose.name,
        'clip': selected,
        'clipTime': time,
        'acceptedDelta': accepted,
        'x': x,
        'y': y,
        'z': z,
        'facingX': facingX,
        'facingZ': facingZ,
        'dashPolicy': 'reuse_jog_on_actual_displacement',
      });
    previousPose = pose;
  }

  void pauseAll() {
    for (final c in clips.values) {
      c.pause();
    }
  }

  void dispose() {
    if (closed) return;
    pauseAll();
    closed = true;
    node.removeAll();
    clips.clear();
    durations.clear();
  }
}
