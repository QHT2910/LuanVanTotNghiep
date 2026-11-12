# Bàn giao bản xuất DRAFT v0.8 — 11/11/2026

Nguồn Chương 1–4 đã qua QA và Cindy accept. Lead đã xuất hai tệp mới `thesis/Ban_thao_Chuong_1-4_v0.8.docx` và `.pdf`; không thay bản v0.7/v0.3. Đây là bản thảo, UI chưa hoàn thiện, chưa phải bản nộp.

## Phương pháp và kiểm tra thực chạy

- DOCX: Cindy make_docx từ đầu vào riêng v0.8, sau đó format-draft/finalize-publication. Kiểm XML bằng `node tools/validate-v08-docx.cjs`: PASS; 1.749 paragraph, 27 hình sơ đồ có sẵn, 3 display OMML. Log: `.scratch/v08-docx-validation-final.txt`.
- Body Times New Roman 13, Before 6 pt, Multiple 1,3. Heading thực có: chương 24 bold uppercase right; cấp 2: 15 bold uppercase; cấp 3: 14 bold. Chưa có heading cấp 4 hoặc mục lục thực để nghiệm thu trên bản xuất. After kế thừa mẫu: 0 pt ở code và 6 pt ở body; chưa được chốt là quy định cuối.
- PDF: Cindy Chromium từ HTML dựng từ DOCX đã định dạng, A4, 108 trang. Không phải xuất PDF native Word; chưa kiểm phân trang khi mở Word.
- inspect_pdf kiểm qua đủ trang 1–108, verdict ok, không trang trắng. Renderer độc lập tạo 108 ảnh trang và 27 contact sheet; không phát hiện text vượt biên vật lý trang. Log: `.scratch/v08-render-pages-log.txt`.
- Lead xem đủ 27 contact sheet (108 trang), xem lớn bổ sung trang 19 (công thức), 55 (code), 100–101 (KT01–KT13). Không thấy clipping/overlap chặn bàn giao trong phạm vi này. Ảnh rà ở `.scratch/v08-review/`, chưa phải QA độc lập.

## Hash SHA-256

- DOCX: `585d425cafaa2a7b4f7b6c7015952e45af22208bcf399e9a4279a8a5de34f863`
- PDF: `fa57fbc3de44415dc1c2dad2391458578fd85785dd29b0147a761b06e632d9be`
- Validator đối chiếu hash bản v0.7/v0.3 trước/sau: không đổi trong lượt xuất này. v0.3 vẫn là thay đổi ngoài lượt, không stage.

## Điểm còn lại và lỗi đã xử lý

Trang đầu chỉ là nhãn DRAFT, còn thưa; chưa có bìa/mục lục bản nộp. Một số tên kỹ thuật trong bảng hẹp xuống dòng giữa từ; trang cuối chỉ có reference [44]. Chưa bổ sung hình Figma chính thức, không dùng concept AI thay thế. Không nhận bản này đã sẵn sàng nộp.

Validator lần đầu tính cả run chỉ chứa ảnh là run chữ nên báo font thiếu; đã sửa validator bỏ run không có text/br/tab và chạy lại PASS, không đổi DOCX để né lỗi. Lệnh shell truy vấn metadata đầu tiên lỗi quoting; đã chuyển sang script file, không có mutation từ lệnh lỗi.

Bàn giao Cindy review mốc xuất trước QA bản xuất độc lập. QA nguồn trước đó không thay QA Word/PDF. Chưa thay game, demos, workspace hoặc route worker. UI04 V3 vẫn thiếu backup .fig/sync/export được xác minh; giữ draft mở, không reload/close.
