# Cấu trúc project Flutter

Đính chính của sinh viên 10/11/2026: workspace chỉ có một folder tên game trỏ game/offline-practice. Không hiển thị repository/thesis/research/docs/design/qa/tools/demos trong workspace mặc định; không xóa hoặc di chuyển những hồ sơ đó. Mở file hỗ trợ riêng khi cần đọc.

```text
game/offline-practice/
  lib/
    main.dart
    src/
      simulation/     config.dart, practice.dart
      input/          joystick.dart, jump_button.dart, dash_button.dart
      presentation/   practice_page.dart
  test/
  android/
  tool/
  pubspec.yaml
```

main.dart giữ entrypoint/bootstrap. Simulation là trạng thái/chuyển động/luật tập offline; input xử lý pointer; presentation tổ chức Scene/HUD/lifecycle. Dash đang kiểm M3b, không nhận refactor đã có Dash ở commit811493d.

build/.dart_tool/.scratch/.git ẩn bằng settings workspace, không đổi global/không xóa. Snapshot APK và manifest ở demos ngoài cây Flutter, binary không Git. Lịch sử multi-root trong QA chuẩn bị thuộc thời điểm trước đính chính, không cấu hình hiện hành.