# Vai trò thư mục

Workspace `LuanVanTotNghiep.code-workspace` dùng tám root ngang hàng, không mở đồng thời repo root và các thư mục con để tránh lặp cây.

| Root VS Code | Thư mục | Vai trò |
|---|---|---|
| Game và demos | game | App offline, probe/tutorial và bằng chứng từng mốc; không trộn kết quả giữa sản phẩm |
| Thesis | thesis | Source chương, bản tổng hợp, references và bản Word/PDF lưu theo phiên bản |
| UI | design | Đặc tả màn hình; nguồn Figma/PNG thật khi đã tạo, không nhận UI tạm thành thiết kế chính thức |
| Research | research | Claim map, nguồn đã đọc, review/draft chưa chốt |
| QA | qa | Review độc lập, chỉ kết luận trong phạm vi đã quan sát |
| Docs | docs | Roadmap, tiến độ, checkpoint và giới hạn |
| Tools | tools | Migration/validation/publication/finish-session; không tự động chạy chỉ vì mở workspace |
| Demo manifest | demos | Bảng commit/hash; releases là binary local bị ignore |

Trong app: `lib/main.dart` chỉ bootstrap; `src/simulation` giữ config và mô phỏng; `src/input` giữ joystick/nút nhảy; `src/presentation` giữ Scene và HUD. Tests giữ nguyên assertion, chỉ cập nhật imports trong lượt refactor. Bản layout mới phải có gate riêng; evidence lịch sử giữ đường dẫn đúng với commit cũ.

`.git`, `.scratch`, build và `.dart_tool` bị ẩn trong workspace, không xóa. Settings này không đổi global VS Code. Quy trình Git chỉ Lead chạy khi kiểm xong; Wordv0.3 ngoài lượt luôn loại staging. Không force-add APK/raw log hoặc sao chép credential từ máy.
