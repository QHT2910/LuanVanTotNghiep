# M2 early-release guard — Lead source review,17/11/2026

Lead đã review cả proposal đầu và correction terminal của Orca developer o7v9oxz0vq8wm7n5527dnta1 (readonly Sol6.1medium). Correction bắt đúng điểm cancel-only vẫn đổi Jog/Idle phase khác về Idle0 khi flying. Chấp nhận guard cộng freeze submitted pose, không dùng cancel-only; không mở generic blend trong mốc này.

ChargePoseGate gắn generation mỗi lần charge, readiness chỉ ghi sau Scene.update0/hand sampling/ball latch thành công; evaluated actor generation phải đúng, frame và latch generation phải trùng mẫu được thả. consume chỉ một lần. Mẫu held cũ không bị xóa khi bắt đầu charge để zero-frame tap vẫn thả ngay từ bóng đang thấy. Cancel/Dash/reset/background/exit hủy gate, không reset joystick owner trên Dash.

UnpreparedPoseHold.record lưu clip/time/grounded và submittedFrame sau update/latch; pointerup kiểm frame trước physicsrelease. Prepared shot chạy recovery cũ. Nếu chưa có authored frame, physics thả tức thì/exact origin và freeze chính submitted clip/time, không Authored0 hoặc Idle0. Wrapper vẫn do simulation. Pose giữ trong flight; reset/ready/ground-state change rõ ràng kết thúc freeze, beginCharge xóa giữ cũ. Background cancel hủy action/gate nhưng giữ frozen pose cho tới trạng thái chuyển nói trên. Đây là chọn hành vi có chủ đích: zero-frame tap không có animation ném; không trì hoãn vật lý để chờ clip.

So với developer correction freeze-until-round-reset, Lead cho phép ground-state change rõ ràng kết thúc freeze để landing clip còn dùng được. Chưa claim transition đó là generic blend. Nhánh canh ném trên không vẫn dùng authored Idle-backed body, chưa layered jump/shoot hoàn chỉnh. Normal charge bắt đầu chọn authored pose theo policy hiện hành; guard này chỉ xử lý nhả trước authored frame đầu, không tự nhận mọi chuyển clip đã blend mượt.

Stale raw-axis comment đã sửa theo yawpi AVD; không đổi yaw/asset/physics/mapping. Trace trước nhả và firstflight ghi local matrices65joints, mỗi joint một JSON event ngắn qua public Flutter synchronous logger; chỉ CPU sample, không GPU presented-frame acknowledgment. Không ghi xương sau Scene prepass hoặc gọi update/advance lần hai.

Analyze-guard-final3 No issues/full71testsPASS (64cũ+7policy). Build-guard-final/audit16source4assets/install/launch PASS. Trước đó analyzer bắt thiếu import logger và null assertion thừa, đã sửa rồi chạy lại; không dùng gate fail làm PASS. Python audit manifest có16source, chưa chạy Python; Node kiểm4asset và embedded sources. GeneratedGLB80fdf68b…025f8d không đổi. Candidate a8ed và snapshot M1 vẫn giữ.

Runtime guard-idle/jog hai góc0ms và lowcharge hai góc đang tạo bằng chứng riêng. Cần kiểm65local matrices release/firstflight bằng nhau cho unprepared, exact origin/once/analytic(t), prepared recovery đúng, sau đó regression2/3groundair/cancel/Dash/reset/lifecycle/exit. Chưa guardruntimePASS hoặc M2complete. Latest quota Cindy46/20 là inherited, đã gửi yêu cầu refresh trước build, ownnot_exposed; reserve5%cả hai, không quotaerror hay đổi account/provider. Không network/thesis/Figma.

## Cập nhật guard runtime

APK guard b784443d37ab05143dd2d6de61676ea1a3b9866f8fcf24a98d659f84bba65d90 đã build/audit16source4assets/install PASS và pm-path/pull/snapshot matching, installed-apk-guard-final.json. Snapshot mới offline-hand-action-guard-x64.apk giữ candidate a8ed. Full71tests/analyze-final3 PASS trên nguồn cuối này.

assert-m2-guard.cjs PASS sáu ca: guard-idle-side/front, guard-jog-side-zero/front, guard-low-side/front. Bốn zero-frame tap charge0, authoredRecovery=false, giữ nguyên clip/time và65local matrices release→firstflight, maxdelta0. Hai lowcharge q0,111111 dùng current-generation authoredRecovery=true và hồi từ đúng sample; matrix thay đổi là animation dự kiến, không áp oracle freeze.

guard-jog-side lần đầu với harness hold0ms thực tế lọt qua một accepted tick: charge0,020833, authoredRecovery=true là đúng. Assertion yêu cầu zero-frame đã fail và được giữ log; không sửa dữ liệu để nhận false. Chạy lại riêng side trong guard-jog-side-zero mới đạt charge0/false. Đây là khác biệt scheduling, không bốn ca luôn luôn đi trước frame chỉ do tham số0ms. Không lặp retry vô hạn.

Lead đã xem ảnh guard-idle-side và guard-jog-front prepare, guard-jog-side-zero after, guard-low-front after. Ảnh static không thay65matrix CPU trace hoặc GPU-present proof. Nhánh zero-frame giữ base pose không có animation ném; grip đơn giản và airborne charge Idle-backed chưa đáp ứng animation phối hợp hoàn chỉnh. Mức ảnh hưởng: không sai input/physics/score nhưng độ tự nhiên hình ảnh còn hạn chế, chỉ chốt baseline nếu Cindy chấp nhận rõ phạm vi. Regression chuẩn bị5shot/2–3groundair vànegative đang chạy trong guard-regression, chưa dùng candidatea8ed thay gate mới.

## Hồi quy trên APK guard

Đã thực chạy node tool/assert-m2-runtime.cjs guard-regression 5 PASS:5release,5score3+3+3+2+2=13, đủ2/3groundair, exact latched origin/analytic firstflight(t)/prepared clock continuity;6negative ranges khôngrelease, pause/resume simtime/y freeze. Raw/ảnh/ranges trong guard-regression là lượt mới trên b784, không nhận từ candidatea8ed. Guard reentry capture riêng đang lưu để QA xác nhận0điểm/lượt1. Không đổi luật điểm/quỹ đạo để làm test qua.

Next QA readonly closure hai P2/current16source/4assets/hash71tests/65jointtrace/scheduling branch vàảnh, Lead review rồi Cindy review. Chưa claim mọi GPU frame liên tục hoặc complete jump-shoot animation. Source còn uncommitted chờ QA; ba Word ngoài phạm vi, không ép commit lỗi hoặc mở network.

Developer correction terminal đã tới conversation sau khi Lead đọc qua queue và tích hợp. Lead đối chiếu lại: generation gate, submitted-frame provenance, freeze baseclip/time,65joint boundary oracle và commentfix đều đã có. Không replay patch/build từ báo cáo muộn. Khác biệt có chủ đích với đề xuất freeze tới roundreset: bản hiện tại cũng kết thúc freeze khi đổi grounded/ready; background hủy action vẫn giữ pose. Đã nêu giới hạn này để QA/Cindy đánh giá, không nhận worker đã chạy code hoặc AVD. Worker chỉ đọc/proposal NOT RUN; các gate71tests/build/runtime guard là Lead thực chạy.
