# Mở rộng Chương 2 — R2, 05/11/2026

Yêu cầu: luận văn bị đánh giá thiếu cơ sở lý thuyết; giải thích thành phần và nguyên lý sâu hơn, tách hướng dẫn cuối chương. Bản hiện hành dự kiến v0.4, không thay v0.3. Số trang không dùng làm mục tiêu độ sâu.

## Thay đổi trước và sau

| Trước | Sau |
|---|---|
| 2.2–2.9 trộn lý thuyết và thao tác | 2.1–2.11 lý thuyết; 2.12 gồm 12 bước thực hành |
| Thiếu pipeline/toán | CPU/GPU, primitive/fragment/depth/blend; vector/TRS/MVP/viewport/ray và ví dụ tọa độ |
| PBR chủ yếu tên tham số | BRDF, phương trình phản xạ, dielectric/metal, roughness, màu tuyến tính |
| Animation chủ yếu lệnh clip | Keyframe/nội suy, buffer/accessor, joint/weight/inverse bind/skinning |
| Loop/mạng chỉ khái quát | Accumulator có số minh họa; ackSeq=12/replay13–15, event vs state, miền đồng hồ |
| Ví dụ API rời | Một tutorial có source hoàn chỉnh, trigger/texture/HUD và nhánh asset có điều kiện |
| 19 nguồn/8 hình | 35 nguồn/14 hình; 6 hình lý thuyết mới có nguồn Mermaid/PNG |

## Ai làm gì

Orca Worker thesis (Sol 6.1) soạn toàn văn lý thuyết và đọc thêm nguồn; developer (Sol 6.1) đối chiếu API và hướng dẫn; diagrams (Sol 6.1) bàn giao 6 nguồn; QA (Sol 6.1) rà baseline và bản tích hợp, phát hiện 6 P1/10 P2. Lead tích hợp, bổ sung BRDF/skinning/viewport/ack, sửa UTF-8, chạy check và xuất Word. Game-design không giao việc vì không có thay đổi thiết kế game/UI. Research cấu hình Argon nhưng dispatch AGENT_NOT_READY do thread yêu cầu provider cindy_openai không còn cấu hình; không có lượt Gemini được xác minh.

Các worker chỉ đọc do root host còn cũ; Lead lưu báo cáo, không sửa quyền hoặc lách sandbox. Không dùng native subagent.

Sau sửa QA: Word v0.4 đã tạo lại và PASS validator (35 nguồn, 14 ảnh, XML hợp lệ), log .scratch/r2-word-validation-final.log. Quét UTF-8 trên Ch2/refs/outline/sáu Mermaid không còn mẫu chữ–?–chữ hoặc replacement character; .scratch/r2-encoding-check.log. Đã xem cả sáu PNG, nhãn tiếng Việt không bị cắt; chưa xác nhận bố cục trang Word. Hash v0.3 giữ 7062097215C87DF6F1EB429D8DCAF3CD773D3BC4F80C33D1ED80928BB8510404, trùng snapshot trước tích hợp. Đang giao QA kiểm tra phần đã sửa, không chạy lại game.

## QA và sửa lỗi

Baseline: qa/ch02-baseline-r2.md. QA bản tích hợp nhận xét cấu trúc/nội dung cải thiện nhưng phát hiện mất dấu references/hình và thiếu BRDF, skinning, viewport, seq/ack. Lead khôi phục UTF-8, bổ sung các mô hình có nguồn [31]–[35], sửa lifecycle/onLoad và lời dành riêng Lead trong tutorial. Word phải được tạo lại từ nguồn sau sửa. Hồ sơ nguồn: research/ch02-r2-sources.md; claim map cập nhật riêng.

## Kiểm tra thực sự chạy

Offline resolve, analyze, build bundle Android arm64 và smoke loopback tại game/tutorial-r2 đều exit 0. Log công khai đã rà ở game/evidence-r2; checks.json lưu kernel bytes/SHA256. Không suy ra APK/render Android, GLB/animation runtime, hai Android, Internet hoặc FPS đạt.

Sáu nguồn Mermaid đã render bằng mmdc và cấu hình Puppeteer hiện có; không cài browser mới. Lead đã xem cả sáu PNG sau sửa, chữ tiếng Việt đúng, không thấy nhãn cắt. XML Word, số trích dẫn và số ảnh được validator kiểm tra. Chưa có công cụ xác nhận pagination Word thực; cần mở Word rà bảng/code, ngắt trang và mục lục trước nộp. Không nhận XML pass là visual pass.

QA Orca Worker tester xác nhận lần cuối: text/structure đạt trong phạm vi sửa, không còn P1 được giao; đọc XML có 14 ảnh và refs [1]–[35], không thấy encoding hỏng. QA không chạy lại build/game hoặc xem Word pages. Báo cáo lưu qa/ch02-r2-final.md. Đây là bàn giao cho review độc lập tiếp, không bảo đảm GVHD chấp nhận mọi độ sâu/chuẩn trích dẫn.

## Còn cần xác nhận

GVHD có yêu cầu giáo trình/chuẩn citation hoặc mức diễn giải khác thì cập nhật tiếp. Asset GLB có giấy phép, thiết bị Android và thiết kế UI bằng công cụ bên thứ ba còn thiếu. YouTube mới đọc metadata chính thức, chưa xem/transcript; GitHub tag/commit của bản phân phối chưa xác minh. Không tự chốt luật/mạng/vật lý trong lượt này.

Word v0.3 đã có sửa ngoài lượt R2 trước khi tích hợp; giữ nguyên byte hiện tại và loại khỏi staging. Script cuối phiên có --exclude để không đưa thay đổi chưa rà vào commit. Không reset hoặc khôi phục đè lên file này.
