# QA bàn giao mốc 1

Orca Worker tester bkm37d3uiwhgp757im7y9hov, gpt-6.1-sol, chỉ đọc. Terminal report trước tạm ngưng: đạt phạm vi source/test/evidence runtime một AVD; ba P2 đã xử lý, không P1/P2 mới chặn bàn giao. Lead lưu xác nhận sau tạm ngưng, không dispatch lại.

Đã rà seenRound reset, footprint tiếp xúc ±1e-6, reset charge/flight, lineTolerance1e-9, README trạng thái; log 13 test pass. SceneView giữ ticker mặc định, hai vòng background cancel/paused/resumed rồi mô phỏng tiến/ném tiếp. AA-none là mitigation trong ảnh quan sát, không kết luận nguyên nhân backend.

Events/script/report khớp: sáu release; scores [[1,3,3],[2,2,5],[6,2,7]], không lặp shotId. Miss3 charge≈0,056 và miss4 charge1 không điểm. Shot5 reset sau≈0,25s trước crossing1,4s không điểm; shot6 cộng2/tổng7/auto-reset lượt7. eventId tăng, simTime không giảm.

Đã xem sáu ảnh probe, three-point, two-point, miss-high, reset-flight, continued. Scene/Fox, offline landscape/HUD góc trái/rổ nhìn được, tổng3/5/7; không thấy vệt cũ trong ảnh cuối đã xem. Không suy ảnh tĩnh thành kiểm toàn bộ render; UI không phải Figma.

Log terminal analyze/test/APK/install phù hợp. Launch intent về foreground riêng lẻ không chứng minh cold launch; không dựa riêng dòng đó để nhận cold launch. Ba JSON kiểm không BOM, TXT không hit bộ mẫu profile/debug URL/IPv4/MAC; không cam kết mọi loại dữ liệu nhạy cảm.

```text
Get-Content/Select-String source/test/README/logs | PASS 3P2 sửa | logpath=none
ConvertFrom-Json + oracle chỉ đọc | PASS 6release/3score/reset/cancel/resume/continue | logpath=none
view_image 6 ảnh | PASS phạm vi giao | logpath=none
Byte-prefix và quét TXT | PASS bộ mẫu/BOM đã kiểm | logpath=none
```

QA không chạy assert-runtime (có ghi output), ADB, build hoặc test. Chưa đa ngón đồng thời AVD, input race đúng trước tick, máy thật/Redmi/benchmark/Internet/multiplayer hoặc solver bảng-vành. Lead có thể chốt hồ sơ/Git, giữ các giới hạn.
