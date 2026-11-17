# QA follow-up hai P2 M2 — 17/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, route Codex/gpt-6.1-sol medium, chỉ đọc. Lead đã đọc terminal và chấp nhận đóng hai P2 ở phạm vi source/contract. Đây không phải nghiệm thu M2 runtime hoặc hình ảnh.

- P2-01: ShotPoseClock lưu mẫu charge cuối, release latch mẫu đó và hồi tới2 theo accepted time. Tests q0/0,6/1 kiểm equality tại release/zero delta, bước nhỏ và kết thúc. Không trì hoãn physics. Nhả trước authored frame đầu vẫn cần kiểm hình; clock equality không chứng minh joint continuity.
- P2-02: production Dash accepted xóa pointer/action và invalidate HeldBallLatch generation, giữ joystick owner. Pointerup đòi round/epoch/generation hiện hành; startCharge không khôi phục mẫu cũ. Cancel/reset/background/exit cũng invalidate. Pure tests chưa chứng minh mọi race Scene/AVD.
- Instrumentation có sample time/round/epoch/generation/frame/acceptedDelta/camera, lastRenderBall và firstFlight elapsed. Đây là CPU submitted sample, không phải GPU presentation acknowledgment.

Worker tự hash15source và APK2479faa2…5897f7 khớp audit-p2 tại thời điểm review. Analyze/tests64/build/install P2 là bằng chứng Lead kế thừa. Các calibration asset/yaw sau review đó phải dùng audit/runtime cuối riêng. localKernelMatchesAPK=null vẫn chưa so.

Gates worker: Get-Content/rg production paths/tests/review PASS; Get-FileHash15source+APK PASS; đọc logs P2 PASS; logpath=none. Một lần đoán sai tên test đã sửa sang shot_pose_continuity_test.dart. Không worker build/test/ADB/GUI/Git mutation. Next: Lead runtime hai góc/handorigin/animation/cancel/lifecycle rồi QA cuối.
