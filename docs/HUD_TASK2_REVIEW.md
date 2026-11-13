# HUD task2 — bàn giao QA, 13/11/2026

Lead review ACCEPT implementation để QA độc lập; chưa có verdict QA task2. Base Git 318d094. Nguồn chuẩn là UI04 Page3 node35:2 trong manifest user-revised-v010; không dùng concept cũ. Đã xem ảnh verified/figma-vs-avd.png và hud-jump-shot-active.png: các nút tách riêng, thanh canh ném gần Ném, HUD trên giữa, joystick trái dưới. Giữ bố cục/màu/chữ/hình nút theo reference và thích nghi dữ liệu offline. Cảnh sân/nhân vật vẫn primitive của demo, chưa phải nền Figma hoặc model hoàn thiện; không tuyên bố pixel-perfect toàn cảnh.

## Thay đổi và review

Orca developer o7v9oxz0vq8wm7n5527dnta1 giao proposal chỉ đọc; Lead tích hợp và kiểm thực tế. Metadata route gpt-6.1-sol medium, không có bằng chứng Terra/Luna/Argon chạy task này. Typed HUD không đặt input trong builder thay đổi theo charge. Simulation, dependency, callback ownership/epoch/mapping và 49 tests cũ giữ nguyên.

Hai lỗi trong lượt calibration đã sửa: nhãn Dash làm dịch nút → cố định vùng nhãn; thumb vẽ lớn làm đổi độ nhạy → tách visualThumbRadius27 khỏi logical thumbRadius20/travel44. Test mới kiểm owner khi HUD cập nhật, geometry vùng chạm và target/status/độ nhạy. Không có chi phí/usage model riêng được host cung cấp để so sánh.

## Gate thực chạy bởi Lead

- analyze: PASS, game/evidence-ui-offline-2/analyze-accepted.txt.
- flutter test: PASS 52 bài (49 cũ + 3 mới), tests-accepted.txt cùng thư mục.
- build debug Android x64: PASS, build-accepted.txt.
- source audit: PASS 11 source nhúng kernel, x86_64, không source phẳng cũ; source-apk-audit-accepted.json. localKernelMatchesAPK=null là chưa so.
- install: PASS, install-accepted.txt. Hash APK đã pull từ bản cài trùng local; verified/installed-apk.json.
- node tool/assert-hud-runtime.cjs verified: PASS, verified/assert-runtime.txt và runtime-assertions.json.
- node tool/compare-hud.mjs verified: PASS tạo bảng so ảnh cùng tỷ lệ chứa, không kéo méo; verified/comparison-check.txt.

Runtime một Pixel_9a emulator-5554: hai chuỗi hai pointer move+shoot và jump+shoot ghi 3+3=6; airborne playerY0,8841927083, originY2,6841927083, feetY0. Dash 0,2s/1,6 đơn vị, giữ quá cooldown không repeat; clip từ trong sân đến x3,78. Cancel không ném; reset về đất giữ điểm6; pause/resume cùng simTime66,7416666667/y0,8038; platform pointer_cancel xảy ra trước paused, không phải mọi cancel đều mang nhãn background. Exit charge và Android Back pause; reentry là phiên mới.

Nguồn bằng chứng cuối: các log *-accepted.txt, source-apk-audit-accepted.json và thư mục verified/. Các file ở root evidence và final/ là calibration/thăm dò phiên trước, không thay oracle cuối. hud-resume.png là ảnh chuyển tiếp Android, giữ local/ignore; ảnh ổn định là hud-background-finished.png.

APK cuối SHA256 db9a6b7d56e05fb360fb29b8ab2fcfe9c26568c2cacea375131499489af203db. Snapshot mới offline-practice-ui2-calibrated-x64.apk giữ bên cạnh candidate cũ, không ghi đè UI1/M3b. Xem verified/checks.json để truy vết.

## Giới hạn và bước tiếp

Không ba pointer, máy thật, Internet, benchmark hoặc mọi race/cancel riêng trên AVD. Fixture và unit không thay runtime Scene. Khung hình quan sát không chứng minh mọi resolution. Sau QA/Cindy review mới probe model pinned0.24.3 theo game/MODEL_PROBE_PROPOSAL.md; Fox chỉ baseline, chưa nhân vật bóng rổ. Chưa tải/mua asset mới hoặc chạy model probe trong mốc này.

Quota kế thừa host Cindy đầu 13/11: primary0% used, secondary81% used, primary resetsAt1794559578; không phải refresh trực tiếp của Lead. accounts.settings not_exposed. Cần Cindy refresh trước task/build dài kế tiếp; primary>=95% dừng/checkpoint. Ba Word modified nằm ngoài phạm vi, không stage.

## QA terminal và Lead review

Orca QA PASS không P1/P2; Lead ACCEPT milestone sau đọc report source/hash/8ảnh, lưu qa/hud-task2.md. Chưa full game. Evidence TXT được chuyển UTF16→UTF8 để đọc Git, không sửa nội dung; quét mẫu URI/IP không hit.
