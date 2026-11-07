Đề nghị thêm entrypoint riêng dưới đây; không sửa A–F, dependency hoặc SDK. Toàn bộ code mới chưa analyze/build/runtime.

## 2.12.13 Ví dụ khai báo tùy chọn

Mục tiêu của ví dụ là biểu diễn khối hộp tương tự bài A bằng `SceneView.declarative`, `SceneNode` và `SceneMesh`. Cảnh dùng geometry, material và camera được tạo một lần trong State. Một nút đếm giúp quan sát state và identity của node khi rebuild.

Tiền đề: dùng project hiện có với `flutter_scene` 0.24.3, `scene` 0.4.1 và `vector_math` 2.4.4 theo lockfile R3. Khi chạy Android, giữ cấu hình Flutter GPU đã hướng dẫn. Ví dụ không cần model, texture hoặc asset ngoài.

Tệp mới: `game/tutorial-r3/lib/checkpoints/declarative/main.dart`.

```dart
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
```

Sau khi Lead lưu tệp, chạy từ `game/tutorial-r3`:

```powershell
flutter analyze lib/checkpoints/declarative/main.dart
```

```powershell
flutter build bundle --debug --target-platform android-arm64 --target lib/checkpoints/declarative/main.dart
```

Cả hai lệnh trên đều chưa được thực hiện cho ví dụ này. Analyze kiểm tra mã tĩnh; build bundle kiểm tra biên dịch và đóng gói kernel/assets, chưa tạo bằng chứng render trên Android.

Khi có thiết bị phù hợp:

```powershell
flutter run --debug --target lib/checkpoints/declarative/main.dart
```

Kết quả dự kiến là một khối hộp được tô màu, có camera và vị trí tương tự A. Nhấn nút làm tăng bộ đếm. Từ lần ghi nhận đầu, các lần rebuild thông thường được kỳ vọng vẫn tham chiếu cùng node; cần chạy thực tế để xác nhận.

### So sánh với bài A và quyền sở hữu

| Nội dung | Bài A | Ví dụ khai báo |
|---|---|---|
| Scene | Ứng dụng tạo và host quản lý cleanup | `SceneView.declarative` tạo và sở hữu scene nội bộ |
| Cấu trúc | Tạo `Node`, `Mesh`, gọi `add` | Mô tả bằng `SceneNode`, `SceneMesh`, `children` |
| Geometry/material | Builder tạo đối tượng | State giữ đối tượng ổn định qua rebuild |
| Node | Ứng dụng thao tác trực tiếp | Widget sở hữu node được giữ lại |
| Controller | Không cần cho bài A | Chỉ đọc node để so sánh identity |

Kích thước hộp, camera và vị trí actor được giữ tương ứng A. Ví dụ khai báo có thêm màu tint và HUD phục vụ bài thực hành. `SceneMesh` tạo một mesh node con dưới `SceneNode`; cây engine vì thế không hoàn toàn giống cấu trúc một node có mesh ở A.

`SceneMesh` đối chiếu geometry/material theo identity. Tạo hai đối tượng này trong mỗi lần `build()` sẽ làm mất sự ổn định cần minh họa. Mã trên chỉ tạo widget mô tả và giá trị vector nhỏ khi rebuild; không tạo lại geometry, material hoặc camera.

State là nơi duy nhất cập nhật `baseColorFactor`. Controller chỉ đọc node, không gán position hoặc thay cấu trúc cây. Không để mã khác đồng thời ghi thuộc tính mà `SceneNode` đã khai báo.

Khi view bị hủy, source của `SceneView` thu hồi ticker/listener và dispose scene nội bộ. Widget node chịu trách nhiệm detach node/component và bỏ liên kết controller. Ví dụ không giữ một `Scene` riêng để tự dispose và không gọi API `controller.dispose()` không có trong lớp này. Geometry/material là các payload được State giữ tham chiếu; không suy rằng việc bỏ widget bảo đảm GPU memory được trả đồng bộ ngay lập tức.

### Loading và warm-up

Future bên ngoài chờ static resources và tạo các đối tượng dùng lại. Bên trong, `warmUp: true` yêu cầu view chuẩn bị render pipelines trước khi reveal; `loadingBuilder` cung cấp giao diện chờ.

Trường `loading` của API là `ResourceGroup?`, không phải boolean hoặc future tùy ý. Ví dụ không có nhóm asset nên bỏ trường này. Loading, warm-up và hoàn tất I/O là các trạng thái khác nhau; không dùng spinner hoặc bật warm-up làm bằng chứng đã loại bỏ mọi stall.

### Lỗi thường gặp

| Hiện tượng | Điều cần kiểm tra |
|---|---|
| Không nhận constructor/member | Import `package:flutter_scene/scene.dart` và lockfile đúng 0.24.3 |
| Không tìm thấy SceneScope | `SceneNode`/`SceneMesh` phải nằm dưới SceneView; không đặt cạnh nó trong Stack |
| Controller trả null | Node chưa mount hoặc đã unmount; không đọc một lần trong `initState` rồi mặc định luôn có |
| Assert transform | Không truyền đồng thời `transform` và bộ `position`/`rotation`/`scale` |
| Node bị đổi ngoài dự kiến | Kiểm tra key, kiểu widget, vị trí cây và thao tác remount |
| Màn hình trống/loading kéo dài | Đọc log static initialization, GPU và warm-up; analyze đạt không chứng minh runtime |
| Màu không đổi sau reload | Sửa thân `_tint()`, không chỉ sửa initializer hoặc `_prepare()` đã chạy một lần |

Trạng thái: đã đối chiếu chữ ký API và ownership với source 0.24.3; chưa analyze, build hoặc quan sát runtime.

## 2.12.14 Kiểm tra hot reload có điều kiện

Bài kiểm tra này chỉ thực hiện khi có thiết bị được nhận diện, ứng dụng debug đã mở cảnh thành công và công cụ phát triển vẫn kết nối. Nếu chưa có các điều kiện đó, ghi “chưa chạy”; không lấy log compile thay cho quan sát.

1. Chạy đúng entrypoint khai báo. Đợi cảnh xuất hiện, nhấn “Ghi nhận state” ba lần. Ghi lại màu, bộ đếm bằng 3 và trạng thái identity. Không ghi serial vào tài liệu công khai.

2. Chỉ sửa thân `_tint()`:

   ```dart
   vm.Vector4 _tint() => vm.Vector4(0.1, 0.35, 0.9, 1);
   ```

   Không sửa key, tên lớp hoặc initializer trong lần thử này.

3. Thực hiện hot reload bằng nút của IDE hoặc `r` trong phiên `flutter run` tương tác. Không chạy thêm `flutter run` để thay thế thao tác reload.

4. Quan sát màu và bộ đếm trước khi nhấn tiếp. Sau đó nhấn nút một lần nữa để so identity với node đã đánh dấu trước reload.

   Kỳ vọng cần kiểm chứng: màu đổi, counter trước lần nhấn tiếp vẫn là 3; sau lần nhấn là 4 và identity vẫn “Giữ nguyên”. `_ready`, geometry và material được kỳ vọng giữ nguyên vì State không được tạo lại trong lần hot reload thông thường.

5. Thực hiện hot restart bằng IDE hoặc `R` trong phiên tương tác. Kỳ vọng State được khởi tạo lại: counter về 0, identity về “Chưa đánh dấu”, geometry/material được tạo lại. Không so identity xuyên hai lần restart bằng trường tham chiếu đã bị reset.

6. Ghi kết quả thực tế từng thao tác, kể cả lỗi. Nếu Flutter yêu cầu restart hoặc reload thất bại, ghi đúng thông báo; không sửa kết quả thành hành vi kỳ vọng.

| Thao tác | Nội dung quan sát |
|---|---|
| Rebuild do nhấn nút | Counter tăng; kiểm tra node còn cùng identity |
| Hot reload thân `_tint()` | Kiểm tra mã màu mới và State cũ |
| Hot restart | Kiểm tra khởi tạo lại State |
| Dừng rồi chạy lại | Phiên ứng dụng mới; không gọi là hot reload |

Bài này kiểm tra sửa mã Dart và tham số material trong bộ nhớ. Nó chưa kiểm chứng reload GLB, ảnh texture, `.fmat`, shader bundle hoặc tài nguyên tiền xử lý. Source có coordinator cho asset reload trong debug, nhưng mỗi đường nạp cần bài thử riêng. Không suy hành vi bản release từ kết quả hot reload.

## Ghi chú API và rủi ro dành cho Lead

Đã đọc source trong cache được cấu hình package R3 tham chiếu:

- `lib/src/widgets/scene_view.dart`: constructor declarative; `children`, `loading`, `loadingBuilder`, `warmUp`; tạo/dispose owned scene; `reassemble`.
- `lib/src/widgets/declarative.dart`: ownership, controller, transform constraints, `SceneNode`, `SceneMesh`, identity diff và cleanup.
- `lib/src/camera.dart`: constructor `PerspectiveCamera`.
- `lib/src/geometry/primitives.dart`: `CuboidGeometry`.
- `lib/src/hot_reload/hot_reload_coordinator.dart`: debug-only asset reload và phạm vi đăng ký tài nguyên.
- `lib/scene.dart`: public exports của các API được import.

Rủi ro còn cần kiểm tra: analyze entrypoint mới, build đúng `--target`, warm-up/runtime GPU và lifecycle thực tế. FutureBuilder chỉ xử lý lỗi của `_prepare`; lỗi render/warm-up bên trong cần xem log Flutter riêng.

Báo cáo video được đọc như bằng chứng kế thừa từ Cindy về các đoạn đã chọn. Không mở video, không nhận đã xem và không thay đổi mô tả metadata-only của lịch sử R2.

```text
pub/analyze/build/runtime | NOT RUN — nhiệm vụ chỉ đọc | logpath=none
```

- Sản phẩm bàn giao: toàn văn entrypoint độc lập và hai mục 2.12.13–2.12.14.
- Bằng chứng: đọc source API 0.24.3, source A và lockfile R3; áp dụng `research-paper-writing`/`humanizer` cho phần văn bản.
- Điểm chưa rõ: kết quả compile, render và hot reload của ví dụ mới.
- Bước tiếp theo: Lead lưu tệp, chạy analyze/build đúng target rồi tích hợp văn bản; chỉ ghi runtime sau khi thực hiện trên thiết bị.
