# Model/animation probe sau HUD — đề xuất 13/11/2026

Chưa tích hợp model mới hoặc chạy probe mới. HUD phải qua QA trước bước build/probe này; giữ Flutter Scene 0.24.3, không áp API master mới. Đây là ghi chú nghiên cứu ngoài manuscript.

## Tài nguyên và API đã đọc

- Fox.glb hiện có trong tutorial-r3: 162852 bytes, SHA256 d97044e701822bac5a62696459b27d7b375aada5de8574ed4362edbba94771f7. Đọc GLB JSON mới xác nhận clips Survey/Walk/Run, 1 skin,1 mesh,1 material. Giữ ATTRIBUTION/Fox-LICENSE-README: asset tổng hợp CC BY4.0, không gán toàn bộ Fox là CC0. Fox chỉ baseline diagnostic, không là cầu thủ bóng rổ.
- Candidate người: [Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html). Trang tác giả đọc13/11 ghi humanoid rig, glTF, CC0; mô tả average13k triangles, bản Standard chỉ một phần pack. Chưa tải ZIP/chọn model cuối; chưa xác nhận triangle/material/clip của file phân phối thực.
- [Universal Animation Library](https://quaternius.com/packs/universalanimationlibrary.html) trang tác giả đọc13/11 ghi GLB và CC0, các nhóm locomotion/animation. Không suy bản miễn phí chứa đủ shoot bóng rổ hoặc mọi clip quảng bá; phải kiểm file/license thực, không mua Source/Patreon.
- Đã đọc cache gói0.24.3: Node.fromGlbAsset(assetPath,{onWarning,maxTextureSize}), parsedAnimations, findAnimationByName, createAnimationClip; AnimationClip có loop/play/pause/stop/replay/playbackTime/weight. Binding theo tên node, thiếu node có thể bị bỏ qua; website nói rig compatible không chứng minh channel bind trong Scene.
- SceneView0.24.3 dùng delta từ clock rồi gọi onTick trước notify repaint. Node cập nhật animation player trong update nội bộ. Chưa truy vết toàn đường render/update để kết luận pause simulation tự freeze clip; đây là câu hỏi cần thử.

## Chọn thử và phân chia trách nhiệm

Một nhân vật người hoạt hình, một rig, ít material/texture; ưu tiên Regular male/female hoặc mannequin đơn giản từ phần miễn phí nếu file/license/rig đáp ứng. Dùng GLB có clip in-place cùng skeleton sau kiểm binding, không ghép animation khác rig bằng phỏng đoán. Clip đầu: idle/run/jump và shoot prepare–release–recover; Dash có thể reuse locomotion phù hợp, Block để sau. Clip chưa có thì ghi thiếu và thử workflow export riêng, không giả đã đủ.

Simulation vẫn sở hữu x/z/y, jump, charge và điểm. Clip chỉ trình bày, không quyết định score hoặc cộng root motion vào logic. Không gắn model/hand vào gameplay ngay: thử riêng world transform của bone và mẫu ball attach/release đúng version; xác nhận origin khớp bóng hiển thị rồi mới đề xuất thay release interface có hồi quy.

## Câu hỏi → thử → dữ liệu → nhận xét

1. GLB nạp/scale/orientation/material/skin đúng không? Probe Fox trước với frame/camera/light cố định, một clip mỗi lần; log warning, thời gian load, dimensions/clip list và ảnh. Load Future hoàn tất không mặc nhiên GPU/first frame ready.
2. Clip chuyển/loop/replay/blend và pause/resume có đúng không? Ghi playbackTime/weights/pose trước–sau; kiểm channel-target names với node thực. Không toggle autoTick như cách pause mặc định.
3. Người/ball có drift hoặc double motion không? Đặt actor transform ngoài model root, thử in-place; ghi root translations và attach/release mẫu, không fake animation ném.
4. Chi phí primitive/model khác thế nào? Cùng camera/light/render size/build/device, xen kẽ cold/warm runs. Nếu đo được, lưu load time, Flutter frame timings (UI/raster, không gọi GPU time), Android process memory. AVD debug chỉ diagnostic, không FPS điện thoại thật.

## Bàn giao probe cần có

Asset origin/URL/license bản thực/hash/clip names/rig-target map; SDK/engine/build/device; reproducible entrypoint/lệnh; log raw local và dữ liệu sạch; ảnh hoặc video nếu được phép. Giữ APK/source HUD trước khi cài probe. Không tải paywall/đổi dependency hoặc chuyển full gameplay/multiplayer trước gate. Sau probe đạt mới mở network minimal2client theo phạm vi đã bàn.
