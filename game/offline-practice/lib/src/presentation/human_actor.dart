import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import 'actor_motion.dart';
import 'shot_pose_clock.dart';
import 'charge_pose_gate.dart';

class HumanActor {
  HumanActor._(this.model, this.log);
  static const asset = 'assets/human-ual-standard/HumanBasketball.glb';
  static const idle = 'Idle_Loop', jog = 'Jog_Fwd_Loop';
  // Visual yaw offset calibrated to pi using AVD toward/away-rim captures;
  // raw GLB joint axes alone do not establish Scene-facing direction.
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
  final action = ShotPoseClock();
  final unpreparedPose = UnpreparedPoseHold();
  final boundaryJoints = <fs.Node>[];
  int? evaluatedChargeGeneration;
  double landLeft = 0;
  bool wasGrounded = true;
  late fs.Node hand;
  static const jumpClips = ['Jump_Start', 'Jump_Loop', 'Jump_Land'];
  vm.Vector3 handWorld() =>
      hand.globalTransform.clone().transform3(vm.Vector3(0, .07, 0));

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
    for (final name in [idle, jog, ...jumpClips]) {
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
    a.hand = nodes.singleWhere((n) => n.name == 'hand_r');
    a.boundaryJoints.addAll(
      nodes
          .singleWhere((n) => n.skin != null)
          .skin!
          .joints
          .whereType<fs.Node>(),
    );
    final authored = model.findAnimationByName('Authored_Basketball_v1')!;
    for (final name in [idle, jog, ...jumpClips]) {
      final animation = model.findAnimationByName(name)!;
      final clip = model.createAnimationClip(animation)
        ..loop = true
        ..weight = 0;
      clip.pause();
      clip.seek(0);
      a.clips[name] = clip;
      a.durations[name] = animation.endTime;
    }
    final shooting = model.createAnimationClip(authored)..weight = 0;
    shooting.pause();
    shooting.seek(0);
    a.clips[authored.name] = shooting;
    a.durations[authored.name] = authored.endTime;
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
      'yawCalibration': 'Scene imported forward calibrated by AVD court directions; raw GLB axes alone are insufficient',
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
    required double jumpVelocity,
    required double jumpSpeed,
    required double gravity,
    required double charge,
    required int chargeGeneration,
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
    action.advance(accepted);
    String? override;
    double overrideTime = 0;
    if (!grounded) {
      landLeft = 0;
      final j = jumpPose(
        velocity: jumpVelocity,
        speed: jumpSpeed,
        gravity: gravity,
        startDuration: durations['Jump_Start']!,
        loopDuration: durations['Jump_Loop']!,
      );
      override = j.name;
      overrideTime = j.time;
    } else {
      if (!wasGrounded) landLeft = .18;
      if (landLeft > 0) {
        override = 'Jump_Land';
        overrideTime = (1 - landLeft / .18) * durations['Jump_Land']!;
        landLeft = math.max(0, landLeft - accepted);
      }
    }
    wasGrounded = grounded;
    if (action.active) {
      override = 'Authored_Basketball_v1';
      overrideTime = action.sample(charge);
    }
    if (reset) {
      action.cancel();
      landLeft = 0;
      wasGrounded = true;
      override = idle;
      overrideTime = 0;
    }
    final held = unpreparedPose.sample(
      ready: ready,
      reset: reset,
      grounded: grounded,
    );
    if (held != null) {
      override = held.clip;
      overrideTime = held.time;
    }
    final next = override ?? (pose == ActorPose.jog ? jog : idle);
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
    if (override != null) time = overrideTime;
    clips[selected]!.seek(time);
    evaluatedChargeGeneration =
        action.charging && selected == 'Authored_Basketball_v1'
        ? chargeGeneration
        : null;
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

  void beginCharge() {
    unpreparedPose.clear();
    action.charge();
  }

  void cancelAction() {
    action.cancel();
  }

  void recordSubmitted(int frame) => unpreparedPose.record(
    clip: selected,
    time: time,
    grounded: wasGrounded,
    frame: frame,
  );

  void releaseAction({required bool prepared, required int frame}) {
    if (prepared) {
      unpreparedPose.clear();
      action.release();
    } else {
      if (!unpreparedPose.freeze(frame)) {
        throw StateError('Missing matching submitted pose');
      }
      action.cancel();
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
