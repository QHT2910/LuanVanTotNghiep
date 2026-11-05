import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' as fs;

typedef LessonBuilder = FutureOr<Lesson> Function(fs.Scene scene);

class Lesson {
  Lesson({
    required this.root,
    required this.actor,
    required this.material,
    required this.camera,
  });

  final fs.Node root;
  final fs.Node actor;
  final fs.PhysicallyBasedMaterial material;
  final fs.Camera camera;
  Widget? overlay;
  final List<VoidCallback> cleanups = [];
  bool _closed = false;

  void close() {
    if (_closed) return;
    _closed = true;
    for (final cleanup in cleanups.reversed) {
      cleanup();
    }
    // Body/collider con được gỡ trước PhysicsWorld trên root.
    root.removeAll();
  }
}

void startLesson(LessonBuilder builder) {
  runApp(MaterialApp(home: _LessonHost(builder)));
}

class _LessonHost extends StatefulWidget {
  const _LessonHost(this.builder);
  final LessonBuilder builder;

  @override
  State<_LessonHost> createState() => _LessonHostState();
}

class _LessonHostState extends State<_LessonHost> {
  late final Future<void> _ready;
  fs.Scene? _scene;
  Lesson? _lesson;

  @override
  void initState() {
    super.initState();
    _ready = _load();
  }

  void _release(fs.Scene scene, Lesson? lesson) {
    lesson?.close();
    scene.removeAll();
    scene.dispose();
  }

  Future<void> _load() async {
    await fs.Scene.initializeStaticResources();
    if (!mounted) return;
    final scene = fs.Scene();
    try {
      final lesson = await widget.builder(scene);
      if (!mounted) {
        _release(scene, lesson);
        return;
      }
      _scene = scene;
      _lesson = lesson;
    } catch (_) {
      _release(scene, null);
      rethrow;
    }
  }

  @override
  void dispose() {
    final scene = _scene;
    if (scene != null) _release(scene, _lesson);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final scene = _scene;
          final lesson = _lesson;
          if (snapshot.connectionState != ConnectionState.done ||
              scene == null || lesson == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              fs.SceneView(scene, camera: lesson.camera),
              if (lesson.overlay != null)
                SafeArea(child: lesson.overlay!),
            ],
          );
        },
      ),
    );
  }
}
