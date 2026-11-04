# Hướng dẫn cho các phiên tiếp theo

Đây là chỉ dẫn mới cho workspace D:\totnghiep\LuanVanTotNghiep; AGENTS.md của workspace trước đã được người dùng thu hồi.

- Làm việc bằng tiếng Việt, tuân thủ yêu cầu ngôn ngữ báo lỗi của host.
- Khi biên tập luận văn, dùng research-paper-writing và humanizer. Không tự nhấn đậm hoặc viết hoa toàn bộ tiêu đề/nội dung. Giữ cách viết chuẩn của tên riêng, mã và định danh kỹ thuật. Đưa ghi chú quy trình, đường dẫn nội bộ và checklist rà soát ra tài liệu riêng, không chèn vào bản luận văn.
- Tên game tạm: Bóng rổ đối kháng 3D. Gameplay demo đã được sinh viên đồng ý theo gợi ý: nửa sân 1v1, 2/3 điểm, 11 điểm hoặc 3 phút, di chuyển/ném/nhảy/Dash/Block, phòng bằng mã và ghép trận nhanh bổ sung sau. Kiến trúc và kết quả thực nghiệm vẫn chưa được xác nhận.
- Ch2 có 2.1 Các hệ thống tương tự, các mục cũ dịch tăng một số. Ch3 có 3.3 Hệ thống màn hình riêng theo mẫu; bản UI tự sinh cũ không được dùng làm hình thiết kế chính thức. Giao diện phải được thiết kế trong công cụ bên thứ ba, lưu nguồn và ảnh xuất thực tế.
- Đọc PROJECT_BRIEF.md (hồ sơ nội bộ) và thesis/OUTLINE.md trước khi viết.
- Ưu tiên bản thảo Chương 1–3 trước giữa kỳ 16–28/11/2026. Ch4–5 chỉ viết nội dung kết quả sau khi có sản phẩm/bằng chứng. Bố cục hiện tại là sơ bộ, sẽ thay đổi khi sinh viên yêu cầu.
- Bản Word cũ chỉ là nguồn tham khảo. Không tự biến đề xuất trong đó thành yêu cầu đã phê duyệt hoặc tính năng đã hoàn thành.
- Chưa có sản phẩm; không bịa kết quả thử, ảnh chụp, nguồn, API. Ghi rõ sơ đồ/kiến trúc là thiết kế đề xuất và code hướng dẫn chưa thực thi.
- Hiện có một Redmi Note11; mục tiêu kết nối hai mạng qua Internet nếu khả thi. Client desktop/giả lập không thay bằng chứng hai Android.
- Cuối mỗi phiên có thay đổi đã rà soát: chạy `node tools/finish-session.cjs --message "mô tả thay đổi"`. Người dùng đã yêu cầu tự commit/push lên origin/main; không hỏi lại từng phiên. Khi chưa có thay đổi thì không tạo commit rỗng.
- Script chỉ stage các đường dẫn dự án được liệt kê. Rà diff và chỉ chạy khi sản phẩm đã kiểm tra. Không push bản gốc trường, tài liệu tham khảo cá nhân, credential, môi trường máy hoặc dữ liệu nhạy cảm. Không force-push, tự sửa lịch sử, reset hoặc tự giải quyết xung đột bằng ghi đè. Nếu lỗi mạng/quyền/remote thay đổi: giữ commit local và báo rõ, không tuyên bố push thành công.
- Không dùng hook hậu commit tự push, tác vụ định kỳ hoặc tiến trình nền để đoán lúc kết thúc phiên. Chỉ Lead thực hiện bước cuối phiên sau khi tích hợp các agent.

## Bảo toàn context

- Đọc docs/CONTEXT_HANDOFF.md khi bắt đầu, sau compaction hoặc khi nhận bàn giao. Thứ tự: AGENTS → PROJECT_BRIEF → checkpoint → CURRENT_STATUS → chỉ phần liên quan; không nạp lại toàn bộ lịch sử/tool output.
- Sau mỗi mốc bàn giao, khi đổi quyết định/blocker, và trước chuyển phiên hoặc nén chủ động khi có cơ hội: cập nhật checkpoint ngắn bằng trạng thái đã kiểm chứng. Không đợi context đầy, không đoán phần trăm token hoặc hứa callback trước mọi lần nén/đóng ứng dụng.
- Ghi mục tiêu, quyết định vs đề xuất, Git cơ sở, sản phẩm hiện hành, worker ID/model/root/quyền/trạng thái, việc dở/side effect chưa rõ, blocker và bước tiếp/nghiệm thu. Không chép dữ liệu nhạy cảm, credential hoặc log đầy đủ. Mỗi worker chỉ bổ sung checkpoint riêng theo vai trò khi có việc dở và quyền ghi đúng root; Lead sở hữu checkpoint chung.
- Dùng native compaction của Codex; không dùng /clear. Chưa có auto rollover/session mới tự động được xác minh. Xem docs/CONTEXT_PROTOCOL.md. Không tạo cron/polling, nhiều Lead/worker trùng hoặc tự thử lại đổi Gemini đã bị từ chối.
- Trước giao việc tiếp, kiểm tra lại worker/team/queue thật. Root/quyền cũ phải được sửa qua chức năng host áp dụng được và đọc lại xác nhận trước khi ghi; không lách sandbox hoặc ghi nhầm root cũ. Báo cáo gửi muộn chỉ đối chiếu đầu ra, không chạy lại việc đã hoàn tất.
- tools/checkpoint-context.cjs chỉ tự cập nhật phần Git của checkpoint. Nội dung ngữ nghĩa vẫn phải được agent rà theo bằng chứng. tools/finish-session.cjs cập nhật snapshot khi có thay đổi rồi commit/push; snapshot trong commit là trạng thái trước commit, không phải lệnh replay.
