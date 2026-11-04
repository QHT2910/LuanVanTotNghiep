import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() => runApp(const MaterialApp(home: SceneProbe()));

class SceneProbe extends StatefulWidget {
  const SceneProbe({super.key});
  @override
  State<SceneProbe> createState() => _SceneProbeState();
}

class _SceneProbeState extends State<SceneProbe> {
  final Scene scene = Scene();
  late final Future<void> ready;

  @override
  void initState() {
    super.initState();
    ready = initialize();
  }

  Future<void> initialize() async {
    await Scene.initializeStaticResources();
    scene.add(Node(mesh: Mesh(
      CuboidGeometry(vm.Vector3(1, 1, 1)),
      PhysicallyBasedMaterial(),
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<void>(
      future: ready,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Scene initialization failed: ${snapshot.error}'));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return SceneView(scene,
          camera: PerspectiveCamera(position: vm.Vector3(2, 2, -4)));
      },
    ),
  );
}
