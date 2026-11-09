# Mốc 2 nhỏ — joystick và phối hợp ném

09/11/2026, nền Git d882fc7. Lead tích hợp/thực thi tại root hiện hành; Orca Worker developer Sol6.1/root OLD chỉ đọc đề xuất, không chạy code. Orca Worker QA đã rà độc lập, không P1/P2 chặn; xem qa/milestone-2-final.md. M2 đã commit/push 112afd0 và được Cindy chấp nhận trong phạm vi một AVD. Giữ Word v0.3 ngoài lượt và các bản luận văn cũ.

## Đã làm

Kiểm HEAD/status/checkpoint/process/team trước sửa, không chạy lại probe. VS Code visible mở file thật main/joystick/test/helper theo từng bước; công cụ cập nhật sau lưu, không stream từng phím. Không đổi settings/extension/model/provider. Một Pixel_9a visible, không mở trùng; giữ VS Code và emulator mở ở lần kiểm cuối.

Thay pad bằng joystick trái analog: deadzone 0,15, clamp tròn, rescale tốc độ ngoài vùng chết. Một pointer sở hữu, ngón khác giữ/thả ném độc lập. Reset/background dừng logic đồng bộ và dùng token/guard chặn callback cũ. Shoot cancel không xóa joystick. Giữ ticker/AA-none của M1. Practice/config/scoring tests cũ và dependency/SDK không đổi.

## Gate Lead đã chạy

| Lệnh | Kết quả | Log trong game/evidence-m2 |
|---|---|---|
| dart format bốn file Dart | PASS | format.txt |
| flutter analyze | PASS, No issues found | analyze.txt |
| flutter test | PASS, 22 test: 13 cũ + 9 mới | tests.txt |
| flutter build apk --debug --target-platform android-x64 --target lib/main.dart | PASS | build-apk.txt |
| adb install/relaunch | PASS | install.txt, launch.txt |
| javac --release 17 / d8 harness | PASS, exit 0, stdout rỗng | touch-javac.txt, touch-d8.txt |
| joystick-avd render/move/multi/cancel/background/multi-resumed | PASS thao tác; oracle bên dưới | runtime-*.txt, touch-*.txt |
| node tool/assert-joystick-runtime.cjs | PASS | assert-runtime.txt, runtime-assertions.json |
| APK/source/installed hash | PASS | source-apk-audit.json, installed-apk.json |
| Quét fatal/ticker log app hiện hành | PASS trong mẫu quét | runtime-errors.txt |

APK: game/offline-practice/build/app/outputs/flutter-apk/app-debug.apk; SHA-256 4610a8ddf9156daa59662056bca9167d1e145e40a28bf4f64eab81b8b65a7763. Kernel chứa nguyên văn main/joystick/practice/config hiện hành; APK đã cài cùng hash. ABI x86_64; binary/build không đưa Git. Entrypoint lib/main.dart, lệnh chạy trong README app.

## Runtime quan sát

- Kéo joystick lên: z từ spawn 3 tới khoảng 1,95, ảnh joystick-moved.
- Hai MotionEvent pointer thực: pointer 0 giữ joystick, pointer 1 giữ/thả ném; sau POINTER_UP ngón ném, joystick tiếp tục giữ 400 ms rồi UP. Ảnh multi-active: charge 29%, x khoảng −1,21; release: charge 0,6111, x khoảng −1,965/z 1,952; multi-finished: x khoảng −2,82, tổng 3. Đây là di chuyển trong charge và sau release, không chỉ fixture.
- ACTION_CANCEL cả hai pointer: charge_cancel(pointer_cancel), không tạo shot mới, joystick về tâm, tổng vẫn 3.
- Giữ joystick rồi HOME/trở lại: paused/resumed, joystick về tâm. Hai pointer sau resume: shot 2 ở simTime lớn hơn resume, charge 0,6319; cộng 3, tổng 6, auto-reset lượt 3. Không thấy mẫu lỗi MultipleTicker/fatal trong buffer app đã quét.
- Assertions: eventId tăng, simTime không giảm; hai release, score đúng [[1,3,3],[2,3,6]], không lặp shotId; cancel không release, resume rồi ném tiếp/reset. Có dt_clamped, không coi thời gian mô phỏng là wall-clock.

Ảnh game/evidence-m2 tiền tố 2026-11-09-: joystick-neutral/moved, multi-active/finished, cancel-active/finished, joystick-resumed, multi-resumed-active/finished. Ảnh từng mốc đã gửi timeline; không hứa stream iPhone.

## Giới hạn và bước tiếp

Hủy riêng từng pointer, deadzone/diagonal/NaN và reset/disable race được kiểm unit/widget. AVD mới kiểm cancel cả hai, chưa chèn đầy đủ race trước frame. Fixture dùng Practice thật nhưng không main/Scene, không thay runtime. Ảnh tĩnh không chứng minh mọi frame. Chưa máy thật/Redmi, benchmark, Internet, multiplayer/Dash/Block, model thật hoặc solver. UI tạm không phải Figma; chưa file/session Figma.

Logs TXT đã chuẩn hóa UTF-8 và lọc mẫu profile/debug URL/IP/MAC, raw chỉ .scratch/m2-raw; quét không bảo đảm phát hiện mọi dữ liệu nhạy cảm. Không đưa serial/đường dẫn APK cài ngẫu nhiên vào hồ sơ công khai.

QA source/test/helper/events/sáu ảnh đã PASS. M2 đã chốt tại 112afd0; lượt M3a mới chỉ thêm nhảy theo yêu cầu tiếp theo, không replay kiểm thử M2 khi chưa đổi source.