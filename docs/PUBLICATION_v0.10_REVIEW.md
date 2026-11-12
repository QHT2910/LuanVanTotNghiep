# UI người dùng sửa và DRAFT v0.10 — 12/11/2026

Verdict Lead ACCEPT để bàn giao Cindy review. Không dispatch worker mới; không nghiệm thu bản nộp hoặc gameplay mạng.

Đã đọc fresh Figma PID8748/window67312 đúng draft cũ, Page3 có 11 frame, gồm UI04 mới node35:2. Không vẽ lại hoặc sửa nội dung UI. Save local copy mới `design/figma/source/User-revised-2026-11-12-v010.fig`: 4179914 bytes, SHA256 `9087c214cd6c0ce53102f4f109aecbbbd0b7b43cef6b4bf5cfa3e0a9f276f1aa`; kiểm ZIP có canvas.fig. FIG ignored, bản cũ giữ nguyên.

Native export 10 frame có setting cũ và riêng UI04 mới sau thêm PNG export setting. 11 ảnh ở `design/figma/exports/user-revised-v010/`; manifest ghi kích thước/hash, 5 ảnh thay đổi: UI04, không tìm thấy phòng, chuẩn bị trận, thua, hòa/phòng đóng. Sáu ảnh còn lại cùng hash bộ v0.9. Lead đã xem lớn năm ảnh đổi: bốn trạng thái bỏ khung tiêu đề trên, UI04 thay nền sân; chữ/nút/cảnh báo đọc được. Screenshot không dùng thay native export.

Ch3 giữ Hình3.9–3.19, dùng 11 alias mới, cập nhật mô tả UI04 thành nền sân minh họa và HUD; không nhận thiết kế đã triển khai mạng. Hai bản tổng hợp khớp nguồn; 44 refs/13 ca/Ch2 không đổi.

Rule 12/11 đã thêm vào THESIS_FORMAT và OUTLINE: mỗi chương bắt đầu trang mới bằng PageBreak/pageBreakBefore, không Enter trống, không ép trang lẻ/trang trắng. DOCX pipeline giữ pageBreakBefore; HTML giữ break-before:page. Bổ sung checker XML và PDF để phát hiện ngắt kép/trang trắng.

v0.10 dựa trên DOCX đã commit ở 8f43bb6, thay đúng 11 media và một đoạn mô tả, giữ định dạng. DOCX v0.9 hiện tại đã được thay đổi từ ngoài trước lượt này (SHA256 7d5f8e54…810ac), được giữ nguyên và loại khỏi stage cùng v0.3. Không ghi đè bản người dùng sửa.

## Gate

- `node tools/update-ui-v010.cjs`: PASS tích hợp 11 ảnh/5 ảnh đổi, FIG ZIP, 4 chapter breaks; log `.scratch/v010-integration.txt`. Lượt đầu dừng do directory entry ZIP, sửa lọc file rồi hoàn tất; chưa xuất DOCX ở lượt lỗi.
- `node tools/check-thesis-v08-source.cjs`: PASS nguồn; log `.scratch/v010-source.txt`.
- `node tools/validate-v08-docx.cjs thesis/Ban_thao_Chuong_1-4_v0.10.docx`: PASS TNR13/Before6/Multiple1.3/headings/38PNG/3OMML; log `.scratch/v010-xml.txt`.
- PDF Chromium 114 trang, inspect_pdf đủ114 verdict ok, không trang trắng; SHA256 `d9050a24ce81209c8767d20d51de128d1fca5a55311d8b3d5eeb6f847d02b387`. Không phải native Word pagination.
- Render114 trang, 29 contact sheets, không text vượt mép; `.scratch/v010-render.txt`. Lead xem lớn trang99/101/102: năm ảnh đổi và caption đúng, không thấy clipping. Không nhận đã đọc lại từng chữ toàn luận văn.
- Chapter checker: XML pageBreakBefore đủ Ch1–4, không explicit page-break kép; PDF chương bắt đầu trang2/7/68/104; log `.scratch/v010-chapter-breaks.txt`.

DOCX SHA256 `b73063d4f3c82a4e0e6b48797a5675d527da6869e88f03217124bca9a9707ad3`. Còn bìa/TOC/After cuối/native Word và các biến thể UI04 đầy đủ. Không thêm Ch4 test/game/model thay đổi. Không sửa source từ ảnh khái niệm AI trong chat.
