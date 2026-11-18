# Rà nội dung v0.11

Ngày 18/11/2026. Kênh thực hiện: Orca Worker thesis-writer i5ekkscj1rnt90hdtb8zk3n2, chỉ đọc; Lead tích hợp sau review.

Nguồn: actual DOCX v0.10 SHA256 a3bfb35b02d69e7c941841afe9bfd793e14978946e1d0e361ef2039624e617c1 qua inventory/trích paragraph. Không tái dựng từ Markdown cũ. Worker đọc toàn Ch1/Ch4, văn xuôi/bảng Ch3, các phần Ch2 và tutorial có mục tiêu; không xác nhận mọi dòng code, 24 công thức hoặc toàn bộ nguồn tham khảo.

## Sửa được Lead chấp nhận

- p22: phân biệt kết quả một AVD với chưa có thử nghiệm Redmi/hai điện thoại; tránh phủ định kết quả Ch4.
- p473/476/479/922/1012: gắn trạng thái tutorial với lượt kiểm bundle lịch sử, không nâng các bài A–F thành kết quả Android đã quan sát.
- p1258: kết nối Internet là thiết kế mục tiêu.
- p1443: bỏ lặp resolved/Block đã giải thích trước; p1444–45 gộp lời dẫn bảng.
- p1477: chuyển hướng dẫn connector về sau Hình 3.7(c2), rút phần lặp, giữ T/V/G/L/E/F/Z.
- p1544 bỏ đoạn Tập luyện lặp p1535; p216 rút lifecycle lặp p211, giữ ownership/dispose và giới hạn.
- p1384 bỏ một câu danh tính lặp p1383, giữ ACK processed khác accepted.
- Tám caption p1422/24/26/28, p1435/37/39/42 bỏ hậu tố “Nguồn: thiết kế đề xuất của tác giả.”, không gán nguồn giả.
- Lead thêm câu giới hạn phạm vi Ch4 ở M1–M3b; không thay số liệu bằng các mốc game/network mới.

ID là baseline, không phải số đoạn sau chỉnh. Sửa thực tế được ghi tại script tools/revise-thesis-v011.cjs và surgical-changes.json trong vùng review tạm.

## Quyết định còn để tác giả review

1. Hai heading “So sánh với bài A và quyền sở hữu”, “Loading và warm-up” đang cùng cấp với mục tutorial chính; nên xét chuyển thành cấp 4 hoặc nhãn đoạn. Chưa tự đánh số lại.
2. Tutorial dài: chuyển code đầy đủ sang phụ lục là thay đổi cấu trúc lớn, chưa thực hiện. Phần lý thuyết và hướng dẫn đã tách vai trò, không cắt chỉ vì cùng nhắc API.
3. Ch4 giữ cutoff M1–M3b. Kết quả human/network mới chưa được tổng hợp thành một chương kết quả cập nhật; không coi các câu thiết kế là fullgame đã hoàn thành.

## Coverage và giới hạn

Metadata 11 Figma user-revised-v010 có thực, không đảo về UI tự sinh cũ. Worker không kiểm pixel; Lead/QA bản cuối phải kiểm bảo toàn. API component.dart pinned0.24.3 được đọc theo mục tiêu, không thay nguồn bằng web hiện hành. BasicSimulation chưa định vị đầy đủ nên không sửa citation/backend.

Gate worker: Get-Content/rg actual paragraphs, inventory, rules, manifest Figma và component.dart | PASS theo phạm vi; một số output dài truncated | logpath=none. Word/PDF/render/GUI/build/write/Git | NOT RUN.
