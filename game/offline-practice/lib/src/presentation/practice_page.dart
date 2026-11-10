import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import 'package:offline_practice/src/simulation/config.dart';
import 'package:offline_practice/src/simulation/practice.dart';
import 'package:offline_practice/src/input/joystick.dart';
import 'package:offline_practice/src/input/jump_button.dart';
import 'package:offline_practice/src/input/dash_button.dart';

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
  late fs.Node playerNode, ballNode, feetNode;
  late fs.PerspectiveCamera camera;
  final hud = ValueNotifier<(String, double)>(('', 0.0));
  int joystickResetToken = 0;
  int? shotPointer;
  bool resumed = true;
  bool skipFrame = false;
  int seenRound = 1;

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
    if (!mounted) return;
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

      playerNode = fs.Node(name: 'player');
      playerNode.add(
        box(vm.Vector3(0.44, 0.8, 0.3), vm.Vector3(0, 0.85, 0), blue),
      );
      playerNode.add(
        fs.Node(
          mesh: fs.Mesh(
            fs.SphereGeometry(radius: 0.2, segments: 16, rings: 8),
            white,
          ),
        )..position = vm.Vector3(0, 1.45, 0),
      );
      // Ground projection stays on the court while the player jumps.
      feetNode = fs.Node(
        name: 'feet_projection',
        mesh: fs.Mesh(fs.DiscGeometry(radius: c.footRadius), blue),
      );
      root.add(feetNode);
      root.add(playerNode);
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
      publish();
    } catch (_) {
      s.removeAll();
      s.dispose();
      rethrow;
    }
  }

  // The only runtime writer of player/ball Scene transforms.
  void syncScene() {
    final p = game.player, b = game.ball;
    playerNode.position = vm.Vector3(p.x, p.y, p.z);
    ballNode.position = vm.Vector3(b.x, b.y, b.z);
    feetNode.position = vm.Vector3(p.x, 0.025, p.z);
  }

  void publish() {
    if (!mounted) return;
    final p = game.player;
    final points = game.shot?.pointValue ?? game.pointsAt(p);
    final text =
        'Điểm: ' +
        game.score.toString() +
        ' | ' +
        game.phase.name +
        ' | Lượt: ' +
        game.round.toString() +
        '\nVị trí: ' +
        p.x.toStringAsFixed(2) +
        ', ' +
        p.z.toStringAsFixed(2) +
        ' | Giá trị: ' +
        points.toString() +
        '\nCharge: ' +
        (game.charge * 100).toStringAsFixed(0) +
        '% | Canh khoảng ' +
        (c.idealCharge * 100).toStringAsFixed(0) +
        '%';
    final jumpInfo =
        '\ny=' +
        p.y.toStringAsFixed(3) +
        ' | ' +
        (game.grounded ? 'grounded' : 'airborne');
    hud.value = (text + jumpInfo + ' | Dash: ' + game.dashStatus, game.charge);
  }

  void tick(Duration elapsed, double dt) {
    if (!mounted || !resumed || scene == null) return;
    if (skipFrame) {
      skipFrame = false;
      return;
    }
    game.advance(dt);
    if (seenRound != game.round) {
      seenRound = game.round;
      cancelInputs('round_changed');
      // Rebuild only at the round transition, not every frame.
      setState(() {});
    }
    syncScene();
    publish();
  }

  void cancelInputs(String reason) {
    // Synchronous logic neutralization precedes the child's rebuild.
    joystickResetToken++;
    shotPointer = null;
    game.setMove(0, 0);
    game.cancelCharge(reason);
    game.cancelDash(reason);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    resumed = state == AppLifecycleState.resumed;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PracticeJoystick(
          key: const ValueKey('practice_joystick'),
          enabled: resumed,
          resetToken: inputEpoch,
          deadZone: 0.15,
          hitSize: 152,
          radius: 64,
          thumbRadius: 20,
          onChanged: (axis) {
            if (!inputValid()) return;
            game.setMove(-axis.dx, axis.dy);
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Semantics(
                    label: 'new_round',
                    child: ElevatedButton(
                      onPressed: () {
                        cancelInputs('manual_reset');
                        game.newRound();
                        seenRound = game.round;
                        syncScene();
                        setState(() {});
                        publish();
                      },
                      child: const Text('Lượt mới'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PracticeJumpButton(
                    key: const ValueKey('practice_jump'),
                    enabled: resumed,
                    resetToken: inputEpoch,
                    onJump: () {
                      if (!inputValid()) return;
                      game.jump();
                      publish();
                    },
                  ),
                  const SizedBox(width: 8),
                  PracticeDashButton(
                    key: const ValueKey('practice_dash'),
                    enabled: resumed,
                    resetToken: inputEpoch,
                    onDash: () {
                      if (!inputValid()) return;
                      if (game.dash()) {
                        // The old charging finger cannot release after Dash.
                        // Do not reset joystick/jump ownership here.
                        shotPointer = null;
                      }
                      publish();
                    },
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: 'shoot_hold_release',
                    button: true,
                    excludeSemantics: true,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) {
                        if (!inputValid()) return;
                        if (shotPointer == null && game.startCharge()) {
                          shotPointer = event.pointer;
                          publish();
                        }
                      },
                      onPointerUp: (event) {
                        if (!inputValid() || shotPointer != event.pointer)
                          return;
                        shotPointer = null;
                        game.release();
                        publish();
                      },
                      onPointerCancel: (event) {
                        if (shotPointer != event.pointer) return;
                        shotPointer = null;
                        game.cancelCharge('pointer_cancel');
                        publish();
                      },
                      child: Container(
                        width: 130,
                        height: 64,
                        alignment: Alignment.center,
                        color: Colors.deepOrange,
                        child: const Text(
                          'Giữ / thả ném',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cancelInputs('dispose');
    game.setPaused(true);
    scene?.removeAll();
    scene?.dispose();
    hud.dispose();
    semanticsHandle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<(String, double)>(
                        valueListenable: hud,
                        builder: (context, value, child) => Semantics(
                          label: 'practice_hud',
                          value: value.$1,
                          excludeSemantics: true,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(value.$1, textAlign: TextAlign.center),
                                  SizedBox(
                                    width: 220,
                                    child: LinearProgressIndicator(
                                      value: value.$2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      controls(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
