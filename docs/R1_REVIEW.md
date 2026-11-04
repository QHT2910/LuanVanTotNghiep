# Bàn giao lượt cải thiện R1

Ngày 04/11/2026. Đầu ra để Cindy rà soát độc lập; không xác nhận luận văn hoặc game đã hoàn tất.

## Nhóm và trách nhiệm

Tái sử dụng research, thesis, game-design, diagrams, developer, qa; không tạo bản trùng. Lead được runtime xác nhận `gpt-6.1-sol`/OpenAI; sáu worker được xác nhận cùng model. `gemini-4-argon`/`google-gemini-api` có trong danh mục đã kết nối, nhưng đổi riêng research bị automatic approval review từ chối vì yêu cầu chuyển model không có xác nhận trực tiếp của người dùng. Không đổi model hoặc provider của Lead/toàn ứng dụng. Model switch remains blocked pending the owner's direct approval; research stayed on GPT-6.1-Sol.

| Ai | Đầu ra thực tế | Giới hạn |
|---|---|---|
| research | research/verification-r1.md | Đọc lại chín nguồn, phân biệt nguồn kế thừa; không compile ở worker |
| thesis | Ba chương, REFERENCES.md, CITATION_MAP.md | 19 nguồn số duy nhất; không đổi bố cục hoặc tự tuyên bố thực nghiệm |
| game-design | Nội dung design/ui-spec-r1.md | Worker trả trực tiếp; Lead lưu do lỗi tạo thư mục. Chưa có file thiết kế UI |
| diagrams | SVG UML, lớp/tuần tự R1, traceability-r1.md | Lead render PNG và thay tham chiếu trong bản thảo |
| developer | Đã chạy version/doctor/devices/adb và kiểm tra SDK/cache; báo cáo gửi muộn ở game/evidence-r1/developer-environment.md | Không resolve/probe/analyze/compile ở worker; kết quả Lead lưu riêng |
| qa | Nội dung qa/review-r1.md | Rà tài liệu độc lập, bảy vấn đề và tám nhóm ca thử game chưa chạy; Lead lưu |
| Lead | Tích hợp, luồng UI02, ví dụ Dart, probe, Word v0.3, kiểm tra và Git | Giữ giới hạn thiết bị/hạ tầng và các quyết định còn mở |

## Vấn đề đã sửa

| Mức độ | Vấn đề | Sửa và bằng chứng |
|---|---|---|
| Cao | Hướng dẫn getter/lifecycle/khởi tạo còn thiếu chi tiết | Làm rõ getter bản sao, lifecycle, initializeStaticResources và single update loop theo bảng nguồn R1 |
| Cao | Khả năng Android bị diễn đạt quá rộng | Tách Flutter GPU và Impeller, yêu cầu xác minh API/GPU/backend thiết bị; không suy từ Flutter version thành render thành công |
| Trung bình | SCENE/LT/HT không thống nhất | Hợp nhất 19 nguồn số, loại URL trùng, giữ ngày truy cập cũ/mới chính xác và có map |
| Trung bình | Use case tổng quát chỉ là flowchart | Thay bằng UML có actor, boundary, ellipse, association; không đưa server ra ngoài boundary; bổ sung UC08 theo F01 |
| Trung bình | Lớp thiếu các trường đã có trong bảng | Nguồn R1 thêm score/result, ready/lastSeen, vị trí/thời điểm ném, velocity/facing/cooldowns/slotIndex |
| Trung bình | Tuần tự xử lý kết quả ngoài vòng tick | Nguồn R1 có guard resolved, nhánh kết quả trong loop và check-ball trước pha mới; bổ sung bảng trạng thái Player/Ball |
| Trung bình | Luồng UI bỏ qua màn hình tạo/vào phòng | Hình 3-8 mới có đủ UI01–UI06; thống nhất hướng ngang là đề xuất và cài đặt từ Menu |
| Trung bình | Không có ví dụ API được compile | Package Scene biệt lập qua analyze/build bundle; ví dụ Ch2 dùng đúng mã của probe |
| Thấp | README và trạng thái lịch sử dễ lẫn hiện hành | CURRENT_STATUS.md trỏ v0.3, v0.1/v0.2 giữ lịch sử; wireframe tự sinh không nằm trong bản mới |

## Vấn đề còn lại

| Mức độ | Việc còn lại | Hướng cải thiện |
|---|---|---|
| Cao | Chính sách rời trận/timeout và phân xử Block–qua rổ cùng tick chưa chốt | Sinh viên/thiết kế xác nhận oracle; không tự coi nhánh ưu tiên trong sơ đồ là luật đã duyệt |
| Cao | Chưa có bộ UI bằng phần mềm bên thứ ba | Chọn công cụ và cung cấp file/session; dùng ma trận UI và component để vẽ rồi xuất ảnh thật |
| Cao | Không có Android kết nối, chưa kiểm chứng rendering trên Redmi Note11 hoặc Internet | Kết nối một máy thật để kiểm backend/GPU trước; bổ sung máy thứ hai/endpoint sau, không thay bằng loopback |
| Trung bình | ackSeq đã rõ mốc xử lý nhưng thiếu chính sách gap/reconnect/phạm vi phiên hoàn chỉnh | Cụ thể hóa giao thức rồi bổ sung ca thử input từ chối, seq thiếu và dữ liệu trận cũ |
| Trung bình | Hình học vùng rổ, kiểm tra vượt vùng giữa bước và vòng đời sự kiện chưa triển khai | Đặc tả swept crossing, event retention và reset theo matchId; chưa đặt sai số hoặc thời lượng tùy ý |
| Trung bình | Nhiều use case mới có mô tả ngắn; activity còn là flowchart xử lý | Bổ sung đặc tả cần thiết và cân nhắc UML activity khi hoàn thiện, tránh lặp sơ đồ |
| Trung bình | Sơ đồ tuần tự dài; Word chưa kiểm tra từng trang/mục lục/header/footer | Tách hình khi dàn trang cuối và kiểm tra bản in trước nộp; không coi XML hợp lệ là bố cục hoàn chỉnh |
| Vận hành | Ba worker chưa ghi được thư mục mới; root runtime vẫn cũ | Cần chuyển quyền/working directory qua luồng host được phép ở lượt sau; không lách ghi sang workspace cũ |

## Kiểm tra thực sự chạy

- `flutter --version`, `flutter doctor -v`, `flutter devices --machine`: Flutter 3.47.8, Dart 3.13.7, Android SDK 37; chỉ Windows/Chrome/Edge, không Android.
- `flutter pub get`: exit 0; lockfile Scene 0.24.3 / scene 0.4.1 / vector_math 2.4.4.
- `flutter analyze`: exit 0, không có issue, lần cuối sau khi sửa smoke để tránh kết luận sớm.
- `flutter build bundle --debug --target-platform android-arm64`: exit 0; stdout rỗng nhưng kernel có thật, 63.705.384 byte và SHA-256 trong game/evidence-r1/checks.json. Không phải APK hoặc render trên máy thật.
- `dart tool/sync_smoke.dart`: exit 0; hai client cùng máy nhận x=3/tick=2, input trùng không làm thay đổi x, ack riêng bằng 1. Không kiểm chứng game/Android/Internet/hiệu năng.
- Render SVG UML bằng canvas; render lớp, tuần tự và luồng màn hình R1 bằng Mermaid CLI/Chrome; Lead xem ảnh UML, tuần tự và luồng UI. Không gọi đây là thiết kế UI bằng Figma.
- `node tools/validate-manuscript.cjs`: kiểm tra bố cục, mã nguồn hình, trích dẫn, XML và hình nhúng. Kết quả lưu docs/r1-validation.txt.
- `git diff --check`: kiểm tra diff trước commit. Chỉ Lead commit/push bằng tools/finish-session.cjs sau khi tích hợp.

## Sản phẩm và Git

- thesis/Ban_thao_Chuong_1-3_v0.3.docx và thesis/BAN_THAO_CHUONG_1-3.md là bản hiện hành.
- docs/CURRENT_STATUS.md tổng hợp trạng thái; docs/WORKER_OWNERSHIP.md phân quyền đầu ra.
- Xem commit và kết quả push thực tế trong phản hồi bàn giao cuối lượt; báo cáo này không tự suy ra push thành công chỉ vì commit local tồn tại.
- Bản gốc trường, cache/build và hồ sơ môi trường cá nhân không được đưa lên repo công khai; lịch sử cũ được giữ.
