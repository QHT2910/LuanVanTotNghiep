# Bàn giao bản sơ bộ v0.1 — 2026-11-04

## Có trong phiên bản

- Nội dung Ch1–3 trong các file riêng và `thesis/BAN_THAO_CHUONG_1-3.md`.
- Bản Word `thesis/Ban_thao_Chuong_1-3_v0.1.docx` để đọc và sửa.
- 8 nguồn Mermaid và ảnh PNG đã xuất bằng Mermaid CLI/Chrome; thêm 1 wireframe SVG/PNG bố cục trận đấu. Cả 9 hình được nhúng trong Word. Use case tổng quát là flowchart mô phỏng quan hệ, chưa phải biểu diễn UML use case chuẩn.
- Nguồn Ch2 trong `research/ch02-sources.md`; chưa hợp nhất mã trích dẫn SCENE/LT thành danh mục số cuối.
- Quy cách xuất ban đầu: A4, lề trái 3 cm/còn lại 2 cm, Times New Roman 13, line spacing 1,3 và khoảng cách đoạn 6 pt. Tiêu đề phân cấp và ngắt chương đã thiết lập sơ bộ.

## Chưa phải bản nộp

- Chưa chọn tên game, chưa chốt toàn bộ luật/kỹ năng/kiến trúc. Thiết kế được ghi nhãn đề xuất.
- Hướng dẫn Ch2 đã đối chiếu nguồn nhưng chưa chạy; cần mở rộng bằng ví dụ Dart đã compile và hình thao tác thật sau khi dựng thử.
- Chưa có game, đo hiệu năng, kiểm thử hai Android hay Internet. Ch4–5 chờ sản phẩm.
- Chưa kiểm tra bố cục trực quan từng trang Word, số trang thực, mục lục tự động, danh mục hình, header/footer từng section, bìa/nhiệm vụ và định dạng caption cuối. Không tuyên bố bản này đủ 60–100 trang hoặc đạt mọi quy định trường.
- Không import thêm skill viết luận văn: hiện chưa cần công cụ bổ sung; dùng quy cách trường, quy trình truy vết nguồn và rà soát nội dung. Skill không thay việc duyệt bố cục/GVHD.

## Công cụ tài liệu

Script cuối phiên chỉ cần Node.js và Git: `node tools/finish-session.cjs --check` hoặc thêm `--message` để commit/push.

`tools/format-draft.cjs` là bước hiệu chỉnh một lần sau khi tạo Word từ Markdown bằng công cụ tài liệu Cindy; không chạy lại trên bản đã chèn ảnh. Cần các tiện ích cục bộ không commit: `npm.cmd install --prefix .local-tools jszip @xmldom/xmldom --ignore-scripts`. Nguồn sơ đồ được xuất bằng `@mermaid-js/mermaid-cli` với Chrome đã cài; không liên quan dependency game.
