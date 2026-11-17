import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import 'arm_transition.dart';

// Preserve authored negative-scale decomposition, rather than decomposing a
// matrix and moving its mirrored axis. Public API only.
void copyJointPose(fs.Node source, fs.Node destination) {
  final position = source.position;
  final rotation = source.rotation;
  final scale = source.scale;
  destination.position = position;
  destination.rotation = rotation;
  destination.scale = scale;
}

// Actual model must have no active Node-owned AnimationPlayer. Proxy players
// evaluate local TRS off-scene; caller merges BEFORE its sole Scene.update(0).
class LayeredPose {
  LayeredPose(this.model, this.joints, {this.transitions = false}) {
    if (joints.length != 65 || joints.map((n) => n.name).toSet().length != 65) {
      throw StateError('Expected 65 uniquely named joints');
    }
    for (final j in joints) {
      final b = fs.Node(name: j.name), a = fs.Node(name: j.name);
      copyJointPose(j, b);
      copyJointPose(j, a);
      bodyRoot.add(b);
      armRoot.add(a);
      bodyNodes[j.name] = b;
      armNodes[j.name] = a;
      submitted.add(fs.Node(name: j.name));
      frozen.add(fs.Node(name: j.name));
    }
    for (final name in bases) {
      final animation = model.findAnimationByName('Body_$name');
      if (animation == null) throw StateError('Missing Body_$name');
      _validate(animation, isArms: false);
      body[name] = bodyPlayer.createAnimationClip(animation, bodyRoot)
        ..weight = 0;
      body[name]!.pause();
    }
    for (final name in [...bases, shot]) {
      final animation = model.findAnimationByName('Arms_$name');
      if (animation == null) throw StateError('Missing Arms_$name');
      _validate(animation, isArms: true);
      arms[name] = armPlayer.createAnimationClip(animation, armRoot)
        ..weight = 0;
      arms[name]!.pause();
    }
  }
  static const bases = [
    'Idle_Loop',
    'Jog_Fwd_Loop',
    'Jump_Start',
    'Jump_Loop',
    'Jump_Land',
  ];
  static const shot = 'Authored_Basketball_v1';
  static const four = ['upperarm_l', 'upperarm_r', 'lowerarm_l', 'lowerarm_r'];
  final fs.Node model;
  final List<fs.Node> joints;
  final bool transitions;
  final bodyRoot = fs.Node(name: 'body_proxy'),
      armRoot = fs.Node(name: 'arm_proxy');
  final bodyNodes = <String, fs.Node>{}, armNodes = <String, fs.Node>{};
  final bodyPlayer = fs.AnimationPlayer(), armPlayer = fs.AnimationPlayer();
  final body = <String, fs.AnimationClip>{},
      arms = <String, fs.AnimationClip>{};
  final submitted = <fs.Node>[], frozen = <fs.Node>[];
  final transition = ArmTransition();
  Map<String, vm.Quaternion> submittedArms = {}, from = {};
  int? submittedFrame, evaluatedGeneration;
  bool frozenActive = false, frozenGrounded = true, evaluatedShooting = false;
  String? mode;
  String bodyName = 'Idle_Loop', armName = 'Idle_Loop';
  double bodyTime = 0, armTime = 0, alpha = 1;
  bool transitionStarted = false, transitionFinished = false;
  double bodyCopyError = 0, armStartError = 0;

  void _validate(fs.Animation animation, {required bool isArms}) {
    final keys = <String>{};
    for (final channel in animation.channels) {
      final key = channel.bindTarget;
      if (!bodyNodes.containsKey(key.nodeName) ||
          !keys.add('${key.nodeName}:${key.property.name}')) {
        throw StateError('Missing/duplicate masked binding');
      }
      final armRotation =
          four.contains(key.nodeName) && key.property.name == 'rotation';
      if (isArms != armRotation) throw StateError('Invalid masked property');
    }
    if (keys.length != (isArms ? 4 : 191))
      throw StateError('Incomplete masked channels');
  }

  void _sample(Map<String, fs.AnimationClip> clips, String name, double time) {
    if (!time.isFinite || time < 0 || !clips.containsKey(name)) {
      throw StateError('Invalid proxy sample');
    }
    for (final e in clips.entries) {
      e.value.pause();
      e.value.weight = e.key == name ? 1 : 0;
    }
    clips[name]!.seek(time);
  }

  void apply({
    required String base,
    required double baseTime,
    required bool shooting,
    required double shotTime,
    required int generation,
    required double accepted,
    required bool grounded,
    required bool ready,
    required bool reset,
  }) {
    if (!accepted.isFinite || accepted < 0) throw ArgumentError('accepted');
    transitionStarted = false;
    transitionFinished = false;
    if (reset || ready || (frozenActive && grounded != frozenGrounded)) {
      frozenActive = false;
    }
    if (frozenActive) {
      for (var i = 0; i < joints.length; i++)
        copyJointPose(frozen[i], joints[i]);
      evaluatedGeneration = null;
      evaluatedShooting = false;
      return;
    }
    if (reset) {
      mode = null;
      transition.reset();
    }
    final nextMode = shooting ? 'shot:$generation' : 'base';
    final changed = mode != nextMode;
    if (changed && !reset && submittedArms.isNotEmpty) {
      from = {for (final e in submittedArms.entries) e.key: e.value.clone()};
      transition.begin();
      transitionStarted = true;
    } else if (!changed) {
      final activeBefore = transition.active;
      transition.advance(accepted);
      transitionFinished = activeBefore && !transition.active;
    }
    mode = nextMode;
    if (reset) transition.reset();
    bodyName = base;
    bodyTime = baseTime;
    armName = shooting ? shot : base;
    armTime = shooting ? shotTime : baseTime;
    _sample(body, bodyName, bodyTime);
    bodyPlayer.update(0);
    _sample(arms, armName, armTime);
    armPlayer.update(0);
    alpha = transitions ? transition.alpha : 1;
    bodyCopyError = 0;
    armStartError = 0;
    for (final joint in joints) {
      copyJointPose(bodyNodes[joint.name]!, joint);
      if (four.contains(joint.name)) {
        final target = armNodes[joint.name]!.rotation;
        joint.rotation = alpha < 1 && from.containsKey(joint.name)
            ? fs.QuaternionSlerp(from[joint.name]!).slerp(target, alpha)
            : target.clone();
      }
      final b = bodyNodes[joint.name]!;
      final p = joint.position, bp = b.position, s = joint.scale, bs = b.scale;
      for (var i = 0; i < 3; i++) {
        final pe = (p.storage[i] - bp.storage[i]).abs(),
            se = (s.storage[i] - bs.storage[i]).abs();
        if (pe > bodyCopyError) bodyCopyError = pe;
        if (se > bodyCopyError) bodyCopyError = se;
      }
      if (!four.contains(joint.name)) {
        final error =
            (1 - fs.QuaternionSlerp(joint.rotation).dot(b.rotation).abs())
                .abs();
        if (error > bodyCopyError) bodyCopyError = error;
      } else if (alpha == 0 && from.containsKey(joint.name)) {
        final error =
            (1 -
                    fs.QuaternionSlerp(joint.rotation)
                        .dot(from[joint.name]!)
                        .abs())
                .abs();
        if (error > armStartError) armStartError = error;
      }
    }
    evaluatedShooting = shooting && alpha > 0;
    evaluatedGeneration = evaluatedShooting ? generation : null;
  }

  // Only after Scene.update(0) and accepted hand/ball latch.
  void recordSubmitted(int frame) {
    submittedFrame = frame;
    for (var i = 0; i < joints.length; i++)
      copyJointPose(joints[i], submitted[i]);
    submittedArms = {
      for (final j in joints)
        if (four.contains(j.name)) j.name: j.rotation.clone(),
    };
  }

  bool freezeSubmitted(int frame, bool grounded) {
    if (submittedFrame != frame) return false;
    for (var i = 0; i < joints.length; i++)
      copyJointPose(submitted[i], frozen[i]);
    frozenActive = true;
    frozenGrounded = grounded;
    evaluatedGeneration = null;
    evaluatedShooting = false;
    return true;
  }

  void beginCharge() => frozenActive = false;
  void clear() {
    frozenActive = false;
    submittedFrame = null;
    submittedArms = {};
    from = {};
    mode = null;
    transition.reset();
  }

  void dispose() {
    clear();
    bodyRoot.removeAll();
    armRoot.removeAll();
    body.clear();
    arms.clear();
    bodyNodes.clear();
    armNodes.clear();
    submitted.clear();
    frozen.clear();
  }
}
