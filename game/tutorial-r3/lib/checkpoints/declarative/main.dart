import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  runApp(const MaterialApp(home: DeclarativeLesson()));
}

class DeclarativeLesson extends StatefulWidget {
  const DeclarativeLesson({super.key});

  @override
  State<DeclarativeLesson> createState() =>
      _DeclarativeLessonState();
}

class _DeclarativeLessonState extends State<DeclarativeLesson> {
  final fs.SceneNodeController _controller =
      fs.SceneNodeController();

  late final Future<void> _ready;
  late final fs.CuboidGeometry _geometry;
  late final fs.PhysicallyBasedMaterial _material;
  late final fs.PerspectiveCamera _camera;

  fs.Node? _firstNode;
  int _counter = 0;
  String _identity = 'Chưa đánh dấu';

  @override
  void initState() {
    super.initState();
    _ready = _prepare();
  }

  Future<void> _prepare() async {
    await fs.Scene.initializeStaticResources();
    if (!mounted) return;

    _geometry = fs.CuboidGeometry(
      vm.Vector3(0.5, 0.5, 0.5),
    );
    _material = fs.PhysicallyBasedMaterial();
    _camera = fs.PerspectiveCamera(
      position: vm.Vector3(3, 3, -6),
      target: vm.Vector3(0, 0.5, 0),
      fovNear: 0.1,
      fovFar: 50,
    );
  }

  // Chỉnh thân hàm này trong bài thử hot reload.
  vm.Vector4 _tint() => vm.Vector4(0.9, 0.35, 0.1, 1);

  void _recordState() {
    final node = _controller.node;
    setState(() {
      _counter++;
      if (node == null) {
        _identity = 'Node chưa mount';
        return;
      }
      _firstNode ??= node;
      _identity = identical(_firstNode, node)
          ? 'Giữ nguyên'
          : 'Đã đổi';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi chuẩn bị cảnh: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // Cập nhật tham số trên material cũ, không tạo material mới.
          _material.baseColorFactor = _tint();

          return Stack(
            fit: StackFit.expand,
            children: [
              fs.SceneView.declarative(
                camera: _camera,
                warmUp: true,
                loadingBuilder: (context, progress) =>
                    const Center(
                  child: CircularProgressIndicator(),
                ),
                children: [
                  fs.SceneNode(
                    key: const ValueKey('actor'),
                    name: 'actor',
                    controller: _controller,
                    position: vm.Vector3(-1.5, 0.35, 0),
                    children: [
                      fs.SceneMesh(
                        key: const ValueKey('actorMesh'),
                        geometry: _geometry,
                        material: _material,
                      ),
                    ],
                  ),
                ],
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Số lần nhấn: $_counter'),
                          Text('Identity node: $_identity'),
                          ElevatedButton(
                            onPressed: _recordState,
                            child: const Text('Ghi nhận state'),
                          ),
                        ],
                      ),
                    ),
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
