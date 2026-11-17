import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrintSynchronously;
import 'package:flutter/semantics.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import 'package:offline_practice/src/simulation/config.dart';
import 'package:offline_practice/src/simulation/practice.dart';
import 'package:offline_practice/src/input/joystick.dart';
import 'package:offline_practice/src/input/jump_button.dart';
import 'package:offline_practice/src/input/dash_button.dart';

import 'practice_navigation.dart';
import 'practice_hud.dart';
import 'human_actor.dart';
import 'held_ball_latch.dart';
import 'charge_pose_gate.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with WidgetsBindingObserver {
  static const c = PracticeConfig();
  late final Practice game;
  late final SemanticsHandle semanticsHandle;
  late final Future<void> ready;
  fs.Scene? scene;
  late fs.Node ballNode, feetNode;
  HumanActor? human;
  final heldBall = HeldBallLatch();
  final chargePoseGate = ChargePoseGate();
  int poseFrame = 0;
  double frameAccepted = 0;
  String cameraAngle = 'court';
  bool inspectFrozen = false;
  int inspectionId = 0;
  int loggedFlightShot = 0;
  late fs.PerspectiveCamera camera;
  final hud = ValueNotifier<PracticeHudData>((
    score: 0,
    round: 1,
    points: 3,
    charge: 0.0,
    target: c.idealCharge,
    dash: 'ready',
  ));
  int joystickResetToken = 0;
  int? shotPointer;
  bool resumed = true;
  bool skipFrame = false;
  int seenRound = 1;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    semanticsHandle = WidgetsBinding.instance.ensureSemantics();
    game = Practice(
      config: c,
      onEvent: (event) {
        debugPrint('practice_event ' + jsonEncode(event));
      },
    );
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    resumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    game.setPaused(!resumed);
    WidgetsBinding.instance.addObserver(this);
    ready = prepare();
  }

  fs.UnlitMaterial material(double r, double g, double b) =>
      fs.UnlitMaterial()..baseColorFactor = vm.Vector4(r, g, b, 1);

  fs.Node box(vm.Vector3 size, vm.Vector3 position, fs.UnlitMaterial paint) {
    return fs.Node(mesh: fs.Mesh(fs.CuboidGeometry(size), paint))
      ..position = position;
  }

  Future<void> prepare() async {
    await fs.Scene.initializeStaticResources();
    if (!mounted || _leaving) return;
    final actor = await HumanActor.load(
      alive: () => mounted && !_leaving,
      log: (event) {
        if (mounted && !_leaving)
          debugPrint('practice_actor ' + jsonEncode(event));
      },
    );
    if (actor == null) return;
    if (!mounted || _leaving) {
      actor.dispose();
      return;
    }
    human = actor;
    // Keep the emulator diagnostic path simple; no temporal/MSAA history.
    final s = fs.Scene()..antiAliasingMode = fs.AntiAliasingMode.none;
    try {
      final root = fs.Node(name: 'practice_world');
      s.add(root);
      final court = material(0.12, 0.35, 0.25);
      final white = material(0.95, 0.95, 0.95);
      final orange = material(1, 0.35, 0.03);
      final blue = material(0.08, 0.35, 0.95);
      final dark = material(0.15, 0.15, 0.18);

      root.add(
        box(
          vm.Vector3(c.maxX - c.minX, 0.1, c.maxZ - c.minZ),
          vm.Vector3((c.minX + c.maxX) / 2, -0.05, (c.minZ + c.maxZ) / 2),
          court,
        ),
      );

      void line(double x1, double z1, double x2, double z2) {
        final dx = x2 - x1, dz = z2 - z1;
        final length = math.sqrt(dx * dx + dz * dz);
        if (length < 1e-6) return;
        root.add(
          box(
              vm.Vector3(length, 0.02, 0.035),
              vm.Vector3((x1 + x2) / 2, 0.015, (z1 + z2) / 2),
              white,
            )
            ..rotation = vm.Quaternion.axisAngle(
              vm.Vector3(0, 1, 0),
              -math.atan2(dz, dx),
            ),
        );
      }

      line(c.minX, c.minZ, c.maxX, c.minZ);
      line(c.maxX, c.minZ, c.maxX, c.maxZ);
      line(c.maxX, c.maxZ, c.minX, c.maxZ);
      line(c.minX, c.maxZ, c.minX, c.minZ);
      // Visible front semicircle of the experimental two-point line.
      for (var i = 0; i < 96; i++) {
        final a = math.pi * i / 96;
        final b = math.pi * (i + 1) / 96;
        final x1 = c.hoopX + c.arcRadius * math.cos(a);
        final z1 = c.hoopZ + c.arcRadius * math.sin(a);
        final x2 = c.hoopX + c.arcRadius * math.cos(b);
        final z2 = c.hoopZ + c.arcRadius * math.sin(b);
        if (x1 >= c.minX &&
            x1 <= c.maxX &&
            x2 >= c.minX &&
            x2 <= c.maxX &&
            z1 >= c.minZ &&
            z1 <= c.maxZ &&
            z2 >= c.minZ &&
            z2 <= c.maxZ) {
          line(x1, z1, x2, z2);
        }
      }

      root.add(
        box(
          vm.Vector3(0.12, 3.4, 0.12),
          vm.Vector3(c.hoopX, 1.7, c.hoopZ - 0.8),
          dark,
        ),
      );
      root.add(
        box(
          vm.Vector3(1.8, 1, 0.1),
          vm.Vector3(c.hoopX, c.rimY + 0.35, c.hoopZ - 0.6),
          white,
        ),
      );
      root.add(
        fs.Node(
          name: 'rim',
          mesh: fs.Mesh(
            fs.TorusGeometry(
              radius: c.rimInnerRadius + c.rimTubeRadius,
              tubeRadius: c.rimTubeRadius,
              radialSegments: 32,
              tubularSegments: 8,
            ),
            orange,
          ),
        )..position = vm.Vector3(c.hoopX, c.rimY, c.hoopZ),
      );

      // Ground projection stays on the court while the player jumps.
      feetNode = fs.Node(
        name: 'feet_projection',
        mesh: fs.Mesh(fs.DiscGeometry(radius: c.footRadius), blue),
      );
      root.add(feetNode);
      root.add(actor.node);
      root.add(
        fs.Node()
          ..position = vm.Vector3(-2, 6, 1)
          ..addComponent(
            fs.PointLightComponent(
              fs.PointLight(intensity: 40, range: 25, castsShadow: false),
            ),
          ),
      );
      ballNode = fs.Node(
        name: 'ball',
        mesh: fs.Mesh(
          fs.SphereGeometry(radius: c.ballRadius, segments: 20, rings: 10),
          orange,
        ),
      );
      root.add(ballNode);
      camera = fs.PerspectiveCamera(
        position: vm.Vector3(0, 10, 14),
        target: vm.Vector3(0, 1.2, 0),
        fovNear: 0.1,
        fovFar: 80,
      );
      scene = s;
      syncScene();
      s.update(0);
      finishPose();
      publish();
    } catch (_) {
      actor.dispose();
      human = null;
      scene = null;
      s.removeAll();
      s.dispose();
      rethrow;
    }
  }

  // The only runtime writer of player/ball Scene transforms.
  void syncScene({
    double accepted = 0,
    double dx = 0,
    double dz = 0,
    bool reset = false,
  }) {
    final p = game.player, f = game.facing;
    human?.setPose(
      x: p.x,
      y: p.y,
      z: p.z,
      facingX: f.x,
      facingZ: f.z,
      accepted: accepted,
      dx: dx,
      dz: dz,
      grounded: game.grounded,
      ready: game.phase == PracticePhase.ready,
      reset: reset,
      jumpVelocity: game.jumpVelocity,
      jumpSpeed: c.jumpSpeed,
      gravity: c.gravity,
      charge: game.charge,
      chargeGeneration: chargePoseGate.generation,
    );

    feetNode.position = vm.Vector3(p.x, 0.025, p.z);
  }

  void finishPose() {
    final actor = human;
    if (actor == null || !resumed || _leaving) return;
    if (game.phase == PracticePhase.ready ||
        game.phase == PracticePhase.charging) {
      final w = actor.handWorld(), held = V3(w.x, w.y, w.z);
      if (!game.acceptHeldWorld(held)) {
        heldBall.invalidate();
        chargePoseGate.cancel();
        actor.cancelAction();
        game.cancelCharge('invalid_hand_sample');
        shotPointer = null;
        return;
      }
    } else {
      heldBall.invalidate();
    }
    final b = game.ball;
    // practice_world has identity transform; ball remains its child throughout.
    ballNode.position = vm.Vector3(b.x, b.y, b.z);
    poseFrame++;
    if (game.phase == PracticePhase.ready ||
        game.phase == PracticePhase.charging) {
      final rendered = ballNode.globalTransform.clone().getTranslation();
      heldBall.record(
        world: b,
        renderWorld: V3(rendered.x, rendered.y, rendered.z),
        round: game.round,
        epoch: joystickResetToken,
        simTime: game.simulatedTime,
        frame: poseFrame,
        acceptedDelta: frameAccepted,
        camera: cameraAngle,
      );
      final latched = heldBall.current(
        round: game.round,
        epoch: joystickResetToken,
      )!;
      actor.recordSubmitted(poseFrame);
      chargePoseGate.record(
        evaluatedGeneration: actor.evaluatedChargeGeneration ?? -1,
        frame: latched.frame,
        latchGeneration: latched.generation,
        authored:
            game.phase == PracticePhase.charging &&
            actor.action.charging &&
            actor.layer.evaluatedShooting,
      );
    }
    if (game.shot != null && game.shot!.elapsed > 0 && loggedFlightShot != game.shot!.id) {
      loggedFlightShot = game.shot!.id;
      traceBoundary('first_flight', loggedFlightShot);
      debugPrint(
        'hand_event ' +
            jsonEncode({
              'event': 'first_flight',
              'flightTime': game.shot!.elapsed,
              'frame': poseFrame,
              'acceptedDelta': frameAccepted,
              'camera': cameraAngle,
              'simTime': game.simulatedTime,
              'shotId': loggedFlightShot,
              'ball': [b.x, b.y, b.z],
              'origin': [
                game.shot!.origin.x,
                game.shot!.origin.y,
                game.shot!.origin.z,
              ],
            }),
      );
    }
  }

  void publish() {
    if (!mounted) return;
    hud.value = (
      score: game.score,
      round: game.round,
      points: game.shot?.pointValue ?? game.pointsAt(game.player),
      charge: game.charge,
      target: c.idealCharge,
      dash: game.dashStatus,
    );
  }

  void traceBoundary(String stage, int shotId) {
    final a = human;
    if (a == null) return;
    for (final joint in a.boundaryJoints) {
      debugPrintSynchronously(
        'hand_event ' +
            jsonEncode({
              'event': 'joint_boundary',
              'stage': stage,
              'shotId': shotId,
              'joint': joint.name,
              'clip': a.layer.bodyName,
              'clipTime': a.layer.bodyTime,
              'armClip': a.layer.armName,
              'armTime': a.layer.armTime,
              'alpha': a.layer.alpha,
              'simTime': game.simulatedTime,
              'frame': poseFrame,
              'local': joint.localTransform.storage.toList(),
            }),
      );
    }
  }

  void tick(Duration elapsed, double dt) {
    final s = scene;
    frameAccepted = 0;
    if (!mounted || s == null) return;
    if (_leaving || !resumed) {
      human?.pauseAll();
      s.update(0);
      finishPose();
      return;
    }
    if (inspectFrozen) {
      s.update(0);
      finishPose();
      return; // Inspection only: no simulation or pose-clock advance.
    }
    if (skipFrame) {
      skipFrame = false;
      human?.pauseAll();
      s.update(0);
      finishPose();
      return;
    }
    final before = game.player, beforeTime = game.simulatedTime;
    game.advance(dt);
    final changedRound = seenRound != game.round;
    if (changedRound) {
      seenRound = game.round;
      cancelInputs('round_changed');
      setState(() {});
    }
    final accepted = game.simulatedTime - beforeTime;
    frameAccepted = accepted;
    if (accepted <= 0 && !changedRound) {
      s.update(0);
      finishPose();
      publish();
      return;
    }
    syncScene(
      accepted: accepted,
      dx: game.player.x - before.x,
      dz: game.player.z - before.z,
      reset: changedRound,
    );
    s.update(0);
    finishPose();
    publish();
  }

  void cancelInputs(String reason) {
    if (inspectFrozen) {
      inspectFrozen = false;
      skipFrame = true;
    }
    // Synchronous logic neutralization precedes the child's rebuild.
    joystickResetToken++;
    shotPointer = null;
    game.setMove(0, 0);
    game.cancelCharge(reason);
    game.cancelDash(reason);
    chargePoseGate.cancel();
    human?.cancelAction();
    heldBall.invalidate();
  }

  void _stopForMenu() {
    if (_leaving) return;
    _leaving = true;
    resumed = false;
    human?.pauseAll();
    cancelInputs('return_menu');
    game.setPaused(true);
    skipFrame = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || _leaving) return;
    resumed = state == AppLifecycleState.resumed;
    human?.pauseAll();
    if (!resumed) cancelInputs('background');
    game.setPaused(!resumed);
    skipFrame = true;
    setState(() {});
    publish();
  }

  Widget controls() {
    final inputEpoch = joystickResetToken;
    bool inputValid() =>
        mounted &&
        resumed &&
        inputEpoch == joystickResetToken &&
        seenRound == game.round;

    final joystick = PracticeJoystick(
      key: const ValueKey('practice_joystick'),
      enabled: resumed,
      resetToken: inputEpoch,
      deadZone: 0.15,
      hitSize: 152,
      radius: 64,
      thumbRadius: 20,
      visualThumbRadius: 27,
      backgroundColor: practiceNavy,
      thumbColor: Colors.white,
      onChanged: (axis) {
        if (!inputValid()) return;
        game.setMove(-axis.dx, axis.dy);
      },
    );
    final reset = Semantics(
      label: 'new_round',
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: practiceNavy,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          cancelInputs('manual_reset');
          game.newRound();
          seenRound = game.round;
          syncScene(reset: true);
          setState(() {});
          publish();
        },
        child: const Text('Lượt mới'),
      ),
    );
    final jump = PracticeJumpButton(
      size: practiceActionSize,
      label: 'NHẢY',
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
      key: const ValueKey('practice_jump'),
      enabled: resumed,
      backgroundColor: practiceNavy,
      pressedColor: const Color(0xff355777),
      borderRadius: BorderRadius.circular(12),
      resetToken: inputEpoch,
      onJump: () {
        if (!inputValid()) return;
        if (game.jump() && inspectFrozen) {
          setState(() => inspectFrozen = false);
          skipFrame = true;
        }
        publish();
      },
    );
    final dash = PracticeDashButton(
      size: practiceActionSize,
      label: 'DASH',
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
      key: const ValueKey('practice_dash'),
      enabled: resumed,
      backgroundColor: practiceNavy,
      pressedColor: const Color(0xff355777),
      borderRadius: BorderRadius.circular(12),
      resetToken: inputEpoch,
      onDash: () {
        if (!inputValid()) return;
        if (game.dash()) {
          if (inspectFrozen) {
            setState(() => inspectFrozen = false);
            skipFrame = true;
          }
          // The old charging finger cannot release after Dash.
          // Do not reset joystick/jump ownership here.
          shotPointer = null;
          chargePoseGate.cancel();
          human?.cancelAction();
          heldBall.invalidate();
        }
        publish();
      },
    );
    final shoot = Semantics(
      label: 'shoot_hold_release',
      button: true,
      excludeSemantics: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (!inputValid()) return;
          if (shotPointer == null && game.startCharge()) {
            shotPointer = event.pointer;
            chargePoseGate.begin();
            human?.beginCharge();
            publish();
          }
        },
        onPointerUp: (event) {
          if (!inputValid() || shotPointer != event.pointer) return;
          if (inspectFrozen) {
            setState(() => inspectFrozen = false);
            skipFrame = true; // Ignore wall time spent in diagnostic freeze.
          }
          shotPointer = null;
          final sample = heldBall.current(
            round: game.round,
            epoch: joystickResetToken,
          );
          final origin = sample?.world;
          if (origin != null &&
              human!.layer.submittedFrame == sample!.frame &&
              game.release(displayedOrigin: origin)) {
            final w = human!.handWorld();
            debugPrint(
              'hand_event ' +
                  jsonEncode({
                    'event': 'release_latched',
                    'sampleTime': sample.simTime,
                    'sampleRound': sample.round,
                    'sampleEpoch': sample.epoch,
                    'sampleGeneration': sample.generation,
                    'sampleFrame': sample.frame,
                    'sampleAcceptedDelta': sample.acceptedDelta,
                    'camera': sample.camera,
                    'lastRenderBall': [
                      sample.renderWorld.x,
                      sample.renderWorld.y,
                      sample.renderWorld.z,
                    ],
                    'simTime': game.simulatedTime,
                    'shotId': game.shot!.id,
                    'displayed': [origin.x, origin.y, origin.z],
                    'hand': [w.x, w.y, w.z],
                    'origin': [
                      game.shot!.origin.x,
                      game.shot!.origin.y,
                      game.shot!.origin.z,
                    ],
                  }),
            );
            final beforePose = human!.layer.armTime;
            traceBoundary('release', game.shot!.id);
            final chargeGeneration = chargePoseGate.generation;
            final prepared = chargePoseGate.consume(
              frame: sample.frame,
              latchGeneration: sample.generation,
            );
            human!.releaseAction(prepared: prepared, frame: sample.frame);
            debugPrint(
              'hand_event ' +
                  jsonEncode({
                    'event': 'release_visual_guard',
                    'shotId': game.shot!.id,
                    'chargeGeneration': chargeGeneration,
                    'evaluatedGeneration': human!.evaluatedChargeGeneration,
                    'sampleFrame': sample.frame,
                    'sampleGeneration': sample.generation,
                    'clipBefore': human!.selected,
                    'poseTimeBefore': beforePose,
                    'authoredRecovery': prepared,
                  }),
            );
            debugPrint(
              'hand_event ' +
                  jsonEncode({
                    'event': 'release_pose_clock',
                    'shotId': game.shot!.id,
                    'before': beforePose,
                    'after': prepared
                        ? human!.action.sample(game.charge)
                        : null,
                    'authoredRecovery': prepared,
                    'clip': human!.selected,
                    'armClip': human!.layer.armName,
                    'armAlpha': human!.layer.alpha,
                  }),
            );
            heldBall.invalidate();
          } else {
            game.cancelCharge('missing_or_invalid_displayed_origin');
            chargePoseGate.cancel();
            human?.cancelAction();
          }
          publish();
        },
        onPointerCancel: (event) {
          if (shotPointer != event.pointer) return;
          if (inspectFrozen) {
            setState(() => inspectFrozen = false);
            skipFrame = true;
          }
          shotPointer = null;
          game.cancelCharge('pointer_cancel');
          chargePoseGate.cancel();
          human?.cancelAction();
          heldBall.invalidate();
          publish();
        },
        child: Container(
          width: practiceShootSize.width,
          height: practiceShootSize.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: practiceOrange,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'NÉM',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
    return OfflinePracticeHud(
      data: hud,
      joystick: joystick,
      reset: reset,
      jump: jump,
      dash: dash,
      shoot: shoot,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cancelInputs('dispose');
    game.setPaused(true);
    human?.dispose();
    human = null;
    scene?.removeAll();
    scene?.dispose();
    hud.dispose();
    semanticsHandle.dispose();
    super.dispose();
  }

  void inspectionMarker(String reason) {
    final a = human;
    if (a == null) return;
    final w = a.handWorld(), b = game.ball;
    debugPrintSynchronously(
      'hand_event ' +
          jsonEncode({
            'event': 'held_contact_capture',
            'captureId': ++inspectionId,
            'reason': reason,
            'frozen': inspectFrozen,
            'phase': game.phase.name,
            'frame': poseFrame,
            'simTime': game.simulatedTime,
            'charge': game.charge,
            'camera': cameraAngle,
            'chargeGeneration': chargePoseGate.generation,
            'hand': [w.x, w.y, w.z],
            'ball': [b.x, b.y, b.z],
            'body': a.layer.bodyName,
            'bodyTime': a.layer.bodyTime,
            'arms': a.layer.armName,
            'armTime': a.layer.armTime,
            'alpha': a.layer.alpha,
            'bodyCopyError': a.layer.bodyCopyError,
          }),
    );
  }

  void toggleInspection() {
    if (!const bool.fromEnvironment('M2_INSPECT')) return;
    if (!inspectFrozen &&
        (game.phase != PracticePhase.charging || shotPointer == null))
      return;
    setState(() => inspectFrozen = !inspectFrozen);
    skipFrame = true;
    inspectionMarker(inspectFrozen ? 'freeze' : 'resume');
  }

  @override
  Widget build(BuildContext context) {
    return PracticeNavigation(
      onExit: _stopForMenu,
      child: Scaffold(
        body: FutureBuilder<void>(
          future: ready,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Scene error: ' + snapshot.error.toString()),
              );
            }
            final s = scene;
            if (snapshot.connectionState != ConnectionState.done || s == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                // Keep the view's SingleTickerProvider alive; pause our logic above.
                fs.SceneView(s, camera: camera, onTick: tick),
                controls(),
                if (const bool.fromEnvironment('M2_INSPECT'))
                  Positioned(
                    top: 100,
                    left: 8,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: toggleInspection,
                          child: Text(
                            inspectFrozen ? 'FROZEN inspection' : 'Giữ ảnh',
                          ),
                        ),
                        for (final view in ['Cận trước', 'Cận bên', 'Góc sân'])
                          TextButton(
                            onPressed: () {
                              final p = game.player;
                              setState(() {
                                cameraAngle = view;
                                camera = view == 'Góc sân'
                                    ? fs.PerspectiveCamera(
                                        position: vm.Vector3(0, 10, 14),
                                        target: vm.Vector3(0, 1.2, 0),
                                        fovNear: .1,
                                        fovFar: 80,
                                      )
                                    : fs.PerspectiveCamera(
                                        position: view == 'Cận trước'
                                            ? vm.Vector3(
                                                p.x,
                                                p.y + 1.8,
                                                p.z - 4,
                                              )
                                            : vm.Vector3(
                                                p.x + 4,
                                                p.y + 1.8,
                                                p.z + .3,
                                              ),
                                        target: vm.Vector3(p.x, p.y + 1.5, p.z),
                                        fovNear: .1,
                                        fovFar: 80,
                                      );
                              });
                              if (inspectFrozen) inspectionMarker('camera');
                            },
                            child: Text(view),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
