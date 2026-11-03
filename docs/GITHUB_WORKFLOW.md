# Lưu thay đổi cuối phiên lên GitHub

Repo: https://github.com/QHT2910/LuanVanTotNghiep (công khai).

Luồng được sinh viên yêu cầu ngày 2026-11-04: cuối phiên, Lead tích hợp các agent → rà nội dung và diff → chạy script → commit nếu có thay đổi → push main → báo kết quả thực tế. AGENTS.md nhắc lại quy tắc cho các phiên sau.

```powershell
node tools/finish-session.cjs --check
node tools/finish-session.cjs --message "docs: cap nhat ban thao chuong 1-3"
```

Đây là bước do agent thực hiện cuối phiên, không phải bộ theo dõi tự chạy khi đóng ứng dụng. Nếu ứng dụng đóng đột ngột hoặc agent không được chạy, không có bảo đảm push. Không cài tác vụ nền; không force-push. Push lỗi thì commit vẫn lưu tại máy, báo người dùng và thử lại khi kết nối/quyền được khắc phục.

Chỉ đưa tài liệu do dự án tạo, source sơ đồ và code đã rà vào Git; bản PDF mẫu trường và Word gốc giữ ngoài repo. `.gitignore` loại các đầu vào, cache, cấu hình cá nhân và credential phổ biến. File ignore không thay cho kiểm tra nội dung trước commit.
