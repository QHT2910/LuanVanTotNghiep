# Đặc tả giao diện R1

Cập nhật trạng thái 10/11/2026: sinh viên đã chọn và cho phép kết nối Figma. Chưa có tool/session được hỗ trợ, file editable hoặc PNG. Xem FIGMA_HANDOFF.md; thông tin lựa chọn/công cụ ngày04/11 bên dưới là lịch sử, không phải trạng thái hiện hành. Đặc tả UI01–UI06 giữ làm căn cứ dựng, chưa nhận là sản phẩm UI.


Ngày rà soát: 04/11/2026. Phạm vi: UI01–UI06 và các trạng thái lỗi, chờ, hồi chiêu phục vụ mục 3.3. Đây là đặc tả đề xuất để dựng trong công cụ thiết kế, chưa phải giao diện đã triển khai.

## 1. Căn cứ và trạng thái yêu cầu

Đã đọc tại `D:/totnghiep/LuanVanTotNghiep`:

- `AGENTS.md`, `PROJECT_BRIEF.md`, `thesis/OUTLINE.md`.
- Mục 3.1 và 3.3 trong `thesis/03-xay-dung-game.md`.

Gameplay đã được sinh viên đồng ý: nửa sân 1v1, một rổ, 2/3 điểm, 11 điểm hoặc 3 phút, di chuyển/ném/nhảy/Dash/Block và tạo/vào phòng bằng mã. Ghép trận nhanh bổ sung sau. Mục tiêu ưu tiên kết nối Internet từ hai mạng khác nhau; LAN phục vụ thử nghiệm bước đầu.

Kiến trúc mạng, cách ném, tham số kỹ năng và chính sách xử lý mất kết nối chưa được kiểm chứng. Hiện có một Redmi Note 11; chưa có bằng chứng chạy game hoặc thử trên hai Android.

Mục 3.1.3 gọi màn hình ngang là đề xuất, trong khi 3.3.1 viết như đã xác nhận. Đặc tả này dùng hướng ngang làm phương án chuẩn bị frame; Lead cần thống nhất trạng thái quyết định.

## 2. Công cụ thực tế và điều kiện dựng UI

| Hạng mục | Kết quả kiểm tra ngày 04/11/2026 | Giới hạn |
|---|---|---|
| Plugin | `ghost_list` trả về GitHub và Mermaid | Không có plugin Figma/Penpot đang kết nối |
| Browser | `backend=external`, `enabled=true`, `running=false`, `cdpReady=false`, `realProfile.applied=false` | Có runtime nhưng chưa có phiên thiết kế để thao tác; chưa xác minh đăng nhập Figma/Penpot |
| Công cụ được chọn | Figma mới là đề xuất; sinh viên đang cân nhắc lựa chọn | Chưa có quyết định chọn hoặc quyền tạo project |
| Nguồn thiết kế | Chưa có URL file/project hoặc design session được cung cấp | Chưa có nguồn chỉnh sửa và ảnh xuất mới |

Chưa đăng nhập, đăng ký, tạo tài khoản/project, dựng hình hoặc dùng SVG AI cũ làm bộ thiết kế chính thức.

UI production remains blocked by the missing tool selection and design file/session. The Lead can save this specification now; editable UI and exported images require the selected tool and an accessible design file.

## 3. Frame và component đề xuất

Frame khởi đầu: 960 × 540 đơn vị thiết kế, hướng ngang. Đây là kích thước chuẩn bị prototype, không phải độ phân giải thiết bị đã xác minh. Khi dựng thật cần kiểm tra vùng an toàn, màn hình hẹp, bàn phím Android và khả năng chạm đồng thời.

Các giá trị khởi đầu có thể dùng: lề 24; khoảng cách 8/16/24; chữ nội dung 16, nhãn phụ 14, tiêu đề 24. Phải điều chỉnh sau khi xem trên điện thoại; không coi chúng là tiêu chí nghiệm thu đã duyệt.

| Component | Biến thể cần dựng | Quy tắc |
|---|---|---|
| Button | Mặc định, nhấn, vô hiệu, đang gửi | Chặn gửi lặp; có đường hủy/quay lại hợp lệ |
| RoomCodeInput | Trống, đang nhập, lỗi, đang gửi | Giữ mã khi lỗi; độ dài và bộ ký tự chờ thiết kế giao thức |
| ConnectionBanner | Đang nối, đã nối, gián đoạn, mất nối | Có thông báo chữ; không hiển thị RTT giả |
| PlayerSlot | Trống, đã vào, sẵn sàng, rời/mất nối | Phân biệt Bạn và Đối thủ |
| Countdown | Chờ, đang đếm, bị hủy | Theo trạng thái phòng; không tự đếm để bắt đầu trận |
| ScoreClock | Bình thường, chờ xác nhận, kết thúc | Điểm, thời gian và kết quả theo trạng thái được xác nhận |
| ActionControl | Ném, giữ canh ném, Block, bị khóa | Nhãn đổi theo quyền giữ bóng; thể hiện lý do không dùng được |
| JumpDashControl | Sẵn dùng, nhấn, khóa, hồi chiêu | Không tự đặt thời lượng hoặc gán hồi chiêu chưa có trong luật |
| Notice/Dialog | Lỗi, thông báo, xác nhận rời | Có hành động tiếp theo; không biến lớp phủ thành Pause online |
| AudioSettings | Bật/tắt, điều chỉnh, lỗi lưu | Chỉ tác động thiết bị hiện tại; vẫn có phản hồi thị giác |

Không dùng riêng màu hoặc âm thanh để truyền trạng thái. Font phải hỗ trợ tiếng Việt và có giấy phép phù hợp.

## 4. Sáu màn hình và tương tác

| Mã | Nội dung frame | Tương tác và đích |
|---|---|---|
| UI01 Menu chính | Tên tạm Bóng rổ đối kháng 3D; trạng thái kết nối; Tạo phòng, Vào phòng, Cài đặt | Tạo/Vào → UI02 theo chế độ; Cài đặt → UI06. Ghép trận nhanh ẩn hoặc ghi chưa hỗ trợ trong bản đầu |
| UI02 Tạo/vào phòng | Tiêu đề theo chế độ; xác nhận tạo hoặc ô nhập mã; thông báo cạnh form | Thành công → UI03; lỗi giữ UI02; Quay lại → UI01. Mã phòng lấy từ hệ thống, không sinh mã giả |
| UI03 Sảnh chờ | Mã phòng; hai vị trí người chơi; Sẵn sàng/Hủy sẵn sàng; đếm ngược; Rời phòng | Đủ hai người và cùng sẵn sàng mới đếm; bắt đầu theo trạng thái phòng → UI04; người rời khi đếm → chờ; rời phòng → UI01 |
| UI04 Trận đấu | Cảnh 3D ở giữa; điểm/thời gian phía trên; joystick trái; ACTION/JUMP/DASH phải; thanh canh ném | Có bóng: giữ/thả ACTION để yêu cầu ném nếu hợp lệ; không bóng: Block. Mất chạm/xuống nền đưa input liên tục về trung tính. Kết thúc xác nhận → UI05 |
| UI05 Kết quả | Tỷ số; thắng/thua/hòa; lý do kết thúc; trạng thái kết nối | Về sảnh → UI03 nếu phòng còn hợp lệ và đặt lại sẵn sàng; Về menu → UI01. Phòng không còn thì khóa Về sảnh |
| UI06 Cài đặt | Bật/tắt âm thanh; âm lượng; Quay lại | Phương án đầu: UI01 ↔ UI06. Chưa tự mở cài đặt trong trận hoặc coi cài đặt là Pause |

Luồng chuẩn bị:

`UI01 → UI02 → UI03 → UI04 → UI05 → UI03 hoặc UI01`

`UI01 ↔ UI06`

Đây là luồng giao diện, chưa chọn router hoặc API. Phản hồi bất đồng bộ phải thuộc đúng yêu cầu/phòng/trận hiện hành để phản hồi muộn không đưa người đã rời trở lại phòng.

## 5. Ma trận trạng thái

Các tên variant dưới đây dùng để tổ chức frame trong công cụ; không phải tên API đã tồn tại.

| Frame/variant | Điều kiện | Phản hồi và thao tác | Điều kiện thoát |
|---|---|---|---|
| UI01/connecting | Đang nối dịch vụ | “Đang kết nối”; khóa thao tác cần mạng; Cài đặt còn dùng | Kết nối thành công hoặc lỗi |
| UI01/offline | Không nối được | “Chưa kết nối được”; Thử lại và Cài đặt | Thử lại thành công |
| UI02/empty-invalid | Trống hoặc sai định dạng | Nhắc nhập mã/lỗi cạnh ô; không gửi mã trống | Người dùng sửa mã |
| UI02/submitting | Đã gửi tạo/vào phòng | “Đang tạo phòng”/“Đang vào phòng”; chặn nhấn lặp | Thành công, lỗi hoặc hủy ý định |
| UI02/not-found | Không có phòng | “Không tìm thấy phòng”; giữ mã | Sửa mã, thử lại hoặc về menu |
| UI02/full | Phòng đủ người | “Phòng đã đủ người”; giữ mã | Đổi mã hoặc về menu |
| UI02/network-error | Lỗi gửi hoặc chưa nhận phản hồi | “Chưa nhận được phản hồi”; không tự kết luận đã vào | Đối chiếu yêu cầu cũ trước khi thử lại hoặc về menu |
| UI03/waiting-player | Phòng có một người | “Đang chờ đối thủ”; hiện mã và Rời phòng | Người thứ hai vào hoặc rời phòng |
| UI03/waiting-ready | Đủ hai người, chưa cùng sẵn sàng | Hiện trạng thái từng người; cho đổi sẵn sàng khi được phép | Cùng sẵn sàng hoặc một người rời |
| UI03/countdown | Phòng xác nhận bắt đầu đếm | Hiện đếm ngược; tránh gửi sẵn sàng lặp | Bắt đầu trận hoặc hủy đếm |
| UI03/room-lost | Phòng đóng hoặc mất kết nối | “Không còn kết nối với phòng”; bỏ đếm cũ | Về menu; reconnect chỉ khi được thiết kế |
| UI04/possess-charge | Có bóng và thao tác hợp lệ | ACTION là Ném; giữ hiện thanh canh | Thả, mất bóng, kết thúc hoặc mất chạm |
| UI04/defend | Không giữ bóng | ACTION là Block; JUMP/DASH theo điều kiện | Quyền bóng hoặc trạng thái đổi |
| UI04/cooldown | Kỹ năng chưa sẵn sàng | Hiện tiến độ nếu có dữ liệu; nút không giống trạng thái sẵn dùng | Dữ liệu cho phép lại |
| UI04/locked | Trạng thái cấm hành động | Thể hiện lý do khóa; khóa ném khi Dash theo phương án 3.1 | Trạng thái cho phép lại |
| UI04/interrupted | Mất chạm hoặc xuống nền | Input liên tục về trung tính; không tự biến mất chạm thành cú ném | Trở lại và đọc trạng thái hiện hành |
| UI04/connection-lost | Mạng gián đoạn | Phân biệt mất mạng của mình/đối thủ nếu có dữ liệu; không tự xử thắng/thua hoặc Pause | Nhận trạng thái hợp lệ hoặc lỗi cuối |
| UI05/result-pending | Chưa có kết quả xác nhận | “Đang chờ kết quả”; không suy thắng từ điểm tạm | Nhận kết quả hoặc xử lý lỗi cuối |
| UI05/final | Có kết quả xác nhận | Hiện tỷ số, kết quả, lý do; Về sảnh/Về menu theo trạng thái phòng | Người dùng chọn |
| UI05/room-gone | Có kết quả nhưng phòng không còn | Giữ kết quả đã nhận; khóa Về sảnh | Về menu |
| UI06/muted | Âm thanh tắt | Âm lượng vô hiệu; thông tin thị giác vẫn đầy đủ | Bật âm thanh |
| UI06/save-error | Không lưu được tùy chọn | Phân biệt thay đổi đang áp dụng với thay đổi chưa lưu | Thử lưu hoặc quay lại |

Thời lượng hồi chiêu, timeout, đếm ngược và ngưỡng cảnh báo mạng chưa chốt. Prototype không được biến giá trị minh họa thành thông số đã duyệt.

## 6. Checklist nguồn UI

Khi công cụ được chọn và có quyền truy cập:

- Ghi tên công cụ và URL/file ID hoặc đường dẫn nguồn chỉnh sửa.
- Ghi trang/frame ID cho UI01–UI06 và từng variant.
- Ghi phiên bản, ngày sửa và người thiết kế.
- Lưu component, kiểu chữ, khoảng cách và tương tác trong nguồn.
- Ghi nguồn, tác giả và giấy phép font/icon/asset.
- Xuất ảnh thật từ đúng phiên bản nguồn; ghi đường dẫn ảnh và frame tương ứng.
- Kiểm tra nhãn tiếng Việt, trạng thái vô hiệu/chờ/lỗi/hồi chiêu và đường quay lại.
- Kiểm tra ảnh không chứa dữ liệu cá nhân hoặc thông tin tài khoản.
- Chỉ đưa ảnh vào 3.3 sau khi đối chiếu nguồn; không thay bằng SVG AI cũ hoặc ảnh dựng giả.

## 7. Điểm cần Lead tích hợp vào 3.1 và 3.3

1. Bảng UI01 và sơ đồ đang bỏ qua UI02. Thống nhất luồng Tạo/vào phòng qua UI02 trước Sảnh chờ.
2. Ghép trận nhanh cần ghi rõ là phần bổ sung sau.
3. Thống nhất cách diễn đạt về hướng ngang giữa 3.1.3 và 3.3.1.
4. Làm rõ UI06 có mở từ trong trận không; phương án đầu chỉ mở từ Menu.
5. Chốt hành vi hủy giữ ném khi mất chạm, điều kiện hồi chiêu, hết giờ và ghi điểm cùng nhịp.
6. Chốt xử lý mất kết nối và quay lại sảnh khi chỉ một người muốn tiếp tục.
7. Giữ phân biệt phản hồi sớm trên máy khách với điểm, thời gian và kết quả được xác nhận.

## 8. Bàn giao và giới hạn

- Sản phẩm bàn giao: nội dung đặc tả R1 gồm frame/component/interaction, ma trận trạng thái, checklist nguồn UI và góp ý 3.1/3.3; Lead lưu thành `design/ui-spec-r1.md`.
- Bằng chứng: đã đọc tài liệu hiện hành và kiểm tra plugin/browser. Chưa có kiểm thử giao diện, đa chạm, khả năng đọc trên điện thoại, hiệu năng hoặc độ trễ.
- Điểm chưa rõ: công cụ/file/session thiết kế; hướng màn hình được duyệt; tham số kỹ năng và chính sách luật/mạng chi tiết.
- Bước tiếp theo: Lead lưu tài liệu, thống nhất các quyết định rồi cung cấp context công cụ để dựng nguồn và xuất ảnh thật. Giữ ưu tiên Chương 1–3 trước giữa kỳ; chưa viết kết quả Chương 4–5.

Lead lưu báo cáo trả trực tiếp từ worker do worker không tạo được thư mục đầu ra. Các nhận xét phản ánh bản mà worker đã đọc; xem docs/R1_REVIEW.md để biết sửa đã tích hợp và giới hạn hiện hành.

