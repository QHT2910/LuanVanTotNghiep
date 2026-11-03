# Hướng dẫn cho các phiên tiếp theo

Đây là chỉ dẫn mới cho workspace D:\totnghiep\LuanVanTotNghiep; AGENTS.md của workspace trước đã được người dùng thu hồi.

- Làm việc bằng tiếng Việt, tuân thủ yêu cầu ngôn ngữ báo lỗi của host.
- Đọc PROJECT_BRIEF.md (hồ sơ nội bộ) và thesis/OUTLINE.md trước khi viết.
- Ưu tiên bản thảo Chương 1–3 trước giữa kỳ 16–28/11/2026. Ch4–5 chỉ viết nội dung kết quả sau khi có sản phẩm/bằng chứng. Bố cục hiện tại là sơ bộ, sẽ thay đổi khi sinh viên yêu cầu.
- Bản Word cũ chỉ là nguồn tham khảo. Không tự biến đề xuất trong đó thành yêu cầu đã phê duyệt hoặc tính năng đã hoàn thành.
- Chưa có sản phẩm; không bịa kết quả thử, ảnh chụp, nguồn, API. Ghi rõ sơ đồ/kiến trúc là thiết kế đề xuất và code hướng dẫn chưa thực thi.
- Hiện có một Redmi Note11; mục tiêu kết nối hai mạng qua Internet nếu khả thi. Client desktop/giả lập không thay bằng chứng hai Android.
- Cuối mỗi phiên có thay đổi đã rà soát: chạy `node tools/finish-session.cjs --message "mô tả thay đổi"`. Người dùng đã yêu cầu tự commit/push lên origin/main; không hỏi lại từng phiên. Khi chưa có thay đổi thì không tạo commit rỗng.
- Script chỉ stage các đường dẫn dự án được liệt kê. Rà diff và chỉ chạy khi sản phẩm đã kiểm tra. Không push bản gốc trường, tài liệu tham khảo cá nhân, credential, môi trường máy hoặc dữ liệu nhạy cảm. Không force-push, tự sửa lịch sử, reset hoặc tự giải quyết xung đột bằng ghi đè. Nếu lỗi mạng/quyền/remote thay đổi: giữ commit local và báo rõ, không tuyên bố push thành công.
- Không dùng hook hậu commit tự push, tác vụ định kỳ hoặc tiến trình nền để đoán lúc kết thúc phiên. Chỉ Lead thực hiện bước cuối phiên sau khi tích hợp các agent.
