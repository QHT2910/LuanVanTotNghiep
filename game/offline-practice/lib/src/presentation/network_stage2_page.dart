import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../network/network_snapshot.dart';
import '../network/stage2_client.dart';

class NetworkStage2Page extends StatefulWidget {
  const NetworkStage2Page({super.key});
  @override
  State<NetworkStage2Page> createState() => _NetworkStage2PageState();
}

class _NetworkStage2PageState extends State<NetworkStage2Page>
    with WidgetsBindingObserver {
  fs.Scene? scene;
  late final Future<void> ready;
  late final fs.PerspectiveCamera camera;
  final players = <fs.Node>[];
  fs.Node? ball;
  Stage2Client? client, shootClient;
  NetworkSnapshot? pending;
  int applied = -1, effects = 0;
  String status = 'disconnected', hud = 'Chờ hai client';
  bool leaving = false, resumed = true;
  int? shootPointer;
  final moves = <int, NetVec>{};
  bool get alive => mounted && !leaving;
  void log(Map<String, Object?> data) =>
      debugPrintSynchronously('network_stage2 ${jsonEncode(data)}');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final life = WidgetsBinding.instance.lifecycleState;
    resumed = life == null || life == AppLifecycleState.resumed;
    log({'event': 'mode', 'mode': 'NETWORK_STAGE2_CANONICAL_1_8'});
    ready = prepare();
  }

  fs.UnlitMaterial paint(double r, double g, double b) =>
      fs.UnlitMaterial()..baseColorFactor = vm.Vector4(r, g, b, 1);
  fs.Node box(
    vm.Vector3 size,
    vm.Vector3 position,
    fs.UnlitMaterial material,
  ) =>
      fs.Node(mesh: fs.Mesh(fs.CuboidGeometry(size), material))
        ..position = position;
  Future<void> prepare() async {
    await fs.Scene.initializeStaticResources();
    if (!alive) return;
    final s = fs.Scene()..antiAliasingMode = fs.AntiAliasingMode.none;
    try {
      s.add(
        box(
          vm.Vector3(8, .1, 9),
          vm.Vector3(0, -.05, .5),
          paint(.12, .35, .25),
        ),
      );
      for (final color in [paint(.1, .4, .95), paint(.8, .2, .3)]) {
        final p = box(vm.Vector3(.45, 1.8, .4), vm.Vector3(0, .9, 0), color);
        players.add(p);
        s.add(p);
      }
      ball = fs.Node(
        mesh: fs.Mesh(
          fs.SphereGeometry(radius: .12, segments: 16, rings: 8),
          paint(1, .35, .03),
        ),
      );
      s.add(ball!);
      s.add(
        box(
          vm.Vector3(1.8, 1, .1),
          vm.Vector3(0, 3.4, -3.6),
          paint(.95, .95, .95),
        ),
      );
      s.add(
        fs.Node(
          mesh: fs.Mesh(
            fs.TorusGeometry(
              radius: .485,
              tubeRadius: .035,
              radialSegments: 24,
              tubularSegments: 8,
            ),
            paint(1, .35, .03),
          ),
        )..position = vm.Vector3(0, 3.05, -3),
      );
      camera = fs.PerspectiveCamera(
        position: vm.Vector3(0, 10, 14),
        target: vm.Vector3(0, 1.2, 0),
        fovNear: .1,
        fovFar: 80,
      );
      scene = s;
      if (alive && resumed) connect();
    } catch (_) {
      s.removeAll();
      s.dispose();
      rethrow;
    }
  }

  void connect() {
    if (!alive || !resumed || scene == null) return;
    stop();
    pending = null;
    applied = -1;
    effects = 0;
    late final Stage2Client c;
    c = Stage2Client(
      onCommit: (commit) {
        if (!alive || client != c) return;
        pending = commit.snapshot;
        effects += commit.effects.length;
        final s = commit.snapshot;
        final text =
            'Slot ${c.slot} | Điểm ${s.scores.join(':')} | Lượt slot ${s.owner} | ${s.phase} | FX $effects';
        if (text != hud) setState(() => hud = text);
      },
      onStatus: (text) {
        if (!alive || client != c) return;
        if (c.closed) {
          moves.clear();
          shootPointer = null;
          shootClient = null;
          pending = null;
        }
        setState(() => status = text);
      },
      onLog: (e) {
        if (alive && client == c) log(e);
      },
    );
    client = c;
    status = 'connecting';
    hud = 'Chờ hai client';
    setState(() {});
    unawaited(
      c.connect(
        const String.fromEnvironment(
          'NETWORK_URL',
          defaultValue: 'ws://10.0.2.2:8091/room/stage1',
        ),
      ),
    );
  }

  // Sole runtime transform writer. No Practice/physics/prediction on this client.
  void tick(Duration elapsed, double delta) {
    final s = scene;
    if (!alive || s == null) return;
    final d = pending;
    if (resumed && d != null && d.tick > applied) {
      for (final p in d.players) {
        players[p.slot].position = vm.Vector3(
          p.position.x,
          p.position.y + .9,
          p.position.z,
        );
        players[p.slot].rotation = vm.Quaternion.axisAngle(
          vm.Vector3(0, 1, 0),
          math.atan2(p.facing.x, p.facing.z),
        );
      }
      ball!.position = vm.Vector3(d.ball.x, d.ball.y, d.ball.z);
      applied = d.tick;
      log({
        'event': 'scene_applied',
        ...d.core(),
        'writer': 'snapshot_only',
        'renderPlayers': [
          for (final p in players) [p.position.x, p.position.y, p.position.z],
        ],
        'renderBall': [ball!.position.x, ball!.position.y, ball!.position.z],
      });
    }
    s.update(0);
  }

  void updateMove() {
    double x = 0, z = 0;
    for (final v in moves.values) {
      x += v.x;
      z += v.z;
    }
    client?.move(x.clamp(-1.0, 1.0).toDouble(), z.clamp(-1.0, 1.0).toDouble());
  }

  Widget moveButton(String label, double x, double z) => Semantics(
    label: 'network_move_$label',
    button: true,
    child: Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        if (!resumed || client?.closed != false) return;
        moves[e.pointer] = (x: x, y: 0, z: z);
        updateMove();
      },
      onPointerUp: (e) {
        if (moves.remove(e.pointer) != null) updateMove();
      },
      onPointerCancel: (e) {
        if (moves.remove(e.pointer) != null) updateMove();
      },
      child: SizedBox(width: 52, height: 48, child: Center(child: Text(label))),
    ),
  );
  Widget shoot() => Semantics(
    label: 'network_shoot_hold_release',
    button: true,
    child: Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        final c = client, s = pending;
        if (!resumed ||
            c == null ||
            c.closed ||
            s == null ||
            !s.ready ||
            s.owner != c.slot ||
            shootPointer != null)
          return;
        shootPointer = e.pointer;
        shootClient = c;
        c.send('charge');
      },
      onPointerUp: (e) {
        if (shootPointer != e.pointer) return;
        final old = shootClient;
        shootPointer = null;
        shootClient = null;
        if (resumed && old != null && identical(client, old) && !old.closed)
          old.send('release');
      },
      onPointerCancel: (e) {
        if (shootPointer != e.pointer) return;
        final old = shootClient;
        shootPointer = null;
        shootClient = null;
        if (old != null && identical(client, old) && !old.closed)
          old.send('cancel');
      },
      child: const SizedBox(
        width: 84,
        height: 48,
        child: Center(child: Text('NÉM')),
      ),
    ),
  );
  void stop() {
    moves.clear();
    shootPointer = null;
    shootClient = null;
    final c = client;
    client = null;
    c?.close();
    pending = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!alive) return;
    resumed = state == AppLifecycleState.resumed;
    if (!resumed) {
      stop();
      status = 'background: disconnected';
    }
    setState(
      () {},
    ); // Resume requires explicit Connect; never replay old input.
  }

  @override
  void dispose() {
    leaving = true;
    WidgetsBinding.instance.removeObserver(this);
    stop();
    scene?.removeAll();
    scene?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<void>(
      future: ready,
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Scene initialization failed'));
        final s = scene;
        if (s == null) return const Center(child: CircularProgressIndicator());
        return Stack(
          fit: StackFit.expand,
          children: [
            fs.SceneView(s, camera: camera, onTick: tick),
            SafeArea(
              child: Column(
                children: [
                  const Text(
                    'NETWORK STAGE2 | primitive / canonical origin 1.8',
                  ),
                  Text('$status | $hud'),
                  const Text(
                    'Luân phiên thử nghiệm • local • chưa là trận 1v1',
                  ),
                  const Spacer(),
                  LayoutBuilder(
                    builder: (context, bounds) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: bounds.maxWidth * .42,
                          child: Wrap(
                            children: [
                              moveButton('X−', -1, 0),
                              moveButton('X+', 1, 0),
                              moveButton('Z−', 0, -1),
                              moveButton('Z+', 0, 1),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: bounds.maxWidth * .56,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              TextButton(
                                onPressed: resumed ? connect : null,
                                child: const Text('Connect'),
                              ),
                              TextButton(
                                onPressed: resumed
                                    ? () => client?.send('jump')
                                    : null,
                                child: const Text('Jump'),
                              ),
                              TextButton(
                                onPressed: resumed
                                    ? () => client?.send('dash')
                                    : null,
                                child: const Text('Dash'),
                              ),
                              shoot(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
