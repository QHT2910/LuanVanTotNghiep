# Offline practice — M3a: joystick và nhảy

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

src/simulation/config.dart gom bounds, vạch, footprint, kích thước, charge, gravity, flight time/reset/timestep; tất cả là tham số thử nghiệm. Quỹ đạo ballistic giải tích, không va chạm bảng/vành hoặc bật nảy; bóng có thể xuyên bảng. Đường tròn là ranh giới thử nghiệm, không nhận là sân chuẩn.

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

## M3a — nhảy (09/11/2026)

Nút Nhảy bên phải nhận một lần khi chạm xuống, chỉ lúc grounded; giữ nút không tự nhảy lại sau landing. Đang bay không double-jump. Joystick và ném độc lập. Nhảy theo thời gian mô phỏng, jumpSpeed=5 và gravity=9,81 cho đỉnh khoảng1,274 và thời gian khoảng1,019s; đây là tham số thử nghiệm trong config, không luật đã chốt.

Nhân vật và bóng cầm nâng lên thật; đĩa chân là hình chiếu giữ trên sân. Ném lấy đúng mẫu held-ball gần nhất đang được syncScene hiển thị, điểm2/3 lấy projectedfeet y=0 tại release. Quỹ đạo arcade tính lại vận tốc từ origin cao để giữ thời gian crossing, không mang thêm vận tốc đứng của người chơi sang bóng, không solver bảng/vành. Mẫu origin cao hơn vành cũng có test. Một shot chỉ cộng một lần.

Pause hủy charge/hướng đi nhưng giữ tiến trình nhảy; resume tiếp tục, không tự ném hoặc nhảy mới. Reset đưa player về y0 và bóng về tay, giữ tổng điểm. Pointer cancel của nút Nhảy kết thúc giữ nút, không đảo ngược chuyển động đã bắt đầu. HUD có y/grounded; simTime chỉ ở event để tránh cập nhật semantics liên tục.

Lead analyze/34test/build/install PASS. Runtime một Pixel_9a: joystick+jump, jump+shoot ngoài/trong vạch, repeatedjump từ chối, resetmidair, backgroundmidair+charging rồi resume/land. Hai airborne release originY=playerY+1,8, feetY0; score3+2=tổng5, không lặp. Đây là hai ca hai pointer riêng, chưa ba pointer đồng thời hoặc máy thật. Xem ../../docs/MILESTONE_3A_PROGRESS.md và ../evidence-m3a; bằng chứng M2 bên trên là lịch sử trước M3a.

```powershell
node tool/jump-avd.cjs <avd-id> move-jump
node tool/jump-avd.cjs <avd-id> jump-shot
node tool/jump-avd.cjs <avd-id> repeat
node tool/jump-avd.cjs <avd-id> reset
node tool/jump-avd.cjs <avd-id> background
node tool/jump-avd.cjs <avd-id> inside
node tool/jump-avd.cjs <avd-id> inside-shot
node tool/assert-jump-runtime.cjs
```

Compile JoystickTouch.java như hướng dẫn M2 nhưng push dex tới /data/local/tmp/joystick-m3.dex. Harness thêm leadInMillis tùy chọn (mặc định300 để giữ M2), M3a jump+shoot dùng50ms trước khi nhấn ném. Timing wall-clock không phải oracle; chỉ nhận ném trên không khi event releasePlayerY>0. Helper dùng AVD hiện hành/foreground demo, không boot/đóng AVD; mode background dùng HOME. Assertions là oracle phiên M3a lưu (6jump/2release/tổng5), không phải mọi phiên tùy ý. Không dùng helper trong khi người dùng đang điều khiển. Không thêm Dash/Block/multiplayer/model thật.
## Cấu trúc hiện hành sau refactor 10/11

- lib/main.dart: bootstrap, orientation, entrypoint giữ nguyên.
- lib/src/simulation/config.dart và practice.dart: tham số/mô phỏng thuần.
- lib/src/input/joystick.dart và jump_button.dart: input widgets/model pointer.
- lib/src/presentation/practice_page.dart: Scene/HUD/vòng đời.

Bốn source logic/input và toàn thân PracticePage được chuyển nguyên byte; tests chỉ đổi11 import. Logs kiểm bản refactor ở ../evidence-refactor; runtime M3a ở evidence-m3a thuộc layout/commit cũ, không nhận là đã chạy bản mới. Không chạy các helper AVD lịch sử để ghi đè evidence cũ.

Audit đã chạy bằng `node tool/audit-apk-sources.cjs`, dùng ZIP reader sẵn trong .local-tools của repo, không đổi dependency app. Có bản Python standard-library `python tool/audit-apk-sources.py` tùy chọn; máy hiện không có Python thật nên chưa chạy bản này. Script xuất JSON stdout, kiểm cả sáu source mới nhúng trong debug kernel và không còn source flat; không chứng minh APK đã cài hoặc runtime. Không dùng APK release stripped để kết luận PASS. Snapshot M3a trước refactor ở ../../demos/releases/m3a, hash xem manifest.