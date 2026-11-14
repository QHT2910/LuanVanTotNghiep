# Fox diagnostic — runtime Lead review, 14/11/2026

Verdict Lead ACCEPT baseline quan sát/model animation để QA độc lập; chưa human/gameplay integration. Source proposal Orca developer readonly được Lead tích hợp, API cache Scene0.24.3 đã đối chiếu. Không sửa HUD/game simulation/deps/main tutorial cũ. Cảnh dùng model imported material/skin, wrapper scale0,01, camera và PointLight cố định, floor unlit; không claim đã phân tích riêng ảnh hưởng light/material.

## Câu hỏi và kết quả thực chạy

GLB có nạp/render/skin không? APK source/asset audit PASS, installed pull hash khớp local/snapshot d6b66c04fa11334b7df6304701afe7c42c124956c6d8e2265ffe4c4fce96270f. Fox nhìn thấy trong pose0/pose50/root/reopened, material màu cam-trắng. Metadata runtime có clips/skins/joints/warnings và bundleReadMs/importFutureMs. Không biến thời gian import hoặc Flutter callback thành GPUready.

Seek/play/pause/replay: Pose0 lặp lại local matrices3joints giống nhau; Pose50 khác Pose0, clipTime0,5791666507720947 (nửa duration). Play tiến đến0,73118; hai Sample pause giữ time và matrices. Replay sample đầu0. Root transform đổi wrapper và world pose, giữ local joints. Xem runtime-assertions.json/script oracle để truy vết.

Lifecycle paused và playing: trước background/đầuresume cùng clipTime, sample resume cùngtime; paused vẫnpaused, playing tiếp tục theo ý định. Playing vòng Run qua0 trướcbackground là loop, không reset do lifecycle. Update một lần qua Scene.update/onTick, render bỏ implicit tick theo API đã đọc; không có oracle per-frame độc lập chứng minh mọi advance. Ba joint samples không chứng minh fullchannelbinding.

Back→reopen: ảnh chụp đầu ở loading là quá sớm, không dùng làm pass. Capture sau có2runIds/2first_view_tick và Fox pose0 paused hiển thị lại; ảnh reopened.png đã Lead xem. Không khẳng định dispose_GPU hoàn tất chỉ từảnh. Không thấy exception trong scan riêng nếu chưa có logscan thì không gán PASS.

## Gates và artifacts

- dart analyze lib/model_diagnostic.dart | PASS No issues | game/evidence-model-fox/analyze-final.txt.
- flutter build apk --debug --target-platform android-x64 --target lib/model_diagnostic.dart --no-pub | PASS | build-final.txt cùng thư mục.
- node tool/audit-model-apk.cjs | PASS source nhúng kernel/asset nguyênbyte/x86_64 | source-apk-audit-final.json.
- adb install/launch | PASS | install-final.txt/launch-final.txt; package com.example.scene_tutorial_r3 riêng, không thay APK game HUD.
- node tool/run-model-diagnostic.cjs | PASS sequence captured | runtime-sequence-final.txt/ranges/events/PNG.
- node tool/assert-model-runtime.cjs | PASS pose/pause/replay/root/lifecycle | assert-runtime.txt/runtime-assertions.json.
- pull installed APK/hash/snapshot | PASS | installed-apk.json. Snapshot ignored demos/releases/model-fox/fox-diagnostic-x64.apk; HUD snapshot giữ nguyên.

Initial source log dài bị Android cắt khoảng1024 ký tự; sửa emit thành chunk500 ký tự có runId/seq/index/total và parser đòi đủ chunks. Rebuild final/analyze/audit đã chạy sau sửa. Helper lúc đầu chỉ tìm text, Flutter semantics dùng content-desc nên chưa gửi input; sửa parser rồi sequence mới chạy. Các log build/source-audit không hậu tố final là trước sửa chunks, không dùng thay bản cuối. Reopen capture đầu được thay bằng ảnh ổn định sau load; đây là sửa thời điểm capture, không đổi model.

## Giới hạn và bước tiếp

Một AVD debug, không benchmark/Redmi/FPS máy thật, không fullbinding/mọi material/light/backend. Fox baseline không nhân vật bóng rổ; chưa human asset, attach/release, animation shoot hoặc gameplay model. QA existing đọc source/hash/data/ảnh rồi Cindy review trước task human. Cần host refresh quota trước task dài mới: số Cindy14/11 primary14%/weekly91%, reserve5% cảhai, resetsAt1794644148/1794897288; đây là inherited không ownread. Không mở network/thesis mới, không đổiprovider.
