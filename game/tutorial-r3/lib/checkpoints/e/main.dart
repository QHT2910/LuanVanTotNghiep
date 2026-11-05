import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:flutter_scene/physics.dart' as ph;
import 'package:vector_math/vector_math.dart' as vm;

import '../../lesson_host.dart';
import '../d/main.dart' as d;

void main() => startLesson(buildLesson);

Lesson buildLesson(fs.Scene scene) {
  final lesson = d.buildLesson(scene);
  final physics = ph.PhysicsWorld(ph.BasicSimulation());
  lesson.root.addComponent(physics);

  lesson.actor.mesh = fs.Mesh(
    fs.SphereGeometry(radius: 0.25, segments: 24, rings: 12),
    lesson.material,
  );
  lesson.actor.addComponent(ph.RigidBody(
    type: ph.BodyType.kinematic,
    useGravity: false,
  ));
  lesson.actor.addComponent(ph.Collider(
    shape: const ph.SphereShape(radius: 0.25),
  ));

  final gateMaterial = fs.PhysicallyBasedMaterial()
    ..baseColorFactor = vm.Vector4(0.2, 0.5, 0.9, 1)
    ..metallicFactor = 0;
  final gate = fs.Node(
    name: 'gate',
    mesh: fs.Mesh(
      fs.CuboidGeometry(vm.Vector3(0.3, 0.7, 0.7)),
      gateMaterial,
    ),
  )..position = vm.Vector3(0, 0.35, 0);
  gate.addComponent(ph.Collider(
    shape: ph.BoxShape(
      halfExtents: vm.Vector3(0.15, 0.35, 0.35),
    ),
    isTrigger: true,
  ));
  lesson.root.add(gate);

  final count = ValueNotifier<int>(0);
  var closed = false;
  final subscription = physics.collisions.listen((event) {
    if (closed || event is! ph.TriggerEntered) return;
    final matches =
        (identical(event.nodeA, lesson.actor) &&
            identical(event.nodeB, gate)) ||
        (identical(event.nodeB, lesson.actor) &&
            identical(event.nodeA, gate));
    if (matches) count.value++;
  });
  lesson.cleanups.add(() {
    closed = true;
    unawaited(subscription.cancel());
    count.dispose();
  });

  final controls = lesson.overlay!;
  lesson.overlay = Column(
    children: [
      ValueListenableBuilder<int>(
        valueListenable: count,
        builder: (context, value, child) =>
            Card(child: Text('Số lần vào vùng: $value')),
      ),
      Expanded(child: controls),
    ],
  );
  return lesson;
}
