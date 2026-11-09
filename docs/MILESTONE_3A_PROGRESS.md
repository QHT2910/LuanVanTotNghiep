# M3a — QA đạt, chốt Git

09/11/2026. Nền112afd0, chưa commit M3a. Lead tích hợp và thực thi; Orca developer Sol6.1/root OLD chỉ đọc proposal. Orca Worker QA Sol6.1/rootOLD đã terminal PASS source/test/evidence/8ảnh, không P1/P2 chặn; qa/milestone-3a-final.md. Không thêm worker/model/provider. Wordv0.3 giữ nguyên; M2 ghi chú commit đã sửa đúng112afd0.

Gate thực chạy: flutter analyze PASS game/evidence-m3a/analyze-final.txt; flutter test PASS34 (22cũ+12mới) tests-final.txt; build x64 PASS build-apk-final.txt; install/launch PASS install-final.txt/launch-final.txt. Test đầu phát hiện latecancel setState sau dispose, đã fix mounted/owner cleanup, test không đổi. APK đầu HUDsimTime làm uiautomator không idle; đã bỏ clockHUD, giữeventtime, analyze/build/install lại. Không nhận lỗi trung gian là trạng thái cuối.

Runtime PASS workflows move-jump/jump-shot/repeat/reset/background/inside/inside-shot, logs runtime-*.txt và touch-*.txt. Assertions PASS assert-runtime.txt/runtime-assertions.json:6 jump,5 land+1reset; airborne repeatedjump bị từ chối. Hai airborne release (playerY0,906904/originY2,706904; playerY0,884193/originY2,684193), feetY0; score[[1,3,3],[2,2,5]], không lặp. Pause/resume cùngheight1,126304 vàsimTime65,675, chargecancel/background, khôngshot/jumpmới, sau đóland. Resetgrounded giữ3. Exactlandtime khớpplanned. Joystick+jump và jump+shoot là hai ca hai ngón riêng, KHÔNG ba ngón đồng thời.

Ảnh thật game/evidence-m3a/2026-11-09-*:move-jump-air/release/land,jump-shot-air/release/land,repeat-air/land,reset-grounded,background-air/land,inside,inside-shot-air/release/land. Lead xem air/release/land/reset/background; HUD đọcđược khôngche rổ. Ảnh đã gửi timeline ngay từngmốc. Giữ một Pixel_9a visible và VSCode; chưa cóvideo, khôngstreamiPhone.

APK game/offline-practice/build/app/outputs/flutter-apk/app-debug.apk, SHA256d4745966535ecf924d13f617dc357c3c4549a77d3140176158c29b3719413c14. Audit source-apk-audit.json:5source nhúngkernel; installed-apk.json cùnghashlocal. Build/binary khôngGit. AA-none/ticker/Scene0.24.3/SDK/deps/joystickmapping giữ. Tham số jump thửnghiệm, arcgiảilại từheight, khôngsolver.

TXT chuẩn hóaUTF8/lọcprofile/debugURL/IP/MAC, raw .scratch/m3a-raw. Không cam kếtmọiPII. Bước tiếp QA chỉđọc source/test/helper/events/ảnh; Lead ràdiff/PII, chốtGit loạiWordv0.3 sauQA, bàn giao Cindy trướcDash. Chưa máy thật/benchmark/Internet/multiplayer/model/Figma. Phần dưới là lịch sử triển khai, không replay.
# M3a — nhảy, đang kiểm runtime

09/11/2026, nền112afd0. Orca developer chỉ đọc đề xuất; Lead tích hợp config/practice/main/jump_button và12tests mới. 34tests PASS (22cũ giữ nguyên); analyze PASS. Test đầu phát hiện latecancel setState sau dispose; đã fix owner cleanup/mounted guard, không đổi test. APK đầu build/install được; runtime hierarchy không idle do HUD hiển thị simTime liên tục. Đã bỏ clock HUD, giữ simTime event; đang analyze/build/install bản sửa, chưa có ảnh runtime M3a để nghiệm thu. Một Pixel_9a visible, không AVD trùng; VSCode mở file thật. Không Dash/Block/multiplayer/model/deps/SDK/AA/ticker mới, Wordv0.3 giữ nguyên. M2 đã commit/push112afd0, Cindy chấp nhận.

Nhảy analytic theo jumpSpeed5/gravity9.81, apex≈1.274, grounded-only/noqueue. Heldball theo playerY; release từ held sample; chân chiếu y0 để tính2/3; foot marker trênsân. Pause giữ bước nhảy/cancelcharge; reset grounded. Nút jump có owner/epoch, không autojump khi giữ qua landing. Shot arcade giải lại vận tốc từ origin cao, không cộng verticalvelocity nhân vật; không solver.

Bằng chứng đang ở game/evidence-m3a; logs initial không là kết quả cuối. Bước tiếp: runtime move+jump/jump+shot/repeat/reset/background/2point, xem ảnh/events, audit APK/source, QA chỉđọc, rồi chốt Git/bàn giaoCindy. ChưacommitM3a. Không replay boot/test cũ nếu không cần.