# QA UI offline task1 — 12/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, actual terminal report qua send_to_lead. Chỉ đọc; không build/test/ADB/GUI/Git mutation. Không nhận Luna đã chạy. Lead review: ACCEPT phạm vi task1; bàn giao Cindy trước HUD task2.

Verdict worker: PASS Menu/Settings/điều hướng và hồ sơ một AVD, không P1/P2 chặn.

## Kiểm chứng mới của QA

- Rà main/OfflineApp/routes/Menu _opening, disabled backend, Settings disabled audio; không tạo Scene tại Menu.
- PracticeNavigation _exiting gọi onExit một lần; cleanup trước pop, system Back qua PopScope. _stopForMenu khóa leaving/resumed, neutral input, hủy charge/Dash và pause. Prepare sau await kiểm mounted/leaving; lifecycle bỏ callback khi leaving. Dispose thu hồi observer/Scene/HUD/semantics. Đây là review source, không inject pending-init race runtime.
- Hai test mới kiểm route/back/reentry/disabled controls và ba viewport; fixture không Scene/GPU/ticker cleanup đầy đủ. Không nhận toàn sáu ca proposal đã tích hợp.
- Diff HEAD: simulation/input/pubspec/lock/47 test tracked cũ không đổi; hai audit manifests đủ10 source.
- Tự hash10 source khớp source-apk-audit.json; APK local/snapshot cùng2599f6928e7c4b2f81d761de04cbcff818a222886b3e8637a3faff5721afa9a8. Installed identity chỉ kế thừa checks, không tự đọc device.
- Xem6PNG menu-ready/settings/practice/menu-after-charge-exit/menu-after-system-back/practice-reentry. Chữ đọc được, nútMenu không che rổ/joystick trong ảnh; không pixel-perfect/HUD Figma acceptance.
- Trace charge_start → charge_cancel(return_menu) → paused tại simTime68.70000000000074, không shot_release; eventId trở lại1 trong phiên mới không là duplicate toàn cục. Reentry HUD điểm0/lượt1/charge0.

## Gate kế thừa đã đọc

Analyze no issues; 49 tests pass; build x64/install/launch COLD Status ok; source audit10 embedded/x64/no stale. localKernelMatchesAPK=null vẫn chưa so, không PASS. Runtime navigation/two-pointer charge-exit/reentry/Android Back thuộc Lead, không worker chạy lại. menu.png lúc launcher không được dùng làm ảnh Menu.

## Gate worker thực chạy

Get-Content/rg source/tests/manifests/review/checkpoint/logs/events | PASS đọc/đối chiếu | logpath=none

git diff --numstat HEAD -- simulation/input/test/pubspec/lock và status test | PASS regression không đổi | logpath=none

Get-FileHash SHA256 APK local/snapshot và10 source | PASS khớp | logpath=none

view_image6PNG | PASS quan sát task1 | logpath=none

Một rg dùng glob audit* trong đối số path lỗi123 đã được thay bằng đọc đúng file/-g '*audit*'; không thiếu manifest.

## Giới hạn

Chưa runtime pause/resume sau route patch, pending prepare/late exit race, exit trong Dash, gameplay sau HUD mới, máy thật/Internet/audio. Không dùng49tests/ảnh task1 thay oracle HUD task2. Source/hash/ảnh mới được QA kiểm độc lập; gates chạy của Lead được kế thừa rõ.
