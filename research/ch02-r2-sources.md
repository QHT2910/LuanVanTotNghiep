# Hồ sơ nguồn R2 — 05/11/2026

Nguồn [1]–[19] giữ số và ngày đọc cũ; không nhận đã đọc lại tất cả. Orca Worker thesis đã mở tám nguồn mới [20]–[27] qua web theo hồ sơ ch02-thesis-r2-handoff.md. Lead mở trực tiếp [28]–[34], fscene.dev và trang Videos. Package cache 0.24.3 theo lockfile được developer/diagrams và Lead đối chiếu; [35] định danh bản phân phối, không phải khẳng định đã checkout một tag GitHub có tên đoán.

| Khẳng định | Nguồn | Mức sử dụng và giới hạn |
|---|---|---|
| Pipeline vertex/raster/fragment/depth | [20] Vulkan Specification | Nguyên lý; không gán mọi stage Vulkan thành API Scene |
| Cấu trúc glTF/GLB và màu | [21] glTF 2.0 | Phân biệt container, semantics; không bảo đảm mọi extension |
| Fixed timestep và backlog | [22] Fiedler | Tác giả gốc; không chứng minh tất định |
| Collider/body và kiểu điều khiển | [23] Rapier JS | Nguyên lý, không sao API JS thành Dart |
| Authority, prediction/replay, interpolation | [24]–[26] Gambetta | Mô hình; chưa triển khai full game |
| Thiết bị thật/profile và metric | [27] Flutter | Không lấy debug hoặc UI graph làm toàn bộ GPU metric |
| MVP/viewport | [28] LearnOpenGL | Vector cột; không áp NDC depth OpenGL vào Scene |
| Normal inverse transpose | [29] Basic Lighting | Hướng pháp tuyến dưới nonuniform scale; không phải thuật toán gameplay |
| Semi-implicit Euler | [30] Integration Basics | Bước h và sai số; không tự chốt physics backend |
| BRDF, microfacet, metallic/roughness | [31] PBR Theory | Nền tảng, không xác nhận shader cụ thể Scene |
| Buffer/view/accessor | [32] Khronos Tutorial | Cấu trúc dữ liệu asset |
| Joint/weight/inverse bind/skinning | [33] Khronos Tutorial | Không có asset runtime mới |
| Quaternion trong chuyển động 3D | [34] Fiedler Physics in 3D | Mô hình toán, không API Scene |
| Mount trước load | [35] source package 0.24.3 | Cache component.dart; khác thứ tự web, không nói load đúng một lần trong mọi remount |

## Video bổ trợ

Đã truy cập https://fscene.dev/videos/ ngày 05/11/2026. Trang chính thức dẫn video https://www.youtube.com/watch?v=BPAg7qt5Dz0 — “Scene, a complete 3D engine for Flutter”, Flutter & Friends 2026, Stockholm, tháng 09/2026, dài 37:52. Tác giả diễn giả: Brandon DeRosier, theo trang hội nghị https://flutterfriends.dev/ và nguồn giới thiệu tác giả Scene. Mục liên quan theo chapter do trang Videos cung cấp: 6:48 materials/lighting; 9:56 physics/audio; 12:13 getting started/APIs; 16:58 graphics stack; 20:36 editor.

Mức truy cập: đã đọc metadata và mô tả chapter trên trang Scene; mở YouTube bị cache miss. Chưa xem hình/âm thanh hoặc đọc transcript. Không dùng chapter title để chứng minh API, không đưa ngày chính xác của video khi trang chỉ ghi tháng. Video 0.23 (08/2026, 1:39) chỉ là liên kết bổ trợ lịch sử, không xác nhận API 0.24.3. Các showcase FPS trên trang không phải số đo của đề tài.

## GitHub và phạm vi phiên bản

Đã đọc nội dung README repo bdero/flutter_scene qua kết quả web; nhánh hiện hành mô tả audio/editor/asset pipeline/rendering rộng. URL tag v0.24.3 thử mở bị cache miss: chưa xác minh tag hoặc commit tương ứng, không bịa hash GitHub. Khẳng định API hướng dẫn bám source package cache 0.24.3 và lockfile tutorial-r2. Mã package là nguồn kiểm chứng API thực tế, README master chỉ giúp khảo sát hệ sinh thái hiện tại. Research Argon không chạy được do saved thread yêu cầu provider cindy_openai đã mất; không nhận báo cáo nghiên cứu này là đầu ra Gemini.
