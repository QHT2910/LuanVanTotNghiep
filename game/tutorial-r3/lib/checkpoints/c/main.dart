import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../../lesson_host.dart';
import '../b/main.dart' as b;

void main() => startLesson(buildLesson);

Lesson buildLesson(fs.Scene scene) {
  final lesson = b.buildLesson(scene);
  lesson.material
    ..baseColorFactor = vm.Vector4(0.9, 0.35, 0.1, 1)
    ..metallicFactor = 0
    ..roughnessFactor = 0.7;

  final floorMaterial = fs.PhysicallyBasedMaterial()
    ..baseColorFactor = vm.Vector4(0.25, 0.35, 0.3, 1)
    ..metallicFactor = 0
    ..roughnessFactor = 0.9;
  lesson.root.add(fs.Node(
    name: 'floor',
    mesh: fs.Mesh(
      fs.CuboidGeometry(vm.Vector3(5, 0.1, 3)),
      floorMaterial,
    ),
  )..position = vm.Vector3(0, -0.05, 0));

  lesson.root.add(fs.Node(name: 'lamp')
    ..position = vm.Vector3(-2, 3, -2)
    ..addComponent(fs.PointLightComponent(
      fs.PointLight(
        intensity: 25,
        range: 10,
        castsShadow: false,
      ),
    )));
  return lesson;
}
