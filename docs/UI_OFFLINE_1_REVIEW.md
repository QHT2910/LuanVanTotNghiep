# UI offline — mốc 1: Menu và điều hướng

12/11/2026. Lead accept implementation/gates để QA và Cindy review; chưa nhận milestone HUD hoàn chỉnh. Nền game M3b, HEAD lúc nhận task 1ad37e9; không thay simulation/input/AA/ticker/scoring/dependency hoặc 47 test cũ.

## Worker và review

Orca developer o7v9oxz0vq8wm7n5527dnta1 đã bàn giao proposal chỉ đọc qua session cũ, metadata Codex/gpt-6.1-sol medium; không nhận Terra/Argon đã chạy. Root worker vẫn cũ nên không được ghi. Lead review ACCEPT hướng route mới/exit guard/khóa tính năng chưa có, sau đó tự tích hợp. Không dispatch worker/model mới.

Ba file presentation mới: offline_app.dart, menu_pages.dart, practice_navigation.dart; main chuyển sang menu. PracticePage thêm _leaving, pending-init/lifecycle guard và wrapper trở Menu. Lead dùng menu native đơn giản hơn painter proposal, không nhận pixel-perfect Figma. Settings thật chỉ là màn thông tin với công tắc/slider disabled vì chưa audio engine. Tạo/Vào phòng disabled, lý do hiển thị. Không connection/room/clock/opponent giả.

Test mới có hai ca gồm nhiều bước route/back/reentry/settings và ba viewport 320×640,724×280,960×540. Builder fixture không Scene/GPU: không nâng thành bằng chứng Scene cleanup. Không tích hợp toàn bộ sáu ca proposal/ticker fixture; giới hạn này giữ rõ.

## Gate Lead thực chạy

- dart format các presentation/main/test mới: PASS; game/evidence-ui-offline-1/format.txt.
- flutter analyze: PASS no issues; analyze.txt.
- flutter test: PASS 49 tests, giữ nguyên 47 cũ; tests.txt.
- flutter build apk --debug --target-platform android-x64 --target lib/main.dart: PASS; build.txt.
- node tool/audit-apk-sources.cjs: PASS 10 source nhúng kernel, không stale path; source-apk-audit.json.
- adb install -r: PASS; install.txt. Launch khi AVD đang boot chưa lên app; sau boot launch-ready.txt xác nhận COLD/Status ok. Không coi screenshot launcher ban đầu menu.png là app Menu. Dùng menu-ready.png trở đi.
- Một Pixel_9a hiện có đã mở visible, không tạo AVD mới. VSCode mở menu_pages.dart trong workspace chỉ game/offline-practice; receipt title/window đã đọc. Emulator có cảnh báo RAM khuyến nghị, không đổi AVD/SDK.
- Node checks từ clean route sequence: PASS; checks.json/runtime-events.json. Phân biệt eventId có thể khởi động lại khi vào phiên mới.

## Runtime mới

Menu → Settings → back → Practice thật. Ảnh menu-ready/settings/practice đã Lead xem. Menu/Settings đọc được, nút Menu góc phải không che joystick; sân/HUD vẫn M3b, chưa Figma HUD mới.

Shell harness DashTouch hiện có gửi hai pointer thật: pointer0 ở nút ném, pointer1 ở Menu; nhãn joystick/shoot trong stdout chỉ là tên cũ, không oracle. Trace có charge_start → charge_cancel reason return_menu → paused, không shot_release. Ảnh menu-after-charge-exit đã xem. Vào lại Practice HUD điểm0/ready/lượt1/charge0; Android Back → Menu ảnh menu-after-system-back đã xem. Không có exception/multipleTicker trong log process được lấy. Không coi điều này là chứng minh mọi race/pending-init hoặc exit trong Dash.

APK đã cài/local/snapshot cùng SHA256 2599f6928e7c4b2f81d761de04cbcff818a222886b3e8637a3faff5721afa9a8. Snapshot local demos/releases/ui-offline-1/offline-practice-ui1-x64.apk ignored. Trước build đã copy/verify APK M3b hash5ea9514a…d0f44 vào demos/releases/pre-ui-offline-1/app-debug.apk; snapshot M3b cũ giữ.

## Còn thiếu

QA độc lập đã PASS phạm vi task1, không P1/P2: qa/ui-offline-1.md. Lead ACCEPT sau đọc review/diff/checks; chốt riêng mốc để Cindy review trước HUD task2. Task tiếp HUD responsive theo UI04 mới, giữ Scene/gameplay và multitouch; runtime movement/charge/jump/Dash/ném sau thay HUD phải có ảnh/oracle mới, không dùng mốc điều hướng này thay. Còn settings chưa audio playback, chưa backend, chưa máy thật/Internet. Không sửa luận văn/publication.

Một lệnh tạo log nhầm thư mục nested game/offline-practice/game/evidence-ui-offline-1; logs thực nằm game/evidence-ui-offline-1. Cleanup bị auto-review từ chối do chưa xác minh nội dung, để nguyên, không bypass; không ảnh hưởng gates. Public runtime log chỉ lấy JSON sự kiện; raw device logs ở .scratch.
