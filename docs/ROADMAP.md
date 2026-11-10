# Kế hoạch tiếp tục — 10/11/2026

Nền ab9bf92: M1 offline, M2 joystick, M3a nhảy đã commit/push và QA theo phạm vi một AVD. Không chạy lại gate cũ khi không đổi source. Giữ Wordv0.3 ngoài lượt.

1. Bảo toàn demo: manifest commit/source/evidence/ABI/hash; copy APK M3a local trước build mới. M1/M2 APK đã bị ghi đè, chỉ source/evidence và hướng dựng lại được bảo toàn.
2. Tổ chức VS Code: workspace chỉ trỏ game/offline-practice theo đính chính mới; hồ sơ/snapshot ngoài cây Flutter. Refactor app thành src/simulation,input,presentation, giữ main.dart. Sau đổi imports chạy analyze/34tests/build và đối chiếu source/APK. Commit tổ chức thư mục riêng, không đổi gameplay.
3. UI Figma: kiểm tool/session thật, mở app, cần Computer Use và người dùng tự đăng nhập nếu yêu cầu. Ưu tiên HUD, sau menu/phòng/lobby/kết quả/settings theo UI01–06. Chỉ hoàn thành khi có editable Figma thật và PNG export; không thay bằng SVG tự sinh. Hiện thiếu desktop-control tool, không suy cài app là có connector.
4. Luận văn: dùng hai skill, rà Ch2 input/lifecycle/jump/crossing, Ch3 đề xuất so triển khai, Ch4 phạm vi AVD. Bổ sung nguồn official trước khẳng định; source nhỏ, review/claim map riêng. Chưa xuất lại Word/PDF. Style mới theo THESIS_FORMAT_2026-11-09.md, không tự chọn After.
5. M3b Dash chỉ sau snapshot/structure gate: grounded-only, hướng joystick/facing, bounded/cooldown/edge, hủy charge; cấm nhảy/ném trong Dash, reset/background an toàn. Unit/widget/runtime và scoring regression, QA rồi chốt Git, chưa Block/mạng/model thật.

Mỗi mốc mở file thật trong VS Code, báo trước/sau code và kết quả test/ảnh thực. Lead ghi/tích hợp/chạy/Git; Orca Worker hiện root OLD chỉ đọc đề xuất/review. Không worker trùng/model/provider mới. Ưu tiên snapshot/structure/Figma session/thesis review trước Dash nếu phải chia phiên; ghi phần dở trong checkpoint, không tự đánh dấu hoàn thành.
