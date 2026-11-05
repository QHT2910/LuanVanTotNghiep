import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../../lesson_host.dart';
import '../a/main.dart' as a;

void main() => startLesson(buildLesson);

class Spin extends fs.Component {
  double angle = 0;

  @override
  void update(double deltaSeconds) {
    final dt = deltaSeconds.clamp(0.0, 0.05).toDouble();
    angle += 0.8 * dt;
    node.rotation = vm.Quaternion.axisAngle(
      vm.Vector3(0, 1, 0),
      angle,
    );
  }
}

Lesson buildLesson(fs.Scene scene) {
  final lesson = a.buildLesson(scene);
  final pivot = fs.Node(name: 'pivot')
    ..position = vm.Vector3(0, 1.2, 1)
    ..scale = vm.Vector3(1, 0.7, 1)
    ..addComponent(Spin());
  final marker = fs.Node(
    name: 'marker',
    mesh: fs.Mesh(
      fs.CuboidGeometry(vm.Vector3(0.4, 0.4, 0.4)),
      fs.PhysicallyBasedMaterial(),
    ),
  )..position = vm.Vector3(0.6, 0, 0);
  pivot.add(marker);
  lesson.root.add(pivot);
  return lesson;
}
