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
