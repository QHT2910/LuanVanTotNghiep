# Checkpoint tiếp tục dự án

## Lượt đang làm 07/11/2026 — bổ sung từ video Scene

Mốc cuối v0.7: tích hợp/QA/source/Word/PDF hoàn tất trong phạm vi. Word41refs/27ảnh/3OMML; bài declarative analyze/buildtargetPASS, chưaruntime. QA khôngP1, P2 hồsơđãsửa; qa/video-v0.7.md. PDF titlemetadatađúng, inspect79/79okkhôngtrangtrắng; Leadxem20contactsheetvàtrang14/19/28/43/48lớn. SHA256PDF dac7ba0c5caad802ac35ebbb53cec8903766e5c50ec87c5a5d8f0e2e86eb4019. Sảnphẩmhiệnhànhthesis/Ban_thao_Chuong_1-3_v0.7.docx/.pdf, báo cáo docs/VIDEO_v0.7_REVIEW.md. Cả ba Orca thesis/developer/qa terminal, gpt-6.1-sol/rootOLD/chỉđọc; Leadthựcthivàtíchhợp. Khôngđổimodel/provider. V0.6vàv0.3đượcgiữ. Bướctiếplàfinish-sessionloạiv0.3; kiểm gitlog/statusvà.scratch/v07-finish.logtrướcretry, khôngreplaycácmốcdưới. SaupushbàngiaoCindyreview, khôngtựmởrộngchươnghoặcchạyAndroid. Các đoạn “chưa QA/chưa xuất” bên dưới là lịch sử trong lượt, không trạng thái hiện hành.

Mốc tích hợp: thesis và developer đều terminal, patch đã tích hợp Ch2/refs41 và OUTLINE, bài2.12.13–14 đã ghép. Mở formatter/validator/finalizer cho v0.7; Word/PDF v0.7 đã tạo, validator PASS41refs/27ảnh/3OMML. docs/VIDEO_v0.7_REVIEW.md là hồ sơ lượt này. PDF đầu đang mang titlemetadata v0.6 do generator cũ; generator đã sửa title chung, PHẢI tạo lại HTML/render PDF sau QA rồi inspect/rà toàn trang. QA chuẩn bị giao chỉ đọc source/Word/code/logs; không nghiệm thu PDF đầu. Lead chưa commit. Tham chiếu sourceweb/claimmap trong research/video-scene-v07-*.md. Bỏ qua các câu “thesis chờ terminal/chưa tích hợp” ở mốc cũ dưới đây; không replay.

Mốc kiểm mã: developer Orca terminal, toàn văn lấy từ lịch sử session ddab0b98-abe6-4524-9b16-9a548be30b63; draft lưu research/declarative-v07-developer-draft.md. Entrypoint mới đã lưu tại game/tutorial-r3/lib/checkpoints/declarative/main.dart. Lead chạy flutter analyze target PASS và flutter build bundle --debug --target-platform android-arm64 --target lib/checkpoints/declarative/main.dart PASS; log game/evidence-v07/analyze-declarative.txt và build-declarative.txt. Chưa runtime/warm-up/hot reload Android. research/video-scene-v07-verification.md ghi nguồn Lead đã trực tiếp đọc và video kế thừa Cindy. Thesis Orca vẫn chờ terminal report, chưa tích hợp manuscript/refs hoặc xuất v0.7. Không dispatch lại developer. Cleanup hai thư mục rỗng tạo nhầm game/tutorial-r3/game/evidence-v07 và thư mục cha bị automatic approval review từ chối; đã để nguyên, không retry/lách. Đây không phải blocker sản phẩm. Tiếp: nhận patch thesis, đối chiếu/tích hợp+bài2.12.13–14, cập nhật trạng thái code đã analyze/build nhưng chưaruntime; mở hỗ trợ v0.7 trong formatter/validator/finalizer (hiện chỉ nhận v0.6), xuất bản mới không ghi đè v0.6, QA và rà PDF rồi commit/push loại v0.3.

Cơ sở v0.6 / commit 8e67b8c. Yêu cầu mới: bổ sung Ch2 về declarative/imperative, retained graph/ownership, I/O–parse–build preprocessing–GPU preparation/loading/warm-up, hot reload và vai trò editor; một bài khai báo nhỏ tùy chọn so với A. Không mở rộng AI/ragdoll/audio, không nâng SDK hoặc đổi A–F/model/provider. Giữ v0.6 và sửa ngoài lượt Word v0.3. Đang giao Orca thesis và developer chỉ đọc vì root vẫn OLD; Lead tích hợp và thực thi kiểm mã tại D:. QA giao sau tích hợp. Không ghi nhận đã xem video độc lập: Cindy đã xem chọn đoạn, không có full transcript; báo cáo gốc được chuyển qua task, phải phân biệt bằng chứng kế thừa. Xuất Word/PDF phiên bản mới, giữ OMML/caption/comment filter v0.6, rà phân trang thật rồi finish-session loại v0.3. Chưa có sản phẩm mới hoặc commit lượt này.

Ngày 06/11/2026. Đọc AGENTS → PROJECT_BRIEF (nội bộ) → checkpoint này → CURRENT_STATUS → tài liệu liên quan. Các checkpoint trước còn trong lịch sử Git; không replay báo cáo worker hoặc lệnh đã hoàn tất.

## Mục tiêu và quyết định

Ưu tiên Ch1–3 trước giữa kỳ 16–28/11/2026. Tên tạm Bóng rổ đối kháng 3D; gameplay demo đã đồng ý, kiến trúc và ngưỡng thực nghiệm còn là đề xuất. Ch2 có khảo sát 2.1, lý thuyết trước, hướng dẫn riêng 2.12; Ch3 có 3.3 Hệ thống màn hình. Dùng research-paper-writing và humanizer; không tự bold/caps, không đưa ghi chú nội bộ vào manuscript. UI phải có nguồn công cụ bên thứ ba, hình AI cũ không dùng chính thức. Ch4–5 chờ sản phẩm.

Cindy đã nhận nội dung R3/v0.5; lượt v0.6 chỉ sửa xuất bản, không mở rộng lý thuyết hoặc chạy test game.

## Sản phẩm và kiểm tra

- Hiện hành: thesis/Ban_thao_Chuong_1-3_v0.6.docx và .pdf; nguồn Ch2/Ch3 và bản tổng hợp. 37 refs, 27 ảnh, ba display OMML. Bốn nhóm Ch3 chia thành 15 panel có connector, UML 3.2 giữ nguyên.
- QA Orca đã rà source/Word XML/15 PNG, không phát hiện P1/P2 trong phạm vi; qa/publication-v0.6.md. Lead đã xem toàn bộ 71 trang PDF bằng 18 contact sheet, xem riêng trang 15/19/52/56/63 ở kích thước lớn.
- PDF inspect 71/71, verdict ok, không trang trắng. SHA256 e5fb32a270deda86d0eb78d26ec948c13e4251b516d7a5b672368b1090dc61f4.
- Native Word PDF export did not finish. Final PDF uses Cindy Chromium with content/images from the reviewed DOCX, OMML mapped to MathML. Word and PDF pagination can differ; native Word pagination is not approved. No Word export process remains active at the final check.
- docs/PUBLICATION_v0.6_REVIEW.md ghi phương pháp, log và giới hạn; docs/publication-v0.6-checks.json ghi hash/kết quả. Ảnh rà nội bộ .scratch/v06-final-review; không đưa log đầy đủ hoặc ảnh desktop vào Git.
- V0.5/v0.4 giữ nguyên; Markdown Ch2/Ch3 v0.5 lưu riêng. Word v0.3 có sửa ngoài lượt, SHA256 7062097215C87DF6F1EB429D8DCAF3CD773D3BC4F80C33D1ED80928BB8510404, luôn loại khỏi staging.

## Git và side effect

Project D:/totnghiep/LuanVanTotNghiep, origin https://github.com/QHT2910/LuanVanTotNghiep.git, branch main; cơ sở trước tích hợp 6697b3170aff0b668eab2b67b0789f2d0c7d0427. Cuối lượt chỉ Lead dùng finish-session --exclude thesis/Ban_thao_Chuong_1-3_v0.3.docx. Đọc git status/log và log .scratch/v06-finish-session.log trước retry; snapshot dưới là trước commit, không phải lệnh replay.

<!-- checkpoint-git:start -->
Ghi UTC: 2026-11-07T04:25:21.036Z. Snapshot trước commit chứa checkpoint, không phải HEAD cuối phiên.
- Branch: `main`; HEAD cơ sở: `8e67b8c9c0e5815bdc48cc77b8580243d35b54f7`.
- Local tracking origin/main: `8e67b8c9c0e5815bdc48cc77b8580243d35b54f7` (không tự fetch hoặc suy ra remote live).
- Git status lúc ghi: có 21 mục thay đổi chưa commit. Khi khôi phục đọc lại `git status --short` và HEAD thật.
<!-- checkpoint-git:end -->

## Worker theo mốc bàn giao

Root OLD có hậu tố dialogues/2026-11-03/f803dbbb-c27e-4ad8-b1c2-b8a55da1aae3; chưa chuyển quyền sang D:. Không thử ghi hoặc lách sandbox. Lấy root đầy đủ bằng get_workspace_info trước giao việc.

| Vai trò | Worker ID | Model theo runtime đã đọc | Quyền/nhiệm vụ lượt này | Trạng thái/đầu ra |
|---|---|---|---|---|
| diagrams | ub7cjeu5ajbo6e9kxn475jsn | gpt-6.1-sol | OLD, chỉ đọc | Terminal, đề xuất 11 panel; Lead chia tiếp/render |
| qa | bkm37d3uiwhgp757im7y9hov | gpt-6.1-sol | OLD, chỉ đọc | Terminal, QA source/Word/PNG v0.6 |
| thesis | i5ekkscj1rnt90hdtb8zk3n2 | gpt-6.1-sol | OLD, không giao lại | Terminal R3 |
| developer | o7v9oxz0vq8wm7n5527dnta1 | gpt-6.1-sol | OLD, không giao lại | Terminal R3; evidence-r3 kế thừa |
| game-design | abdcapmgtptm06rzkdgyhkxp | gpt-6.1-sol | OLD, không giao lại | Idle; ui-spec-r1 đã lưu |
| research | stc57nkw9b4keymzvagsg2nz | gemini-4-argon cấu hình | OLD, không giao lại | AGENT_NOT_READY ở R2 do saved provider cindy_openai; chưa có bằng chứng Argon chạy |

Không đổi model/provider/Lead/mặc định ứng dụng. Không còn nhiệm vụ worker đang chờ trong lượt xuất bản; báo cáo gửi muộn chỉ đối chiếu. Không dùng native subagent trong lượt này.

## Còn lại và bước tiếp

Cindy review độc lập v0.6 theo báo cáo xuất bản, đặc biệt chấp nhận cách chia panel và phần trắng khi panel dùng trang riêng. Không tuyên bố bản thảo đã đủ điều kiện nộp: bìa/header/TOC và bộ UI còn thiếu; native Word pagination chưa rà hết. Không tự chạy lại R3 hoặc Android/Internet. Một Redmi Note11, chưa có bằng chứng render Android/asset runtime/hai Android hoặc Internet mới.

Nếu nhận yêu cầu tiếp, đọc đúng phạm vi và Git hiện tại rồi thực hiện phần đó. Root worker phải được sửa qua host hỗ trợ và xác nhận quyền trước ghi. Không retry Argon/provider bị từ chối hoặc tạo worker trùng. Dùng native compaction và CONTEXT_PROTOCOL; chưa có auto rollover được xác minh, không /clear, cron hoặc polling.
