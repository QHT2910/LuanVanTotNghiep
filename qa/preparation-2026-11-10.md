# QA chuẩn bị 10/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, Sol6.1/root OLD, chỉ đọc. Lead lưu báo cáo terminal; không chạy lại build/test/ADB/export.

PASS snapshot APK/workspace/thesis source; một P2 hồ sơ chậm hơn working tree, không nghiệm thu refactor/Dash.

APK M3a snapshot hash d4745966535ecf924d13f617dc357c3c4549a77d3140176158c29b3719413c14 đúng. Manifest ghi đúng M1/M2 thiếu binary, chỉ rebuildable; releases ignored, không tracked binary/staged khi kiểm. Workspace tám root ngang cấp, không lồng root; settings workspace, allowlist chỉ thêm demos/root workspace.

Ch2 pointer/cancel/deadzone/pause/jump/crossing đúng phạm vi; công thức không gán thành Flutter feature. Ch3 phân biệt thiết kế1v1/offline. References1–44 liên tục, source chương và tổng hợp khớp, không nhãn nguồn treo. Ch4 draft riêng, test13/22/34 theo bản, probeFox không thay game. Style useroverride ghi rõ, chưa Word/After. Wordv0.3 hash706209…10404 giữ, không đổi Word/PDF khác. Figma chỉ gọi mở, chưa file/session/PNG, không SVG giả.

P2: khi QA đọc, app đã chuyển src nhưng progress/checkpoint còn câu chưa refactor/chưa đổi source. Cần ghi rõ mốc chuẩn bị trước migration và trạng thái source/gate/refactor QA riêng. Không coi kết quả review này là kiểm chứng refactor. Lead đã cập nhật theo gate thực chạy ở lượt sau.

```text
Get-Content + git diff ab9bf92 | PASS snapshot/workspace/thesis, phát hiện P2 hồ sơ | logpath=none
Get-FileHash APK/Wordv0.3 | PASS hash | logpath=none
git check-ignore/ls-files/diff cached | PASS không tracked release binary | logpath=none
Regex registry/citation + source tổng hợp | PASS44refs | logpath=none
```

URL YouTube ?v= là false positive encoding. Chưa có UI Figma, refactor nằm ngoài phạm vi QA chuẩn bị; cần lượt QA riêng.
