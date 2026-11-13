# QA HUD task2 — 13/11/2026

Orca tester bkm37d3uiwhgp757im7y9hov, session hiện có; metadata Codex/gpt-6.1-sol medium. Worker chỉ đọc, không đổi model/provider, ghi project, GUI/ADB hoặc chạy lại build/test. Lead đã đọc report terminal và ACCEPT phạm vi source HUD, provenance và bằng chứng một AVD; không có P1/P2 chặn bàn giao Cindy. Không nghiệm thu full game/model/Figma toàn cảnh.

## Kiểm mới bởi QA

- Đọc diff so318d094: typed notifier/slots ổn định; input nằm ngoài builder; callbacks/epoch/owner/mapping giữ nguyên. Dash thành công chỉ xóa shotPointer, không reset joystick/jump owner. Logical radius64/thumb20/travel44; visualThumbRadius27 chỉ đổi vẽ. Vùng nhãn Dash64×20 không dịch nút. Optional style không đổi cancel/ownership. Simulation/deps/49 tests cũ không diff; thêm3ca HUD.
- Tự hash11source đều khớp source-apk-audit-accepted.json. APK local và snapshot calibrated cùng db9a6b7d56e05fb360fb29b8ab2fcfe9c26568c2cacea375131499489af203db. Identity bản cài là bằng chứng Lead kế thừa; localKernelMatchesAPK=null vẫn chưa so.
- Đọc verified/ranges/events/assertions/checks, không dùng calibration cũ. Hai release/score3+3=6; airborne playerY0,8841927083/origin2,6841927083/feet0. Dash0,2s/1,6 và giữ quá cooldown chỉ1start. Bounds thực từ x3,6388936818 đến3,78. Cancel không release; reset về đất giữ6. Pause/resume cùngt66,7416666667/y0,8038; pointer_cancel trước paused đúng platform. Exit charge/AndroidBack pause; reentry score0/lượt1.
- Tự xem8ảnh verified: figma-vs-avd, hud-controls-comparison, hud-neutral, hud-jump-shot-active, hud-dash-duration-active, hud-background-finished, menu-charge-exit, hud-reentry. HUD bám reference Page3/node35:2, nút tách riêng, không thấy che rổ/đè vùng chạm trong ảnh. Contain không stretch. Không dùng hud-resume chuyển tiếp Android làm app ổn định. Scene vẫn primitive.

## Gates và nguồn thực thi

Gate QA: Get-Content/rg + git diff318d094 | PASS phạm vi nguồn/oracle | logpath=none.

Gate QA: git diff --numstat simulation/test/pubspec/lock + status test | PASS49tests cũ/simulation/deps khôngdiff | logpath=none.

Gate QA: Get-FileHash11source/APK/snapshot | PASS | logpath=none.

Gate QA: view_image8ảnh verified | PASS quan sát theo giới hạn | logpath=none.

Gates kế thừa Lead: analyze No issues, tests52PASS, build/install/audit11source/x64 và runtime assertions PASS. Worker không chạy lại; không nhận fixture là Scene/GPU. Script assertion ghiJSON nên QA chỉ đọc.

## Giới hạn và quyết định

Chưa ba pointer, toàn bộ per-pointer cancel/races trên AVD, máy thật, hiệu năng, Internet hoặc full Figma scene/model. Lead ACCEPT milestone HUD để Cindy review; chưa mở model probe. Review/trace chi tiết: docs/HUD_TASK2_REVIEW.md. Snapshot UI1/M3b giữ nguyên.
