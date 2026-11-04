# Kiểm chứng nhỏ R1

Đây là package thí nghiệm độc lập, không phải mã game chính hoặc quyết định chọn giao thức/vật lý cuối cùng. Chỉ có Scene khối cơ bản và kiểm tra đồng bộ loopback. Không có logic bóng rổ hoàn chỉnh.

```powershell
flutter pub get
flutter analyze
flutter build bundle --debug --target-platform android-arm64
dart tool/sync_smoke.dart
```

Lệnh build bundle tạo kernel/assets phục vụ kiểm tra compile, không tạo APK và không chứng minh chạy trên Android. Chỉ báo kết quả lệnh trong game/feasibility-r1.md. Smoke hai client WebSocket cùng máy không chứng minh hai điện thoại hoặc hai mạng Internet. Dependency ghim riêng cho probe; không áp đặt cho dự án game chính.
