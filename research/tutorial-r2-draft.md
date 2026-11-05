## 2.12 Hướng dẫn xây dựng một cảnh mẫu xuyên suốt

### 2.12.1 Mục tiêu và điều kiện thực hiện

Ví dụ xây dựng một cảnh nhỏ gồm mặt nền, quả cầu di chuyển, khối hộp quay, nguồn sáng và vùng phát hiện giao nhau. Giao diện Flutter cung cấp nút điều khiển và hiển thị vị trí quả cầu. Các bước sau bổ sung mô hình GLB, hoạt ảnh và chương trình kiểm tra đồng bộ cục bộ trong cùng project.

Ví dụ minh họa cách kết hợp các thành phần; chưa xây dựng luật bóng rổ, phòng đấu, prediction hoặc kết nối Internet.

Bộ phiên bản tham chiếu lấy từ lockfile của probe R1:

| Thành phần | Phiên bản |
|---|---|
| Flutter | 3.47.8 stable |
| Dart | 3.13.7 |
| `flutter_scene` | 0.24.3 |
| `scene` | 0.4.1, dependency gián tiếp |
| `vector_math` | 2.4.4 |

Máy phát triển cần Flutter và Android toolchain hoạt động. Muốn quan sát cảnh trên điện thoại phải có Android được Flutter nhận diện và hỗ trợ backend đồ họa cần thiết. Analyze hoặc build bundle không thay cho việc chạy cảnh trên thiết bị.

Trạng thái kiểm chứng: probe R1 với khối hộp đơn giản đã qua analyze và build bundle. Mã mở rộng trong hướng dẫn này mới được đối chiếu với source package, chưa analyze, build hoặc chạy.

### 2.12.2 Tạo project và bật Flutter GPU

Tạo project riêng để giữ nguyên probe và bằng chứng cũ. Các lệnh dưới đây dành cho lần thực hiện sau, chưa chạy trong lượt soạn hướng dẫn:

```powershell
flutter create --platforms=android --project-name=scene_tutorial_r2 game/tutorial-r2
Set-Location game/tutorial-r2
```

Thay `pubspec.yaml` bằng:

```yaml
name: scene_tutorial_r2
description: Vi du hoc Flutter Scene, khong phai game hoan chinh.
publish_to: none

environment:
  sdk: '>=3.13.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_scene: 0.24.3
  vector_math: 2.4.4

flutter:
  uses-material-design: true
```

Chạy:

```powershell
flutter pub get
```

Kiểm tra `pubspec.lock`: Scene phải là 0.24.3 và `vector_math` là 2.4.4. Dependency gián tiếp có thể thay đổi khi resolve mới; muốn tái lập toàn bộ bộ dependency R1 cần dùng lockfile R1 làm cơ sở và kiểm tra diff sau resolve. Không khẳng định cùng bộ dependency chỉ từ hai dòng ghim phiên bản trực tiếp.

Trong `android/app/src/main/AndroidManifest.xml`, thêm metadata vào bên trong `<application>` hiện có:

```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableFlutterGPU"
    android:value="true" />
```

Không tạo thêm một phần tử `<application>` thứ hai. Metadata này thuộc cấu hình Android; bật Impeller không tự thay thế bước bật Flutter GPU.

README của package 0.24.3 cũng cung cấp cách bật khi chạy phát triển:

```powershell
flutter run --enable-flutter-gpu
```

Trong project mẫu đã cấu hình manifest, có thể dùng `flutter run` và chọn đúng Android. Chưa thực hiện lệnh chạy trên điện thoại trong hướng dẫn này.

Dấu hiệu đúng: resolve dependency hoàn tất; manifest có metadata đúng vị trí. Việc xác nhận GPU hoạt động còn cần lần chạy thực tế.

### 2.12.3 Tổ chức tệp của ví dụ

Project sử dụng các tệp sau:

```text
lib/
  main.dart
  assets_step.dart
tool/
  sync_smoke.dart
assets/                 chỉ thêm khi có asset thật
  model.glb
  surface.png
```

`main.dart` chứa cảnh, component và giao diện. `assets_step.dart` là bước nạp tài nguyên tùy chọn. `tool/sync_smoke.dart` sử dụng nguyên chương trình smoke R1, không đưa một server thử nghiệm vào ứng dụng Android.

Tên `model.glb` và `surface.png` là tên quy ước cần cung cấp, không phải các tệp đã có trong repository.

### 2.12.4 Dựng scene, node, mesh và component

Lưu nội dung sau vào `lib/main.dart`. Toàn bộ mã mới dưới đây chưa được analyze/build.

```dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:flutter_scene/physics.dart' as ph;
import 'package:vector_math/vector_math.dart' as vm;

import 'assets_step.dart';

void main() {
  runApp(const MaterialApp(home: TutorialPage()));
}

fs.PhysicallyBasedMaterial makeMaterial(vm.Vector4 color) {
  return fs.PhysicallyBasedMaterial()
    ..baseColorFactor = color
    ..metallicFactor = 0.0
    ..roughnessFactor = 0.7;
}

class DriveComponent extends fs.Component {
  DriveComponent(this.onChanged);

  final VoidCallback onChanged;
  double direction = 0.0;

  @override
  void update(double deltaSeconds) {
    final dt = deltaSeconds.clamp(0.0, 0.05).toDouble();
    final p = node.position;
    final x = (p.x + direction * 1.2 * dt)
        .clamp(-2.0, 2.0)
        .toDouble();

    node.position = vm.Vector3(x, p.y, p.z);
    onChanged();
  }
}

class SpinComponent extends fs.Component {
  double angle = 0.0;

  @override
  void update(double deltaSeconds) {
    final dt = deltaSeconds.clamp(0.0, 0.05).toDouble();
    angle += 0.8 * dt;
    node.rotation = vm.Quaternion.axisAngle(
      vm.Vector3(0.0, 1.0, 0.0),
      angle,
    );
  }
}

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  fs.Scene? _scene;
  fs.Node? _world;
  fs.Node? _ball;
  DriveComponent? _drive;

  final ValueNotifier<String> _hud =
      ValueNotifier<String>('Đang khởi tạo');

  StreamSubscription<ph.CollisionEvent>? _collisionSubscription;
  late final Future<void> _ready;
  int _entries = 0;

  @override
  void initState() {
    super.initState();
    _ready = _initialize();
  }

  Future<void> _initialize() async {
    await fs.Scene.initializeStaticResources();
    if (!mounted) return;

    final physics = ph.PhysicsWorld(ph.BasicSimulation());
    final world = fs.Node(name: 'world')
      ..addComponent(physics);

    final floor = fs.Node(
      name: 'floor',
      mesh: fs.Mesh(
        fs.CuboidGeometry(vm.Vector3(5.0, 0.1, 3.0)),
        makeMaterial(vm.Vector4(0.25, 0.35, 0.3, 1.0)),
      ),
    )..position = vm.Vector3(0.0, -0.05, 0.0);
    world.add(floor);

    final checker = fs.Texture2D.fromPixels(
      Uint8List.fromList([
        240, 120, 30, 255,
        80, 30, 10, 255,
        80, 30, 10, 255,
        240, 120, 30, 255,
      ]),
      2,
      2,
    );

    final ballMaterial =
        makeMaterial(vm.Vector4(1.0, 1.0, 1.0, 1.0))
          ..baseColorTexture = checker;

    final ball = fs.Node(
      name: 'ball',
      mesh: fs.Mesh(
        fs.SphereGeometry(
          radius: 0.25,
          segments: 24,
          rings: 12,
        ),
        ballMaterial,
      ),
    )..position = vm.Vector3(-1.5, 0.35, 0.0);

    ball.addComponent(ph.RigidBody(
      type: ph.BodyType.kinematic,
      useGravity: false,
    ));
    ball.addComponent(ph.Collider(
      shape: const ph.SphereShape(radius: 0.25),
    ));

    final drive = DriveComponent(_refreshHud);
    ball.addComponent(drive);
    world.add(ball);

    final gate = fs.Node(
      name: 'gate',
      mesh: fs.Mesh(
        fs.CuboidGeometry(vm.Vector3(0.3, 0.7, 0.7)),
        makeMaterial(vm.Vector4(0.2, 0.5, 0.9, 1.0)),
      ),
    )..position = vm.Vector3(0.0, 0.35, 0.0);

    gate.addComponent(ph.Collider(
      shape: ph.BoxShape(
        halfExtents: vm.Vector3(0.15, 0.35, 0.35),
      ),
      isTrigger: true,
    ));
    world.add(gate);

    final pivot = fs.Node(name: 'pivot')
      ..position = vm.Vector3(0.0, 1.2, 1.0)
      ..scale = vm.Vector3(1.0, 0.7, 1.0)
      ..addComponent(SpinComponent());

    pivot.add(fs.Node(
      name: 'orbitingCube',
      mesh: fs.Mesh(
        fs.CuboidGeometry(vm.Vector3(0.4, 0.4, 0.4)),
        makeMaterial(vm.Vector4(0.8, 0.7, 0.2, 1.0)),
      ),
    )..position = vm.Vector3(0.6, 0.0, 0.0));
    world.add(pivot);

    final lamp = fs.Node(name: 'lamp')
      ..position = vm.Vector3(-2.0, 3.0, -2.0)
      ..addComponent(fs.PointLightComponent(
        fs.PointLight(
          intensity: 25.0,
          range: 10.0,
          castsShadow: false,
        ),
      ));
    world.add(lamp);

    await addOptionalAssets(world, ballMaterial);
    if (!mounted) {
      physics.simulation.dispose();
      return;
    }

    final scene = fs.Scene();
    _scene = scene;
    _world = world;
    _ball = ball;
    _drive = drive;

    _collisionSubscription = physics.collisions.listen((event) {
      if (!mounted || event is! ph.TriggerEntered) return;

      final matches =
          (identical(event.nodeA, ball) &&
              identical(event.nodeB, gate)) ||
          (identical(event.nodeA, gate) &&
              identical(event.nodeB, ball));

      if (matches) {
        _entries++;
        _refreshHud();
      }
    });

    scene.add(world);
    _refreshHud();
  }

  void _refreshHud() {
    if (!mounted || _ball == null) return;
    final x = _ball!.position.x.toStringAsFixed(2);
    _hud.value = 'x = $x | Số lần vào vùng: $_entries';
  }

  @override
  void dispose() {
    final subscription = _collisionSubscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    // Gỡ con trước để hủy body/collider trước physics world.
    _world?.removeAll();
    final world = _world;
    if (world != null) _scene?.remove(world);
    _scene?.dispose();
    _hud.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Không thể khởi tạo cảnh: ${snapshot.error}',
              ),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final scene = _scene;
          if (scene == null) {
            return const SizedBox.shrink();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              fs.SceneView(
                scene,
                camera: fs.PerspectiveCamera(
                  position: vm.Vector3(3.0, 3.0, -6.0),
                  target: vm.Vector3(0.0, 0.5, 0.0),
                  fovNear: 0.1,
                  fovFar: 50.0,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: _hud,
                      builder: (context, value, child) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(value),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _drive?.direction = -1.0;
                          },
                          child: const Text('Trái'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _drive?.direction = 0.0;
                          },
                          child: const Text('Dừng'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _drive?.direction = 1.0;
                          },
                          child: const Text('Phải'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

Ở bước chưa dùng asset ngoài, tạo `lib/assets_step.dart` với nội dung đầy đủ ở mục 2.12.9. Khi không truyền tham số asset, hàm đó không nạp tệp nào.

### 2.12.5 Quan sát cấu trúc node và transform

Scene chứa node `world`. Node này chứa nền, quả cầu, vùng trigger, nguồn sáng và node `pivot`. Khối hộp `orbitingCube` là con của `pivot`; vị trí `(0.6, 0, 0)` của nó được hiểu trong hệ tọa độ của cha.

`SpinComponent` thay đổi rotation của `pivot`. Vì vậy, khối hộp vừa nhận biến đổi quay của cha, vừa giữ độ lệch cục bộ. Scale `(1, 0.7, 1)` của cha làm thay đổi hình dạng hiển thị của node con. Quan sát này giúp phân biệt biến đổi cục bộ với vị trí cuối cùng trong cảnh.

Trong Scene 0.24.3, getter `position`, `rotation` và `scale` trả bản sao. Cách cập nhật đúng là gán lại:

```dart
final p = node.position;
node.position = vm.Vector3(p.x + 0.1, p.y, p.z);
```

Không dùng cách sau:

```dart
node.position.x += 0.1;
```

Mã sau chỉ sửa đối tượng được trả về; source còn có kiểm tra debug phát hiện việc sửa transform thông qua bản sao.

Dấu hiệu cần quan sát khi chạy: khối hộp chuyển động quanh pivot, không quay cùng một vị trí như khi đặt hộp trực tiếp ở tâm. Đây là kết quả dự kiến, chưa phải quan sát thực nghiệm.

### 2.12.6 Mesh, material và texture

Mesh kết hợp hình học và vật liệu:

```dart
fs.Mesh(
  fs.SphereGeometry(radius: 0.25),
  fs.PhysicallyBasedMaterial(),
)
```

Trong ví dụ, `SphereGeometry` dùng bán kính 0.25, 24 segment và 12 ring. Các giá trị này chỉ xác định độ phân giải hình học của ví dụ, chưa được chọn theo phép đo trên Redmi Note 11.

Hàm `makeMaterial` đặt:

- `baseColorFactor`: màu RGBA nhân với màu texture.
- `metallicFactor = 0`: vật liệu phi kim.
- `roughnessFactor = 0.7`: độ nhám của bề mặt.

`baseColorFactor` được đặt trắng cho quả cầu để không làm lệch màu texture. Texture mặc định gồm bốn pixel RGBA8888, được tạo bởi `Texture2D.fromPixels`. Bước này không cần tải ảnh hoặc giả định asset đã có.

Nền là khối hộp dày 0.1, đặt tâm ở `y = -0.05`; mặt trên nằm tại `y = 0`. Quả cầu có tâm ở `y = 0.35`, nên đáy nằm cao hơn nền 0.1 đơn vị. Không có trọng lực hoặc cơ chế giữ bóng trên nền trong ví dụ này.

Dấu hiệu cần quan sát: quả cầu có biến thiên màu từ texture, khối hộp và nền có màu vật liệu khác nhau. Không thấy texture có thể do camera quá xa, texture rất nhỏ hoặc điều kiện ánh sáng; cần kiểm tra trên thiết bị trước khi kết luận.

### 2.12.7 Camera và nguồn sáng

Camera trong ví dụ đặt tại `(3, 3, -6)`, nhìn về `(0, 0.5, 0)`. Các tham số `fovNear` và `fovFar` lần lượt là khoảng cắt gần và xa, không phải vị trí camera.

```dart
fs.PerspectiveCamera(
  position: vm.Vector3(3, 3, -6),
  target: vm.Vector3(0, 0.5, 0),
  fovNear: 0.1,
  fovFar: 50,
)
```

`SceneView` chỉ nhận một trong các lựa chọn `camera`, `cameraBuilder` hoặc `viewsBuilder`. Ví dụ dùng camera cố định.

Nguồn sáng được gắn qua component:

```dart
final lamp = fs.Node()
  ..position = vm.Vector3(-2, 3, -2)
  ..addComponent(fs.PointLightComponent(
    fs.PointLight(intensity: 25, range: 10),
  ));
```

Vị trí của PointLight lấy từ world transform của node sở hữu. Thay đổi vị trí node sẽ di chuyển nguồn sáng. Cường độ 25 và tầm ảnh hưởng 10 là giá trị minh họa, không phải thông số đã hiệu chỉnh cho game.

Ví dụ tắt bóng đổ để giảm số biến cần kiểm tra. Không lấy cảnh chưa bật shadow để kết luận hiệu năng khi game có shadow.

### 2.12.8 Vòng lặp, nhập liệu và HUD

`SceneView` sở hữu ticker và quá trình vẽ cảnh. Các component ghi đè `update(double deltaSeconds)` để cập nhật hành vi theo thời gian.

`DriveComponent` tính quãng đường bằng tốc độ nhân thời gian:

```dart
final x = p.x + direction * 1.2 * dt;
```

Ba nút Flutter thay đổi `direction` thành −1, 0 hoặc 1. Nút “Trái” và “Phải” làm quả cầu tiếp tục di chuyển đến khi chọn “Dừng” hoặc chạm biên, không phải cơ chế nhấn giữ.

Ví dụ giới hạn:

- Tốc độ: 1.2 đơn vị cảnh/giây.
- Biên di chuyển: `[-2, 2]`.
- Delta dùng cho chuyển động minh họa: tối đa 0.05 giây.

Giới hạn delta ngăn một bước chuyển động quá lớn sau khung hình chậm, nhưng làm chuyển động mất một phần thời gian khi bị chậm lâu. Đây không phải giải pháp đồng bộ thời gian cho multiplayer.

HUD dùng `ValueNotifier` và `ValueListenableBuilder`. Thay đổi giá trị chỉ xây dựng lại phần văn bản theo dõi; không tạo Scene mới ở mỗi frame.

Không đồng thời thêm ticker riêng để gọi `scene.update` mà vẫn để cơ chế cập nhật tự động hoạt động không kiểm soát. Nếu cần chủ động timestep, phải thiết kế rõ một nơi duy nhất chịu trách nhiệm cập nhật cảnh.

Dấu hiệu cần quan sát: chọn hướng làm tọa độ x đổi, chọn “Dừng” giữ vị trí; counter chỉ đổi khi đi vào vùng trigger. Việc ứng dụng trở lại foreground và điều khiển đa chạm chưa được xử lý trong ví dụ.

### 2.12.9 Nạp model, texture ngoài và animation

Để sử dụng asset ngoài, cần chuẩn bị thực tế:

1. Một GLB hợp lệ, có quyền sử dụng và ghi nguồn.
2. Nếu thử animation, GLB phải chứa ít nhất một animation clip.
3. Nếu thử texture ảnh riêng, cần tệp PNG/JPEG đọc được và có giấy phép phù hợp.

Có thể tự tạo model/animation bằng công cụ dựng hình và xuất GLB. Hướng dẫn không giả định đã có nhân vật, tên clip `Idle` hoặc bộ tài nguyên được tải về.

Chỉ sau khi có tệp thật, thêm đường dẫn vào `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/model.glb
    - assets/surface.png
```

Nếu chỉ có model thì chỉ khai báo model. Không khai báo các tệp chưa tồn tại vì Flutter sẽ báo lỗi asset.

Nội dung `lib/assets_step.dart`:

```dart
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

const modelAsset = String.fromEnvironment('MODEL_ASSET');
const textureAsset = String.fromEnvironment('TEXTURE_ASSET');
const clipName = String.fromEnvironment('CLIP_NAME');

Future<void> addOptionalAssets(
  fs.Node world,
  fs.PhysicallyBasedMaterial ballMaterial,
) async {
  if (textureAsset.isNotEmpty) {
    ballMaterial.baseColorTexture = await fs.Texture2D.fromAsset(
      textureAsset,
      maxSize: 1024,
    );
  }

  if (modelAsset.isEmpty) return;

  final model = await fs.Node.fromGlbAsset(
    modelAsset,
    maxTextureSize: 1024,
  );

  model.position = vm.Vector3(-1.0, 0.0, 1.0);
  model.scale = vm.Vector3(1.0, 1.0, 1.0);
  world.add(model);

  final animations = model.parsedAnimations;
  if (animations.isEmpty) {
    if (clipName.isNotEmpty) {
      throw StateError(
        'Có yêu cầu clip nhưng GLB không chứa animation.',
      );
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
    ..playbackTimeScale = 1.0;

  clip.play();
}
```

Các lệnh chạy dự kiến:

```powershell
flutter run --dart-define=MODEL_ASSET=assets/model.glb
```

```powershell
flutter run --dart-define=MODEL_ASSET=assets/model.glb --dart-define=CLIP_NAME=TenClipThucTe
```

```powershell
flutter run --dart-define=TEXTURE_ASSET=assets/surface.png
```

`TenClipThucTe` phải lấy từ model. Có thể xem danh sách tên trong debugger qua:

```dart
model.parsedAnimations.map((animation) => animation.name).toList()
```

Khi không truyền `CLIP_NAME`, ví dụ chọn animation đầu tiên nếu có. Khi không có animation và cũng không yêu cầu tên clip, model được hiển thị tĩnh.

`createAnimationClip` tạo clip ở trạng thái dừng; `play()` bắt đầu phát. Các API điều khiển đã có trong source:

```dart
clip.pause(); // Giữ thời điểm hiện tại.
clip.play();  // Tiếp tục phát.
clip.stop();  // Dừng và trở về đầu.
```

Scene cập nhật animation player trong vòng lặp của nó; không tự gọi thêm một animation ticker cho clip này.

Giá trị 1024 giới hạn kích thước texture khi nạp, không phải ngân sách bộ nhớ đã được đo. Model có kích thước hoặc gốc tọa độ khác sẽ cần chỉnh placement, scale hoặc camera. Không dùng một scale tùy ý để kết luận model đã hiển thị đúng đơn vị.

Trạng thái kiểm chứng: đã đối chiếu chữ ký `fromGlbAsset`, `fromAsset`, `parsedAnimations`, `findAnimationByName`, `createAnimationClip` và điều khiển clip trong source 0.24.3; chưa có asset để kiểm tra nhánh này.

### 2.12.10 Vật lý và phát hiện giao nhau

Ví dụ import phần vật lý riêng:

```dart
import 'package:flutter_scene/physics.dart' as ph;
```

`PhysicsWorld` quản lý subtree. `RigidBody` của quả cầu có loại `kinematic`, còn `Collider` xác định thể tích hình cầu. Vùng `gate` có collider hình hộp với `isTrigger: true`.

```dart
final world = fs.Node()
  ..addComponent(ph.PhysicsWorld(ph.BasicSimulation()));
```

`BasicSimulation` trong `scene` 0.4.1 hỗ trợ truy vấn và trigger cho chuyển động kinematic. Source nêu rõ backend này không có solver, contact response hoặc joints; tạo dynamic body không phải cách mô phỏng bóng rơi bằng backend này.

Do đó, hành vi dự kiến của ví dụ là:

- Quả cầu đi xuyên vùng hộp.
- `TriggerEntered` phát ra khi bắt đầu giao nhau.
- Counter tăng một lần khi vào vùng, không tăng liên tục khi còn ở trong.
- Ra khỏi vùng rồi quay lại có thể tạo lần vào tiếp theo.

Vùng trigger trong ví dụ có mesh hộp đục để nhìn thấy vị trí. Sự che khuất một phần quả cầu là kết quả vẽ hình học, không phải phản lực va chạm.

Kích thước `CuboidGeometry` là kích thước đầy đủ, còn `BoxShape` dùng `halfExtents`; vì vậy hộp `(0.3, 0.7, 0.7)` tương ứng half extents `(0.15, 0.35, 0.35)`.

Component di chuyển cập nhật theo frame; body kinematic chuyển pose sang mô phỏng ở bước vật lý. Không mặc định event và HUD xuất hiện đúng cùng một frame với thao tác nút.

Counter này chỉ đếm sự kiện vào thể tích, chưa phải tính điểm bóng rổ. Ghi điểm qua rổ còn cần xác định hướng đi qua, thứ tự giao cắt, trạng thái cú ném và quyền quyết định kết quả. Chưa chọn Rapier hoặc backend solver cho toàn game.

### 2.12.11 Networking sample trong cùng project

Dùng nguyên tệp `game/probe-r1/tool/sync_smoke.dart` làm `tool/sync_smoke.dart` của project hướng dẫn. Giữ nguyên source để đối chiếu với bằng chứng R1; không viết một phiên bản rút gọn rồi gán cho nó kết quả đã chạy của bản cũ.

Chương trình dùng thư viện chuẩn:

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
```

Mẫu tạo server loopback tại cổng được hệ điều hành cấp:

```dart
final server = await HttpServer.bind(
  InternetAddress.loopbackIPv4,
  0,
);
```

Hai client kết nối đến cùng địa chỉ `ws://127.0.0.1:<port>`. Mỗi client gửi số thứ tự riêng. Phần xử lý cốt lõi trong source R1 là:

```dart
final seq = data['seq'] as int;
if (seq > lastSeq[socket]!) {
  lastSeq[socket] = seq;
  x += data['dx'] as int;
  tick++;
}

for (final peer in sockets) {
  peer.add(jsonEncode({
    'x': x,
    'tick': tick,
    'ack': lastSeq[peer],
  }));
}
```

Trình tự kiểm tra:

1. Client A gửi `seq = 1`, `dx = 1`.
2. Chờ cả hai client nhận trạng thái đầu tiên.
3. A gửi lại `seq = 1`, nhưng `dx = 100`.
4. Chờ cả hai client quan sát phản hồi input trùng.
5. Client B gửi `seq = 1`, `dx = 2`.
6. Kiểm tra cả hai nhận `x = 3`, `tick = 2`, `ack = 1`.

Lệnh dự kiến trong project hướng dẫn:

```powershell
dart tool/sync_smoke.dart
```

Dòng thành công của source R1:

```text
PASS: two loopback clients share x=3/tick=2; duplicate input ignored; per-client ack=1.
```

`tick` trong mẫu là bộ đếm input được chấp nhận, không phải tần số mô phỏng. Các timeout 5 giây trong chương trình chỉ giới hạn thời gian chờ của smoke check, không phải ngưỡng độ trễ gameplay.

Mẫu kiểm tra seq trùng với payload hợp lệ; chưa kiểm tra validation dữ liệu không tin cậy, bỏ sót seq, phân xử luật hoặc input bị từ chối. Nó chưa kết nối với SceneView; việc gán `x` nhận từ mạng vào node cần được thiết kế và kiểm tra riêng.

Chương trình chạy trong Dart VM và dùng `dart:io`; không chạy như chương trình trình duyệt. Không thay loopback bằng public bind rồi coi đó là giải pháp Internet. Chưa có TLS, xác thực, NAT/relay, hosting hoặc reconnect cho sản phẩm.

### 2.12.12 Kiểm tra theo từng mức và xử lý lỗi

Sau khi Lead lưu source mới, kiểm tra lần lượt:

```powershell
flutter pub get
flutter analyze
flutter build bundle --debug --target-platform android-arm64
dart tool/sync_smoke.dart
```

Chỉ khi có Android được nhận diện mới chạy:

```powershell
flutter devices
flutter run
```

Dấu hiệu đạt của từng mức:

| Mức | Dấu hiệu | Chưa chứng minh |
|---|---|---|
| Resolve | Có lockfile, đúng Scene 0.24.3 | API dùng đúng hoặc render được |
| Analyze | Không có lỗi phân tích tĩnh | GPU, asset và hành vi runtime |
| Build bundle | Tạo kernel/assets thành công | APK, cài đặt hoặc render Android |
| Smoke mạng | Đúng state, duplicate và ack | Hai Android hoặc Internet |
| Chạy Android | Quan sát cảnh, điều khiển và trigger | Hiệu năng đạt hoặc game hoàn chỉnh |
| GLB/animation | Model và clip thực hiển thị đúng | Tương thích mọi asset hoặc nhân vật game |

Các lỗi cần phân biệt:

| Hiện tượng | Cách kiểm tra |
|---|---|
| Không tìm thấy package hoặc member | Kiểm tra lockfile, `flutter pub get`, tên import và source đúng 0.24.3 |
| Flutter GPU chưa bật | Kiểm tra metadata trong `<application>` hoặc cờ chạy theo README package |
| Không có thiết bị Android | Kiểm tra cáp, USB debugging, ủy quyền thiết bị và ADB; không lấy web/desktop thay kết quả Android |
| Asset không tồn tại | Kiểm tra tên tệp, chữ hoa/thường và khai báo `pubspec.yaml` |
| GLB không có clip | Kiểm tra `parsedAnimations`; chỉ thử animation khi asset chứa animation thật |
| Model không thấy | Kiểm tra camera, scale, vị trí và warning importer; chưa kết luận lỗi engine |
| Node không di chuyển | Gán lại `node.position`; kiểm tra component đã mount/load và direction khác 0 |
| Quả cầu không bật nảy | Đây không phải hành vi của `BasicSimulation`; ví dụ chỉ có trigger |
| Counter không tăng | Kiểm tra world ở ancestor, collider/trigger, thể tích giao nhau và listener |
| Smoke timeout | Đọc exception và thứ tự chờ; không kết luận Internet có độ trễ quá cao từ phép thử loopback |

Khi lưu bằng chứng, mỗi check ghi một dòng gồm command, pass/fail và đường dẫn log. Log công khai phải loại serial, credential và đường dẫn hồ sơ cá nhân. Mã mới chưa qua check nào thì ghi “chưa chạy”, không dùng log R1 thay thế.

