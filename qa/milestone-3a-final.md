# QA cuối M3a: nhảy

09/11/2026. Orca Worker tester bkm37d3uiwhgp757im7y9hov, Sol6.1, root OLD chỉ đọc; Lead lưu bản bàn giao terminal. PASS source/test/bằng chứng một AVD, không P1/P2 chặn. QA không chạy lại test/build/ADB hoặc điều khiển editor/AVD.

## Source và test

Jump latch airborne ngay trước bước mô phỏng, từ chối double-jump và không queue. Landing giải tích đưa y/vận tốc đứng về0, event một lần. Nút một owner, giữ qua landing không tự nhảy; reset/disable xóa owner; late up/cancel sau dispose có mounted/owner guard. Test phát hiện lỗi ban đầu vẫn giữ.

Main kiểm epoch/resumed/round. Reset hạ người/hủy shot và charge/giữ điểm; pause giữ tiến trình nhảy, hủy charge/hướng. Release lấy ball bất biến gần nhất được sync; chân chiếu y0/cache2v3. Giải lại vận tốc từ origin cao, không cộng vận tốc nhảy, README ghi mô hình arcade. Config kiểm finite giá trị suy ra, phóng lên/nhánh xuống/horizon; có test origin trên vành.

Diff112afd0 không đổi joystick,22test cũ/pubspec/lock đã kiểm. Harness thêm lead-in tùy chọn, mặc định300ms giữ M2. Analyze cuối không lỗi,34test pass, build/install thành công. Log launch intent chuyển tới activity đang chạy không tự chứng minh cold launch mới.

## Runtime và ảnh

| Oracle | Kết quả |
|---|---|
| Jump | 6 start,5 land+1 reset, mỗi jump đúng một kết thúc |
| Double-jump | Từ chối airborne |
| Landing | Exact landingSimTime khớp dự kiến trong dung sai |
| Airborne release | y≈0,906904/0,884193, origin cộng1,8,feetY0 |
| Score | [[1,3,3],[2,2,5]], không lặp |
| Pause/resume | y≈1,126304 vàsimTime≈65,675 giống nhau; sau resume land, không tựshot |
| Reset | Hủy jump về grounded, giữ tổng3 |

QA xem8ảnh move-jump-air,jump-shot-release/land,inside-shot-release/land,reset-grounded,background-air/land. Người có độ cao/đĩa chân trên sân; landing/reset grounded, HUD đọc được khôngche rổ, tổngcuối5. Hai ca hai pointer riêng joystick+jump và jump+shoot, không ba ngón đồng thời; ảnh tĩnh không chứng minh mọi frame.

Năm source hash khớp audit, source nhúngkernel và APK cài khớp d4745966535ecf924d13f617dc357c3c4549a77d3140176158c29b3719413c14. Không coi localKernelMatchesAPK=null là PASS. BốnJSON khôngBOM, TXT khônghit mẫu profile/debugURL/IPv4/MAC, không bảo đảm mọiPII. Hồ sơ phân biệt lỗi trung gian/kết quảcuối, unit/widget/runtime, AVD/máythật.

```text
Get-Content source/tests/helpers/final logs | PASS phạm vi đọc | logpath=none
git diff 112afd0 -- joystick/tests cũ/pubspec/lock | PASS các đường dẫn kiểm không đổi | logpath=none
ConvertFrom-Json + đối chiếu oracle | PASS jump/land/reset/release/score/pause | logpath=none
Get-FileHash năm source so audit | PASS | logpath=none
view_image tám ảnh | PASS quan sát phạm vi giao | logpath=none
Quét BOM/mẫu nhạy cảm TXT | PASS mẫu kiểm | logpath=none
```

QA không thực thi assertion có ghi output. Chưa ba ngón/máy thật/benchmark/Internet/fullgame/Figma/solver. Lead rà diff/chốt Git, giữ Wordv0.3 ngoài lượt, bàn giao Cindy trước Dash.
