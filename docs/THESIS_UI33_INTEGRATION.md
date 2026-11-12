# Tích hợp nguồn 3.3 — 11/11/2026

Cindy accept proposal với sửa bổ sung Tập luyện. Lead đã thay nội dung 3.3.1–3.3.3 trong thesis/03-xay-dung-game.md, giữ source Mermaid/caption Hình3.8. Dẫn hình được ghi rõ chỉ mô tả nhánh phòng đấu; nhánh tập offline được trình bày riêng trong bảng/văn bản. Không sửa sơ đồ để nhận đã triển khai Menu.

UI01 có Tập luyện → biến thể offline UI04, HUD riêng không đồng hồ trận/đối thủ giả, không qua phòng/sảnh. Bảy frame chính vẫn thuộc sáu nhóm, biến thể tập chưa được nhận là frame Figma đã hoàn thành. UI02 create/join, UI03 ready/countdown, UI05 roomgone và UI06 audio theo đặc tả. Captionmap3.9–3.15 nằm research/thesis-ui33-proposal.md, ngoài manuscript. Chưa link ảnh hoặc caption giả; không đổi Ch4/44refs/Ch2.

Đã cập nhật spec UI01 và đánh dấu các dòng chờ review cũ là lịch sử. Dùng research-paper-writing và humanizer khi tích hợp; không thêm nguồn hoặc số liệu. Reverse-outline: danh mục/luồng → từng màn/trạng thái → phản hồi và giới hạn; mỗi mô tả đều ở phạm vi thiết kế, không thay runtime evidence.

Gate Lead thực chạy:

```text
node .scratch/integrate-ui33.cjs | PASS tích hợp có anchor/preflight, giữ3.8, không image-link | logpath=.scratch/ui33-integration.txt
node tools/build-manuscript.cjs | PASS tổng hợp1–3/đầu vào Markdown | logpath=.scratch/ui33-combined13.txt
node tools/build-manuscript.cjs --include-ch4 | PASS tổng hợp1–4/đầu vào Markdown | logpath=.scratch/ui33-combined14.txt
node tools/check-thesis-v08-source.cjs | PASS 4chương/44refs/13ca/combinedExact/ch2Unchanged | logpath=.scratch/ui33-source-check.txt
```

Các lệnh build-manuscript chỉ ghép Markdown, không xuất Word/PDF. V0.8/v0.7/v0.3 giữ nguyên. P2 bảng đã sửa ở pipeline nhưng trang nối sau sửa vẫn chờ lần xuất kế tiếp. Còn thiếu native Figma/PNG thật để hoàn thành 3.3; source gate không thay QA hình/bản xuất. Tiếp QA nguồn chỉ đọc và bàn giao Cindy từng task trước tích hợp ảnh/xuất version mới.

## Sau QA nguồn

11/11: OrcaQA PASS manuscript/tổng hợp; hai P2 spec đã Lead sửa (Tập luyện khi connecting/offline và câu backup lịch sử). Source checker sau sửa PASS, log .scratch/ui33-postqa-source.txt; diffcheck PASS .scratch/ui33-postqa-diff.txt. Report qa/thesis-ui33-source.md. Không QA ảnh hoặc bản xuất mới.

