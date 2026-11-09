# Offline practice — mốc 2: joystick

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

Kéo joystick trái để di chuyển analog; thả hoặc hủy touch thì về tâm. Vùng chết bán kính 15%, ngoài vùng chết tốc độ tăng dần và được giới hạn theo vòng tròn nên đường chéo không nhanh hơn. Kéo lên đi tới rổ. Một ngón sở hữu joystick, ngón khác có thể giữ/thả nút ném đồng thời; ngón lạ không chiếm joystick đang bận. Canh khoảng 60% thanh charge; thả sớm hoặc giữ đầy sẽ lệch. Thời gian giữ theo mô phỏng, AVD chậm có thể khác thời gian thực. Không có nút cộng điểm.

Lượt mới hủy cú ném, giữ tổng điểm và vị trí chân. Sau bóng chạm đất tự reset lượt; có thể ném tiếp. Xuống nền hủy charge và hướng đi; trở lại phải nhấn lại. Phiên ứng dụng mới bắt đầu từ 0.

## Mô hình và giới hạn

config.dart gom bounds, vạch, footprint, kích thước, charge, gravity, flight time/reset/timestep; tất cả là tham số thử nghiệm. Quỹ đạo ballistic giải tích, không va chạm bảng/vành hoặc bật nảy; bóng có thể xuyên bảng. Đường tròn là ranh giới thử nghiệm, không nhận là sân chuẩn.

Tâm bóng đi qua mặt phẳng rổ từ trên xuống và nằm trong lỗ sau khi trừ bán kính bóng mới tính điểm. Crossing dùng nghiệm thời gian trong khoảng bước; shot crossed/scored khóa cộng lặp. Vị trí chân và giá trị 2/3 được cache lúc nhả. Footprint tiếp xúc vạch tính 2; chỉ hoàn toàn ngoài vạch mới 3. lineTolerance=1e-9 là dung sai số học, không phải biên gameplay hữu hình.

dt sai bị bỏ; dt lớn bị cap và phần dư bị bỏ. Tính lặp lại chỉ theo thời gian mô phỏng được chấp nhận, không chứng minh tất định đa thiết bị/mạng. Không suy hiệu năng Redmi hoặc điện thoại thật từ AVD.

SceneView giữ một ticker suốt vòng đời; logic pause/skip frame đầu khi resume, tránh tạo lại ticker qua autoTick. AA đặt none để thử đường render đơn giản trên AVD, không chốt chất lượng cho sản phẩm cuối. HUD góc trái để không che rổ; semantics được giữ để ADB đọc bounds ổn định.

## Kiểm chứng

Mốc 2 ngày 09/11/2026: analyze đạt, 22 test đạt (13 test cũ và 9 test logic/widget joystick/phối hợp), build/install APK x64 đạt. Pixel_9a chạy joystick, hai pointer MotionEvent thực vừa di chuyển vừa giữ/thả ném; ghi 3 điểm, hủy cả hai pointer không ném, xuống nền/trở lại rồi ném thêm 3 điểm. Xem ../../docs/MILESTONE_2_PROGRESS.md và ../evidence-m2. Không dùng widget fixture làm bằng chứng runtime Scene; hủy riêng từng pointer mới được kiểm trong widget test, chưa kiểm riêng trên AVD.

Helper M2 đọc bounds semantics `move_joystick` và `shoot_hold_release`. Chỉ chạy khi chính demo đang ở foreground; không tranh input với người dùng. Lệnh từ thư mục app:

```powershell
node tool/joystick-avd.cjs <avd-id> render
node tool/joystick-avd.cjs <avd-id> move
node tool/joystick-avd.cjs <avd-id> multi
node tool/joystick-avd.cjs <avd-id> cancel
node tool/joystick-avd.cjs <avd-id> background
node tool/joystick-avd.cjs <avd-id> multi-resumed
node tool/assert-joystick-runtime.cjs
```

`multi`/`cancel` cần shell harness Java có sẵn JDK, android.jar và d8. Không cài thêm phần mềm, không sửa quyền APK. Từ gốc repo, tạo thư mục build tạm .scratch/m2-touch/classes và .scratch/m2-touch/dex rồi:

```powershell
$sdk = "$env:LOCALAPPDATA/Android/Sdk"
javac --release 17 -cp "$sdk/platforms/android-37.0/android.jar" -d .scratch/m2-touch/classes game/offline-practice/tool/JoystickTouch.java
& "$sdk/build-tools/37.0.0/d8.bat" --lib "$sdk/platforms/android-37.0/android.jar" --output .scratch/m2-touch/dex .scratch/m2-touch/classes/JoystickTouch.class
& "$sdk/platform-tools/adb.exe" -s <avd-id> push .scratch/m2-touch/dex/classes.dex /data/local/tmp/joystick-m2.dex
```

Harness dùng injectInputEvent qua shell trên AVD hiện hành, không bảo đảm khả dụng trên thiết bị/bản Android khác. Nó gửi DOWN/MOVE/POINTER_DOWN/POINTER_UP/UP với hai pointer, hoặc ACTION_CANCEL toàn bộ. Helper có thao tác HOME khi thử background, chỉ dùng trên AVD thử nghiệm. Assertion hiện là oracle cho phiên M2 đã lưu (hai cú ném/tổng 6), không phải mọi phiên tùy ý. Ảnh tĩnh không thay quan sát toàn bộ chuyển động.

Helper cũ dưới đây thuộc lịch sử mốc 1 có pad bốn nút; không dùng nguyên workflow move cho UI joystick hiện hành:

```powershell
node tool/avd-smoke.cjs <avd-id> render
node tool/avd-smoke.cjs <avd-id> shot 720 three-point
node tool/avd-smoke.cjs <avd-id> move move_toward_rim 1400
node tool/avd-smoke.cjs <avd-id> background
node tool/avd-smoke.cjs <avd-id> reset-flight
```

Helper chỉ điều khiển AVD đang chạy, không boot/đóng AVD. Nhãn: practice_hud, shoot_hold_release, new_round, move_left/right/toward_rim/away_rim. Chờ event reset có giới hạn; workflow thành công chưa thay việc kiểm oracle score/charge. Events JSON có eventId/simTime/round/shotId, không serial/credential. Ca nhiều pointer đồng thời và ranh giới chính xác cần phân biệt unit test với thao tác AVD đã thực hiện.
