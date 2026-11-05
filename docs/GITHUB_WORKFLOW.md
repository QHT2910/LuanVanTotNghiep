# Lưu thay đổi cuối phiên lên GitHub

Repo: https://github.com/QHT2910/LuanVanTotNghiep (công khai).

Nếu tệp có thay đổi sẵn ngoài phạm vi chưa được rà, dùng `--exclude relative/project/path` với script cuối phiên để giữ nó ngoài staging. Ví dụ R2: `--exclude thesis/Ban_thao_Chuong_1-3_v0.3.docx`. Script từ chối đường dẫn không hợp lệ hoặc tệp loại trừ đã được stage; không tự reset hoặc ghi đè thay đổi sẵn có.

Trước bước cuối phiên, Lead cập nhật phần quyết định, đầu ra và việc dở trong [checkpoint](CONTEXT_HANDOFF.md). Script cuối phiên tự làm mới vùng Git của checkpoint khi có thay đổi; không tự tổng hợp lịch sử hoặc mở session mới. `--check` chỉ đọc, không cập nhật timestamp. Chi tiết khôi phục sau compaction ở [quy trình context](CONTEXT_PROTOCOL.md).

Luồng được sinh viên yêu cầu ngày 2026-11-04: cuối phiên, Lead tích hợp các agent → rà nội dung và diff → chạy script → commit nếu có thay đổi → push main → báo kết quả thực tế. AGENTS.md nhắc lại quy tắc cho các phiên sau.

```powershell
node tools/finish-session.cjs --check
node tools/finish-session.cjs --message "docs: cap nhat ban thao chuong 1-3"
```

Đây là bước do agent thực hiện cuối phiên, không phải bộ theo dõi tự chạy khi đóng ứng dụng. Nếu ứng dụng đóng đột ngột hoặc agent không được chạy, không có bảo đảm push. Không cài tác vụ nền; không force-push. Push lỗi thì commit vẫn lưu tại máy, báo người dùng và thử lại khi kết nối/quyền được khắc phục.

Chỉ đưa tài liệu do dự án tạo, source sơ đồ và code đã rà vào Git; bản PDF mẫu trường và Word gốc giữ ngoài repo. `.gitignore` loại các đầu vào, cache, cấu hình cá nhân và credential phổ biến. File ignore không thay cho kiểm tra nội dung trước commit.
