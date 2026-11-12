# QA nguồn 3.3 — 11/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov. Verdict worker: PASS manuscript3.3/tổng hợp, không P1; hai P2 đồng bộ đặc tả. Không nghiệm thu Figma/ảnh/Word/PDF.

## Đối chiếu mới của worker

- Đọc docs review/integration, proposal, toàn bộ3.3, ui-spec và Mermaid3-8-giao-dien-r1.mmd. Nhánh Tập luyện → UI04 offline riêng, không phòng/sảnh, không clock trận/đối thủ giả, Menu chưa triển khai. Bảy frame/sáu nhóm; không UI07 hoặc nhận biến thể tập đã có frame Figma.
- Create không mã giả/chặn gửi lặp; join sai/notfound/full/network; ready/hủy/countdown theo xác nhận không Start; roomgone khóa về sảnh; possession độc lập cooldown; audio không pauseonline. Cancel/mất mạng không tự ném/reconnect/replay/xử kết quả.
- Hình3.8 giữ nhánh phòng đấu, đoạn dẫn giải thích tập offline ngoài sơ đồ. Captionmap3.9–3.15 chỉ ở proposal, không link ảnh/caption giả trong manuscript.
- Source gate PASS exactconcat1–3/1–4,44refs/13ca/Ch2unchanged; diff xác nhận Ch2/refs/Ch4 không đổi HEAD.

## P2 và Lead xử lý

P2-01: ma trận UI01/connecting/offline chưa nêu Tập luyện còn dùng dù mất mạng. Lead chấp nhận và sửa: khóa chỉ thao tác cần mạng; Tập luyện/Cài đặt vẫn dùng và có nhánh thoát tương ứng.

P2-02: câu current blocker còn nói chưa bảo toàn nguồn, trái backup verified. Lead chấp nhận và thay bằng ghi nhận lịch sử; backup cũ đạt nhưng cloud sync/V3/PNG vẫn chưa xác minh.

Lead đọc lại đúng hai vị trí, đã sửa trong design/ui-spec-r1.md. Verdict Lead accept nguồn và hai sửa spec nhỏ; không thay manuscript để né QA, không xuất Word/PDF hoặc kiểm ảnh mới. Các gate sau sửa ghi tại docs/THESIS_UI33_INTEGRATION.md. Bàn giao Cindy review ngay mốc task.

## Gate worker thực chạy

```text
Get-Content docs/proposal/3.3/spec/sourceMermaid; rg anchors | PASS phạm vi đọc, hai P2 phụ trợ | logpath=none
node tools/check-thesis-v08-source.cjs | PASS 4chương/44refs/13ca/combinedExact/ch2Unchanged; WordOrPDFValidated=false | logpath=none
git diff --exit-code HEAD -- thesis/02-co-so-ly-thuyet.md thesis/REFERENCES.md thesis/04-kiem-thu.md | PASS không đổi | logpath=none
Đọc diagrams/3-8-man-hinh.mmd | FAIL sai tên đường; đã đọc đúng 3-8-giao-dien-r1.mmd sau đó | logpath=none
```

Worker không ghi root, builder/render/export/GUI/game/Ch4 hoặc đổi route. Host terminal Lead đọc: Codex/OpenAI/gpt-6.1-sol medium generation0 pendingnull, completed/persisted; không Luna/Argon. Còn thiếu ảnh chính thức và QA bản xuất mới.
