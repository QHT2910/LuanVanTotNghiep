Bản R3 dưới đây chỉ là source đề nghị để Lead lưu và kiểm tra. Tôi đã đọc source `game/tutorial-r2` và evidence hiện có; không ghi tệp hoặc chạy lại kiểm chứng.

```text
Gate R3: none | chỉ đọc source, chưa analyze/build/test mã mới | logpath: none
```

## Cách tổ chức sáu checkpoint

Giữ `game/tutorial-r2` làm bằng chứng R2. Đề nghị Lead tạo bản làm việc `game/tutorial-r3` từ source/config R2, không sao chép `.dart_tool` hoặc `build`.

```text
lib/
  lesson_host.dart
  checkpoints/
    a/main.dart
    b/main.dart
    c/main.dart
    d/main.dart
    e/main.dart
    f/main.dart
  snapshot_replica.dart
test/
  snapshot_replica_test.dart
tool/
  sync_smoke.dart
```

Mỗi checkpoint có `main()` riêng, chạy bằng `--target`. B–F gọi builder của checkpoint trước để giữ cùng một cảnh; import không thực thi `main()` của tệp được import. Không cần chép đè `lib/main.dart` hoặc ghép các đoạn vào một tệp dài.

Trong luận văn, trình bày mục tiêu và thay đổi của từng mốc trước đoạn code tương ứng. Host chung là hạ tầng khởi tạo/vòng đời, tách khỏi các bước học Scene.

### Điều kiện chung

Giữ bộ phiên bản từ R2:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_scene: 0.24.3
  vector_math: 2.4.4
```

Giữ lockfile làm cơ sở đối chiếu; không nâng dependency hoặc SDK trong lượt này. Khi tạo project có Android runner, metadata sau nằm trong `<application>` hiện có:

```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableFlutterGPU"
    android:value="true" />
```

Analyze không cần điện thoại. Quan sát render cần Android được Flutter nhận diện và cấu hình GPU phù hợp. Build bundle chưa chứng minh điều này.

## Source chung — tạo trước checkpoint A

Tệp `lib/lesson_host.dart` cung cấp khởi tạo tài nguyên, loading/error UI, SceneView và thu hồi scene. Các checkpoint chỉ cần xây dựng cảnh.

```dart
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
```

Host giữ một future khởi tạo, không khởi tạo tài nguyên lại trong `build()`. Nếu việc nạp asset kết thúc sau khi widget bị hủy, scene tạm được thu hồi thay vì gắn vào giao diện đã đóng.

Trạng thái: source mới, chưa analyze hoặc kiểm tra lifecycle runtime.

## A. Scene và camera

Mục tiêu: hiển thị một khối hộp bằng SceneView với camera cố định. Chưa có component chuyển động, input, vật lý hoặc asset.

Tiền đề: đã lưu `lesson_host.dart`, resolve dependency và cấu hình GPU khi chạy Android.

Tệp `lib/checkpoints/a/main.dart`:

```dart
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
```

Lệnh đề nghị:

```powershell
flutter analyze lib/checkpoints/a/main.dart
flutter run --target lib/checkpoints/a/main.dart
```

Kết quả dự kiến: một khối hộp nằm lệch trái trong cảnh, camera đứng yên. Scene dùng cấu hình môi trường mặc định; chưa thêm nguồn sáng riêng.

Nếu màn hình trống, kiểm tra exception khởi tạo, Flutter GPU, camera và thiết bị. Không thêm vật lý hoặc asset để xử lý lỗi của mốc A.

## B. Transform và component

Mục tiêu: quan sát phép biến đổi cha–con và component cập nhật theo frame. Quả hộp chính của A giữ nguyên; thêm một khối hộp con quay quanh pivot riêng.

Tiền đề: checkpoint A đã analyze đạt; khi có thiết bị, cần quan sát được A trước khi đánh giá B.

Tệp `lib/checkpoints/b/main.dart`:

```dart
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
```

Lệnh đề nghị:

```powershell
flutter analyze lib/checkpoints/b/main.dart
flutter run --target lib/checkpoints/b/main.dart
```

Kết quả dự kiến: marker quay quanh pivot và chịu scale theo trục Y của cha. Actor chính không quay.

`position`, `rotation` và `scale` trong Scene 0.24.3 trả bản sao. Để cập nhật vị trí phải gán lại:

```dart
final p = node.position;
node.position = vm.Vector3(p.x + 0.1, p.y, p.z);
```

Không dùng `node.position.x += 0.1`. Khi component không cập nhật, kiểm tra node đã nằm trong scene và component đã load/mount; không tự thêm ticker thứ hai.

Giới hạn delta 0.05 giây là quy ước minh họa, không phải timestep mạng hoặc ngưỡng nghiệm thu.

## C. Material và ánh sáng

Mục tiêu: thay màu, độ nhám của actor, thêm nền và PointLight. Chưa dùng texture hoặc model ngoài.

Tiền đề: mốc B hoạt động; không thêm dependency mới.

Tệp `lib/checkpoints/c/main.dart`:

```dart
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
```

Lệnh đề nghị:

```powershell
flutter analyze lib/checkpoints/c/main.dart
flutter run --target lib/checkpoints/c/main.dart
```

Kết quả dự kiến: actor màu cam, nền xanh xám; thay đổi vị trí lamp hoặc intensity làm thay đổi phần chiếu sáng trực tiếp. Môi trường mặc định vẫn có thể đóng góp ánh sáng.

Nền dày 0.1, tâm tại `y = -0.05`, nên mặt trên nằm ở `y = 0`. Actor vẫn chưa có trọng lực.

Nếu bề mặt quá sáng, kiểm tra intensity, metallic và exposure trước khi đổi renderer. Mốc này tắt shadow; không dùng nó để dự đoán hiệu năng cảnh có bóng đổ.

## D. Input và HUD

Mục tiêu: nút Flutter đổi hướng chuyển động; HUD hiển thị tọa độ. Chỉ `Drive` ghi vị trí actor trong mốc này.

Tiền đề: giữ source A–C và host chung. Không import physics.

Tệp `lib/checkpoints/d/main.dart`:

```dart
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
```

Lệnh đề nghị:

```powershell
flutter analyze lib/checkpoints/d/main.dart
flutter run --target lib/checkpoints/d/main.dart
```

Kết quả dự kiến: chọn hướng làm actor chuyển động đến biên `[-2, 2]`; nút Dừng đặt vận tốc điều khiển về 0. Nút là chế độ chọn hướng, chưa phải nhấn giữ hoặc joystick đa chạm.

HUD được cập nhật qua notifier; không dựng Scene mới mỗi frame. Nếu vị trí không đổi, kiểm tra direction, lifecycle component và phép gán `node.position`.

Tốc độ 1.2 đơn vị/giây chưa phải tốc độ người chơi của game.

## E. Trigger

Mục tiêu: thêm vùng giao nhau và đếm số lần actor đi vào. Actor đổi từ hộp sang cầu để hình học và collider cùng bán kính.

Tiền đề: D đã được kiểm tra. Backend chỉ là `BasicSimulation`, không cần Rapier và không mô phỏng bật nảy.

Tệp `lib/checkpoints/e/main.dart`:

```dart
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
```

Lệnh đề nghị:

```powershell
flutter analyze lib/checkpoints/e/main.dart
flutter run --target lib/checkpoints/e/main.dart
```

Kết quả dự kiến: cầu đi xuyên hộp xanh; counter tăng khi bắt đầu vào vùng, giữ nguyên khi đứng trong vùng, tăng tiếp sau khi ra rồi vào lại.

`CuboidGeometry` dùng kích thước đầy đủ; `BoxShape` dùng half extents. Hai bộ số trong code mô tả cùng thể tích.

`BasicSimulation` chỉ hỗ trợ query/trigger và chuyển động kinematic; không có solver, contact response hoặc dynamic body. Không gọi counter này là điểm bóng rổ. Không chọn fixed timestep hoặc solver của toàn game từ mốc này.

Nếu không có event, kiểm tra PhysicsWorld ở ancestor, collider và thể tích giao nhau. Actor được Drive di chuyển theo frame; pose kinematic được đưa vào bước vật lý, nên không mặc định event xảy ra đúng frame nút được nhấn.

## F. Texture, model và animation

Mục tiêu: thêm texture tạo từ dữ liệu trước; sau đó bật nhánh model/texture ngoài khi có asset thật. Không cần đợi asset để analyze F hoặc kiểm tra nhánh mặc định.

Tiền đề: A–E và host đã tồn tại. Không import helper khác; hàm nạp asset được định nghĩa ngay trong checkpoint F.

Tệp `lib/checkpoints/f/main.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../../lesson_host.dart';
import '../e/main.dart' as e;

void main() => startLesson(buildLesson);

Future<Lesson> buildLesson(fs.Scene scene) async {
  final lesson = e.buildLesson(scene);
  try {
    lesson.material
      ..baseColorFactor = vm.Vector4(1, 1, 1, 1)
      ..baseColorTexture = fs.Texture2D.fromPixels(
        Uint8List.fromList([
          240, 120, 30, 255, 80, 30, 10, 255,
          80, 30, 10, 255, 240, 120, 30, 255,
        ]),
        2,
        2,
      );
    await loadAssets(lesson);
    return lesson;
  } catch (_) {
    lesson.close();
    rethrow;
  }
}

Future<void> loadAssets(Lesson lesson) async {
  const texturePath = String.fromEnvironment('TEXTURE_ASSET');
  const modelPath = String.fromEnvironment('MODEL_ASSET');
  const clipName = String.fromEnvironment('CLIP_NAME');

  if (clipName.isNotEmpty && modelPath.isEmpty) {
    throw StateError('CLIP_NAME cần MODEL_ASSET.');
  }
  if (texturePath.isNotEmpty) {
    lesson.material.baseColorTexture = await fs.Texture2D.fromAsset(
      texturePath,
      maxSize: 1024,
    );
  }
  if (modelPath.isEmpty) return;

  final model = await fs.Node.fromGlbAsset(
    modelPath,
    maxTextureSize: 1024,
  );
  model.position = vm.Vector3(-1, 0, 1);
  lesson.root.add(model);

  final animations = model.parsedAnimations;
  if (animations.isEmpty) {
    if (clipName.isNotEmpty) {
      throw StateError('Model không chứa animation.');
    }
    return;
  }

  final animation = clipName.isEmpty
      ? animations.first
      : model.findAnimationByName(clipName);
  if (animation == null) {
    throw StateError('Không tìm thấy clip: $clipName');
  }

  final clip = model.createAnimationClip(animation)
    ..loop = true
    ..playbackTimeScale = 1;
  clip.play();
}
```

Lệnh cho nhánh không cần asset:

```powershell
flutter analyze lib/checkpoints/f/main.dart
flutter run --target lib/checkpoints/f/main.dart
```

Kết quả dự kiến: actor có texture bốn pixel; các hành vi input/trigger của E giữ nguyên.

Khi Lead đã chọn sample chính thức, kiểm tra license, lưu URL/version và khai báo đúng tệp trong `pubspec.yaml`. Ví dụ, chỉ khi các tệp thực sự tồn tại:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/model.glb
    - assets/surface.png
```

Lệnh đề nghị cho từng nhánh:

```powershell
flutter run --target lib/checkpoints/f/main.dart --dart-define=MODEL_ASSET=assets/model.glb
```

```powershell
flutter run --target lib/checkpoints/f/main.dart --dart-define=TEXTURE_ASSET=assets/surface.png
```

Chỉ truyền `CLIP_NAME` sau khi đã đọc tên clip thực từ:

```dart
model.parsedAnimations.map((animation) => animation.name).toList()
```

Không giả định model có clip `Idle`. Khi không truyền tên, code chọn clip đầu tiên nếu có; model không có animation được hiển thị tĩnh.

Giới hạn 1024 là tham số minh họa giới hạn texture khi nạp, không phải ngân sách bộ nhớ đã đo. Placement model còn phụ thuộc đơn vị, gốc tọa độ và kích thước sample; không khẳng định mọi model sẽ vừa camera với vị trí mặc định.

Nếu load lỗi, kiểm tra asset bundle, định dạng, warning importer và tên clip. Không sửa A–E để che lỗi của asset F.

## Bổ sung: snapshot → node cho hai client

Phần này là nhánh riêng sau các checkpoint; không gắn adapter vào actor đang được Drive điều khiển ở D–F.

### Tiền đề và quyền ghi vị trí

Giữ `tool/sync_smoke.dart` của R2 làm tiền đề transport riêng. Nó kiểm tra loopback, input trùng và ack; chưa kiểm tra snapshot áp vào node.

Snapshot adapter dưới đây dùng node mới không có Drive hoặc RigidBody. Trong suốt thời gian nhận snapshot, adapter là nơi duy nhất gán `node.position`. Node có parent identity hoặc không có parent; tọa độ snapshot được hiểu là tọa độ cục bộ tương ứng. Nếu parent có transform, phải bổ sung chuyển đổi tọa độ thay vì gán world position trực tiếp.

Envelope minh họa:

```json
{
  "schema": 1,
  "session": "session-test-1",
  "entity": "ball",
  "tick": 3,
  "x": 3.0,
  "y": 0.35,
  "z": 0.0
}
```

`session` là định danh phiên mô phỏng được xác nhận khi tham gia phiên, không phải credential. Không lấy session của một packet bất kỳ làm session tin cậy. Ví dụ này chưa triển khai handshake/xác thực.

### Source adapter

Tệp `lib/snapshot_replica.dart`:

```dart
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

class SnapshotReplica {
  SnapshotReplica({
    required this.node,
    required this.session,
    this.entity = 'ball',
  }) {
    if (session.isEmpty) {
      throw ArgumentError.value(session, 'session');
    }
  }

  final fs.Node node;
  final String session;
  final String entity;
  int _lastTick = -1;
  bool _closed = false;

  int get lastTick => _lastTick;

  bool apply(Object? raw) {
    if (_closed || raw is! Map) return false;
    if (raw['schema'] != 1 ||
        raw['session'] != session ||
        raw['entity'] != entity) {
      return false;
    }

    final tick = raw['tick'];
    if (tick is! int || tick < 0 || tick <= _lastTick) {
      return false;
    }

    final x = raw['x'];
    final y = raw['y'];
    final z = raw['z'];
    if (x is! num || y is! num || z is! num) {
      return false;
    }

    final px = x.toDouble();
    final py = y.toDouble();
    final pz = z.toDouble();
    if (!px.isFinite || !py.isFinite || !pz.isFinite) {
      return false;
    }

    // Chỉ ghi sau khi toàn bộ envelope đã hợp lệ.
    node.position = vm.Vector3(px, py, pz);
    _lastTick = tick;
    return true;
  }

  void close() {
    _closed = true;
  }
}
```

Packet sai phiên, sai entity/schema, dữ liệu không hữu hạn, trùng tick hoặc cũ hơn đều bị bỏ trước khi đổi vị trí. Không cập nhật `_lastTick` cho packet bị từ chối.

Khi reconnect cùng phiên, giữ adapter và last tick nếu giao thức yêu cầu chống replay xuyên kết nối. Khi server mở một phiên mô phỏng mới, hủy subscription/adapter cũ rồi tạo adapter với session mới. Đây là yêu cầu tích hợp cần thiết kế, chưa phải reconnect hoàn chỉnh.

Adapter không nội suy hoặc prediction; nó minh họa áp trạng thái trực tiếp.

### Test headless đề nghị cho hai client

Thêm dev dependency nếu chưa có:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

Tệp `test/snapshot_replica_test.dart` sau là source mới, chưa chạy. Test dùng hai WebSocket client loopback và hai `fs.Node` không có mesh/Scene; không tạo GPU context hoặc SceneView.

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scene/scene.dart' as fs;

import '../lib/snapshot_replica.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Hai client ap snapshot va bo packet cu/sai phien', () async {
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final peers = <WebSocket>[];
    final clients = <WebSocket>[];
    final subscriptions = <StreamSubscription<dynamic>>[];
    final connected = Completer<void>();

    final serverSubscription = server.listen((request) async {
      final peer = await WebSocketTransformer.upgrade(request);
      peers.add(peer);
      // Tiêu thụ stream để xử lý vòng đời socket.
      subscriptions.add(peer.listen((dynamic _) {}));
      if (peers.length == 2 && !connected.isCompleted) {
        connected.complete();
      }
    });

    final nodes = [fs.Node(), fs.Node()];
    final replicas = [
      for (final node in nodes)
        SnapshotReplica(node: node, session: 's1'),
    ];

    Map<String, Object> packet(
      int tick,
      double x, {
      String session = 's1',
    }) => {
      'schema': 1,
      'session': session,
      'entity': 'ball',
      'tick': tick,
      'x': x,
      'y': 0.35,
      'z': 0.0,
    };

    final packets = [
      packet(1, 1),
      packet(1, 99),                  // Trùng.
      packet(99, 99, session: 's0'), // Sai phiên.
      packet(3, 3),
      packet(2, 2),                  // Đến muộn.
    ];

    final positions = [<double>[], <double>[]];
    final ticks = [<int>[], <int>[]];
    final accepted = [<bool>[], <bool>[]];
    final done = [Completer<void>(), Completer<void>()];

    try {
      final uri = 'ws://127.0.0.1:${server.port}';
      clients.add(await WebSocket.connect(uri));
      clients.add(await WebSocket.connect(uri));
      await connected.future.timeout(const Duration(seconds: 5));

      for (var i = 0; i < clients.length; i++) {
        final index = i;
        subscriptions.add(clients[index].listen(
          (dynamic message) {
            try {
              final raw = jsonDecode(message as String);
              accepted[index].add(replicas[index].apply(raw));
              positions[index].add(nodes[index].position.x);
              ticks[index].add(replicas[index].lastTick);
              if (positions[index].length == packets.length &&
                  !done[index].isCompleted) {
                done[index].complete();
              }
            } catch (error, stack) {
              if (!done[index].isCompleted) {
                done[index].completeError(error, stack);
              }
            }
          },
          onError: (Object error, StackTrace stack) {
            if (!done[index].isCompleted) {
              done[index].completeError(error, stack);
            }
          },
          onDone: () {
            if (!done[index].isCompleted) {
              done[index].completeError(
                StateError('Socket dong truoc khi du snapshot'),
              );
            }
          },
        ));
      }

      for (final packet in packets) {
        final encoded = jsonEncode(packet);
        for (final peer in peers) {
          peer.add(encoded);
        }
      }

      await Future.wait(done.map((item) => item.future))
          .timeout(const Duration(seconds: 5));

      for (var i = 0; i < replicas.length; i++) {
        expect(accepted[i], [true, false, false, true, false]);
        expect(positions[i], [1.0, 1.0, 1.0, 3.0, 3.0]);
        expect(ticks[i], [1, 1, 1, 3, 3]);
        expect(nodes[i].position.y, closeTo(0.35, 1e-9));

        final invalid = packet(4, 4)..['z'] = double.nan;
        expect(replicas[i].apply(invalid), isFalse);
        expect(replicas[i].lastTick, 3);
        expect(nodes[i].position.x, 3.0);

        final wrongEntity = packet(4, 4)..['entity'] = 'other';
        expect(replicas[i].apply(wrongEntity), isFalse);
        expect(replicas[i].lastTick, 3);

        replicas[i].close();
        expect(replicas[i].apply(packet(4, 4)), isFalse);
      }
    } finally {
      for (final replica in replicas) {
        replica.close();
      }
      await Future.wait([
        for (final socket in [...clients, ...peers])
          socket.close(),
      ]).timeout(const Duration(seconds: 5));
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await serverSubscription.cancel();
      await server.close(force: true);
    }
  });
}
```

Test kiểm tra lịch sử sau từng packet, không chỉ vị trí cuối. Nhờ đó, một packet sai phiên làm nhảy node rồi bị snapshot sau sửa lại vẫn bị phát hiện.

Lệnh đề nghị:

```powershell
flutter analyze lib/snapshot_replica.dart test/snapshot_replica_test.dart
flutter test test/snapshot_replica_test.dart
```

Kết quả kỳ vọng: cả hai replica có lịch sử x `[1, 1, 1, 3, 3]`, last tick `[1, 1, 1, 3, 3]`; packet không hợp lệ không đổi node. Đây là tiêu chí test đề nghị, chưa phải kết quả thực chạy.

Test không có render, input từ người chơi, mô phỏng authoritative, hai Android, TLS hoặc Internet. Transport và snapshot schema ở đây không chốt kiến trúc mạng game.

## Hướng dẫn tích hợp và ghi bằng chứng

Lead có thể lưu source mới theo đúng cây tệp trên, rồi kiểm tra từng checkpoint:

```powershell
flutter analyze lib/lesson_host.dart lib/checkpoints/a/main.dart
flutter analyze lib/checkpoints/b/main.dart
flutter analyze lib/checkpoints/c/main.dart
flutter analyze lib/checkpoints/d/main.dart
flutter analyze lib/checkpoints/e/main.dart
flutter analyze lib/checkpoints/f/main.dart
```

Các lệnh chỉ là kế hoạch kiểm tra. Sau mỗi lệnh thực chạy, ghi riêng:

```text
command | PASS/FAIL và exit code | đường dẫn log đã lọc
```

Không gán kết quả R2 cho các checkpoint R3. Các source mới đã thay đổi cách tổ chức, khởi tạo và vòng đời nên cần analyze riêng.

Khi đưa vào 2.12:

1. Giới thiệu host và điều kiện chung.
2. Trình bày A–F theo thứ tự mục tiêu → thay đổi → source → lệnh → dấu hiệu đúng/lỗi.
3. Đặt nhánh snapshot sau tiền đề transport smoke.
4. Để đường dẫn log, lịch sử review và checklist tích hợp ngoài manuscript.
5. Giữ nguyên Word v0.3/v0.4; v0.5 chỉ tạo sau tích hợp và QA.

## Báo cáo kết thúc

- Sản phẩm bàn giao: host chung, sáu source checkpoint A–F, adapter snapshot, test headless hai client và hướng dẫn tích hợp.
- Bằng chứng: đọc source R2 thực tế, lock/config và evidence; đối chiếu API Scene 0.24.3. Không chạy gate mới; `logpath: none`.
- Điểm chưa rõ: kết quả analyze/test R3, render Android, sample GLB chính thức và nhánh asset runtime; chưa kiểm tra Internet.
- Bước tiếp theo: Lead lưu source, analyze từng mốc và chạy test headless đề nghị, sửa theo log thực rồi tích hợp hướng dẫn vào v0.5.
