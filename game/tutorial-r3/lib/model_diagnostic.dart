import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

const humanDiagnostic = bool.fromEnvironment('HUMAN');
const modelAsset = humanDiagnostic
    ? 'assets/human-ual-standard/HumanDiagnostic.glb'
    : 'assets/Fox.glb';
const runClipName = humanDiagnostic ? 'Jog_Fwd_Loop' : 'Run';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MaterialApp(home: FoxDiagnostic()));
}

class FoxDiagnostic extends StatefulWidget {
  const FoxDiagnostic({super.key});
  @override
  State<FoxDiagnostic> createState() => _FoxDiagnosticState();
}

class _FoxDiagnosticState extends State<FoxDiagnostic>
    with WidgetsBindingObserver {
  final runId = DateTime.now().toUtc().toIso8601String();
  late final Future<void> ready;
  fs.Scene? scene;
  fs.Node? actor, model;
  fs.AnimationClip? clip;
  final clips = <String, fs.AnimationClip>{};
  final durations = <String, double>{};
  String selectedClip = runClipName;
  fs.PerspectiveCamera? camera;
  final joints = <fs.Node>[];
  double duration = 0;
  int seq = 0;
  bool active = true, wantsPlay = false, skipDelta = true;
  bool closed = false, shifted = false, frameSeen = false, firstTick = false;
  String? pendingSample = 'pose0_loaded';
  bool get alive => mounted && !closed;

  Iterable<fs.Node> walk(fs.Node node) sync* {
    yield node;
    for (final child in node.children) {
      yield* walk(child);
    }
  }

  void emit(String event, [Map<String, Object?> data = const {}]) {
    if (!alive) return;
    final payload = jsonEncode({
      'schema': 1,
      'runId': runId,
      'seq': ++seq,
      'event': event,
      'clip': selectedClip,
      'clipStates': {
        for (final e in clips.entries)
          e.key: {
            'playing': e.value.playing,
            'weight': e.value.weight,
            'time': e.value.playbackTime,
          },
      },
      'clipTime': clip?.playbackTime,
      'playing': clip?.playing,
      'appActive': active,
      ...data,
    });
    final total = (payload.length / 500).ceil();
    for (var i = 0; i < total; i++) {
      final end = (i + 1) * 500;
      debugPrint(
        'model_diag_chunk ${jsonEncode({'runId': runId, 'seq': seq, 'index': i, 'total': total, 'data': payload.substring(i * 500, end < payload.length ? end : payload.length)})}',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final state = WidgetsBinding.instance.lifecycleState;
    active = state == null || state == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    ready = load();
  }

  Future<void> load() async {
    await fs.Scene.initializeStaticResources();
    if (!alive) return;
    final watch = Stopwatch()..start();
    final data = await rootBundle.load(modelAsset);
    watch.stop();
    final readMs = watch.elapsedMicroseconds / 1000;
    final warnings = <String>[];
    watch.reset();
    watch.start();
    final loaded = await fs.Node.fromGlbBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      maxTextureSize: 1024,
      onWarning: (warning) {
        warnings.add(warning.toString());
        emit('import_warning', {'warning': warning.toString()});
      },
    );
    watch.stop();
    if (!alive) return;
    final animation = loaded.findAnimationByName(runClipName);
    if (animation == null || animation.endTime <= 0) {
      throw StateError('Run clip missing or empty');
    }
    final nodes = walk(loaded).toList();
    final requested = {runClipName, if (humanDiagnostic) 'Idle_Loop'};
    final bindingAudit = <Map<String, Object?>>[];
    for (final name in requested) {
      final matches = loaded.parsedAnimations
          .where((a) => a.name == name)
          .toList();
      if (matches.length != 1 || matches.single.endTime <= 0) {
        throw StateError('Missing/duplicate requested clip: $name');
      }
      final targets = matches.single.channels
          .map((c) => c.bindTarget.nodeName)
          .toSet();
      final counts = {
        for (final name in targets)
          name: nodes
              .where((n) => n.name == name && !identical(n, loaded))
              .length,
      };
      if (counts.values.any((n) => n != 1)) {
        emit('binding_rejected', {
          'clip': name,
          'counts': counts,
          'nodeNames': [for (final n in nodes) n.name],
        });
        throw StateError('Ambiguous clip binding');
      }
      bindingAudit.add({
        'clip': name,
        'targetMatches': counts,
        'syntheticImportRootExcluded': true,
        'importRootName': loaded.name,
      });
    }
    final skins = <Map<String, Object?>>[];
    for (final node in nodes) {
      final skin = node.skin;
      if (skin == null) continue;
      skins.add({
        'node': node.name,
        'jointCount': skin.joints.length,
        'nullJoints': skin.joints.where((j) => j == null).length,
      });
      for (final joint in skin.joints) {
        if (joint != null && !joints.contains(joint)) joints.add(joint);
      }
    }
    emit('asset_metadata', {
      'asset': modelAsset,
      'bindingAudit': bindingAudit,
      'bytes': data.lengthInBytes,
      'bundleReadMs': readMs,
      'importFutureMs': watch.elapsedMicroseconds / 1000,
      'timingScope': 'Bundle read/import Future; not GPU readiness',
      'clips': [
        for (final a in loaded.parsedAnimations)
          {
            'name': a.name,
            'duration': a.endTime,
            'channels': a.channels.length,
          },
      ],
      'runtimeSkinnedNodes': skins,
      'warnings': warnings,
      'nodeNames': [for (final n in nodes) n.name],
    });
    final s = fs.Scene()..antiAliasingMode = fs.AntiAliasingMode.none;
    try {
      final wrapper = fs.Node(name: 'diagnostic_actor')
        ..scale = vm.Vector3.all(humanDiagnostic ? 1 : 0.01);
      wrapper.add(loaded);
      s.add(wrapper);
      final floor = fs.UnlitMaterial()
        ..baseColorFactor = vm.Vector4(0.22, 0.25, 0.28, 1);
      s.add(
        fs.Node(mesh: fs.Mesh(fs.CuboidGeometry(vm.Vector3(6, 0.02, 6)), floor))
          ..position = vm.Vector3(0, -0.03, 0),
      );
      s.add(
        fs.Node()
          ..position = vm.Vector3(-2, 3, -2)
          ..addComponent(
            fs.PointLightComponent(
              fs.PointLight(intensity: 20, range: 12, castsShadow: false),
            ),
          ),
      );
      for (final name in requested) {
        final a = loaded.findAnimationByName(name)!;
        final p = loaded.createAnimationClip(a)
          ..loop = true
          ..weight = 0;
        p.pause();
        p.seek(0);
        clips[name] = p;
        durations[name] = a.endTime;
      }
      model = loaded;
      actor = wrapper;
      clip = clips[selectedClip]!;
      clip!.weight = 1;
      duration = animation.endTime;
      camera = fs.PerspectiveCamera(
        position: humanDiagnostic
            ? vm.Vector3(2.5, 1.8, -3.5)
            : vm.Vector3(4, 3, -5),
        target: humanDiagnostic
            ? vm.Vector3(0, 0.9, 0)
            : vm.Vector3(0.5, 0.8, 0),
        fovNear: 0.1,
        fovFar: 30,
      );
      scene = s;
    } catch (_) {
      s.removeAll();
      s.dispose();
      rethrow;
    }
  }

  void sample(String reason) => emit('pose_sample', {
    'reason': reason,
    'duration': duration,
    'weight': clip?.weight,
    'actorLocal': actor?.localTransform.storage.toList(),
    'modelWorld': model?.globalTransform.storage.toList(),
    'jointSamples': [
      if (joints.isNotEmpty)
        for (final i in <int>{0, joints.length ~/ 2, joints.length - 1})
          {
            'index': i,
            'name': joints[i].name,
            'local': joints[i].localTransform.storage.toList(),
            'world': joints[i].globalTransform.storage.toList(),
          },
    ],
  });

  void tick(Duration elapsed, double delta) {
    final s = scene;
    if (!alive || s == null) return;
    final dt = active && wantsPlay && !skipDelta && delta.isFinite && delta > 0
        ? delta.clamp(0.0, 0.05).toDouble()
        : 0.0;
    skipDelta = false;
    s.update(dt); // renderViews skips its implicit tick after explicit update.
    final reason = pendingSample;
    pendingSample = null;
    if (reason != null) sample(reason);
    if (!firstTick) {
      firstTick = true;
      emit('first_view_tick', {'acceptedDelta': dt, 'gpuReady': null});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!alive) return;
        emit('first_flutter_frame_callback', {'gpuReady': null});
        setState(() => frameSeen = true);
      });
    }
  }

  void play(bool value) {
    if (!active || clip == null) return;
    emit('before_play_change');
    wantsPlay = value;
    if (value) {
      clip!.play();
    } else {
      clip!.pause();
    }
    skipDelta = true;
    pendingSample = value ? 'play' : 'pause';
    setState(() {});
  }

  void switchClip(String name) {
    if (!alive || !active || !clips.containsKey(name)) return;
    emit('before_clip_switch', {'next': name});
    for (final old in clips.values) {
      old.pause();
      old.weight = 0;
    }
    selectedClip = name;
    clip = clips[name]!;
    duration = durations[name]!;
    clip!.seek(0);
    clip!.weight = 1;
    wantsPlay = false;
    skipDelta = true;
    pendingSample = 'clip_switch_$name';
    setState(() {});
  }

  void pose(double fraction) {
    wantsPlay = false;
    clip!.pause();
    clip!.seek(duration * fraction);
    pendingSample = 'seek_fraction_$fraction';
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!alive) return;
    emit('before_lifecycle', {'next': state.name});
    active = state == AppLifecycleState.resumed;
    if (!active) {
      for (final c in clips.values) {
        c.pause();
      }
    } else if (wantsPlay) {
      clip?.play();
    }
    skipDelta = true;
    pendingSample = active ? 'resume' : 'background';
    emit('after_lifecycle');
    setState(() {});
  }

  @override
  void dispose() {
    emit('dispose_requested');
    closed = true;
    WidgetsBinding.instance.removeObserver(this);
    for (final c in clips.values) {
      c.pause();
    }
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
          return Center(child: Text('Diagnostic error: ${snapshot.error}'));
        final s = scene;
        if (s == null) return const Center(child: CircularProgressIndicator());
        Widget button(String id, String text, VoidCallback action) =>
            TextButton(
              key: ValueKey(id),
              onPressed: active ? action : null,
              child: Text(text),
            );
        return SafeArea(
          child: Column(
            children: [
              Semantics(
                label: 'model_frame_status',
                value: frameSeen
                    ? 'Flutter callback; GPU unverified'
                    : 'waiting',
                child: Text(
                  '${humanDiagnostic ? "Human" : "Fox baseline"} / $selectedClip / ${wantsPlay ? "playing" : "paused"}',
                ),
              ),
              Expanded(
                child: fs.SceneView(s, camera: camera, onTick: tick),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  if (humanDiagnostic)
                    button('diag_idle', 'Idle', () => switchClip('Idle_Loop')),
                  if (humanDiagnostic)
                    button('diag_run', 'Run', () => switchClip(runClipName)),
                  button('diag_play', 'Play', () => play(true)),
                  button('diag_pause', 'Pause', () => play(false)),
                  button('diag_replay', 'Replay', () {
                    clip!.replay();
                    wantsPlay = true;
                    skipDelta = true;
                    pendingSample = 'replay';
                    setState(() {});
                  }),
                  button('diag_pose0', 'Pose 0', () => pose(0)),
                  button('diag_pose50', 'Pose 50%', () => pose(0.5)),
                  button(
                    'diag_sample',
                    'Sample',
                    () => pendingSample = 'manual',
                  ),
                  button('diag_root', 'Root transform', () {
                    wantsPlay = false;
                    clip!.pause();
                    shifted = !shifted;
                    actor!.position = vm.Vector3(shifted ? 1 : 0, 0, 0);
                    actor!.rotation = vm.Quaternion.axisAngle(
                      vm.Vector3(0, 1, 0),
                      shifted ? 1.5707963267948966 : 0,
                    );
                    pendingSample = 'root_transform';
                    setState(() {});
                  }),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
