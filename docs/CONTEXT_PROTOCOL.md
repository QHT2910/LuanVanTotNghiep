# Quy trình bảo toàn context

## Đã triển khai trong dự án

AGENTS.md yêu cầu cập nhật CONTEXT_HANDOFF.md sau mốc bàn giao, trước đổi phiên/nén chủ động khi có cơ hội và khi thay quyết định/blocker. `tools/checkpoint-context.cjs` chỉ cập nhật vùng Git được đánh dấu trong checkpoint; phần ngữ nghĩa do agent cập nhật và kiểm tra theo bằng chứng. Script không gửi prompt hoặc chép lịch sử/tool output.

`tools/finish-session.cjs` gọi script đó khi có thay đổi dự án để lưu checkpoint trong cùng commit, rồi dùng luồng commit/push cũ. Khi không có thay đổi, không làm mới timestamp để tạo commit vô ích. Đây là bước cuối phiên do agent gọi rõ ràng, không phải daemon, cron hay hook hậu commit.

```powershell
node tools/checkpoint-context.cjs
node tools/finish-session.cjs --message "docs: cap nhat checkpoint context"
```

Snapshot nằm trước commit chứa nó: HEAD/tracking trong file là mốc trước commit, không thể là hash của chính commit đó. Sau khôi phục luôn đọc git status, HEAD và remote thật; không tự tạo lại commit/push đã thành công. Khi push bị gián đoạn, kiểm tra remote trước khi thử lại.

## Khả năng thực tế đã kiểm tra

Ngày 04/11/2026 đọc trợ giúp host `sessions-and-chat`, `personalization`, `collaboration` và danh mục control/handoff. Cindy mô tả Codex tự quản lý context; vòng context trên UI là chỉ đọc với Codex và ngưỡng ở Personalization không áp dụng cho Codex. Không sửa setting hoặc tự bịa mức phần trăm đầy.

Danh mục tool hiện có không cung cấp lệnh gọi compaction của Codex, sự kiện token sắp đầy hoặc giao dịch tự chuyển quyền sở hữu team. Do đó dùng native compaction mặc định kết hợp checkpoint. Không tuyên bố checkpoint đã cài auto rollover.

Tài liệu OpenAI mô tả compaction giúp tiếp tục cuộc trò chuyện dài và lệnh `/compact` trên các bề mặt hỗ trợ; điều này không tự tạo một tool gọi được trong host hiện tại:

- https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide (phần Compaction, đọc 04/11/2026).
- https://developers.openai.com/blog/mastering-codex-remote-for-engineering (phần Manage context, đọc 04/11/2026).

Không dùng `/clear`: trợ giúp host nêu lệnh này xóa context/nội dung session tại chỗ. Không tạo cron/polling hoặc tự gọi slash command trong terminal.

## Sau native compaction

1. Đọc lại AGENTS/brief/checkpoint và phần tài liệu liên quan, không nạp toàn bộ lịch sử.
2. Đối chiếu Git, task/model/project/root, trạng thái và queue worker theo tool host. Checkpoint chỉ là snapshot.
3. Xác nhận đầu ra nào đã được tích hợp/push; chỉ thực hiện bước dở hoặc bước mới được giao. Báo cáo worker đến muộn không kích hoạt replay.
4. Ghi checkpoint ở mốc tiếp theo. Không thể bảo đảm callback trước mọi lần compaction hoặc khi ứng dụng đóng đột ngột.

## Nếu thật sự cần một session mới hoàn toàn

### Quy tắc quota người dùng — 12/11/2026

- Kiểm usage subscription accounts qua host ở đầu task, mốc bàn giao và trước lệnh build/runtime dài; kiểm cả primary theo giờ và secondary theo tuần, không polling vòng lặp.
- Khi primary used >=95% (còn5%), không nhận task/build dài mới. Dừng worker an toàn nếu đang làm, giữ file dở và ghi checkpoint ngay: file đổi, task done/pending, lệnh đã chạy/kết quả/evidence, side effect chưa rõ, bước tiếp, quota used và resetsAt thực đọc. Không ép commit code hỏng.
- Sau reset giờ, đọc lại usage xác nhận rồi mới resume từ checkpoint; reset giờ không reset tuần. Không đổi account/provider để né hạn mức, không replay bước đã xong.
- Nếu host không expose phép đọc, ghi rõ chưa thể tự đọc; số Cindy cung cấp là bằng chứng kế thừa, không giả đã đọc mới hoặc bịa resetsAt. Yêu cầu host refresh tại mốc trước công việc dài; không đọc credential/config riêng để lách.


Chưa tạo session mới hoặc cài luồng tự nối tiếp. Host có `send_to_session` create/jump và UI có New/fork; đây là khả năng tạo/gửi task, không phải trigger context hoặc chuyển team. Create không truyền context Orca/team của Lead một cách đã được chứng minh; jump không thay working_dir/model task cũ. Không dùng các đường này để tự tạo nhiều Lead hoặc thay worker.

Quy trình chỉ thực hiện khi được phép và host đủ hỗ trợ:

1. Chọn mốc an toàn, cập nhật checkpoint và xác minh side effect/Git/queue; không dừng hoặc ghi đè phiên cũ.
2. Xác định chính xác project, model/provider, quyền và cơ chế sở hữu worker. Nếu không bảo đảm một chủ tích hợp/ghi duy nhất hoặc không có cơ chế chuyển team, giữ session cũ và native compaction.
3. Nếu mở session mới, dùng cấu hình host đã kiểm chứng. Prompt đầu chỉ yêu cầu đọc checkpoint và trả nhận biết trạng thái, chưa chạy lệnh có side effect.
4. Bên mới phải xác nhận đã đọc, HEAD/branch/root, đầu ra hiện hành và việc sẽ tiếp tục. Chỉ sau xác nhận và cơ chế loại trừ chạy trùng mới giao việc tiếp.

Auto rollover cần hook host đáng tin về context, checkpoint an toàn và xác nhận người nhận/team. Các hook đó chưa được xác minh trong danh mục hiện tại; phần đã làm là checkpoint dự án và quy tắc khôi phục, không phải thay đổi engine.

## Kiểm tra lượt triển khai 04/11/2026

Đã kiểm tra cú pháp hai script bằng `node --check`; chạy checkpoint và so sánh xác nhận chỉ vùng Git bị đổi; chạy `finish-session --check` và so hash xác nhận chế độ này không sửa checkpoint. Bảng chứa đủ sáu worker ID không lặp, checkpoint dưới 14 KB. Log cục bộ: `.scratch/context-check.log`; không đưa log máy vào Git. `git diff --check` đạt, log `.scratch/context-diff-check.log`. Không chạy lại build/probe/game hoặc đánh thức worker trong lượt này.
