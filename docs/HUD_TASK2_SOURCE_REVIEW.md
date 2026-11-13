# HUD task2 — source integration, chưa chạy gate

12/11/2026, base318d094. Cindy đã ACCEPT UI1; task hiện hành chỉ HUD presentation, không đổi Scene background/model hoặc simulation.

Orca developer o7v9oxz0vq8wm7n5527dnta1 bàn giao readonly qua session hiện có; route thực chưa truy vấn trong lượt worker, không nhận Terra/Luna/Argon. Lead review ACCEPT proposal typed record, input slots ổn định ngoài builders, visual options null-default và ba test. Không nhận code đã chạy. Root worker cũ, Lead tự ghi đúng project.

## Đã tích hợp

- `practice_hud.dart`: panel navy điểm tập/lượt/giá trị cú ném trên giữa; charge marker theo config gần Ném; Dash status độc lập. Không opponent/clock/network giả.
- `practice_page.dart`: notifier typed PracticeHudData thay chuỗi kỹ thuật; publish dữ liệu thật; tách nguyên joystick/reset/jump/dash/shoot thành slot HUD. Giữ handlers/epoch/mapping/SceneView/navigation.
- Ba input widgets thêm màu/bo góc tùy chọn, mặc định cũ giữ. Ném cam124×88; Nhảy/Dash88×64; joystick hit152. Không đổi thuật toán sở hữu pointer, pause/cancel hoặc defaults geometry.
- `practice_hud_test.dart`: ba ca layout724×280/960×540, typed charge/target/cooldown, owner joystick không bị thay qua HUD rebuild. Pure Flutter fixture, không Scene/GPU hoặc AVD.

## Kiểm đã chạy và chưa chạy

`dart format`6file | PASS parse/format | .scratch/hud2-format.txt

`git diff --check` | PASS | .scratch/hud2-diff-check.txt

Read-only diff simulation/pubspec/lock/test UI1 | PASS không đổi | logpath=none

Get-FileHash UI1 snapshot | PASS2599f6928e7c4b2f81d761de04cbcff818a222886b3e8637a3faff5721afa9a8 | logpath=none

Analyze/3test mới/full regression/build/sourceaudit/runtime HUD | NOT RUN. Không lấy49test/UI1runtime cũ làm gate HUD mới. Chưa commit source chưa qua gate. Cần kiểm top header vs Menu/rổ, safeareas, hình thật, charge+jump/move/Dash/shot, cancel/exit/lifecycle; không claim màn hẹp dưới500dp hoặc portrait đã đạt.

## Quota và bước tiếp

Đã gọi host list_tools subscriptionAccounts/subscription và get_capabilities control/runtime, rồi accounts.settings detail: phép đọc accounts not_exposed, operations rỗng. Không tự đọc được usage mới. Cindy cung cấp đầu task primary35%used/secondary79%used/statusready; resetsAt unknown. Đây là dữ liệu kế thừa, không phải phép refresh của Lead.

Rule CONTEXT_PROTOCOL: primary>=95% dừng task/build dài, lưu file/progress/commands/evidence/next/used/resetsAt, dừng worker an toàn; sau reset đọc lại cả primary/secondary, không đổi account/provider. Không có worker đang thực hiện HUD ở thời điểm bàn giao proposal này.

Bước tiếp: Cindy/host refresh usage và resetsAt; nếu dưới95%/secondary còn đủ thì chạy analyze → test HUD → full tests theo source mới, cập nhật audit manifests11source rồi build/install/runtime trên đúng AVD hiện có. Trước build dài refresh quota tại mốc. Giữ UI1 APK/sourcecommit và mọi evidence cũ. Không replay UI1 gates hoặc thay thesis/Word. Nếu chạm95% giữ checkpoint, không ép commit code chưa đạt.
