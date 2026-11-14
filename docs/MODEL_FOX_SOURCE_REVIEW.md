# Fox diagnostic source — Lead review 14/11/2026

Orca developer o7v9oxz0vq8wm7n5527dnta1, metadata Sol6.1 medium, chỉ đọc source/package cache/GLB. Lead ACCEPT proposal kiến trúc, tích hợp entrypoint game/tutorial-r3/lib/model_diagnostic.dart. Không model/provider mới. Chưa nghiệm thu render/skin hoặc gameplay.

Lead đối chiếu API0.24.3: Scene.update đặt cờ để renderViews bỏ implicit tick; AnimationClip.pause chặn advance, seek áp pose qua update. Probe chỉ explicit update ở onTick, không advance riêng hoặc đổi autoTick. Có Play/Pause/Replay/Pose0/Pose50/Sample/root transform; lifecycle nhớ ý định play, first delta sau resume bằng0. Samples chứa cliptime và matrices actor/model/3joints; callback Flutter không tự nhận GPUready.

Biên tập khi tích hợp: bỏ GLB parser nội tuyến dành riêng Fox, chuyển metadata raw/hash sang manifest ngoài runtime; runtime vẫn ghi clips/skinnednodes/jointcount/nodenames/warnings/timing. Không claim target binding đầy đủ chỉ từ tên hoặc sample joints. Chưa có benchmark, model người hoặc clip shoot. Giữ asset/license hiện có, Fox không cầu thủ.

Gate worker thực chạy: đọc source/cache + GLB JSON/hash | PASS | logpath=none. Không chạy mã mới.

Gate Lead: dart format | PASS | game/evidence-model-fox/format.txt.

Gate Lead: flutter analyze lib/model_diagnostic.dart | PASS No issues | game/evidence-model-fox/analyze.txt. Flutter tự thêm exclude vào analysis_options.yaml, Lead đã bỏ riêng thay đổi tự sinh đó để giữ policy cũ. Chưa build/bundle/install/runtime. Lệnh format/analyze đầu sai cwd/logpath, chưa chạy analyze; log lỗi đã giữ tại evidence-model-fox/initial-path-error.txt.

Build kế tiếp: từ game/tutorial-r3, flutter build apk --debug --target-platform android-x64 --target lib/model_diagnostic.dart --no-pub. Sau build đối chiếu source/asset/APK, cài đúng applicationId hiện có, giữ HUD snapshot. Lấy ảnh Pose0/Pose50, sample paused hai lần, root transform, lifecycle playing/paused và reopen; không suy máy thật từ AVD debug. Cần host refresh quota trước build dài: Cindy14/11 primary0%, weekly89%, reserve5% cho cả hai; own account usage not_exposed.

Verdict source ACCEPT để Cindy review mốc này; chưa diagnostic runtime PASS. Bước kế tiếp build/AVD thực rồi QA readonly, không lặp52tests HUD hoặc mở network/human download.
