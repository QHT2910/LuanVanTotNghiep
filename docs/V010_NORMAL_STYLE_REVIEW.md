# Sửa trực tiếp v0.10 theo yêu cầu — 12/11/2026

Lead verdict ACCEPT bản chỉnh định dạng để Cindy review; không đổi sang v0.11. Không worker/model/game/UI thay đổi.

## Bảo toàn và tệp sửa

Backup trước sửa ở `thesis/archive/v010-before-normal-style-2026-11-12/`: DOCX SHA256 `be5e658732eaa8c9cb6eafd643746ac33fd7a91aae66bd4fc8cc2076d3852505`, PDF SHA256 `d9050a24ce81209c8767d20d51de128d1fca5a55311d8b3d5eeb6f847d02b387`. DOCX hiện tại trước sửa có chỉnh sửa từ ngoài so với bản từng commit; dùng chính tệp hiện tại, không phục hồi nội dung từ Git. Backup tạo bằng copy exclusive trước mọi thay đổi.

Đã sửa cùng đường dẫn `thesis/Ban_thao_Chuong_1-4_v0.10.docx` và `.pdf`. Hash sau sửa DOCX `56095cd29f81f3d89c26bc9f5cb793d7196bc6ed637d060ec90cc3b028ce52fc`, PDF `d12ca23bdf6805a6df2933c49bfa8750d7230eb0c4150dfbdeb741f5ebc9b6ce`.

## Thay đổi

- Quy định THESIS_FORMAT bổ sung normal TNR13 cho thuật ngữ trong prose/ô bảng, giữ exact case; caption dưới đối tượng, giữa, normal, tên+số nguồn có căn cứ; nhãn bảng sentence case.
- Nguồn bốn chương bỏ inline backtick trong prose, giữ code fences nguyên nội dung; caption bỏ diễn giải Nguồn dài, giữ đúng số nguồn đã có, không cấp nguồn cho hình tự tạo. Hai caption bảng đánh số Ch1 chuyển xuống dưới bảng. Hai bản tổng hợp cập nhật khớp.
- DOCX chuẩn hóa run body/ô bảng: bỏ bold/italic/underline riêng, rStyle/codefont, shading/highlight/codebox; không lowercase định danh. Không xóa công thức OMML hoặc định dạng chỉ số toán học. Tiêu đề cấp/chương giữ kiểu theo quy định; “Lỗi thường gặp” tách khỏi heading viết hoa.
- Shared `normal-publication.cjs` gọi từ formatter/finalizer và CLI normalize; HTML caption giữa, bảng giữ với caption phía sau. Nguồn và pipeline được đồng bộ, không chỉ sửa PDF.

## Gate và phạm vi quan sát

- `node tools/check-normal-publication.cjs ...v0.10.docx`: PASS 1877 run normal, 32 caption dưới đối tượng/căn giữa, không shading/highlight nội dung; `.scratch/v010-normal-props.txt`.
- `node tools/validate-v08-docx.cjs ...v0.10.docx`: PASS TNR13/Before6/Multiple1.3/headings/38PNG/3OMML; `.scratch/v010-normal-xml.txt`. Các mismatch alignment/bold/spacing đầu tiên đã được sửa bằng giá trị trực tiếp tương ứng quy định, không hạ tiêu chí validator.
- `node tools/check-thesis-v08-source.cjs`: PASS nguồn/tổng hợp/44 refs/13 ca; `.scratch/v010-normal-source.txt`. Ch2 nay có chỉnh định dạng được yêu cầu, không còn nhận “Ch2 unchanged”.
- PDF render Chromium từ DOCX/HTML: inspect đủ107 trang, verdict ok, không blank. Không nhận native Word pagination.
- `review-pdf-pages.mjs`: render107/27sheets, zero textOutsidePhysicalPage; `.scratch/v010-normal-final-render.txt`.
- `check-chapter-breaks.cjs`: PASS pageBreakBefore, không ngắt kép/parity, chương bắt đầu PDF trang1/6/61/97; `.scratch/v010-normal-breaks.txt`.
- Lead xem lớn trang3 (caption bảng),31 (Hình2.8[26]),58 (SceneMesh/SceneNode prose),59 (bảng lỗi/initState/_tint()/_prepare()), và trang đầu bốn chương1/6/61/97. Chữ/caption/bảng đọc được, không thấy clipping trong các trang đó. Không nhận đã đọc từng chữ toàn107 trang hoặc QA worker độc lập mới.

After vẫn kế thừa, chưa chốt; bìa/TOC/native Word còn ngoài nghiệm thu. Các ảnh UI/game/demos/Wordv0.3/v0.9 giữ nguyên; v0.3/v0.9 modified từ trước tiếp tục loại khỏi stage.
