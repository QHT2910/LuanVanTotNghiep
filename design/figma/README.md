# UI04 trong Figma — bản đang làm

Ngày 10/11/2026. Nguồn chỉnh sửa trong draft [Bóng rổ đối kháng 3D — UI](https://www.figma.com/design/AKyJ1SFfjiJH8oS8q8m4JW/?node-id=1-2), Page 1. Không tạo thêm file khi tiếp tục.

Đã trực tiếp tạo lớp chữ, hình chữ nhật và ellipse trong Figma, không nhập ảnh phẳng hoặc SVG thay cho nguồn. Frame gốc 960×540; ba frame trạng thái được nhân từ frame gốc:

- UI04-Trận đấu / Sẵn sàng: điểm hai người, thời gian mẫu, trạng thái kết nối, joystick trái và nhãn Nhảy/Dash/Ném bên phải.
- UI04-Trận đấu / Canh ném: hướng dẫn thả và thanh mức ném bằng hai hình chữ nhật.
- UI04-Trận đấu / Hồi chiêu: nhãn Dash đang hồi; ACTION đổi thành Block khi phòng thủ.
- UI04-Trận đấu / Mất kết nối: thông báo kết nối lại và điều khiển tạm khóa; bỏ thanh mức ném.

Đây là các frame trạng thái riêng, chưa phải component set/prototype tương tác. Phần sân 3D được ghi rõ là minh họa thiết kế. Điểm, đồng hồ và kết nối là dữ liệu thiết kế mẫu, không phải kết quả game hoặc mạng đã chạy. Chưa được Cindy/sinh viên duyệt bố cục; cần tiếp tục tách, căn chỉnh nhóm nút và rà vùng chạm/độ đọc.

## Bảo toàn và phần chưa xong

Figma vẫn hiện “Some changes won't be synced until Figma is able to reconnect.” Có nguồn đang chỉnh sửa được trong cửa sổ hiện hành, nhưng chưa chứng minh toàn bộ thay đổi đã được lưu lên cloud. Không đóng/reload app trước khi kiểm tra đồng bộ hoặc lưu được bản local.

Đã gọi File → Save local copy và kiểm tra lại, chưa quan sát được hộp lưu hay tệp `.fig` mới trong Downloads. Export/shortcut chưa tạo ra tệp PNG được xác minh. Công cụ cuộn inspector gửi wheel vào giữa cửa sổ thay vì vùng inspector đã chỉ định; focus chính xác một số nút bị từ chối. Không dùng shell, clipboard trực tiếp hoặc debug port để thay thế điều khiển GUI.

`exports/` và `source/` chưa có sản phẩm; thư mục rỗng không được coi là bằng chứng hoàn tất. Các PNG trong `progress/` là ảnh cửa sổ Figma, không phải ảnh export frame. Giữ local/ignored vì có chrome ứng dụng và avatar tài khoản.

Ảnh tiến độ local:

| Tệp | Nội dung |
|---|---|
| progress/UI04-01-frame.png | Khung đầu tiên |
| progress/UI04-02-hud-controls.png | HUD và điều khiển đang dựng |
| progress/UI04-03-charge.png | Frame canh ném |
| progress/UI04-04-cooldown.png | Frame hồi chiêu/phòng thủ |
| progress/UI04-05-connection-lost.png | Frame mất kết nối |
| progress/UI04-06-ready.png | Frame sẵn sàng sau chỉnh nhãn |

Bước tiếp: kiểm tra đúng draft và các lớp hiện có; khôi phục đồng bộ/lưu local qua GUI được hỗ trợ; hoàn thiện căn chỉnh; export PNG thật từng frame, kiểm kích thước và nội dung; bàn giao UI04 để review trước năm màn còn lại. Không đưa ảnh tiến độ này vào luận văn như thiết kế đã nghiệm thu.
