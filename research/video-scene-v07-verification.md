# Hồ sơ nguồn bổ sung từ video Scene

Ngày 07/11/2026, nền v0.6 / 8e67b8c. Đây là hồ sơ nội bộ, không đưa nguyên văn vào luận văn.

## Video — bằng chứng kế thừa

URL https://www.youtube.com/watch?v=BPAg7qt5Dz0. Cindy bàn giao tiêu đề “Scene: A complete 3D engine for Flutter — Brandon DeRosier | Flutter & Friends 2026”, ngày đăng hiển thị 01/10/2026, player 37:51. Cindy xem chọn đoạn 07:40,10:15,13:00,13:40,14:10,15:10,17:15,19:30,21:30,24:40. Lead/developer không xem lại video trong lượt này. Không có full transcript: Cindy báo get_transcript HTTP400, caption track HTTP200 rỗng. Không sửa hồ sơ R2 vốn chỉ có metadata.

13:00/13:40 hỗ trợ minh họa declarative/đổi màu giày; 14:10 component/update; 15:10 tài nguyên thay đổi trong khung xem; 17:15 phân tầng graphics; 24:40 vai trò editor. Không suy benchmark, backend Redmi, API hiện hành hoặc khả năng dự án từ demo diễn giả. Không mở rộng audio/ragdoll/AI.

## Nguồn Lead trực tiếp đọc

- https://fscene.dev/guides/declarative-scenes/ : mô tả widget giữ engine objects, diff theo identity, geometry/material giữ ổn định; không đồng nhất rebuild với tạo lại toàn GPU. Tài liệu web hiện hành.
- https://fscene.dev/guides/assets-and-loading/ : phân biệt GLB runtime và tiền xử lý build; các bước chuẩn bị tài nguyên và reveal. Tài liệu web hiện hành, cần source phiên bản cho mã.
- https://fscene.dev/editor/ : công cụ desktop authoring/inspection; trang niêm yết editor 0.24.0, yêu cầu phối hợp phiên bản. Chưa cài/chạy editor, không giả có editor 0.24.3.
- Package cache flutter_scene 0.24.3 theo package_config project R3: scene_view.dart phần ResourceGroup/loading/loadingBuilder/warmUp; declarative.dart phần retained objects/ownership/controller; hot_reload_coordinator.dart phần debug-only và reassemble/đăng ký tài nguyên. Không đoán Git tag hoặc dùng master thay nguồn package.

Coordinator chỉ hoạt động debug; reload tùy đường nạp được đăng ký. Geometry/material ổn định trong State là lựa chọn của bài thực hành, không kết luận mọi rebuild luôn miễn chi phí. Loading hoàn tất và GPU preparation là các mốc khác nhau, cần đo nếu đánh giá hiệu năng.

## Mã nguồn mới

Developer Orca bàn giao chỉ đọc, Lead lưu entrypoint game/tutorial-r3/lib/checkpoints/declarative/main.dart và toàn văn draft tại research/declarative-v07-developer-draft.md. Analyze và build bundle cho entrypoint declarative đã kết thúc với mã 0 ngày 07/11/2026; xem game/evidence-v07/checks.json. Chưa có bằng chứng runtime Android, warm-up hoặc hot reload. Không đổi A–F, dependency hoặc SDK. Hướng dẫn hot reload là quy trình có điều kiện.
