# QA M2 final candidate — 17/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, Codex/gpt-6.1-sol medium, review chỉ đọc. Lead đã review terminal. Verdict REVISE hai P2 trước chốt visual baseline; physics/hand-origin/negative-action baseline đạt, không có P1 hoặc lỗi tính điểm được phát hiện.

## Findings cần sửa

P2-01: down/up trước authored charge frame đầu để selected còn Idle/Jog/Jump nhưng release bật authored recovery0. Tick sau hard-switch clip dù clock equality trong cùng authored clip đã được sửa trước. Cần chỉ bật recovery khi mẫu pose latched thuộc authored clip của chính charge generation hiện tại; nếu chưa thì physics release ngay/exact origin nhưng cancel visual action, giữ base pose. Không delay input/physics. Test Idle/Jog down+up trước tick và AVD short-tap hai góc/lowcharge. Đây là source path/coverage finding, không giả đã thấy giật mọi frame từ ảnh tĩnh.

P2-02: human_actor.dart comment raw toe vector còn suy imported forward+Z trái calibration. Sửa thành mô tả yawpi được kiểm bằng AVD toward/away; không đổi yaw/mapping. Metadata hiện đúng.

## Bằng chứng QA tự kiểm

15source/4asset khớp audit-yaw-final; APKlocal/snapshot cùng a8ed4bed9f0957ebd05d3d1f10830eaf5dbc2a0332f0df2b4686bbe6f693ab13. Generated GLB80fdf68b…025f8d. Installed matching là Lead pm-path/pull kế thừa; localKernelMatchesAPK=null chưa so.

Tính raw accepted/events+ranges trong memory:7release,5score3+3+3+2+2=13; đủ grounded/airborne2/3. Max displayed/hand/lastRenderBall/origin/shot-origin error0; authored clock before/after error0. Firstflight analytic(t) maxerror3,48e-16. Sáu negative ranges không release; background time/y freeze. Actor có Idle/Jog/Authored/JumpStart/Loop/Land, metadata65/null0/warnings; không nhận full GPUbinding/perframe evaluation proof.

QA tự xem15ảnh: accepted inspect-side prepare/hold/release/after, inspect-front hold/release, jump-only-air, jump-shot-release, ground-shot-prepare, move-shot-prepare, background-settled, exit-held-settled; reentry-final/capture; directions toward/away. Bóng trước/ngay tay, nâng theo tay và tách sau nhả, không mesh nổ rõ. Grip/fingers đơn giản, chưa mocap/follow-through chuyên nghiệp. Toward thấy lưng/away thấy mặt phù hợp yawpi. Court jump đủ toàn thân; không dùng cận cắt đầu. Reentry0điểm/lượt1. Ảnh tĩnh không chứng minh mọi frame/GPU ACK.

Analyze/build/install/audit yaw-final là Lead kế thừa.64tests trong tests-forward trước constant yawfix, không nhận fullsuite mới sau. Worker không chạy assertion vì ghiJSON, không build/test/ADB/GUI/Git mutation.

Gate actual: Get-Content/rg PASS source/oracle; Get-FileHash15source/4asset/APK/snapshot PASS sourceBad0/assetBad0; ConvertFrom-Json in-memory checks PASS vectors/analytic/negative/freeze; view_image15PNG PASS baseline quan sát. logpath=none. Không fullgame/realphone/FPS/network/fullbinding claim.

Lead quyết định: chấp nhận findings; dùng authored-frame/charge-generation guard nhỏ cho early release, chưa mở rộng blend/layered body trong lượt sửa. Shorttap helper đã tái hiện charge0 từ Idle/Jog ở hai góc, docs/M2_EARLY_RELEASE_REVIEW.md. Tiếp sửa/test/build/runtime bounded, giữ candidate APK và dữ liệu cũ; Cindy review sau gate mới.

## Supplement short-tap từ cùng Orca QA

QA đã đọc mới doc và bốn early-idle-side/front, early-jog-side/front events. Log chứa lịch sử trước đó, nên chọn release/clock cuối mỗi ca, không đếm thành bốn session mới độc lập. Charge0 khi clip còn Idle/Jog đã đi tới runtime; source onehot chuyển authored recovery ở tick sau. Số clock của hai clip khác nhau không đo joint continuity; CPU origin đúng không đóng P2 pose. Giữ REVISE, không phủ nhận baseline7release/13điểm trước.

Sau fix cần trace TRS/joint/hand tại biên Idle/Jog→shot và hai góc cận tay, không chỉ clock hoặc ảnh sau400ms. Physics vẫn thả tức thì từ origin latch. Gate readonly supplement: Get-Content + ConvertFrom-Json4early cases PASS xác nhận branch; joint continuity NOT PASS; logpath=none. Không xem ảnh mới/chạy GUI/ADB/build/test/ghi/Git/provider. Developer đang chuẩn bị guard proposal theo quyết định Lead mới, không mở task phụ thuộc.
