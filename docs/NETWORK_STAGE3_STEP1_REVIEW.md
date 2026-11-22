# Network Stage 3, bước 1: proof điểm rời bóng — 22/11/2026

Kết quả: 32/32 fixture đạt ngưỡng đề xuất cố định 1e-4 m. Sai số Euclidean tọa độ tay lớn nhất 0 m trong dữ liệu xuất; chênh thành phần TRS cục bộ lớn nhất 5.9604644775390625e-8; bind TRS delta 0. QA Orca Worker đã tính lại độc lập sai số tay 32 ca, đối chiếu bind và frozen pose; terminal encoding closure PASS, bảng và hai oracle không đổi. Đây là proof bước 1 cho asset đã pin; tích hợp mạng end-to-end bước 2 chưa được giao.

## Môi trường thực dùng

Windows host: Get-ComputerInfo trả ProductName Windows 10 Home Single Language, build 26200; giữ nguyên output máy, không suy từ tên registry sang OS khác. Flutter 3.47.8 revision 737ba8f885; Dart 3.13.7; flutter_scene 0.24.3; vector_math 2.4.4. Collector chạy Android x64 debug trên đúng một Pixel_9a AVD, emulator-5554, Android API37/x86_64, engine log ghi Impeller OpenGLES. CPU CLI chạy trên Windows.

Base commit 4b19355d53beeb74a37c918012b25f6165f8f88a cùng ba tệp diagnostic mới. Source/cache/APK/evidence hash trong game/evidence-network-stage3-step1/manifest.json. Cache được băm riêng; tên phiên bản không tự chứng minh cache bất biến. Asset HumanBasketballLayered.glb SHA256 87d9b9a6d5a3e2bd89621972c38196aadb52638b91bff21eda685f5e488741ba, CC0 local.

## Phương pháp

hand_cpu.dart là Dart thuần, chỉ dùng dart:convert/math/typed_data và vector_math, không import Flutter/Scene. Subset gồm 67 node, 65 joint, bind TRS, parent chain, năm clip Body191channel và sáu clip Arms4channel. Chỉ Float32/LINEAR; matrix node, sparse accessor, component khác và authored scale không dương bị từ chối. Không phải parser glTF tổng quát hay thư viện production.

Giữ thứ tự đăng ký clip, weight0, thời gian paused, clamp seek, bind-relative translation/scale và SLERP shortest hemisphere epsilon0.001. Merge bodyTRS với bốn rotation tay, transition0.12s từ submitted pose. Freeze giữ toàn bộ local pose đến reset/ground-change hoặc điều kiện clear tương ứng.

Golden dùng HumanActor.load và LayeredPose thực. Sau Scene.update(0), collector đọc public position/rotation/scale và hand.globalTransform. CPU CLI replay input độc lập; không dùng golden publicTRS/hand dựng CPU pose. Hai evaluator chia sẻ mô tả fixture, không chia sẻ kết quả.

Palm local(0;0.07;0); world = wrapper feet/yaw × synthetic importer mirror diag(1,1,-1) × authored ancestorTRS × palm. Không flip Z track lần nữa, không inversebind, không bỏ pelvis bob hoặc cộng playerY hai lần. Yaw0/pi. Một đơn vị cảnh quy ước một mét cho proof, không phải hiệu chuẩn vật lý. Asset không có authored scale âm; mirror chỉ được kiểm ở synthetic boundary.

32 mẫu gồm Idle, fullcharge alpha0/0.5/1, Jump_Start/Jump_Loop phối hợp tay, cancel/recharge generation2 giữa blend, freeze khi wrapper đổi độ cao, ground-change/Jump_Land/reset ở cả hai yaw. Jog chỉ đăng ký, chưa exercise; ready=true/clear() riêng chưa có fixture. Các mẫu releaseT lấy palm từ cùng poseT trước khi tiến mẫu tiếp. Đây là origin đề xuất; chưa gọi productionrelease, chưa chứng minh snapshot/event/firstflight mạng. Foot position/tick nằm trong raw input; không dùng origin1.8 rồi dịch visual.

Hand delta0 không phải độ chính xác vật lý tuyệt đối: cùng phép toán vector_math/Float32 có thể cho tọa độ xuất giống nhau dù local quaternion chênh mức làm tròn. Mỗi ca xét riêng, không dùng trung bình hoặc nới ngưỡng. Comparator kiểm hand<=1e-4m và local component<1e-5; bind/alpha được ghi nhưng chưa assert vào exit gate. QA đã tự kiểm bind0 và alpha khớp đủ32.

## Lệnh và evidence

Trong game/offline-practice:

- flutter analyze --no-pub lib/diagnostics tool/compare-stage3-hand.dart
- flutter build apk --debug --no-pub --target-platform android-x64 --target lib/diagnostics/stage3_hand_golden.dart
- adb -s emulator-5554 install -r <collector APK đã băm>
- adb -s emulator-5554 shell am start -W -n com.example.offline_practice/.MainActivity
- adb -s emulator-5554 exec-out run-as com.example.offline_practice cat code_cache/stage3-golden.json
- dart tool/compare-stage3-hand.dart ../evidence-network-stage3-step1/golden-reviewed.json ../evidence-network-stage3-step1/comparison-reviewed.json

Trong game/evidence-network-stage3-step1: golden-reviewed.json là public bind/TRS/hand; comparison-reviewed.json chứa tọa độ hai phía, delta từng trục, khoảng cách/verdict từng ca. Gate cuối: analyze-reviewed.txt, build-reviewed.txt, compare-reviewed-clean.txt. manifest.json và apk-audit.json lưu provenance/marker kernel. capture.png chỉ là màn hình collector DONE, không phải human/SceneView render. APK lớn giữ cục bộ tại .scratch/stage3-preserve.

Negative control sửa duy nhất golden hand x ca đầu thêm0.001m, comparator báo delta0.0010000020265579224m và exit1; không dùng file này làm oracle chính. CLI cuối dùng dart <entry>, exit0 thực. dart run trước đó phát build-hook stderr làm PowerShell báo NativeCommandError dù JSON kết quả đạt; không lấy trạng thái đó làm gate cuối.

## Lỗi đã xử lý và giới hạn

Analyze/build đầu trượt do JSON casts và Vector3.fromList không tồn tại; đã sửa casts và dùng Vector3.array, gate sau đạt. Lượt await static shader resources dừng trước golden; collector numerical cuối không chờ shader readiness. Importer thực và Scene.update(0) vẫn chạy trên AVD. Marker STATIC_READY ở log thăm dò sai, đã đổi IMPORT_BEGIN trong APK cuối. Không dùng log thăm dò làm proof cuối.

Báo cáo ban đầu bị shell thay tiếng Việt thành dấu hỏi; bản này viết trực tiếp UTF-8, giữ nguyên bảng số liệu. collector-reviewed-log-original.txt giữ log đã hỏng BOM/NUL sau lần chuyển encoding trước. collector-reviewed-log-readable.txt là bản phục hồi ASCII, loại NUL/replacement và che local VM-service URL; không phải raw UTF-8 nguyên vẹn. Golden JSON và source/APK hash là oracle chính. Không chạy lại build/AVD để sửa encoding hồ sơ.

Các lỗi CWD khi lưu raw/analyze được sửa trước gate cuối; file thiếu không tính PASS. Không có kết luận GPU frame ACK, SceneView render, FPS, hiệu năng hoặc máy thật. Không replay M2suite/Stage2smoke để suy proof này.

## Bảo toàn và nghiệm thu

InstalledAPK được kéo ra trước proof; sau restore kéo lại cùng SHA256 7da23a38b33567f74c0196eb9fc008a61ce58fbbc560d1567e6782cfc54af53b. App force-stopped; build outputAPK trả về bản trước. Main/gameplay/lib/src/assets/pubspec/lock không đổi. Không sửa luận văn/protocol/server, không mở service mạng, không đổi RAM/GPU hoặc tạo AVD thứ hai.

QA Orca Worker đọc nguồn, tự tính số học/bind/frozenpose trong RAM, xem capture. Analyze/build/AVD/CLI/negativecontrol/install/restore là Lead thực thi, QA kế thừa, không phải QA chạy lại. Chưa nghiệm thu generic parser, authored negative scale, production generation authority/serverclock/releaseevent/snapshotbirthboundary/humanonline. Các nội dung đó thuộc bước2 chưa giao. Cindy review đang chờ.

## Tọa độ từng ca (m)

| Ca | Tick | Alpha Scene | Scene x,y,z | CPU x,y,z | Delta Euclidean m | Gate |
| idle-0.0 | 0 | 1 | 0.096562430, 0.862436771, -0.545413733 | 0.096562430, 0.862436771, -0.545413733 | 0 | PASS |
| idle-mid-0.0 | 1 | 1 | 0.103409037, 0.847611904, -0.573057175 | 0.103409037, 0.847611904, -0.573057175 | 0 | PASS |
| charge-alpha0-0.0 | 2 | 0 | 0.096586421, 0.862226307, -0.552016139 | 0.096586421, 0.862226307, -0.552016139 | 0 | PASS |
| charge-alphaMid-0.0 | 3 | 0.5 | 0.109170265, 1.183021307, -1.062211037 | 0.109170265, 1.183021307, -1.062211037 | 0 | PASS |
| fullcharge-releaseT-0.0 | 4 | 1 | 0.285078645, 1.749923110, -1.002243757 | 0.285078645, 1.749923110, -1.002243757 | 0 | PASS |
| air-start-0.0 | 5 | 1 | 0.325342506, 2.500913620, -0.738208652 | 0.325342506, 2.500913620, -0.738208652 | 0 | PASS |
| air-loop-releaseT-0.0 | 6 | 1 | 0.247544169, 2.537556887, -1.059850216 | 0.247544169, 2.537556887, -1.059850216 | 0 | PASS |
| cancel-alpha0-0.0 | 7 | 0 | 0.245872274, 2.487342596, -1.059600949 | 0.245872274, 2.487342596, -1.059600949 | 0 | PASS |
| cancel-mid-0.0 | 8 | 0.5 | -0.129296482, 1.955000401, -0.937835097 | -0.129296482, 1.955000401, -0.937835097 | 0 | PASS |
| recharge-generation2-alpha0-0.0 | 9 | 0 | -0.109786347, 1.968161702, -1.004465818 | -0.109786347, 1.968161702, -1.004465818 | 0 | PASS |
| recharge-generation2-mid-0.0 | 10 | 0.5 | 0.081880517, 1.959851384, -1.110942006 | 0.081880517, 1.959851384, -1.110942006 | 0 | PASS |
| recharge-generation2-end-0.0 | 11 | 1 | 0.285078645, 2.249923229, -1.002243757 | 0.285078645, 2.249923229, -1.002243757 | 0 | PASS |
| cancel-freeze-0.0 | 12 | 0 | 0.285078645, 2.149923325, -1.002243757 | 0.285078645, 2.149923325, -1.002243757 | 0 | PASS |
| frozen-moving-parent-0.0 | 13 | 0 | 0.285078645, 1.949923038, -1.002243757 | 0.285078645, 1.949923038, -1.002243757 | 0 | PASS |
| ground-change-clear-0.0 | 14 | 0.5 | -0.074053057, 0.705402851, -1.060640931 | -0.074053057, 0.705402851, -1.060640931 | 0 | PASS |
| reset-0.0 | 15 | 1 | 0.096562430, 0.862436771, -0.545413733 | 0.096562430, 0.862436771, -0.545413733 | 0 | PASS |
| idle-3.141592653589793 | 16 | 1 | 0.703437507, 0.862436771, -0.854586244 | 0.703437507, 0.862436771, -0.854586244 | 0 | PASS |
| idle-mid-3.141592653589793 | 17 | 1 | 0.696591020, 0.847611904, -0.826942801 | 0.696591020, 0.847611904, -0.826942801 | 0 | PASS |
| charge-alpha0-3.141592653589793 | 18 | 0 | 0.703413606, 0.862226307, -0.847983837 | 0.703413606, 0.862226307, -0.847983837 | 0 | PASS |
| charge-alphaMid-3.141592653589793 | 19 | 0.5 | 0.690829694, 1.183021307, -0.337788969 | 0.690829694, 1.183021307, -0.337788969 | 0 | PASS |
| fullcharge-releaseT-3.141592653589793 | 20 | 1 | 0.514921308, 1.749923110, -0.397756219 | 0.514921308, 1.749923110, -0.397756219 | 0 | PASS |
| air-start-3.141592653589793 | 21 | 1 | 0.474657506, 2.500913620, -0.661791325 | 0.474657506, 2.500913620, -0.661791325 | 0 | PASS |
| air-loop-releaseT-3.141592653589793 | 22 | 1 | 0.552455783, 2.537556887, -0.340149820 | 0.552455783, 2.537556887, -0.340149820 | 0 | PASS |
| cancel-alpha0-3.141592653589793 | 23 | 0 | 0.554127753, 2.487342596, -0.340399027 | 0.554127753, 2.487342596, -0.340399027 | 0 | PASS |
| cancel-mid-3.141592653589793 | 24 | 0.5 | 0.929296494, 1.955000401, -0.462164879 | 0.929296494, 1.955000401, -0.462164879 | 0 | PASS |
| recharge-generation2-alpha0-3.141592653589793 | 25 | 0 | 0.909786344, 1.968161702, -0.395534188 | 0.909786344, 1.968161702, -0.395534188 | 0 | PASS |
| recharge-generation2-mid-3.141592653589793 | 26 | 0.5 | 0.718119502, 1.959851384, -0.289058059 | 0.718119502, 1.959851384, -0.289058059 | 0 | PASS |
| recharge-generation2-end-3.141592653589793 | 27 | 1 | 0.514921308, 2.249923229, -0.397756219 | 0.514921308, 2.249923229, -0.397756219 | 0 | PASS |
| cancel-freeze-3.141592653589793 | 28 | 0 | 0.514921308, 2.149923325, -0.397756219 | 0.514921308, 2.149923325, -0.397756219 | 0 | PASS |
| frozen-moving-parent-3.141592653589793 | 29 | 0 | 0.514921308, 1.949923038, -0.397756219 | 0.514921308, 1.949923038, -0.397756219 | 0 | PASS |
| ground-change-clear-3.141592653589793 | 30 | 0.5 | 0.874053061, 0.705402851, -0.339358985 | 0.874053061, 0.705402851, -0.339358985 | 0 | PASS |
| reset-3.141592653589793 | 31 | 1 | 0.703437507, 0.862436771, -0.854586244 | 0.703437507, 0.862436771, -0.854586244 | 0 | PASS |
