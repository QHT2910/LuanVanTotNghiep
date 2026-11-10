# Chẩn đoán blocker backup Figma

10/11/2026. Chưa có backup `.fig` được xác minh; chưa dựng UI04 V3 hoặc xuất PNG. Lượt này không gọi Save lại, không reload/close/signout/xóa cache/đổi mạng hoặc chia sẻ file.

## Đã kiểm

| Kiểm tra | Kết quả | Giới hạn |
|---|---|---|
| ComputerUse list_windows | Draft cũ vẫn tồn tại, đang minimized | Không có ảnh canvas mới để nhận xét bằng thị giác |
| AX state của draft | Vẫn có “Some changes won't be synced until Figma is able to reconnect.” | Không tự suy lỗi đăng nhập, firewall hay provider từ một thông báo chung |
| Đăng nhập/error trong AX | Không thấy login dialog hoặc mã lỗi mạng cụ thể được expose | Không chứng minh session auth còn hợp lệ |
| HEAD https://www.figma.com từ máy qua PowerShell | HTTP200 | Không chứng minh socket đồng bộ của app hoạt động |
| HEAD https://status.figma.com từ máy qua PowerShell | HTTP200 | Không đại diện mọi domain/kết nối của Figma |
| Trang status chính thức đọc mới | All Systems Operational, Figma Design/collaboration/sign-in operational | Trạng thái toàn dịch vụ, không loại lỗi cục bộ hoặc account/file riêng |

Không thu cookie/token/credential; không xuất địa chỉ máy, profile proxy hoặc log network thô lên Git. Log probe chọn trường ở `.scratch/figma-network-probes.json` là local.

## Chưa xác định

Chưa biết vì sao Save local copy không tạo hộp/tệp. HTTPS200 chỉ chứng minh đường HTTP đã thử; chưa kiểm được WebSocket hoặc auth của app. Driver menu/focus vẫn là giả thuyết kỹ thuật, chưa được nhận là nguyên nhân chính. Không có cơ sở báo Figma bị outage toàn hệ thống.

Figma có quick action Check network settings trong file canvas để xem domain/action bị chặn. Cửa sổ đang minimized và công cụ không có thao tác giữ foreground lâu dài; đã nhờ người dùng mở đúng diagnostic trong draft (`Ctrl+/`, tìm Check network settings), để hộp đó hiện, không yêu cầu xác nhận đã lưu hoặc thao tác reload. Chờ đọc kết quả thật trước khi đề xuất đổi mạng/proxy/quyền. Không tự tắt firewall/VPN hoặc sửa cấu hình lâu dài.

## Nguồn chính thức

- https://status.figma.com/ — đã đọc trong lượt chẩn đoán.
- https://help.figma.com/hc/en-us/articles/19424714305943-Adjust-your-network-settings — đã đọc: phân biệt truy cập web và WebSocket; đường mở Check network settings từ canvas. Chưa thực hiện thay đổi network theo tài liệu.

Bước tiếp: đọc diagnostic GUI → xử lý đúng blocker được xác minh trong phạm vi cho phép → backup không ghi đè, kiểm nonempty/hash → mới BG_Court/HUD V3 và ba PNG960×540. Nếu diagnostic yêu cầu người dùng/quản trị, báo đúng một hành động cụ thể và giữ draft nguyên trạng.
