import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import 'actor_motion.dart';
import 'shot_pose_clock.dart';
import 'layered_pose.dart';

class HumanActor {
  HumanActor._(this.model, this.log);
  static const asset = 'assets/human-ual-standard/HumanBasketballLayered.glb';
  static const idle = 'Idle_Loop', jog = 'Jog_Fwd_Loop';
  // Visual yaw offset calibrated to pi using AVD toward/away-rim captures;
  // raw GLB joint axes alone do not establish Scene-facing direction.
  static const yawOffset = math.pi;
  final fs.Node model;
  final void Function(Map<String, Object?>) log;
  final node = fs.Node(name: 'simulation_owned_human');
  late final LayeredPose layer;
  final durations = <String, double>{};
  String selected = idle;
  ActorPose? previousPose;
  double time = 0;
  bool closed = false;
  final action = ShotPoseClock();
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
    for (final name in [idle, jog, ...jumpClips, LayeredPose.shot]) {
      final animation = model.findAnimationByName(name)!;
      a.durations[name] = animation.endTime;
    }
    // Never register clips on the actual imported skeleton: its prepass must
    // not overwrite the pose merged from the two independent proxy players.
    a.layer = LayeredPose(model, List.of(a.boundaryJoints), transitions: true);
    log({
      'event': 'actor_asset',
      'asset': asset,
      'bytes': data.lengthInBytes,
      'binding': audit,
      'skins': skins,
      'warnings': warnings,
      'playback': 'manual_seek_accepted_simulation_delta',
      'posePolicy': 'off_scene_body_and_arm_players_prepass_merge',
      'armTransitionSeconds': .12,
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
      ready:
          true, // Actual displacement drives locomotion during charge/flight.
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
    if (reset) {
      action.cancel();
      landLeft = 0;
      wasGrounded = true;
      override = idle;
      overrideTime = 0;
      layer.clear();
    }
    final next = override ?? (pose == ActorPose.jog ? jog : idle);
    final changed = next != selected || pose != previousPose;
    if (changed) time = 0;
    selected = next;
    time = pose == ActorPose.held
        ? 0
        : actorClipTime(time, accepted, durations[selected]!);
    if (override != null) time = overrideTime;
    layer.apply(
      base: selected,
      baseTime: time,
      shooting: action.active,
      shotTime: action.active ? action.sample(charge) : 0,
      generation: chargeGeneration,
      accepted: accepted,
      grounded: grounded,
      ready: ready,
      reset: reset,
    );
    evaluatedChargeGeneration = action.charging
        ? layer.evaluatedGeneration
        : null;
    if (changed || layer.transitionStarted || layer.transitionFinished)
      log({
        'event': 'actor_state',
        'pose': pose.name,
        'clip': selected,
        'clipTime': time,
        'armClip': layer.armName,
        'armTime': layer.armTime,
        'armAlpha': layer.alpha,
        'bodyCopyError': layer.bodyCopyError,
        'armStartError': layer.armStartError,
        'transitionStart': layer.transitionStarted,
        'transitionEnd': layer.transitionFinished,
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

  void
  pauseAll() {} // Both off-scene players always use paused clips/update(0).

  void beginCharge() {
    layer.beginCharge();
    action.charge();
  }

  void cancelAction() {
    action.cancel();
  }

  void recordSubmitted(int frame) => layer.recordSubmitted(frame);

  void releaseAction({required bool prepared, required int frame}) {
    if (prepared) {
      action.release();
    } else {
      if (!layer.freezeSubmitted(frame, wasGrounded)) {
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
    layer.dispose();
    durations.clear();
  }
}
