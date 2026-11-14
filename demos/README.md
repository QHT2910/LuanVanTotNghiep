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
