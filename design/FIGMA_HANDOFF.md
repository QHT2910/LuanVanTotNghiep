# Bàn giao để dựng UI chính thức trong Figma

Cập nhật 10/11/2026 sau khi cửa sổ được khôi phục: đã đăng nhập và dựng bốn frame UI04 bằng lớp native trong draft [Bóng rổ đối kháng 3D — UI](https://www.figma.com/design/AKyJ1SFfjiJH8oS8q8m4JW/?node-id=1-2). Có ảnh tiến độ local; chưa xác minh đồng bộ cloud, bản `.fig` local hoặc PNG export. UI04 chưa hoàn tất/nghiệm thu. Xem [figma/README.md](figma/README.md). Bảng “Chưa có” bên dưới là trạng thái chuẩn bị trước lượt dựng, không phải trạng thái UI04 mới nhất. Năm màn khác chưa bắt đầu.

10/11/2026. Sinh viên đã chọn Figma và cho phép kết nối. Figma có trên máy; host báo Computer Use available=false/joined=false, không MCP Figma hay plugin Figma khả dụng. Chưa xác minh đăng nhập, chưa tạo file, chưa có export. Việc cho phép kết nối không tự tạo session hoặc connector.

Đây là bảng chuẩn bị nội dung, không phải bộ thiết kế đã hoàn thành. Không SVG/mockup tự sinh hoặc ảnh demo được nhận thành sản phẩm Figma. Nguồn yêu cầu: ui-spec-r1.md; các thông tin công cụ chưa chọn ở bản R1 là lịch sử ngày04/11, không phải quyết định hiện hành.

| Ưu tiên | Frame | Nội dung từ đặc tả | Sản phẩm Figma hiện có |
|---|---|---|---|
| 1 | UI04 Trận đấu/HUD | Cảnh trung tâm; điểm/thời gian trên; joystick trái; ACTION/JUMP/DASH phải; charge và hồi chiêu | Chưa có |
| 2 | UI01 Menu | Tên game; Tạo phòng/Vào phòng/Cài đặt; ghép nhanh chưa hỗ trợ | Chưa có |
| 3 | UI02 Tạo/vào phòng | Chế độ tạo hoặc nhập mã; gửi/chờ/lỗi/quay lại | Chưa có |
| 4 | UI03 Sảnh chờ | Mã phòng, hai slot, sẵn sàng/hủy, đếm ngược, rời phòng | Chưa có |
| 5 | UI05 Kết quả | Tỷ số, thắng/thua/hòa, lý do; về sảnh hoặc menu | Chưa có |
| 6 | UI06 Cài đặt | Âm thanh/âm lượng/quay lại; không tự coi mở cài đặt là pause trận | Chưa có |

Giữ tên UI01–UI06 theo đặc tả dù dựng UI04 trước. Frame960×540/ngang, lề/kích thước chữ ở R1 là đề xuất khởi đầu, cần quan sát bản dựng thật trước chốt. Joystick và nút phải kiểm nhận diện, vùng an toàn và thao tác nhiều ngón; không lấy ảnh desktop thay kiểm đọc trên điện thoại.

Tách phạm vi trong file Figma: UI04 mục tiêu1v1 là thiết kế đề xuất, có thể có Block/phòng/đồng hồ trận; UI04 offline hiện hành chỉ chứng minh joystick/nhảy/ném/Dash. Không dùng nhãn kết nối, RTT, kết quả trận hoặc model3D giả để tuyên bố các tính năng đã triển khai. Cảnh hình khối hiện có chỉ là tài liệu tham chiếu cho vùng nhìn, không phải nguồn UI Figma.

Khi host cấp công cụ/session hỗ trợ:

1. Xác nhận đúng ứng dụng/tài khoản; nếu yêu cầu đăng nhập, để người dùng tự đăng nhập qua UI/host. Không lấy cookie/credential hoặc bật debug-port.
2. Tạo/mở file Figma thật, lưu URL/filekey và tên page/frame/version trong hồ sơ; ghi đúng mức thao tác đã thực hiện.
3. Dựng HUD và các trạng thái theo spec, rồi lần lượt năm màn còn lại. Lưu component/frame có thể sửa trong Figma, không chỉ import một ảnh phẳng làm nguồn.
4. Export PNG từ chính frame, ghi frame/version tương ứng và lưu dưới design/figma/exports khi thực sự có sản phẩm. Không tạo file export rỗng để đánh dấu hoàn tất.
5. Rà nhãn, luồng quay lại/lỗi, readability và nguồn editable; chỉ sau đó đưa ảnh vào Ch3.3 và xem xét xuất Word/PDF theo style mới.

Trong lúc chưa có kết nối: giữ snapshot M3a/M3b và workspace game-only; không cài phần mềm/plugin khác, không sửa config kết nối thủ công, không tự mở Block/mạng để lấp thời gian chờ.
