# QA cuối M2: joystick và phối hợp ném

09/11/2026. Báo cáo Orca Worker tester bkm37d3uiwhgp757im7y9hov, Sol6.1, root OLD chỉ đọc; Lead lưu từ bàn giao terminal. QA không chạy lại test/build/ADB, không gửi input.

PASS trong phạm vi source, test và bằng chứng một AVD đã đọc. Không phát hiện P1/P2 chặn bàn giao.

## Source và test

Joystick có một pointer sở hữu; ngón lạ không chiếm quyền, owner up/cancel đưa knob/axis về tâm. Deadzone 0,15 gồm cả biên, rescale ngoài vùng chết và clamp tròn không tăng tốc đường chéo; có kiểm NaN/Infinity và tọa độ hữu hạn rất lớn.

Main neutralize đồng bộ khi reset/background, tăng epoch/chặn callback epoch hoặc round cũ. Revision loại deferred-neutral cũ sau input mới; dispose không callback parent. Shoot cancel chỉ hủy charge, không xóa joystick. Giữ ticker cố định/AA-none của M1. Fixture dùng Practice thật và cùng mapping/cancel/epoch nhưng không dựng main/Scene/lifecycle app, không coi là runtime Scene.

Log terminal: analyze không lỗi, 22 test pass, build/install APK thành công. Diff d882fc7 không đổi practice/config, dependency manifest/lock hoặc hai tệp test cũ đã kiểm.

## Runtime và ảnh

Java harness gửi DOWN/MOVE pointer0 joystick, POINTER_DOWN pointer1 ném; POINTER_UP riêng ngón ném rồi giữ joystick thêm 400 ms trước UP. Cancel gửi ACTION_CANCEL toàn bộ. Shell harness AVD không thêm permission APK.

| Oracle | Đối chiếu events |
|---|---|
| Release đầu | charge≈0,6111; x≈−1,965; z≈1,952 |
| Score | [[1,3,3],[2,3,6]], không lặp shotId |
| Cancel | charge_cancel(pointer_cancel) sau shot đầu/trước background; không có release thứ ba |
| Sau resume | Release hai charge≈0,6319, simTime tăng sau resume; cộng thêm3 |
| Chơi tiếp | Hai shot auto-reset, tổng6 |
| Thứ tự | eventId tăng, simTime không giảm |

QA xem sáu ảnh: multi-active/finished, cancel-active/finished, joystick-resumed, multi-resumed-finished. Active có joystick lệch khi charging; finished vị trí tiếp tục đổi/tổng3. Cancel-finished và resumed có knob tâm/charge0; ảnh cuối tổng6/ready/lượt3. HUD đọc được, không che rổ trong ảnh này.

Hủy riêng/race/reset/disable mới unit/widget; AVD xác nhận cancel cả hai. Hồ sơ giữ đúng giới hạn.

## Truy vết

Hash bốn source khớp source-apk-audit.json; audit ghi cả bốn nhúng kernel. installed-apk.json ghi hash cài khớp local. localKernelMatchesAPK=null không được coi PASS, kết luận dùng source audit/installed hash.

Bốn JSON không BOM. TXT không hit các mẫu profile/debug-loopback URL/IPv4/MAC đã quét, không cam kết mọi PII. Không nhận AVD thành Redmi/benchmark/Internet/fullgame/Figma.

```text
Get-Content source/tests/helpers/logs | PASS phạm vi rà | logpath=none
git diff d882fc7 -- practice/config/pubspec/lock/tests cũ | PASS các đường dẫn kiểm không đổi | logpath=none
ConvertFrom-Json + đối chiếu oracle chỉ đọc | PASS hai release/score3+3/cancel/resume/reset | logpath=none
Get-FileHash bốn source so audit | PASS | logpath=none
view_image sáu ảnh | PASS quan sát phạm vi giao | logpath=none
Quét BOM/mẫu nhạy cảm TXT | PASS trong mẫu kiểm | logpath=none
```

Sản phẩm bàn giao: xác nhận QA M2, không P1/P2 chặn. Chưa nghiệm thu individual-cancel/race trên AVD hoặc máy thật. Lead rà diff/chốt Git, giữ Wordv0.3 ngoài lượt; bàn giao Cindy và không tự mở tính năng khác.
