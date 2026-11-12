# QA artifact DRAFT v0.8 — 11/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov. Verdict: PASS có một P2 trình bày không chặn bàn giao DRAFT cho Cindy review. Không nghiệm thu ready-to-submit hoặc native Word pagination. Lead lưu từ báo cáo terminal của worker; không nhận các kiểm tra dưới đây là do Lead chạy lại.

## Quan sát mới của QA

- Đọc PUBLICATION_v0.8_REVIEW và pipeline format-draft/finalize-publication/publication-html/validate-v08-docx; chỉ chạy validator chỉ đọc.
- Validator PASS: 1.749 paragraph, 27 PNG, 3 display OMML; TNR13, Before6, Multiple1.3. Heading thực cấp1=5/cấp2=23/cấp3=85; size24/15/14, bold, CAP cấp1–2, chương căn phải. Không có heading4/TOC thực để nghiệm thu trên nội dung xuất.
- After: 564 paragraph=0 và 1.158=6pt, kế thừa mẫu, chưa phê duyệt cuối. Validator xác nhận các tệp cũ trong manifest không đổi.
- Tự hash DOCX khớp `585d425cafaa2a7b4f7b6c7015952e45af22208bcf399e9a4279a8a5de34f863`; PDF khớp `fa57fbc3de44415dc1c2dad2391458578fd85785dd29b0147a761b06e632d9be`.
- Tự xem đủ sheet-01..27 (108 trang ở mức contact sheet), xem lớn page19/55/98/100/101. Không thấy clipping/overlap chặn đọc. Công thức BRDF trang19 có tích phân/chỉ số; code trang55 không bị chuyển thành math; Ch4 trang98 và KT01–13 trang100–101 đọc được. Không thấy sơ đồ mất hoặc caption placeholder trong phạm vi quan sát.
- Trang1 chỉ nhãn DRAFT, trang108 chỉ [44], chưa có bìa/TOC hoàn chỉnh. Một số token bảng xuống dòng giữa từ (Metallic/Roughness trang20, Directional/falloffExponent trang22); cần chỉnh cho bản nộp.

## P2 — tiêu đề bảng tiếp trang

Bảng KT01–KT13 nối trang100 sang101 nhưng trang101 bắt đầu KT09, không lặp tiêu đề bốn cột. Không mất ca/nội dung nhưng khó đọc riêng trang101. Trước bản nộp nên dùng `w:tblHeader` trong DOCX và `thead`/`table-header-group` trong HTML, hoặc bảng phần tiếp có đủ nhãn. Sau sửa phải rà lại DOCX/PDF. Worker không sửa trong task này.

## Giới hạn và gate thực chạy

PDF dùng Chromium từ HTML/MathML dựng từ DOCX, không chứng minh Word cũng phân trang108. inspect_pdf đủ108 và dò text vượt biên là gate kế thừa của Lead, QA không chạy lại. Contact sheet không thay việc đọc từng chữ toàn bộ108 trang ở kích thước lớn. Không mở native Word, không kiểm bản in, After cuối, UI Figma; không export/render/ghi file hoặc tác động game/demos/v0.3/v0.7.

```text
node tools/validate-v08-docx.cjs | PASS XML/font/spacing/headings/27images/3OMML/old-files; paginationVisuallyVerified=false | logpath=none
Get-FileHash -Algorithm SHA256 hai artifact v0.8 | PASS hai hash khớp | logpath=none
view_image sheet-01..27 và page19/55/98/100/101 | PASS phạm vi DRAFT; P2 header bảng trang101 | logpath=none
Get-Content pipeline và PUBLICATION_v0.8_REVIEW | PASS phân biệt DOCX/Chromium/nativeWord/DRAFT | logpath=none
```

Route: Orca session hiện có; worker không đổi model/provider. Lead đã kiểm host runtime trước dispatch là Codex/OpenAI/gpt-6.1-sol medium generation0 pendingnull; không nhận Luna/Argon đã chạy.

## Lead review

Accept bàn giao DRAFT với P2 còn mở, vòng sửa0. Lead đã xem lại page101: đúng bắt đầu KT09, thiếu hàng tiêu đề lặp; nhận xét worker có căn cứ. Không nâng kết quả thành bản nộp hoặc native Word đã đạt. Bàn giao Cindy ngay mốc QA trước sửa phụ thuộc/chốt Git.
