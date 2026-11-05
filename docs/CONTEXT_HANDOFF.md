# Checkpoint tiếp tục dự án

Đọc bản này để nối tiếp, không replay toàn bộ lịch sử. Đây là trạng thái theo mốc bàn giao, không phải bộ đo context hoặc trạng thái worker realtime.

## 1. Mục tiêu và yêu cầu đã xác nhận

Mốc cuối R2 05/11/2026: Word v0.4 đã tạo lại sau sửa; QA xác nhận text/structure không còn P1 trong phạm vi giao. Nguồn Ch2/outline, 35 refs/claim map, 6 PNG/Mermaid mới và tutorial đã đồng bộ; xem docs/R2_REVIEW.md, qa/ch02-r2-final.md. Việc tiếp theo là review độc lập của Cindy/GVHD, rà pagination bằng Word và kiểm tra runtime khi có thiết bị/asset; không chạy lại R1. Giữ thay đổi v0.3 ngoài commit bằng --exclude. Các đoạn ghi “đang tích hợp/đang rà” phía dưới là lịch sử mốc, không phải lệnh làm lại.

Ưu tiên mới 05/11/2026: mở rộng Ch2 vì GVHD đánh giá thiếu lý thuyết. Bản thảo R2 đã tích hợp 2.1–2.11 và hướng dẫn riêng 2.12, nguồn/ảnh/code ở docs/R2_REVIEW.md và CURRENT_STATUS. Orca thesis/developer/diagrams/QA đã có terminal report; QA phát hiện 6 P1/10 P2, Lead đã sửa encoding và bổ sung BRDF/skinning/viewport/seqack, đang tạo lại Word v0.4 và giao rà sửa đổi. Không replay R1. 35 refs,14 ảnh; tutorial-r2 bốn check PASS. V0.3 có sửa trước R2, giữ byte, cuối phiên --exclude thesis/Ban_thao_Chuong_1-3_v0.3.docx. Research cấu hình Argon nhưng dispatch lỗi provider cindy_openai, chưa chạy; không tự retry. Các mô tả R1/R2 ban đầu bên dưới là lịch sử theo mốc.

Nghiên cứu Flutter Scene và demo bóng rổ 3D hai người trên Android, ưu tiên hai mạng Internet nếu khả thi. Tên game tạm: Bóng rổ đối kháng 3D; tên đề tài chính thức do sinh viên bổ sung. Ưu tiên sơ bộ Ch1–3 gần hoàn thiện trước giữa kỳ 16–28/11/2026; Ch4–5 chờ sản phẩm. Nộp quyển 21/12/2026 và 08/01/2027, bảo vệ dự kiến 19–23/01/2027.

Đã chốt gameplay demo: nửa sân/một rổ, 1v1, 2/3 điểm, 11 điểm hoặc 3 phút, di chuyển/ném/nhảy/Dash/Block, phòng bằng mã; ghép trận nhanh bổ sung sau. Ch1 giữ bố cục, 1.1.2 là Mục tiêu của đề tài; Ch2 có 2.1 khảo sát và 2.2–2.10 lý thuyết/hướng dẫn; Ch3 có 3.1/3.2/3.3 Hệ thống màn hình. Dùng research-paper-writing và humanizer; không tự nhấn đậm/viết hoa hoặc đưa ghi chú nội bộ vào manuscript.

Chưa chốt: công cụ/file UI (Figma mới là đề xuất), kiến trúc/giao thức/vật lý cuối, tham số, rời/timeout, Block–qua rổ cùng tick. Không tự biến các đề xuất thành quyết định. Chỉ có một Redmi Note11; lần kiểm tra R1 không có Android kết nối.

## 2. Git và sản phẩm

Repo đúng: https://github.com/QHT2910/LuanVanTotNghiep.git; project D:/totnghiep/LuanVanTotNghiep. R1 tích hợp ở d7793fa, bổ sung báo cáo developer ở 48d9096; đã xác nhận push thành công. Không chạy lại R1 chỉ vì nhận báo cáo worker gửi muộn.

<!-- checkpoint-git:start -->
Ghi UTC: 2026-11-05T07:52:07.238Z. Snapshot trước commit chứa checkpoint, không phải HEAD cuối phiên.
- Branch: `main`; HEAD cơ sở: `e6d9092b50ca016459d3ff6cb2f84a642427dc06`.
- Local tracking origin/main: `e6d9092b50ca016459d3ff6cb2f84a642427dc06` (không tự fetch hoặc suy ra remote live).
- Git status lúc ghi: có 37 mục thay đổi chưa commit. Khi khôi phục đọc lại `git status --short` và HEAD thật.
<!-- checkpoint-git:end -->

Hiện hành: thesis/Ban_thao_Chuong_1-3_v0.3.docx, thesis/BAN_THAO_CHUONG_1-3.md, thesis/REFERENCES.md (19 nguồn). Chi tiết: [CURRENT_STATUS](CURRENT_STATUS.md), [R1_REVIEW](R1_REVIEW.md). v0.1/v0.2 và hình cũ giữ lịch sử; wireframe 3-9 không nằm trong Word hiện hành.

Đã có analyze/build bundle Scene 0.24.3 và smoke hai client loopback; log/hash ở game/evidence-r1/, báo cáo game/feasibility-r1.md. Chưa có APK/render Redmi, hai Android hoặc hai mạng Internet. QA game chưa chạy. Không lấy compile hoặc loopback làm kết quả game.

## 3. Worker: snapshot host ngày 04/11/2026

Model đã chạy của sáu worker vẫn là `gpt-6.1-sol`. Cập nhật sau lượt checkpoint ngày 04/11/2026: host đã chấp nhận cấu hình riêng research cho lần gửi kế tiếp: `codex` / `gemini-4-argon` / `google-gemini-api`, generation 1, boundary `next_send`. Đọc lại runtime xác nhận effective vẫn Sol, pending là Argon; chưa gửi nhiệm vụ, chưa có lượt Gemini thực thi. Lead và năm worker khác đã đọc lại: Sol, pending null. Không đổi mặc định ứng dụng.

Lịch sử: lần đổi trước từng bị automatic approval review từ chối; lượt yêu cầu tiếp theo được host chấp nhận qua `set_session_runtime` bình thường, không có thẻ duyệt mới trong kết quả. Không tự đại diện người dùng duyệt hoặc đổi cơ chế quyền. Sau này không tự retry nếu lại bị từ chối.

Root chung OLD = thư mục dialogue cũ có hậu tố `dialogues/2026-11-03/f803dbbb-c27e-4ad8-b1c2-b8a55da1aae3`, không phải project D:. Prefix hồ sơ máy không lưu trong repo; lấy working_dir đầy đủ bằng get_workspace_info trước khi sửa. “Tệp cũ ghi được” chỉ mô tả bằng chứng R1, không phải cấp thêm quyền.

| Vai trò | Worker ID thật | Root / quyền quan sát R1 | Trạng thái / queue | Đầu ra đã tích hợp |
|---|---|---|---|---|
| research | stc57nkw9b4keymzvagsg2nz | OLD; từng ghi được tệp ở project | idle, không làm, 0 | research/verification-r1.md |
| thesis | i5ekkscj1rnt90hdtb8zk3n2 | OLD; từng sửa được tệp có sẵn | done, không làm, 0 | Ch1–3, REFERENCES, CITATION_MAP |
| game-design | abdcapmgtptm06rzkdgyhkxp | OLD; tạo thư mục mới bị chặn | done, không làm, 0 | design/ui-spec-r1.md, Lead lưu |
| diagrams | ub7cjeu5ajbo6e9kxn475jsn | OLD; từng ghi được tệp ở project | done, không làm, 0 | SVG UML, lớp/sequence R1, truy vết |
| developer | o7v9oxz0vq8wm7n5527dnta1 | OLD; tạo thư mục mới bị chặn | done, không làm, 0 | evidence-r1/developer-environment.md, Lead lưu |
| qa | bkm37d3uiwhgp757im7y9hov | OLD; tạo thư mục mới bị chặn | done, không làm, 0 | qa/review-r1.md, Lead lưu |

Không cần sáu checkpoint rời ở mốc này vì không còn công việc dở theo vai trò; tái dùng các đầu ra trên. Nếu giao việc mới, worker cập nhật checkpoint ngắn trong phần sở hữu khi được phép: đã làm, tệp, đang dở, side effect chưa rõ, kiểm tra tiếp; không ghi đè checkpoint Lead.

## 4. Đang dở và side effect

R2 developer đã bàn giao toàn văn qua lịch sử session, Lead lưu research/tutorial-r2-draft.md và tutorial-r2-api-notes.md, trích hai file Dart vào game/tutorial-r2. Ngày 05/11/2026 đã chạy offline resolve/analyze/build bundle/loopback tại project mới: đều exit 0, log/hash ở game/evidence-r2. Không sửa probe cũ, không Android runtime hoặc asset ngoài. Thesis vẫn chưa có terminal report; chưa tích hợp Ch2/Word. Không dùng các đoạn draft còn ghi chưa chạy để phủ nhận checks.json; cần chuẩn hóa trạng thái khi tích hợp cuối.

Cập nhật R2 05/11/2026: người dùng yêu cầu mở rộng Ch2 thực chất, tách hướng dẫn cuối chương. Thesis/developer/diagrams/QA đã nhận nhiệm vụ Orca chỉ đọc, trả nội dung cho Lead do root cũ. QA và diagrams đã bàn giao; baseline ở qa/ch02-baseline-r2.md, sáu Mermaid/PNG 2-*-r2 và ghi chú diagrams/ch02-r2-notes.md đã lưu. Thesis/developer chưa có kết quả cuối. Research dispatch lỗi AGENT_NOT_READY: thread cũ cần provider cindy_openai không còn cấu hình; chưa có bằng chứng Argon chạy. Không dispatch trùng. Word v0.3 đã có thay đổi trong working tree trước khi Lead sửa R2; không stage/ghi đè nó mà chưa đối chiếu nguồn thay đổi. Chưa tích hợp Ch2/Word mới hoặc commit R2. Bước tiếp: nhận văn bản/hướng dẫn, nghiên cứu nguồn còn thiếu, tích hợp và QA bản mới, giữ v0.3. Lifecycle đã đối chiếu cache 0.24.3: onMount trước onLoad.

R1 đã bàn giao; không có worker job đang chạy trong snapshot. Lượt checkpoint đã lưu ở 0d70685; lượt tiếp theo chỉ cập nhật model research và bàn giao. Có một side effect chờ: cấu hình Argon generation 1 sẽ áp dụng ở lần gửi research kế tiếp; cần đọc runtime trước khi gửi, không đặt cấu hình lại hoặc gửi probe chỉ để kích hoạt. Không có session mới, cron, hook token hoặc chuyển root. Chưa có thao tác thiết kế UI/hosting để tiếp tục âm thầm. Trước mọi retry push/move/create/model, đọc trạng thái thực tế; báo cáo gửi muộn không phải lệnh làm lại.

## 5. Blocker và bước tiếp

1. Trước giao việc worker tiếp: đọc workspace/runtime và danh mục project. Host có `move_session` cho task đủ điều kiện, tái sử dụng luồng chuyển task và refresh runtime idle. Không áp dụng cho task đang chạy, bot-owned/review/IM hoặc chính task gọi đang chạy. Chưa xác minh thao tác đó có chuyển được từng Orca worker mà giữ team; không tự gọi để thử, không sửa DB/cấu hình hay lách sandbox. Nếu không áp dụng được, cần host/UI hoặc người dùng sửa đúng root/quyền. Nghiệm thu: host báo root D: đúng, quyền đúng, model/team giữ nguyên, thao tác ghi nhỏ được phép; trước đó chỉ giao đọc hoặc để Lead tích hợp báo cáo, không tăng quyền tự ý.
2. Review tiếp theo dựa CURRENT_STATUS/R1_REVIEW: chọn UI/cấp design session, quyết định luật còn mở, hoặc kết nối Android. Không tự quyết định trong lượt context này. Nghiệm thu mỗi việc dựa nguồn thiết kế thật, quyết định được xác nhận, hoặc log thiết bị thật.
3. Tiếp tục ưu tiên Ch1–3; không chạy lại probe/analyze hoặc rebuild Word nếu không có thay đổi liên quan hoặc lỗi mới.

## 6. Thứ tự đọc khi khôi phục

AGENTS.md → PROJECT_BRIEF.md (nội bộ, gitignored) → checkpoint này → CURRENT_STATUS.md → thesis/OUTLINE.md. Sau đó chỉ đọc phần theo vai trò: research/verification-r1.md + REFERENCES/CITATION_MAP, hoặc design/ui-spec-r1.md, diagrams/traceability-r1.md, game/feasibility-r1.md, qa/review-r1.md. Nếu brief không có ở clone mới, dùng mục 1 và CURRENT_STATUS, không dựng lại thông tin cá nhân.

Đọc [quy trình context](CONTEXT_PROTOCOL.md) trước khi cân nhắc session mới. Sau compaction kiểm tra lại task/model/root, git và queue rồi nối từ việc chưa hoàn thành; không tạo thêm Lead/worker hoặc phát lại thao tác đã xác nhận.
