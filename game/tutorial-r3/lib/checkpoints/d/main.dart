import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../../lesson_host.dart';
import '../c/main.dart' as c;

void main() => startLesson(buildLesson);

class Drive extends fs.Component {
  Drive(this.onMove);

  final VoidCallback onMove;
  double direction = 0;

  @override
  void update(double deltaSeconds) {
    final dt = deltaSeconds.clamp(0.0, 0.05).toDouble();
    final p = node.position;
    final x = (p.x + direction * 1.2 * dt)
        .clamp(-2.0, 2.0)
        .toDouble();
    node.position = vm.Vector3(x, p.y, p.z);
    onMove();
  }
}

Lesson buildLesson(fs.Scene scene) {
  final lesson = c.buildLesson(scene);
  final hud = ValueNotifier<String>('x = -1.50');
  final drive = Drive(() {
    final x = lesson.actor.position.x.toStringAsFixed(2);
    hud.value = 'x = $x';
  });
  lesson.actor.addComponent(drive);
  lesson.cleanups.add(() {
    drive.enabled = false;
    hud.dispose();
  });

  lesson.overlay = Column(
    children: [
      ValueListenableBuilder<String>(
        valueListenable: hud,
        builder: (context, value, child) =>
            Card(child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(value),
        )),
      ),
      const Spacer(),
      Wrap(
        spacing: 8,
        children: [
          ElevatedButton(
            onPressed: () => drive.direction = -1,
            child: const Text('Trái'),
          ),
          ElevatedButton(
            onPressed: () => drive.direction = 0,
            child: const Text('Dừng'),
          ),
          ElevatedButton(
            onPressed: () => drive.direction = 1,
            child: const Text('Phải'),
          ),
        ],
      ),
    ],
  );
  return lesson;
}
