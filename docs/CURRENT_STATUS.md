# Trạng thái hiện hành R1 / v0.3

Ngày cập nhật: 04/11/2026. Đây là bản để rà soát tiếp, chưa phải quyển nộp hoặc sản phẩm game hoàn chỉnh.

Điểm bắt đầu cho phiên/nén ngữ cảnh tiếp theo: [CONTEXT_HANDOFF.md](CONTEXT_HANDOFF.md), quy trình [CONTEXT_PROTOCOL.md](CONTEXT_PROTOCOL.md). Snapshot host lượt context cho thấy sáu worker không làm việc, queue đều 0; chưa sửa root hoặc đổi model, không chạy lại R1. Checkpoint không có nghĩa auto rollover đã được cài.

## Sản phẩm hiện hành

- Bản tổng hợp: thesis/BAN_THAO_CHUONG_1-3.md; ba chương nguồn giữ bố cục sinh viên chỉ định.
- Bản Word: thesis/Ban_thao_Chuong_1-3_v0.3.docx.
- Danh mục chung: thesis/REFERENCES.md, 19 nguồn duy nhất; ánh xạ mã cũ: docs/CITATION_MAP.md.
- Use case UML: diagrams/3-2-usecase-uml.svg và PNG. Lớp, tuần tự và luồng màn hình dùng các nguồn có hậu tố r1.
- Rà nguồn: research/verification-r1.md. Đặc tả UI: design/ui-spec-r1.md. Rà QA: qa/review-r1.md.
- Probe biệt lập và bằng chứng: game/probe-r1/, game/feasibility-r1.md, game/evidence-r1/.

## Bằng chứng đã có

Chương 2 được làm rõ API theo nguồn chính thức. Ví dụ Scene cơ bản qua analyze và build bundle với Flutter 3.47.8/Dart 3.13.7, Scene 0.24.3. Có kernel đầu ra được ghi hash; không có APK hoặc bằng chứng render Android.

Smoke test hai client loopback qua, có kiểm tra input trùng và ack riêng. Không suy ra khả năng chơi qua Internet hoặc hai điện thoại. Android SDK 37 sẵn sàng nhưng hiện không có thiết bị Android kết nối.

Các ca thử game trong QA chưa chạy; Ch4–5 chưa được điền kết quả. Chính sách rời/timeout, phân xử Block–qua rổ cùng tick, giao thức và tham số vẫn còn cần quyết định hoặc kiểm chứng.

## UI chưa hoàn thành

Figma mới được đề xuất; chưa có xác nhận chọn công cụ hoặc file/session thiết kế được truy cập. Worker kiểm tra chưa có kết nối Figma/Penpot hoặc browser design session sẵn sàng. Bộ UI hiện chỉ có đặc tả sáu màn hình và trạng thái. Hình wireframe tự sinh 3-9 không nằm trong Word hiện hành và không được coi là thiết kế bằng công cụ bên thứ ba.

## Lịch sử

v0.1/v0.2, flowchart use case cũ, lớp/tuần tự/luồng màn hình cũ và wireframe 3-9 được giữ để truy lịch sử. Không dùng các tệp đó để mô tả tình trạng mới nhất. Không xóa lịch sử Git hoặc ghi đè bản Word cũ.

## Nhóm và model

Tái sử dụng đủ sáu worker; Lead và tất cả worker giữ GPT-6.1-Sol. Route Gemini 4 Argon tồn tại nhưng thao tác đổi research bị automatic approval review từ chối do thiếu đồng ý trực tiếp của người dùng. Không đổi Lead, model toàn ứng dụng hoặc dùng model khác thay thế âm thầm.

Root của worker vẫn là thư mục cũ. Research/thesis/diagrams ghi được đầu ra vào đường dẫn hiện hành; game-design/developer/QA bị chặn tạo thư mục. Lead lưu báo cáo trả trực tiếp và chạy probe bằng quyền workspace hiện hành. Chỉ Lead commit/push.

Bản Word đã được kiểm tra cấu trúc và hình nhúng; bố cục từng trang, mục lục/header/footer/caption và độ dài quyển vẫn cần rà trên Word trước khi nộp. Sơ đồ tuần tự dài cần cân nhắc tách hình khi dàn trang cuối.
