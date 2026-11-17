# Các demo được bảo toàn

10/11/2026. Source/evidence từng mốc giữ trong Git; không di chuyển hoặc sửa bằng chứng lịch sử để nhận là đã chạy với layout mới. APK là file local, không commit binary.

| Mốc | Commit | Source | Bằng chứng | APK x86_64 |
|---|---|---|---|---|
| M1 | d882fc7 | game/offline-practice | game/evidence-m1 | Missing local; rebuildable từ commit; SHA cũ DA5144F2225F22432F316E38B1D4921AAA2E922DF7D270427B3B029587B562FA |
| M2 | 112afd0 | game/offline-practice | game/evidence-m2 | Missing local; rebuildable từ commit; SHA cũ 4610a8ddf9156daa59662056bca9167d1e145e40a28bf4f64eab81b8b65a7763 |
| M3b | 6d1c120 | game/offline-practice | game/evidence-m3b | Snapshot local demos/releases/m3b/offline-practice-m3b-x64.apk; SHA 5ea9514aaf16d060494e1f46b668c2ec4864c1f7c4e774071ba7f8172c3d0f44 |
| M3a | ab9bf92 | game/offline-practice | game/evidence-m3a | Đã copy/hash verify vào demos/releases/m3a/offline-practice-m3a-x64.apk; SHA d4745966535ecf924d13f617dc357c3c4549a77d3140176158c29b3719413c14 |

APK app/build là đầu ra có thể bị build ghi đè. Snapshot M3a ở trên đã kiểm trước refactor; không khẳng định rebuild tương lai có hash byte giống APK cũ. Các ABI này không dùng làm bằng chứng Redmi ARM.

Mở source lịch sử bằng worktree riêng, không checkout đè workspace đang làm:

```powershell
git worktree add --detach ../LuanVan-demo-m1 d882fc7
git worktree add --detach ../LuanVan-demo-m2 112afd0
git worktree add --detach ../LuanVan-demo-m3a ab9bf92
```

Các lệnh chỉ là hướng dẫn, chưa tạo worktree trong lượt này; chọn vị trí được cấp quyền ghi. Đọc README tại commit tương ứng, dùng SDK/dependency đã ghi ở đó. Có thể xem một file mà không checkout bằng `git show ab9bf92:game/offline-practice/lib/main.dart`.

Probe/tutorial giữ nguyên: game/probe-r1, game/tutorial-r2, game/tutorial-r3 và các game/evidence-r1,r2,r3,v07. Không xóa build/source hàng loạt. UI tạm của demo không phải nguồn thiết kế Figma.

## M3b snapshot local

Source/evidence M3b đã QA đạt và commit/push 6d1c120; có thể đối chiếu bằng `git log --all --grep="Hoàn thành Dash M3b" --format=%H -1` (lệnh đọc, không tạo worktree). Commit được xác nhận từ Git sau khi chốt. APK x86_64 đã copy/hashverify demos/releases/m3b/offline-practice-m3b-x64.apk, SHA2565ea9514aaf16d060494e1f46b668c2ec4864c1f7c4e774071ba7f8172c3d0f44. Binary bịignore;  M3asnapshotgiữnguyên. Workspacehiệnhànhchỉapp, releasesngoàicâyFlutter.

## UI offline task1 — snapshot đã QA
APK local demos/releases/ui-offline-1/offline-practice-ui1-x64.apk x86_64 SHA2562599f6928e7c4b2f81d761de04cbcff818a222886b3e8637a3faff5721afa9a8; source mốc UI offline task1 sau1ad37e9 đã QA PASS; tra commit bằng git log --grep="Menu offline". Evidence game/evidence-ui-offline-1; report docs/UI_OFFLINE_1_REVIEW.md. Prebuild M3b copy demos/releases/pre-ui-offline-1/app-debug.apk hash5ea9514a…d0f44 đã verify; binaries ignored. Không nhận HUD Figma/gameplay gate đã xong.

## HUD task2 — snapshot cuối chờ QA, 13/11/2026

Local ignored `demos/releases/ui-offline-2/offline-practice-ui2-calibrated-x64.apk`, SHA256 `db9a6b7d56e05fb360fb29b8ab2fcfe9c26568c2cacea375131499489af203db`, hash bản cài khớp. UI1/M3b và candidate UI2 trước vẫn giữ nguyên. Source/evidence hiện chờ QA: docs/HUD_TASK2_REVIEW.md và game/evidence-ui-offline-2/verified. Đây là HUD offline; Scene/model chưa thay theo Figma.

## Fox model diagnostic14/11

Local ignored demos/releases/model-fox/fox-diagnostic-x64.apk SHA256d6b66c04fa11334b7df6304701afe7c42c124956c6d8e2265ffe4c4fce96270f; package com.example.scene_tutorial_r3 riêng, giữHUD APK. Entrypoint tutorial-r3/lib/model_diagnostic.dart, Scene0.24.3, Foxlicense giữ. Repro build --target lib/model_diagnostic.dart --debug --target-platform android-x64 --no-pub. QA baseline qa/model-fox.md; chưamodelngười/gameplay.

## Human Idle/Jog diagnostic16/11

Local ignored demos/releases/model-human/human-idle-jog-x64.apk SHA25652f45d5eb20c592ff72024f416a9557861227a98728bedd22d5adc2c8b103b14, installedhashmatch. Scene0.24.3/tutorial-r3 entrypointmodel_diagnostic.dart --dart-define=HUMAN=true; CC0QuaterniusStandardselectednonRMGLB. QA baseline qa/model-human.md, chưagameactor/basketballshoot. Fox/HUDold giữ.

## Offline human actor16/11

Snapshotignored demos/releases/actor-integration/offline-human-actor-x64.apk SHA25618dbb700a5f96ef8039d24d65a63e7f13507ace638ccda498242dbc328bdda6b. Installedhashmatch; oldHUD/Fox/humanprobe giữ. Offline IdleJogactor+gameplayregression1AVD đãQA, qa/actor-integration.md. Chưahandattach/shootjumpDashclip riêng/network/fullgame. Buildoffline-practice lib/main.dart debugandroidx64 nhưREADMEapp, currentassetsCC0/licensegiữ.

## M2 hand/action candidate17/11

Snapshot local được bảo toàn tại `demos/releases/m2-hand-action/offline-hand-action-inspect-x64.apk`, SHA256 `a8ed4bed9f0957ebd05d3d1f10830eaf5dbc2a0332f0df2b4686bbe6f693ab13`. Hash APK build/bản cài/snapshot khớp theo `game/evidence-m2-hand-action/installed-apk-final.json`. Đây là debug x86_64 trên một Pixel_9a AVD, chưa phải APK ARM cho Redmi. Không ghi đè M1.

Mở app → Tập luyện. Joystick di chuyển; giữ/thả Ném, Nhảy và Dash là các điều khiển riêng. Nút Lượt mới đặt lại lượt, Menu kết thúc phiên; vào lại có điểm0/lượt1. Bản kiểm tra này có Cận trước/Cận bên/Góc sân để xem tay và animation; camera cận cố định nên có thể cắt đầu khi nhảy. Chọn Góc sân để xem toàn thân. Tạo/Vào phòng và âm thanh vẫn chưa khả dụng.

Rebuild từ `game/offline-practice` với SDK/dependencies hiện hành:

```powershell
flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=M2_INSPECT=true
node tool/audit-apk-sources.cjs
```

Build không có `M2_INSPECT` sẽ ẩn các nút camera; chưa được dùng làm bằng chứng runtime của candidate này. Rebuild có thể không cho hash byte giống snapshot. Source chưa commit trong lúc chờ QA; đọc `docs/M2_HAND_ACTION_RUNTIME_REVIEW.md` và checkpoint để biết trạng thái mới nhất.

Bằng chứng cuối: `game/evidence-m2-hand-action/accepted/`, audit/logs `*yaw-final`, ảnh directions và `reentry-final/capture.png`. Các thư mục calibration/calibration2/verified/final-session là thử trung gian. Hand origin và gameplay oracle đạt trong phạm vi đã ghi; animation tự author còn đơn giản, chưa layered jump/shoot hoặc full game1v1. QA runtime/Cindy chưa chốt candidate tại thời điểm ghi hướng dẫn này.

### M2 guard follow-up

Snapshot mới `demos/releases/m2-hand-action/offline-hand-action-guard-x64.apk`, SHA256 `b784443d37ab05143dd2d6de61676ea1a3b9866f8fcf24a98d659f84bba65d90`; build/bản cài/snapshot matching theo installed-apk-guard-final.json. Candidate a8ed vẫn giữ nguyên. Cùng cách chạy/build và camera debug như trên.

Nhả trước frame canh ném đầu: thả bóng ngay từ tay đang thấy, giữ pose cơ sở thay vì nhảy sang Authored0/Idle0; nhánh cực ngắn này chưa có animation ném. Các cú canh đã hiển thị pose ném dùng hồi ném bình thường. Full71tests/analyze/build/audit16source4assets PASS. Trace bốn zero-frame Idle/Jog hai góc giữ65local joint matrices; lowcharge bình thường; regression5score tổng13/2–3groundair/cancel/lifecycle PASS. Báo cáo docs/M2_GUARD_SOURCE_REVIEW.md và evidence guard-*; chờ QA/Cindy closure, chưa fullgame hoặc animation phối hợp hoàn chỉnh.
