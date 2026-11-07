# Offline practice — mốc 1

Demo tập offline tách biệt, Flutter Scene 0.24.3, scene 0.4.1, vector_math 2.4.4. Không multiplayer/Dash/Block hoặc rigid-body solver. UI tạm để thử; không phải thiết kế Figma chính thức.

## Chạy

Tại thư mục này, với Flutter 3.47.8 / Dart 3.13.7:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --debug -d <avd-id> --target lib/main.dart
```

Android runner đã có EnableFlutterGPU. Chỉ dùng một AVD đã boot; tìm target qua flutter devices. Build APK cho AVD x86_64:

```powershell
flutter build apk --debug --target-platform android-x64 --target lib/main.dart
```

APK ở build/app/outputs/flutter-apk/app-debug.apk (không đưa binary/build vào Git). Không dùng APK x64 này làm bằng chứng chạy Redmi ARM. Logs và ảnh thật nằm ở ../evidence-m1; hồ sơ tổng hợp docs/MILESTONE_1_REVIEW.md từ gốc repo.

## Điều khiển

Giữ pad để di chuyển; hai hướng được chuẩn hóa. Lên đi tới rổ. Giữ/thả nút ném, canh khoảng 60% thanh charge; thả sớm hoặc giữ đầy sẽ lệch. Thời gian giữ theo mô phỏng, AVD chậm có thể khác thời gian thực. Không có nút cộng điểm.

Lượt mới hủy cú ném, giữ tổng điểm và vị trí chân. Sau bóng chạm đất tự reset lượt; có thể ném tiếp. Xuống nền hủy charge và hướng đi; trở lại phải nhấn lại. Phiên ứng dụng mới bắt đầu từ 0.

## Mô hình và giới hạn

config.dart gom bounds, vạch, footprint, kích thước, charge, gravity, flight time/reset/timestep; tất cả là tham số thử nghiệm. Quỹ đạo ballistic giải tích, không va chạm bảng/vành hoặc bật nảy; bóng có thể xuyên bảng. Đường tròn là ranh giới thử nghiệm, không nhận là sân chuẩn.

Tâm bóng đi qua mặt phẳng rổ từ trên xuống và nằm trong lỗ sau khi trừ bán kính bóng mới tính điểm. Crossing dùng nghiệm thời gian trong khoảng bước; shot crossed/scored khóa cộng lặp. Vị trí chân và giá trị 2/3 được cache lúc nhả. Footprint tiếp xúc vạch tính 2; chỉ hoàn toàn ngoài vạch mới 3. lineTolerance=1e-9 là dung sai số học, không phải biên gameplay hữu hình.

dt sai bị bỏ; dt lớn bị cap và phần dư bị bỏ. Tính lặp lại chỉ theo thời gian mô phỏng được chấp nhận, không chứng minh tất định đa thiết bị/mạng. Không suy hiệu năng Redmi hoặc điện thoại thật từ AVD.

SceneView giữ một ticker suốt vòng đời; logic pause/skip frame đầu khi resume, tránh tạo lại ticker qua autoTick. AA đặt none để thử đường render đơn giản trên AVD, không chốt chất lượng cho sản phẩm cuối. HUD góc trái để không che rổ; semantics được giữ để ADB đọc bounds ổn định.

## Kiểm chứng

Lead đã chạy analyze, 13 test logic/config và build/install APK. Đây không phải widget/touch test; runtime ADB được ghi riêng và phải đối chiếu events/ảnh. Không lấy build hoặc log rỗng làm render PASS. Xem báo cáo mốc 1 cho kết quả runtime cuối và hạn chế.

Helper ADB đọc bounds semantics, không gán tọa độ màn hình cố định:

```powershell
node tool/avd-smoke.cjs <avd-id> render
node tool/avd-smoke.cjs <avd-id> shot 720 three-point
node tool/avd-smoke.cjs <avd-id> move move_toward_rim 1400
node tool/avd-smoke.cjs <avd-id> background
node tool/avd-smoke.cjs <avd-id> reset-flight
```

Helper chỉ điều khiển AVD đang chạy, không boot/đóng AVD. Nhãn: practice_hud, shoot_hold_release, new_round, move_left/right/toward_rim/away_rim. Chờ event reset có giới hạn; workflow thành công chưa thay việc kiểm oracle score/charge. Events JSON có eventId/simTime/round/shotId, không serial/credential. Ca nhiều pointer đồng thời và ranh giới chính xác cần phân biệt unit test với thao tác AVD đã thực hiện.
