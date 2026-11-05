# Tutorial R3 — các mốc A–F

Source do Orca Worker developer đề nghị, Lead lưu và kiểm chứng với Scene 0.24.3; giữ R2 riêng. Khởi tạo/vòng đời Flutter ở lib/lesson_host.dart, A chỉ scene/camera, B transform/component, C material/point light, D input/HUD, E BasicSimulation trigger, F texture/model/animation. Mỗi entrypoint chạy bằng `flutter run --target lib/checkpoints/a/main.dart` và thay a bằng mốc cần thử; B–F import builder mốc trước.

## Kiểm chứng đã chạy

Offline resolve; analyze riêng A–F và toàn project; build bundle F Android arm64; test snapshot_replica đều đạt ngày 05/11/2026. Log ở ../evidence-r3. Test đầu sai ngưỡng y=0,35 vì Scene Float32; đã sửa tolerance 1e-9 thành 1e-6, giữ nguyên logic guard và lịch sử từng packet, lần chạy lại đạt. Chưa render Android, chưa runtime trigger/GLB/animation, chưa Internet.

## Asset có nguồn

assets/Fox.glb được tải theo commit cố định và có attribution/license kèm. F dùng scale 0,01 để thích hợp kích thước ví dụ, không gọi đây là chuyển đơn vị phổ quát. Chạy tùy chọn: `flutter run --target lib/checkpoints/f/main.dart --dart-define=MODEL_ASSET=assets/Fox.glb --dart-define=CLIP_NAME=Walk`. Cần Android runner/cấu hình Flutter GPU trước khi cài/chạy; source bundle hiện không có runner. Không khai báo surface.png giả; nhánh TEXTURE_ASSET chỉ dùng nếu có ảnh thật khai báo trong pubspec.

## Snapshot → node

lib/snapshot_replica.dart là một writer của node không có Drive/RigidBody. Test headless dùng 2 WebSocket loopback clients và 2 fs.Node, xác nhận lịch sử vị trí/tick, packet cũ/trùng/sai phiên/entity/NaN và trạng thái đóng. Không có SceneView/GPU rendering trong test. Adapter áp trực tiếp, không interpolation hoặc prediction. `flutter test test/snapshot_replica_test.dart --reporter expanded`.

tool/sync_smoke.dart giữ bài tiền đề transport R2, không thay bằng test tích hợp. Không quyết định mạng hoặc physics solver của game từ các ví dụ này.
