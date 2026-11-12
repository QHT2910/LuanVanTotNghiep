# Bàn giao DRAFT v0.9 — 12/11/2026

Verdict Lead: ACCEPT bản thảo có ảnh để Cindy review; chưa ready-to-submit. Không có task worker mới trong mốc xuất v0.9 này.

## Sản phẩm

- `thesis/Ban_thao_Chuong_1-4_v0.9.docx`: SHA-256 `75b4ddceceeff552f947934caf48997126df39fe6b1bb3d59c76dfe7432735d3`.
- `thesis/Ban_thao_Chuong_1-4_v0.9.pdf`: SHA-256 `42b1f7c9bcc4ee6533a6def51369490a3a2fb0c740b14018971713e1041e8f20`.
- 38 PNG nhúng (27 hình cũ và 11 ảnh UI), 3 công thức display OMML. Mục 3.3 có Hình 3.9–3.19, mô tả màn hình và trạng thái; không nhận chức năng phòng/mạng đã triển khai.
- Nguồn Figma người dùng chọn: draft `AKyJ1SFfjiJH8oS8q8m4JW`, Page 3. Backup local `design/figma/source/User-selected-FigmaAI-2026-11-12.fig`, 3615396 bytes, SHA-256 `df1fdffc4365e44deb78ed214af51c4784c77eb0b279ee146b978ade9ba7f3a9`; ZIP có canvas.fig, meta.json, thumbnail và hai ảnh. FIG giữ local, bị Git ignore; cloud sync không được nhận là đã đạt.
- 10 PNG native export từ Page 3 trong `design/figma/exports/user-selected-2026-11-12/`; kích thước thực được ghi trong manifest, không nhận tất cả là 960×540. Nền các màn này là ảnh minh họa khóa, chữ/nút/panel là lớp chỉnh sửa được theo bộ người dùng chọn.
- UI04 dùng bản Page 4 V3 r2 đã xuất riêng 960×540, không có nhân vật; không dùng UI04 thô Page 1 hoặc nhận Page 3 có UI04. Alias 11 ảnh nhúng nằm trong `design/figma/exports/thesis/`, giữ nguyên byte ảnh nguồn.

## Kiểm tra thực hiện

- `node tools/check-thesis-v08-source.cjs` PASS nguồn 4 chương, 44 nguồn, 13 ca, tổng hợp khớp, Ch2 giữ nguyên; log `.scratch/v09-source-check.txt`.
- `node tools/validate-v08-docx.cjs thesis/Ban_thao_Chuong_1-4_v0.9.docx` PASS XML/font/spacing/headings/38 PNG/3 OMML/bản cũ; log `.scratch/v09-docx-check.txt`.
- TNR13, Before6pt, Multiple1.3; heading hiện dùng 24/15/14, bold và CAPS đúng cấp, chương căn phải. Không có TOC/heading4 thực để nghiệm thu trên nội dung. After kế thừa mẫu (0 hoặc 6pt), chưa được chốt cuối.
- PDF được dựng từ DOCX qua HTML/MathML rồi Chromium: 114 trang; inspect_pdf kiểm đủ 114, verdict ok, không trang trắng. Không suy Word cũng phân trang 114.
- Render toàn bộ 114 trang/29 contact sheets; không text vượt mép vật lý. Log `.scratch/v09-final-render-log.txt`, previews `.scratch/v09-final-review/`.
- Lead xem riêng cả 10 PNG mới; xem lớn các trang UI 97–102 trước chỉnh hai câu mô tả, rồi xem lại bản cuối trang 97/99/107; xem contact sheets cuối 24–29. Hình/caption đi cùng nhau, chữ đọc được, không thấy tràn che nội dung trong phạm vi quan sát.
- Trang 107 có tiêu đề bốn cột lặp trước KT09–KT13: P2 repeat-header đã sửa ở DOCX `w:tblHeader` và HTML `thead/table-header-group`.
- So render trang 2–94 với v0.8: 88 trang cùng hash; 5 trang 22/24/35/64/71 khác hash được xem lớn, không thấy lỗi chặn đọc. Các token dài trong bảng vẫn có xuống dòng giữa từ như hạn chế cũ; chưa phải bản in cuối.
- v0.8 DOCX/PDF giữ nguyên hash `585d425c…f863` và `fa57fbc3…d9be`; validator kiểm các bản cũ theo manifest. Word v0.3 có thay đổi tồn tại trước và được loại khỏi stage.

## Phần còn thiếu

Bìa/mục lục hoàn chỉnh, kiểm Word native, quyết định After cuối, các biến thể UI04 đầy đủ và tích hợp thiết kế vào game. Ảnh mạng/phòng/tỷ số/đếm ngược là thiết kế và dữ liệu minh họa. Không chạy lại game, thêm kết quả Ch4 hoặc thay model/provider trong mốc này. QA độc lập v0.8 trước đây không được nhận là QA worker của v0.9; bản này bàn giao Cindy review tiếp.
