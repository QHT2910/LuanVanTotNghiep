# Review mốc UI01 và UI04 r2 — 11/11/2026

Lead trực tiếp thao tác Figma native, đọc lại các PNG xuất thực. Không giao worker, không thay route/model, game hoặc Ch4.

## UI04 r2

Giảm Nhảy/Dash từ 22 xuống 18 px, bo hai nút 10 px để tăng đệm chữ. Giữ bố cục, nền và các layer hiện có. Xuất mới `UI04-V3-r2-composite.png` và `UI04-V3-r2-HUD.png`; background không đổi nên dùng nguyên `UI04-V3-background.png` đã kiểm ở mốc trước. Không ghi đè ảnh r1.

Nguồn `source/UI04-V3-r2-2026-11-11.fig` đã lưu qua Save local copy. 62.723 byte; hash trong manifest. HUD r2 có 459.523 pixel hoàn toàn trong suốt, tâm alpha=0; kích thước 960×540.

## UI01 Menu

Frame mới `UI01-Menu`, node `29:36`, Page 4, 960×540. Tạo đúng một bản sao nền từ UI04, bỏ HUD trận đấu trên bản sao; UI04 gốc node25:5 giữ nguyên. Cụm rổ chín layer được chuyển sang phải trong BG của Menu. Nền là shape/vector native; không import concept phẳng.

`UI_Overlay` ngang cấp với `BG_Court`. Có tiêu đề hai dòng “Bóng rổ đối kháng 3D”, Tạo phòng cam, Vào phòng, Tập luyện xanh và Cài đặt. Chip “Đã kết nối” minh họa trạng thái thiết kế, không phải kết quả kiểm mạng. Không có đăng nhập, shop hoặc ghép nhanh như chức năng sẵn dùng. Chưa nối prototype, chưa dựng biến thể offline/connecting của Menu. Quy tắc Tập luyện/Cài đặt vẫn dùng khi offline giữ trong spec; không khẳng định Menu đã code.

`exports/UI01-Menu.png` đã được xuất bằng Figma ở 1x và kiểm 960×540, opaque. Lead nhìn ảnh xuất: đủ bốn lựa chọn, không tràn chữ, rổ ở phải, tiêu đề và nút rõ. Bố cục bám board đã duyệt nhưng nền giản lược theo V3; chưa có icon bánh răng/ball logo và cần Cindy review mức tương đồng. Không nhân vật/model.

Nguồn mốc `source/UI01-and-UI04-review-2026-11-11.fig` 69.553 byte, SHA-256 `0f4af4a097d189037ae9c7b4bf76efbd06281dfe250f14c1c4d7f336511f8631`; ZIP có canvas.fig/thumbnail/meta. Các nguồn trước giữ nguyên, binaries ignored. Không nhận cloud sync đã kiểm.

## Gate và verdict

- Native GUI Export PNG + Save local copy | PASS thực hiện | logpath=exports/UI01-UI04-r2-manifest.json.
- System.Drawing dimension/alpha + SHA256/ZIP read | PASS cả ba PNG mới960×540, HUD alpha thực | logpath=exports/UI01-UI04-r2-manifest.json.
- view_image UI01 và UI04 r2 composite/HUD | PASS phạm vi Lead đọc ảnh/chữ/bố cục | logpath=none.

Verdict Lead: accept mốc editable/export để Cindy review, không nhận toàn bộ UI hoàn thành. Còn UI02A/B, UI03, UI05, UI06, các trạng thái bổ sung và UI04 offline/possession/cooldown/connection-lost. Chưa tích hợp ảnh 3.3 hoặc xuất Word/PDF mới. Không dùng PNG mốc này để chứng minh gameplay/mạng.

Lỗi đã sửa trong mốc: label kết nối lúc đầu kế thừa cỡ36 vì chỉnh font ở caret chỉ đổi định dạng nhập tiếp; chọn lại cả text layer rồi đặt20 và căn lại X805 đã hết tràn. Chọn vùng cụm rổ ban đầu bắt thêm sân/tường, chưa group/move; thu vùng còn8 rồi thêm đệm=9 mới group. Không di chuyển các phần nền ngoài cụm rổ.
