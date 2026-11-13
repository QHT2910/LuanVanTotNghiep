# Kế hoạch tiếp tục — cập nhật 13/11/2026

## Đích hoàn thành và thứ tự hiện hành

Đích là game Android 3D có vòng chơi hoàn chỉnh trong phạm vi đã chốt: phòng 1v1, di chuyển/ném/nhảy/Dash/Block, ghi 2/3 điểm, kết thúc theo 11 điểm hoặc 3 phút và hiển thị kết quả. Quy tắc xử lý các tình huống biên phải được chốt và kiểm trước nghiệm thu. HUD offline, model probe và các demo riêng chỉ là milestone; không đủ để tuyên bố game hoàn thành. Không mở rộng tính năng chỉ để trang trí.

Thứ tự: HUD task2 → probe model/animation trên flutter_scene 0.24.3 và tích hợp → mạng tối thiểu hai client → vòng trận 1v1 hoàn chỉnh. HUD hiện đã có gate 52 tests/build/audit/runtime, đang được Orca QA đọc độc lập; chưa kết luận toàn game. Reference UI là bộ Figma user-revised-v010, không bản concept cũ. Kế hoạch ngày 10/11 bên dưới là lịch sử, không dùng các blocker hoặc lệnh chờ cũ thay trạng thái này.

Mỗi nội dung nghiên cứu phải nối được thành chuỗi: thành phần Scene → code thực chạy → tình huống thử → ảnh/log/data → nhận xét và giới hạn. Bảng sau là tiêu chí nghiệm thu, không phải báo cáo tất cả đã đạt.

| Thành phần | Code/hiện thực cần truy vết | Tình huống và bằng chứng cần có |
|---|---|---|
| Scene graph và transform | Quan hệ node, tọa độ nhân vật/bóng/rổ, cập nhật transform | Di chuyển/nhảy, giữ và thả bóng; log trạng thái và ảnh đúng bản APK |
| Camera | Cấu hình camera và ánh xạ tọa độ điều khiển | Góc nhìn sân, phạm vi hiển thị, kiểm hướng điều khiển và HUD safe area |
| Material và light | Material/ánh sáng thực dùng trong Scene | So sánh cấu hình có kiểm soát, ảnh và giới hạn backend/thiết bị |
| Asset/model | Nạp GLB, scale/orientation/material/skin | Asset origin/license/hash, warning/load data và ảnh model thực |
| Animation | Clip binding, transition, pause, tách animation khỏi luật mô phỏng | Idle/run/jump/shoot và Dash phù hợp; clip list, log và ảnh/video khi thực chạy |
| Flutter HUD và input | Widget tương tác nối mô phỏng/Scene | Đa chạm, cancel, lifecycle, charge/Dash và chuyển Menu; test + AVD evidence |
| Vòng game 1v1 | Hai client, phòng, trạng thái trận, ghi điểm và kết thúc | Chuỗi vào phòng → sẵn sàng → chơi → kết quả; đối chiếu hai phía, lỗi/ngắt kết nối và giới hạn mạng |

Lead tự review sau mỗi task terminal trước tích hợp hoặc tuyên bố hoàn thành: artifact/code thay đổi, analyze/tests/build/APK, runtime, lỗi còn biết và mức bằng chứng. Phân biệt kiểm tự chạy với kết quả kế thừa; bàn giao Cindy review độc lập từng milestone. Tuyên bố hoàn thành game chỉ sau gate vòng chơi toàn tuyến, không ghép kết quả các probe rời thành nghiệm thu full game.

Quota: kiểm primary và secondary ở đầu task/mốc/trước công việc dài khi host cung cấp; primary used ≥95% dừng nhận task/build dài, dừng worker an toàn, lưu checkpoint và reset timestamp. Chỉ resume sau xác minh quota đã reset, không đổi tài khoản/provider để né giới hạn. Hour reset không có nghĩa weekly reset.

## Kế hoạch lịch sử — 10/11/2026

Trạng thái chốt: organization811493d, thesis source1ac51f9, DashM3b6d1c120 đã push. Snapshot/workspacegame-only/refactor/source review/DashQA hoàn tất trong phạm vi bằng chứng đã ghi. Việc đang chờ là UI Figma chính thức: đã cho phép kết nối nhưng chưa tool/session, chưa source/PNG. Không làm Block/mạng/tính năng mới trước review Dash. Các mục dưới ghi thứ tự kế hoạch và cách kiểm, không yêu cầu chạy lại mốc đã đạt.


Nền ab9bf92: M1 offline, M2 joystick, M3a nhảy đã commit/push và QA theo phạm vi một AVD. Không chạy lại gate cũ khi không đổi source. Giữ Wordv0.3 ngoài lượt.

1. Bảo toàn demo: manifest commit/source/evidence/ABI/hash; copy APK M3a local trước build mới. M1/M2 APK đã bị ghi đè, chỉ source/evidence và hướng dựng lại được bảo toàn.
2. Tổ chức VS Code: workspace chỉ trỏ game/offline-practice theo đính chính mới; hồ sơ/snapshot ngoài cây Flutter. Refactor app thành src/simulation,input,presentation, giữ main.dart. Sau đổi imports chạy analyze/34tests/build và đối chiếu source/APK. Commit tổ chức thư mục riêng, không đổi gameplay.
3. UI Figma: kiểm tool/session thật, mở app, cần Computer Use và người dùng tự đăng nhập nếu yêu cầu. Ưu tiên HUD, sau menu/phòng/lobby/kết quả/settings theo UI01–06. Chỉ hoàn thành khi có editable Figma thật và PNG export; không thay bằng SVG tự sinh. Hiện thiếu desktop-control tool, không suy cài app là có connector.
4. Luận văn: dùng hai skill, rà Ch2 input/lifecycle/jump/crossing, Ch3 đề xuất so triển khai, Ch4 phạm vi AVD. Bổ sung nguồn official trước khẳng định; source nhỏ, review/claim map riêng. Chưa xuất lại Word/PDF. Style mới theo THESIS_FORMAT_2026-11-09.md, không tự chọn After.
5. M3b Dash chỉ sau snapshot/structure gate: grounded-only, hướng joystick/facing, bounded/cooldown/edge, hủy charge; cấm nhảy/ném trong Dash, reset/background an toàn. Unit/widget/runtime và scoring regression, QA rồi chốt Git, chưa Block/mạng/model thật.

Mỗi mốc mở file thật trong VS Code, báo trước/sau code và kết quả test/ảnh thực. Lead ghi/tích hợp/chạy/Git; Orca Worker hiện root OLD chỉ đọc đề xuất/review. Không worker trùng/model/provider mới. Ưu tiên snapshot/structure/Figma session/thesis review trước Dash nếu phải chia phiên; ghi phần dở trong checkpoint, không tự đánh dấu hoàn thành.
