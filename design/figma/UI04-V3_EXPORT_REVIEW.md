# UI04 V3 — mốc nguồn và ảnh xuất ngày 11/11/2026

Lead đã khôi phục đúng draft hiện có, rà layer và hoàn thiện mốc nền + HUD để Cindy review. Không tạo page/frame trùng. Đây là thiết kế giao diện, không phải ảnh chạy game.

## Sản phẩm thực

- Page 4, `UI04-V3-composite`, node `25:5`, 960×540.
- Hai lớp ngang cấp: `HUD_Overlay` và `BG_Court`. Chữ là các đối tượng text native; sân, bảng rổ, lưới, cây và điều khiển là shape/vector native. Không nhập ảnh concept phẳng hoặc nhân vật.
- Nguồn mới: `source/UI04-V3-review-2026-11-11.fig`, 62.576 byte, SHA-256 `4af82950b59e1e5b0c2d179ec9b24b8473223b48bf489f9fe0a3cb30d71ce8a9`.
- Ba PNG xuất bằng nút Export của Figma ở 1x: `exports/UI04-V3-composite.png`, `exports/UI04-V3-HUD.png`, `exports/UI04-V3-background.png`.
- Hash, kích thước và alpha lưu trong `exports/UI04-V3-manifest.json`. Các backup trước giữ nguyên; không khẳng định cloud sync.

## Rà của Lead

Ô ngắm đã kín; vành cam dày, lưới có nét đan và nằm trước trụ, chân trụ có đệm cam. Cung sân dùng Bézier mượt cùng nửa vòng trong vùng cam. Mây trắng và cây là các cụm bo tròn; tường có chiều cao rõ.

HUD có cụm điểm/thời gian phía trên, kết nối riêng, joystick trái dưới có núm, Ném lớn màu cam, Nhảy/Dash là hai nút riêng và thanh canh ném gần Ném. Không che rổ. Nhãn và số trên ảnh chỉ minh họa thiết kế. Thanh canh không gán thời gian hồi chiêu. Chưa có biến thể possession/cooldown/mất kết nối trong mốc này.

Lead chấp nhận mốc nguồn + ba export để Cindy review; chưa nhận hoàn thành toàn bộ bộ UI. Điểm cần Cindy xem: khoảng đệm chữ Nhảy/Dash còn sát mép; hình học nền được giản lược mạnh. Chưa nhận usability hoặc prototype đã kiểm.

## Gate mới

- Figma GUI Save local copy + kiểm ZIP/hash | PASS, có canvas.fig/thumbnail.png/meta.json | logpath=exports/UI04-V3-manifest.json.
- System.Drawing đọc ba PNG | PASS, cả ba 960×540; HUD 459.340 pixel alpha=0, tâm alpha=0; composite/background không có pixel alpha=0 | logpath=exports/UI04-V3-manifest.json.
- view_image ba PNG | PASS trong phạm vi Lead quan sát bố cục/chữ/nền tách | logpath=none.

Lỗi trung gian: ứng dụng mở lại ban đầu trắng rồi tải xong; set_value không hỗ trợ canvas Text Document, nhập canvas bằng type_text foreground sau đó được tool chấp nhận và đã đối chiếu text/ảnh. Save dialog từ chối dấu / trong đường dẫn; sửa sang dấu backslash, file mới đã kiểm tồn tại/hash. Không reload/signout hoặc dùng shell nhập GUI. Một thao tác ArrowRight đã dịch frame 1 đơn vị và được undo, X=0/Y=0 được xác nhận lại. Tán cây lẫn trong nhóm HUD cũ đã được bỏ nhóm; HUD mới chỉ gom điều khiển/text, tán cuối dựng lại trong BG.

## Việc tiếp

Cindy review UI04; chỉnh điểm chưa đạt rồi bổ sung trạng thái. Các màn UI01/UI02A/UI02B/UI03/UI05/UI06 và trạng thái phụ chưa dựng trong lượt này. Ảnh chưa tích hợp vào 3.3; chưa xuất v0.9. Không thay game, Ch4, model route hoặc các bản Word/PDF cũ.
