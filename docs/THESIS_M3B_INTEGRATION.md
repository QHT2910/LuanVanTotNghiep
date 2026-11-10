# Tích hợp nguồn Ch3–4 sau review Cindy

Nền028d630. Cindy đã review proposal worker và accept với chỉnh biên tập; Lead đã tích hợp6patchCh3, tạo thesis/04-kiem-thu.md, cập nhật OUTLINE và tạo bản tổng hợp1–4. Bản tổng hợp1–3 cũng được đồng bộ nhưng không thay Word/PDF cũ. Ch2 và44refs giữ nguyên.

Chỉnh theo review: flutter_scene gọi là thư viện kết xuất3D; bỏ cách kể lịch sử “từng đề xuất”; ghi phác thảoUI01–06 đã duyệt nhưng chưaFigmaexport; nêu thư mục3lớp; tách tham sốDashoffline khỏi cân bằng1v1; thêm13ca vớiID/tiêu chí/kết quả/mức bằng chứng. Không có ảnh conceptAI trong manuscript.

Các chi tiết audit source/APK và thứ tự test/HUD được giữ ở hồ sơ này/claimmap, không diễn giải thành runtime mới. Bộ47test được chạy trước chỉnh xuống dòngHUD; analyze/build/install/audit cuối có sourceHUDcuối, không có lượt47test mới sau sửaHUD. localKernelMatchesAPK=null không phảiPASS. Hash APK M3b theo audit:5ea9514aaf16d060494e1f46b668c2ec4864c1f7c4e774071ba7f8172c3d0f44. Hash cài phù hợp theo installed-apk/checks/QA, không vừa tự cài/hash lại trong lượt viết.

## Claim map cho bảng ca Ch4

Mỗi ca trong manuscript dùng mức bằng chứng ghi ngay ở hàng; đường dẫn dưới đây chỉ dành hồ sơ, không chèn vào chương.

| ID | Bằng chứng tương đối project | Giới hạn |
|---|---|---|
| KT01 | game/evidence-m1/runtime-assertions.json; docs/MILESTONE_1_REVIEW.md | Cú1/2/6, tổng7; không tất cả vị trí sân |
| KT02 | docs/MILESTONE_1_REVIEW.md; qa/milestone-1-final.md | Hai mức charge trong phiên cuối |
| KT03 | game/evidence-m1/runtime-assertions.json | Resetshot5, tiếp shot6 |
| KT04 | game/evidence-m2/runtime-assertions.json; qa/milestone-2-final.md | Hai pointer; không phải3ngón |
| KT05 | game/offline-practice/test/joystick_test.dart; game/evidence-m2/tests.txt; qa/milestone-2-final.md | Logic/widget; tênlog kiểm lại khiQA, không suy runtime |
| KT06 | game/evidence-m3a/runtime-assertions.json | 6start/5land/1reset, noDoubleJump |
| KT07 | game/evidence-m3a/runtime-assertions.json; simulation/practice.dart | Hai airborneReleases; không số đo vật lý |
| KT08 | game/evidence-m3b/runtime-assertions.json; qa/milestone-3b-final.md; test/dash_test.dart | Runtime4duration, các hướng dùng logic |
| KT09 | qa/milestone-3b-final.md; game/evidence-m3b/runtime-events.json; test/dash_test.dart | Runtime2ca bắt đầu ngaybiên, raycliptừtrong/chéo unit |
| KT10 | game/evidence-m3b/runtime-assertions.json | already_dashing/cooldown/noAutoDash |
| KT11 | game/evidence-m3b/runtime-assertions.json | chargeCancelledWithoutShot |
| KT12 | qa/milestone-3b-final.md; game/evidence-m3b/runtime-events.json | background0,1s/0,8unit; thời gianpause/resume bằngnhau |
| KT13 | game/offline-practice/test/dash_test.dart; test/dash_button_test.dart; game/evidence-m3b/tests.txt; checks.json | Unit/widget; không nâng thành AVD |

Các mục `simulation/…` và `test/…` rút gọn trong bảng thuộc game/offline-practice/lib/src và game/offline-practice tương ứng. Truy vết tổng thể và nguồnM1–M3b tại THESIS_M3B_WORKER_REVIEW.md; gate/runtime kế thừa, không thử lại game.

## Công cụ và kiểm tra mới

tools/build-manuscript.cjs giữ chế độ3chương cũ, thêm --include-ch4 để tạo BAN_THAO_CHUONG_1-4.md và .scratch/word-input-v08.md riêng. tools/check-thesis-v08-source.cjs kiểm concat đúng nguồn,44refs/citation,13IDca, không lẫn đường máy/ghi chúgate, Ch2/refs không đổi. Đây là gate source, không xác nhận Word/XML/style/pagination.

Preflight đầu dừng trước mọi ghi manuscript vì anchor4.3 bắt cả tiểu mục4.3.x. Lead đã sửa thành heading chính xác, chạy lại thành công; log lỗi đầu giữ local, không giả lần đầuPASS. Không đổi assertion/game/dependency để vượtgate.

Chưa xuất Word/PDF hoặc nhận font/style đã áp vào bản mới. Format khi xuất phảiTNR13/Before6/Multiple1.3 vàheadinguser; After chưa tự chọn. Chờ QA source/claimmap/Ch2 và Cindy review taskQA trước xét v0.8. V0.8 sẽ là bản thảo chưa hoàn thiệnUI nếuFigmaexport vẫn thiếu; không nhận đủ nộp.
