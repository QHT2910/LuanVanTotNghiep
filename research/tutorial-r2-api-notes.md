## Ghi chú bàn giao nội bộ cho Lead

Phần này lưu ngoài nội dung luận văn.

### Nguồn API đã đối chiếu

Ngày đọc: 05/11/2026. Đọc trực tiếp cache package được `.dart_tool/package_config.json` của probe R1 tham chiếu; không tải package mới.

| Nội dung | Source trong package |
|---|---|
| Bật GPU | `flutter_scene-0.24.3/README.md`, mục Enable Flutter GPU |
| Public exports | `lib/scene.dart`, `lib/physics.dart` |
| Node, transform, GLB và clip | `lib/src/node.dart` |
| Component lifecycle/update | `lib/src/components/component.dart` |
| Vòng lặp SceneView | `lib/src/widgets/scene_view.dart` |
| Cập nhật và dispose Scene | `lib/src/scene.dart` |
| Hình học | `lib/src/geometry/primitives.dart` |
| Material | `lib/src/material/physically_based_material.dart` |
| Texture | `lib/src/texture/texture2d.dart` |
| Camera/light | `lib/src/camera.dart`, `lib/src/light.dart`, `lib/src/components/point_light_component.dart` |
| Animation | `lib/src/animation/animation_clip.dart` |
| Physics adapter | `lib/src/physics/physics_world.dart`, `rigid_body.dart`, `collider.dart`, `events.dart` |
| BasicSimulation và shape | `scene-0.4.1/lib/src/physics/basic_simulation.dart`, `shape.dart` |

Nguồn phân phối phiên bản: [Flutter Scene 0.24.3](https://pub.dev/packages/flutter_scene/versions/0.24.3). Không dùng API đang phát triển trên nhánh mới làm căn cứ thay API bản cache.

### Bằng chứng có sẵn, không chạy lại

Các lệnh này do Lead thực hiện ngày 04/11/2026; worker chỉ đọc bằng chứng ngày 05/11:

```text
flutter pub get | PASS, exit 0 | game/evidence-r1/pub-get.txt
flutter analyze | PASS, exit 0 | game/evidence-r1/analyze.txt
flutter build bundle --debug --target-platform android-arm64 | PASS, exit 0 | game/evidence-r1/checks.json
dart tool/sync_smoke.dart | PASS, exit 0 | game/evidence-r1/sync-smoke.txt
```

Build bundle không có stdout log riêng; `checks.json` ghi stdout rỗng, kernel 63.705.384 byte và SHA-256:

```text
e442f3aca89a8d1ce0978b8b3c87d188f5490efc801fac8010f0a448ddb0cbc5
```

Lượt R2 này chỉ chạy lệnh đọc tệp và tìm source, không chạy check chương trình mới. Không lưu log mới vì nhiệm vụ chỉ đọc.

### Tự rà soát

- Mạch hướng dẫn: một project, từ cấu hình đến cảnh, asset và smoke mạng.
- Thuật ngữ: phân biệt frame update, physics step và biến `tick` trong smoke.
- Chứng cứ: kết quả R1 chỉ áp dụng source R1; mã mới chưa thử.
- Giới hạn: GLB cần asset thật; BasicSimulation không có solver; chưa render Android hoặc thử Internet.
- Quyết định: không chọn dependency vật lý/mạng hoặc ngưỡng của toàn game.

### Báo cáo kết thúc

- Sản phẩm bàn giao: toàn văn hướng dẫn 2.12, hai tệp source mới đề xuất, chỉ dẫn tái sử dụng smoke R1 và chuỗi lệnh kiểm tra.
- Bằng chứng: đối chiếu lockfile, evidence R1 và source Scene 0.24.3/`scene` 0.4.1; chưa thực thi mã mới.
- Điểm chưa rõ: asset GLB thực, backend/GPU trên Redmi, kết quả analyze của bản mở rộng và hành vi runtime.
- Bước tiếp theo: Lead lưu riêng source mới, analyze/build rồi sửa theo kết quả thực; chỉ đưa kết quả đã chạy vào hồ sơ bằng chứng, bảo toàn Word v0.3.
