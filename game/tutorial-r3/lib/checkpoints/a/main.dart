import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../../lesson_host.dart';

void main() => startLesson(buildLesson);

Lesson buildLesson(fs.Scene scene) {
  final material = fs.PhysicallyBasedMaterial();
  final actor = fs.Node(
    name: 'actor',
    mesh: fs.Mesh(
      fs.CuboidGeometry(vm.Vector3(0.5, 0.5, 0.5)),
      material,
    ),
  )..position = vm.Vector3(-1.5, 0.35, 0);
  final root = fs.Node(name: 'world')..add(actor);
  scene.add(root);

  return Lesson(
    root: root,
    actor: actor,
    material: material,
    camera: fs.PerspectiveCamera(
      position: vm.Vector3(3, 3, -6),
      target: vm.Vector3(0, 0.5, 0),
      fovNear: 0.1,
      fovFar: 50,
    ),
  );
}
