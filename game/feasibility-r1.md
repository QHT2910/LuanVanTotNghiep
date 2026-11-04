# Kiểm chứng khả thi R1

Ngày 04/11/2026. Developer đã kiểm tra môi trường bằng các lệnh chỉ đọc nhưng không tạo được thư mục đầu ra trong quyền worker cũ; worker không chạy probe/analyze. Lead tiếp nhận và chạy package nhỏ trong workspace hiện hành. Báo cáo môi trường của worker được lưu tại evidence-r1/developer-environment.md. Đây không phải bản game hoàn chỉnh.

## Môi trường thực tế

- Flutter 3.47.8 stable, Dart 3.13.7; Android SDK 37.0.0, license đã chấp nhận.
- `flutter devices --machine` chỉ nhận Windows, Chrome và Edge; không có Redmi Note 11 hoặc Android kết nối.
- Visual Studio cho build Windows chưa sẵn sàng theo doctor. Điều này không cản analyze và build bundle mục tiêu android-arm64 đã chạy.
- Probe ghim `flutter_scene` 0.24.3; lockfile resolve `scene` 0.4.1 và `vector_math` 2.4.4. Không nâng Flutter/Android SDK, không cài backend vật lý hoặc tạo máy chủ công khai.

## Lệnh thực sự chạy

| Lệnh trong game/probe-r1 | Kết quả | Phạm vi chứng minh |
|---|---|---|
| flutter pub get | Exit 0, có lockfile | Bộ dependency của probe resolve được |
| flutter analyze | Exit 0, No issues found | Ví dụ Scene và smoke script qua phân tích tĩnh |
| flutter build bundle --debug --target-platform android-arm64 | Exit 0; stdout rỗng, có kernel 63.705.384 byte | Compile/kernel/assets thành công; không phải APK |
| dart tool/sync_smoke.dart | Exit 0, PASS | Hai client loopback nhận x=3/tick=2, input trùng bị bỏ, ack riêng bằng 1 |

Hash và thông tin artifact nằm ở `evidence-r1/checks.json`. Kernel/build/cache được gitignore, không đưa binary build lên GitHub. Log công khai được lọc để không có serial hoặc đường dẫn cấu hình cá nhân. Lần chạy smoke cuối đã chờ cả hai client quan sát phản hồi input trùng trước khi gửi input tiếp theo để tránh kết luận sớm do thứ tự lịch trình.

## Chưa kiểm chứng

- Chưa render Scene hoặc cài APK lên Redmi Note 11.
- Chưa có hai Android, hai mạng Internet, WSS/hosting/NAT hoặc cơ chế xác thực thật.
- Chưa đo FPS/frame time/RTT, chưa kiểm thử luật bóng rổ hoặc chọn vật lý/giao thức cuối.
- `ack` trong smoke chỉ minh họa lệnh hợp lệ đã xử lý; chưa kiểm chứng input bị luật từ chối hoặc chính sách thiếu seq của game.

Package này là thử nghiệm riêng, không áp đặt WebSocket hoặc dependency cho bản game chính. Chương 4–5 chưa được điền kết quả của sản phẩm dựa trên các probe này. Bước tiếp theo là kết nối điện thoại, xác minh Android/GPU/backend và chạy cảnh nhỏ; kiểm thử Internet cần thiết bị và endpoint được lựa chọn riêng.
