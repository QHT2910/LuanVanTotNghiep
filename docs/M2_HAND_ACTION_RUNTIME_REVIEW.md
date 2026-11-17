# M2 hand/action — Lead runtime review, 17/11/2026

Trạng thái: candidate có build và bằng chứng AVD để QA/Cindy review; chưa nhận game hoàn chỉnh hoặc animation bóng rổ hoàn thiện. Base624fa62, M1/HUD/Fox/human APK giữ nguyên. M2 chưa commit trước QA cuối.

## Hiện thực

Scene0.24.3 nhập HumanBasketball.glb, derivative CC0 từ HumanDiagnostic gốc không đổi. Jump_Start/Loop/Land là clip có thật; pack không có basketball shoot đã xác minh. Authored_Basketball_v1 do tool/author_basketball.dart tạo bốn key arm rotations bằng CCD offline, dùng Idle0 basis và giữ idle body/rig/material. Không gán Pistol_Shoot thành bóng rổ, không import engine internal API. Generated SHA25680fdf68bcd037734e035675bb959f9e67db0e073d18a53f398c739298f025f8d.

Simulation sở hữu vị trí/yaw/jump, physics và score. Actor seek bằng accepted simulation delta, clips paused, selected weight1/others0; Scene.update(0) sau seek. Hand_r.globalTransform clone cộng palm local offset(0,.07,0), đọc sau update0. Ball ở identity practice_world, không parent dưới hand. acceptHeldWorld kiểm phase/paused/finite/distance/y; release lấy mẫu đã hiển thị được latch theo round/epoch/generation. Giải vận tốc lại từ origin tay có chủ đích; không sửa gravity/target/score để che bóng.

Clock hồi từ charge sample cuối tới2 trong0,3s, không nhảy thẳng1. Dash/cancel/reset/background/exit invalidates sample và hủy action, không reset owner joystick trên Dash. QA nguồn đã đóng hai P2: qa/m2-source-p2.md.

## Calibration và nguồn bằng chứng

calibration/, calibration2/, verified/, final-session/ và các audit trước yaw-final là các thử trung gian, không final M2 acceptance. Idle0 basis sửa tư thế tay; target+Z sửa hướng arm trong asset. Suy raw GLB toe axis trực tiếp sang imported Scene từng dẫn tới yaw0 sai: ảnh court phát hiện nhân vật quay ngược. Khôi phục visual yawOffset=pi, giữ asset +Z, kiểm directions/actor-toward-rim và away-rim cuối thấy đúng hướng. Comment đầu HumanActor còn mô tả suy luận toe cũ; metadata runtime ghi rõ AVD calibration là căn cứ. Không coi kiểm raw axis là renderer acceptance.

Nguồn cuối: *yaw-final.txt, source-apk-audit-yaw-final.json, installed-apk-final.json; runtime accepted/events.json+ranges.json và ảnh accepted/*.png; direction images hiện tại là yaw-final, log directions/yaw-final-command.txt. Tên accepted là thư mục candidate do Lead đặt, không phải verdict Cindy.

Analyze-yaw-final No issues. Full64tests ở tests-forward.txt trước constant yaw0→pi; logic/policy không đổi sau đó, không nhận64tests mới sau mọi visual edit. Build debug x64 M2_INSPECT=true có camera controls cận trước/bên/sân để kiểm, không phải UI production mới. Audit15source và4asset PASS, localKernelMatchesAPK=null vẫn chưa so. APK local/installed pm-path pull/snapshot cùng SHA256 a8ed4bed9f0957ebd05d3d1f10830eaf5dbc2a0332f0df2b4686bbe6f693ab13; snapshot demos/releases/m2-hand-action/offline-hand-action-inspect-x64.apk. Không ghi đè M1.

## Kết quả thực chạy

node tool/assert-m2-runtime.cjs accepted PASS, raw và kết quả accepted/runtime-assertions.json. Bảy release gồm hai full-charge inspection miss và năm cú score3+3+3+2+2=13, mỗi shot tối đa một score. Đủ grounded/airborne ở2 và3 điểm. Các origin displayed/hand/lastRenderBall/shot-origin bằng nhau tại CPU sample; clock before/after release bằng nhau. First flight t>0 khớp ballistic(t), không ép ball(t)=origin. Đây chưa phải GPU presented-frame continuity.

Cancel, Dash-cancel, reset-held, reset-jump, background và exit-held không có shot_release trong range tương ứng. Background pause/resume cùng simTime và playerY, pointer_cancel trước pause hợp lệ. Jump-only transition logs có Start/Loop/Land; charge trên không ưu tiên authored shot. Ảnh side prepare/hold/release/after và front hold/release cho thấy bóng nằm trước người, nâng theo tay, tách sau nhả, không mesh nổ rõ trong khung. Ảnh court jump và jump-only thể hiện độ cao/tư thế, không đủ nhận full skin binding.

Emulator20192/window918838 fresh ComputerUse vẫn x416y284W1083H515; không restart/moveoffscreen. VSCode67486 hiện project offline-practice và JoystickTouch.java, là code game/harness; không nhận launcher arguments đã mở practice_page thành công. Background tab click chưa xác minh đổi active tab, không replay.

## Giới hạn cần QA chú ý

- Tư thế tự author đơn giản, chưa có finger/palm grasp hoàn chỉnh, wrist follow-through/blending thể thao chuyên biệt; bóng theo một hand offset cố định.
- Charge khi airborne dùng authored Idle-backed body thay jump body; wrapper vẫn nhảy analytic. Chưa layered legs hoặc Dash clip riêng.
- Nhả trước authored charge frame đầu có thể đổi Idle/Jog sang authored0; clock continuity tests không chứng minh joint continuity trường hợp đó. Chưa inject mọi pointer race/pending init hoặc3pointer.
- Camera cận cố định có thể cắt đầu ở đỉnh nhảy; dùng court frame kiểm toàn thân, không gọi ảnh cắt là fullbody acceptance.
- Comment raw-axis đã nêu ở trên còn cần chỉnh editorial khi sửa nguồn tiếp, không đổi runtime behavior.
- Một AVD debug, chưa máy thật/FPS/network/fullgame; sampleCPU không GPU ACK/fullbinding/disposeGPU proof.

Lead verdict: đủ handorigin/physics/cancel/clip mapping baseline để QA độc lập review candidate; chưa mở network hoặc nhận M2 visual hoàn hảo. Next QA readonly source/hash/raw/ảnh, Lead xử lý findings rồi Cindy review. Quota Cindy refresh đã đọc qua queue primary46/weekly20, reserve5%cả hai; không reorder user-origin message sau auto-review rejection. Không sửa thesis/Figma.
