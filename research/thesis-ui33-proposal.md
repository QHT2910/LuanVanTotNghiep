# Proposal 3.3 — bản Lead lưu sau review worker, 11/11/2026

Nguồn: Orca thesis-writer i5ekkscj1rnt90hdtb8zk3n2. Bản lưu biên tập gọn từ bàn giao, chưa tích hợp manuscript. Chưa có ảnh Figma V3/ảnh bảy frame được kiểm; không chèn image-link hoặc caption giả. Giữ source và caption Hình 3.8 hiện hành khi tích hợp.

## 3.3.1 — nội dung đề xuất

Hệ thống giao diện được đề xuất theo hướng ngang, gồm sáu nhóm chức năng UI01–UI06. UI02 tách thành Tạo phòng và Vào phòng, tạo thành bảy frame trình bày. Đây là giao diện mục tiêu của game 1v1; bản tập offline M3b chỉ cung cấp bằng chứng cho các thao tác trong phạm vi của nó.

| Frame | Mục đích và thông tin | Hành động và đích chuyển |
|---|---|---|
| UI01 Menu chính | Tên game, trạng thái kết nối, chọn chức năng | Tạo phòng → UI02A; Vào phòng → UI02B; Âm thanh → UI06 |
| UI02A Tạo phòng | Yêu cầu tạo phòng, tiến trình và lỗi | Thành công → UI03; quay lại → UI01 |
| UI02B Vào phòng | Nhập mã, phản hồi mã hoặc lỗi tham gia | Thành công → UI03; quay lại → UI01 |
| UI03 Sảnh chờ | Mã phòng, Bạn/Đối thủ, sẵn sàng và đếm ngược | Bắt đầu được xác nhận → UI04; rời phòng → UI01 |
| UI04 Trận đấu | Điểm, thời gian, kết nối, quyền giữ bóng, điều khiển | Kết quả được xác nhận → UI05 |
| UI05 Kết quả | Tỷ số Bạn/Đối thủ, thắng/thua/hòa, lý do | Về sảnh → UI03 nếu phòng hợp lệ; Menu → UI01 |
| UI06 Âm thanh | Bật/tắt và âm lượng | Quay lại → UI01 trong phương án đầu |

Luồng chính đi từ Menu qua Tạo hoặc Vào phòng tới Sảnh chờ, Trận đấu và Kết quả. Khi trở lại sảnh, trạng thái sẵn sàng được đặt lại. Cài đặt âm thanh là nhánh riêng từ Menu. Ghép trận nhanh thuộc phần bổ sung sau.

Hai người vào đủ phòng chưa làm trận bắt đầu. Cả hai cần sẵn sàng, sau đó đếm ngược và chuyển trận theo trạng thái được máy chủ xác nhận. Luồng này là thiết kế cho hệ thống mạng dự kiến, chưa phải kết quả kiểm chứng multiplayer.

## 3.3.2 — nội dung đề xuất

Figma là công cụ được chọn. Sketch UI01–UI06 và concept UI04 V3 đã được duyệt về hướng nội dung; chưa có bộ ảnh xuất chính thức được xác minh. Ảnh thiết kế, khi hoàn thành, không được dùng làm bằng chứng chức năng mạng đã thực thi.

UI01 — Menu chính cung cấp tên game, trạng thái kết nối, Tạo phòng, Vào phòng và Cài đặt. Thao tác cần dịch vụ mạng phải có trạng thái chờ hoặc bị khóa kèm lý do khi không kết nối; Cài đặt là nhánh độc lập. Thử lại kết nối không tự đưa người chơi vào phòng. Ghép nhanh được ẩn hoặc ghi chưa hỗ trợ.

UI02A — Tạo phòng tập trung vào yêu cầu tạo, phản hồi đang xử lý, lỗi và quay lại. Không hiển thị mã minh họa như mã thật trước thành công. Chỉ sau khi nhận xác nhận và mã do hệ thống cấp mới chuyển UI03. Trong khi gửi, chặn thao tác tạo lặp; khi lỗi, giữ màn để đọc lý do và chọn bước tiếp.

UI02B — Vào phòng gồm ô mã, thông báo cạnh form, xác nhận và quay lại. Trống hoặc sai định dạng được xử lý trước khi gửi. Không tìm thấy phòng, Phòng đầy và Lỗi mạng phải phân biệt. Giữ mã đã nhập để sửa; chỉ chuyển UI03 sau xác nhận thành công.

UI03 — Sảnh chờ có mã phòng, hai vị trí Bạn/Đối thủ, trạng thái sẵn sàng, vùng đếm ngược và Rời phòng. Khi Bạn sẵn sàng, nút đổi thành Hủy sẵn sàng; nếu đối thủ chưa sẵn sàng, hiện Chờ đối thủ sẵn sàng. Không có Start thủ công. Đếm ngược chỉ theo trạng thái phòng được xác nhận; khi điều kiện mất hiệu lực, bỏ đếm cũ và trở về chờ.

UI04 — Trận đấu V3 tách nền sân và HUD, không nhân vật hoặc placeholder nhân vật. Điểm Bạn, thời gian, điểm Đối thủ là các nhóm riêng phía trên; kết nối nằm riêng. Joystick trái; Ném lớn, Nhảy và Dash riêng bên phải; thanh canh ném gần hành động. Hành động chính đổi theo quyền giữ bóng trong thiết kế đầy đủ; hồi chiêu độc lập với possession. Thể hiện sẵn dùng, canh ném, khóa, hồi chiêu và gián đoạn bằng nhãn/chỉ báo. Block và mạng còn là thiết kế đề xuất.

UI05 — Kết quả đặt nhãn Bạn/Đối thủ trên điểm, cùng thắng/thua/hòa và lý do. Chưa nhận kết quả xác nhận thì hiện đang chờ, không tự suy kết quả từ điểm tạm. Về sảnh chỉ khả dụng khi phòng hợp lệ; phòng không còn thì khóa và nêu lý do, vẫn cho Về menu. Điểm trong sketch là minh họa.

UI06 — Âm thanh có bật/tắt, âm lượng, quay lại. Khi tắt, thanh âm lượng thể hiện vô hiệu theo đặc tả; phản hồi thị giác vẫn giữ. Lỗi lưu cần phân biệt lựa chọn đang áp dụng và chưa lưu. Màn mở từ Menu, không dùng làm pause online.

## 3.3.3 — nội dung đề xuất

Phản hồi phải thuộc đúng yêu cầu, phòng và trận đang hiệu lực. Khi tạo/vào phòng, trạng thái gửi ngăn nhấn lặp; phản hồi muộn không đưa người đã rời trở lại phòng cũ. Lỗi đi kèm hành động sửa mã, thử lại có kiểm soát hoặc về Menu.

Sảnh cập nhật từng người độc lập. Sẵn sàng của Bạn nhất quán với Hủy sẵn sàng, không tự đổi trạng thái đối thủ. Máy khách hiển thị đếm ngược đã được xác nhận, không tự bắt đầu bằng đồng hồ riêng. Về sảnh sau Kết quả phải bỏ cờ sẵn sàng cũ.

Điểm, thời gian và kết quả lấy từ trạng thái chung được xác nhận; phản hồi sớm/nội suy chỉ phục vụ trình bày. Quyền giữ bóng và hồi chiêu là hai trục riêng. Có bóng chưa chắc được ném khi trạng thái cấm; không có bóng không đồng nghĩa kỹ năng đang hồi.

Mất chạm/xuống nền đưa lệnh liên tục về trung tính và hủy giữ không hợp lệ; cancel không tự thành cú ném. Gián đoạn kết nối phải báo tình trạng và hành động được phép, không tự xử thắng/thua, pause toàn trận, reconnect hoặc phát lại lệnh. Chính sách khôi phục còn cần thiết kế và kiểm riêng.

Âm thanh/hiệu ứng bổ sung phản hồi thị giác; sự kiện có định danh trong phương án đồng bộ giúp tránh phát tác dụng lặp. Tắt âm thanh không làm mất điểm, thông báo hoặc chỉ báo khóa. Đây là đặc tả mục tiêu, chưa nghiệm thu full UI/1v1.

## Caption map — ngoài manuscript, chỉ dùng sau khi có ảnh thật

| Số dự kiến | Frame | Caption |
|---|---|---|
| 3.9 | UI01 | Thiết kế màn hình Menu chính |
| 3.10 | UI02A | Thiết kế màn hình Tạo phòng |
| 3.11 | UI02B | Thiết kế màn hình Vào phòng |
| 3.12 | UI03 | Thiết kế màn hình Sảnh chờ |
| 3.13 | UI04 V3 | Thiết kế nền sân và HUD của màn hình Trận đấu |
| 3.14 | UI05 | Thiết kế màn hình Kết quả |
| 3.15 | UI06 | Thiết kế màn hình Âm thanh |

Không coi caption map là ảnh đã tồn tại. Chỉ thêm nguồn thiết kế trong Figma sau khi đối chiếu native source/export. Không dùng concept chat, screenshot progress hoặc backup cũ làm ảnh V3. Kiểm lại số hình khi tích hợp.
