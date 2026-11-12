## Bàn giao UI và DRAFT v0.9 — 12/11/2026

Ưu tiên hiện hành: dùng bộ FigmaAI người dùng chọn, không vẽ lại Page 4/Menu cũ. Đã backup FIG 3615396 bytes SHA256 df1fdffc…f3a9, xuất native 10 PNG Page 3 và xem cả 10; dùng riêng UI04 V3 r2 Page 4. 11 ảnh thật đã chèn mục 3.3 (Hình 3.9–3.19); tổng DOCX 38 PNG/3 OMML. Manifest design/figma/exports/user-selected-2026-11-12/manifest.json. FIG local ignored, không nhận cloud sync đã đạt.

DRAFT v0.9 DOCX/PDF đã xuất và kiểm XML/nguồn; PDF Chromium 114 trang inspect đủ, render không text vượt mép; rà UI lớn và contact sheets cuối. P2 repeat-header bảng trang 107 đã sửa. Report docs/PUBLICATION_v0.9_REVIEW.md, qa/thesis-v09-lead-review.md. Chưa Word native/bìa/TOC/After cuối/UI04 variants đầy đủ hoặc game tích hợp. Giữ v0.8/v0.7/v0.3/demos; v0.3 ngoài stage. Không worker mới, không model/provider/game/Ch4 test mới. Bước tiếp: Cindy review bản có ảnh; chỉ sửa điểm có bằng chứng, không replay GUI/export hay gate đã xong.

Các mục bên dưới là lịch sử; trạng thái thiếu ảnh/đang chờ v0.9 không còn là hiện hành.

# UI04 trong Figma — bản đang làm

Trạng thái mới nhất 10/11/2026: dừng triển khai bản này vì sinh viên yêu cầu đánh giá/phác thảo lại trong chat trước khi hoàn thiện. Giữ nguyên các frame làm version tham khảo, không xóa/ghi đè. Chờ sinh viên review phương án mới do Cindy chuẩn bị; không tự tiếp tục các bước sửa canvas bên dưới. Sync/.fig/PNG vẫn chưa được xác minh.

Ngày 10/11/2026. Nguồn chỉnh sửa trong draft [Bóng rổ đối kháng 3D — UI](https://www.figma.com/design/AKyJ1SFfjiJH8oS8q8m4JW/?node-id=1-2), Page 1. Không tạo thêm file khi tiếp tục.

Đã trực tiếp tạo lớp chữ, hình chữ nhật và ellipse trong Figma, không nhập ảnh phẳng hoặc SVG thay cho nguồn. Frame gốc 960×540; ba frame trạng thái được nhân từ frame gốc:

- UI04-Trận đấu / Sẵn sàng: điểm hai người, thời gian mẫu, trạng thái kết nối, joystick trái và nhãn Nhảy/Dash/Ném bên phải.
- UI04-Trận đấu / Canh ném: hướng dẫn thả và thanh mức ném bằng hai hình chữ nhật.
- UI04-Trận đấu / Hồi chiêu: nhãn Dash đang hồi; ACTION đổi thành Block khi phòng thủ.
- UI04-Trận đấu / Mất kết nối: thông báo kết nối lại và điều khiển tạm khóa; bỏ thanh mức ném.

Đây là các frame trạng thái riêng, chưa phải component set/prototype tương tác. Phần sân 3D được ghi rõ là minh họa thiết kế. Điểm, đồng hồ và kết nối là dữ liệu thiết kế mẫu, không phải kết quả game hoặc mạng đã chạy. Chưa được Cindy/sinh viên duyệt bố cục; cần tiếp tục tách, căn chỉnh nhóm nút và rà vùng chạm/độ đọc.

## Review Cindy — chưa tích hợp vào canvas

UI04 chưa nghiệm thu. Ưu tiên bảo toàn nguồn trước khi sửa thêm. Sau đó tách ba nút Nhảy, Dash và ACTION thành các nhóm/component riêng với hình nền, nhãn và vùng chạm rõ; hiện tại chúng còn là một lớp chữ trên mảng chung. Tách tên/điểm của từng người, đồng hồ và trạng thái kết nối thành các nhóm HUD riêng, không chỉnh cả dòng bằng khoảng trắng. Đưa hướng dẫn joystick về gần joystick hoặc thành chú giải onboarding, giữ giữa sân thoáng.

Possession và cooldown là hai trục độc lập. Bản hồi chiêu hiện đồng thời hiển thị Block chỉ là tổ hợp đang vẽ, không phải quy tắc cooldown đổi ACTION sang Block. Bản sửa cần thể hiện Ném/Block theo possession và trạng thái Dash sẵn sàng/đang hồi riêng. Thông báo “Đang kết nối lại” hiện có chưa được coi là chính sách tự động reconnect đã chốt; cần đổi sang thông báo trung tính “Kết nối bị gián đoạn” trong lần sửa canvas, chưa hứa tự kết nối hay tự phát lại lệnh.

Lượt kiểm tiếp: Computer Use hoạt động, nhưng cửa sổ draft đang minimized; đọc canvas trả CUA_UNAVAILABLE/window_not_on_screen. Chưa gửi input hoặc thay đổi Figma trong lượt review này; đang chờ chủ máy đưa cửa sổ hiện ra. Không đóng/reload để thử sửa sync.

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
