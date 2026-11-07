# Mốc 1 — Scene trên AVD và tập offline

Ngày 07/11/2026. Ưu tiên mới là demo từng phần; không xuất lại luận văn v0.7. Cơ sở Git cc48173; sửa ngoài lượt Word v0.3 giữ nguyên và loại staging.

## Đầu ra và chạy

- App riêng: game/offline-practice, entrypoint lib/main.dart. APK debug x64: game/offline-practice/build/app/outputs/flutter-apk/app-debug.apk, không đưa binary vào Git. Chạy theo README app bằng flutter run --debug -d <avd-id> --target lib/main.dart.
- Probe hiện có: tutorial-r3 checkpoint F, MODEL_ASSET=assets/Fox.glb, CLIP_NAME=Walk. Thêm Android runner và EnableFlutterGPU; main mặc định trỏ F. Ảnh thật game/evidence-m1/probe-render.png có Scene/Fox. Log unpack glTF26nodes/1mesh/1skin/3animations; không dùng ảnh tĩnh để kết luận hoạt ảnh được kiểm theo thời gian.
- AVD duy nhất Pixel_9a x86_64 Android37/16KB, GPUauto, boot_completed=1. Flutter3.47.8/Dart3.13.7; backend thực được log là Impeller OpenGLES. Không suy GPU/hiệu năng Redmi hoặc kết nối hai Android/Internet.

## Ca đã chạy

13 test logic/config PASS, analyze PASS, build/install/launch APK PASS. Các log offline-*-final.txt trong game/evidence-m1. Không coi widget_test.dart là test tương tác widget: tệp đó kiểm cấu hình NaN.

ADB lấy bounds từ semantics, gửi down/hold/up thật; helper có giới hạn chờ event reset và báo lỗi nếu không có shot mới. Tám workflow cuối final-workflow-1…8.txt chạy trên bản APK sau cài/khởi động cuối: hai vòng background; cú3điểm; di chuyển; cú2điểm; miss thấp; miss đầy; reset-flight và ném tiếp. Events/oracle ở offline-runtime-events.json, runtime-assertions.json và runtime-assertions.txt.

| Ca | Kết quả cuối |
|---|---|
| Render ngang | Thấy sân/rổ/nhân vật/bóng hình khối; HUD góc trái không che rổ |
| Shot1 ngoài vạch | q≈0,556; cộng3 một lần, tổng3 |
| Di chuyển và shot2 trong vạch | q≈0,535; cộng2 một lần, tổng5 |
| Shot3/4 | q≈0,056 và1; không thêm điểm |
| Hai vòng xuống nền/resume | Có charge_cancel/background, paused, resumed; sau đó mô phỏng và ném tiếp được |
| Shot5 reset giữa bay | Reset sau≈0,25s mô phỏng, trước crossing1,4s; không ghi điểm, giữ tổng5 |
| Shot6 tiếp tục | Cộng2 một lần, auto-reset và ready, tổng7 |

Lead xem ảnh probe, offline-render, three-point, two-point, miss-high, reset-flight và continued; không thấy vệt bóng cũ trong các ảnh cuối sau AA-none. Ảnh initial-ghosting/initial-resume-frozen là lỗi trung gian, không đầu ra hiện hành. Đây là UI thử nghiệm, không dùng làm thiết kế Figma chính thức.

## Lỗi tìm được và sửa

- Generated counter/lint config không phù hợp app: bỏ test counter của probe, dùng analyzer config không đòi flutter_lints; không giảm kiểm lỗi mã thực. Scene/version SDK giữ nguyên.
- QA chỉ ra reset-pointer race: handler cập nhật seenRound ngay sau reset. Chưa chèn input chính xác trước một render tick trên AVD; source guard và ca reset/tiếp tục đã kiểm.
- Test biên footprint phát hiện float rounding tại tiếp xúc vạch: thêm lineTolerance1e-9, test chính biên/trong/ngoài; reset khi charge/flight được thêm test. Không nới biên gameplay hữu hình.
- HUD ban đầu che rổ: chuyển góc trái. Semantics giữ ổn định để helper lấy bounds; không dùng tọa độ màn hình cố định.
- Sau resume vòng tick từng đứng: SceneView0.24.3 dùng SingleTickerProviderStateMixin, toggle autoTick false→true tạo ticker lần hai. Giữ ticker mặc định, pause qua logic/guard và bỏ dt đầu sau resume. Hai vòng AVD cuối đã đi tiếp; không sửa cache/engine.
- Vệt cam trên nền transparent: thử AA-none rồi chạy lại; ảnh cuối sạch vệt trong phạm vi quan sát. Đây là mitigation đã thử, chưa chứng minh nguyên nhân backend. Không bật skybox hoặc đổi engine.

Flutter create đã resolve lại bốn transitive trong tutorial lock: code_assets2.1.0→1.2.1, hooks2.2.0→2.0.2, meta1.19.0→1.18.3, record_use1.1.1→0.6.0. Giữ flutter_scene0.24.3/scene0.4.1/vector_math2.4.4 và SDK; lock mới phản ánh APK đã chạy. Bằng chứng lịch sử R3/v0.7 vẫn giữ như lịch sử, không tự sửa kết quả cũ.

## Phạm vi và bàn giao

Quỹ đạo arcade giải tích, không solver/contact bảng-vành/bật nảy. Tham số gom config; camera cố định; vạch thử nghiệm và footprint chạm vạch=2. Chưa multiplayer/Dash/Block/đủ trận11điểm hoặc3phút. Đây là tập offline, không phải full game.

Biên bounds/đường chéo/dt sai và va chạm đúng chiều được kiểm bằng unit test; chưa thực hiện đa ngón đồng thời hoặc kiểm footprint tại sai số nano trên AVD. Không có benchmark hoặc nghiệm thu máy thật. Figma đã được chọn cho UI01–UI06, chưa có file/session; không chờ Figma để làm demo.

Orca Worker developer (Sol6.1/rootOLD/chỉđọc) đề xuất source và chẩn đoán; Orca Worker QA (Sol6.1/rootOLD/chỉđọc) rà source/test/log. Lead tích hợp, sửa, chạy mọi test/ADB/build và chụp bằng chứng. Không native subagent, không thay model/provider/Argon.

Log công khai được chuyển UTF-8 và che user profile/debug-service URL/IP/MAC. Log gốc giữ .scratch/m1-raw, không commit. Trước tạm ngưng đã để AVD/demo cho review; khi tiếp tục kiểm tra hiện không có emulator/qemu/dart hoặc AVD được ADB nhận, không khởi động lại; chỉ force-stop probe/demo do lượt này tạo khi chuyển bản, không đóng app người dùng. Git cuối phiên chỉ Lead thực hiện theo AGENTS.

## Rà soát sau tạm ngưng

Rà diff/candidate trước commit: PASS git diff --check; 124 tệp mới được rà bằng bộ mẫu profile/debug URL/private key/token và JSON parse, không hit. Đây là quét mẫu, không cam kết bao phủ mọi bí mật. Log .scratch/m1-precommit-audit.log và m1-resume-diff-check.log không commit. APK và raw logs thuộc build/.scratch được gitignore; Git chứa source, ảnh và evidence đã che dữ liệu nhạy cảm, không binary APK97MB.

HEAD trước chốt vẫn cc48173, chưa có commit mốc1/finish-session thành công; không replay probe/build/AVD/test. Sáu worker không chạy, queue0. QA terminal cuối đã lưu qa/milestone-1-final.md: không P1/P2 chặn trong phạm vi. Ba P2 cũ đã sửa.

APK SHA256 DA5144F2225F22432F316E38B1D4921AAA2E922DF7D270427B3B029587B562FA khớp checks.json; kernel APK khớp cache build và chứa nguyên văn source hiện tại của main.dart/practice.dart/config.dart. Chi tiết resume-source-audit.json; kiểm này chỉ đọc APK/source, không build lại. Wordv0.3 hash vẫn7062097215C87DF6F1EB429D8DCAF3CD773D3BC4F80C33D1ED80928BB8510404, các bản luận văn cũ không thay đổi. Lỗi ghost/freeze thuộc ảnh initial*, không phải bản cuối. Log launch foreground không dùng riêng làm bằng chứng cold launch.
