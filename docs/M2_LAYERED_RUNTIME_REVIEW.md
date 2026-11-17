# M2 layered runtime candidate — 17/11/2026

Lead đã thực thi bản layered trên Pixel_9a, không dùng runtime b784 cũ làm bằng chứng mới. Baseline7f205ad/APKb784 giữ nguyên. Candidate source chưa commit, chờ QA độc lập và Cindy review; chưa nhận M2 hoặc fullgame hoàn thành.

## Câu hỏi Scene và kết quả

Scene0.24.3 normalize tổng weight trên một AnimationPlayer. Body191 và Arms4 được đánh giá bằng hai standalone player/proxy không geometry, không addScene. Actual skeleton không có Node-owned animation player; public TRS được merge trước một main Scene.update(0). Import thực đã nạp65joint/khôngnull/warnings[], masks/propertybindings validate trong adapter. Đây không phải thay GPU skinning hoặc dùng API nội bộ.

BodyJump_Start/Loop/Land theo analytic simulation, không bị armscharge thay bằng Idle. Ảnh held-air/front-held.png và side-held.png cho thấy tư thế nhảy, bodyJump_Loop cùng armsAuthored_Basketball_v1 trong marker. Trong regression, max body-copy CPU error1.4874622866756226e-7, max alpha0 outgoing-arm error2.3345925992401817e-7; dưới tolerance1e-6. Đây là copy/proxy invariant, không fullbinding/perframeGPU proof. Transition.12s được enable thực; alpha0 và endpoint1 đều có event. Cancel60ms→recharge20ms được chạy qua held-interrupt với generation mới, outgoing từ submitted pose, không delay physics.

## Bằng chứng giữ bóng thật

HeldInspectionTouch.java giữ pointer Ném hiện hành, dùng pointer2 freeze/camera. Không lifecyclecancel/game.setPaused. Timeout45s và finally CANCEL tránh để input mắc. Helper capture-layered-held.cjs ghi rõ frozen/phasecharging/frame/simTime/charge/bodyarms/handball/camera. Hai ảnh trước/bên của mỗi ca được chụp trong cùng frozen state trước khi thả owner.

| Evidence directory | q | Body | Arms | Kết quả |
|---|---:|---|---|---|
| held-low |.111111|Idle_Loop|Authored_Basketball_v1|Hai góc, hand==ball, time/pose giữ|
| held-full-charge |1|Idle_Loop|Authored_Basketball_v1|Hai góc, hand==ball, alpha1|
| held-air |.152778|Jump_Loop|Authored_Basketball_v1|Hai góc, chân/thân nhảy và tay giữ bóng|
| held-interrupt |.111111|Idle_Loop|Authored_Basketball_v1|Cancel/recharge, một release, transition từ submitted|

held-full cũ delay1000 chỉ q~.83 nên giữ dưới dạng calibration, không gọi đó là fullcharge. held-full-charge là capture mới delay1400. Low/air/full giữ simTime/bodyTime/armTime/hand/ball giống nhau qua hai góc; không suy từ tên ảnh prepare. Grip/ngón còn đơn giản, có xuyên nhẹ/ôm bóng chưa hoàn chỉnh, không claim motion capture hoặc animation thể thao chuyên nghiệp. Stable frozen AVD captures vẫn không phải GPU presentation ACK.

## Regression mới

regression/events.json+ranges.json có5release, score3+3+3+2+2=13; đủ ground/air của2và3điểm. Latched displayed/hand/lastRenderBall/origin/shotorigin bằng nhau; firstflight khớp analytic(t>0), score mỗi shot tối đa1. Sáu range cancel/Dash/reset-held/reset-jump/background/exit-held không release. Background giữ simTime/playerY. Không thay physics/scoring/inputmapping từ baseline.

early-idle-side/front và early-jog-side/front có bốn nhánh authoredRecoveryfalse;65local matrices tại release và firstflight có maxdelta0. Ba caq0, Jogfrontq.0138889 có alpha0 chưa có authored contribution nên freeze65mixedpose đúng policy. Không nói mọi0ms luôn chạy trước frame; scheduling được xác minh theo trace. Không có shootanimation trong nhánh này. Các snapshot không dùng một clip/time giả đại diện mixedpose.

held-stop-jump/dash/reset/cancel/background/exit thực thi từ inspection đangcharging. Mỗi ca flagFROZEN biến mất và0release. final-reentry có systemBackpaused và2lần enter tạo actor mới; ảnh capture cuối score0/lượt1, không còn inspection. Main Scene không thêm update thứhai để phục vụ ảnh.

## Provenance và gates

APKlocal/installedpm-path-pull/snapshot SHA256 đều dc2a2e8182dd9a4adc8c3236b444298da69aeb469315c7d2fe1d7bc041f13c48. Xem game/evidence-m2-layered/installed-apk-wired.json. Snapshot demos/releases/m2-layered/layered-wired-x64.apk; baseline cũ không đè. Source18/asset5 khớp source-apk-audit-wired.json; localKernelMatchesAPK=null vẫn chưa so local kernel artifact riêng. Source Dart không đổi sau build; chỉ thêm harness/oracle/docs/evidence.

- flutter analyze --no-pub | PASS Noissues | game/evidence-m2-layered/analyze-wired-final.txt
- flutter test --no-pub | PASS74 sau final debugguard edits | game/evidence-m2-layered/tests-wired-final.txt
- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=M2_INSPECT=true | PASS | game/evidence-m2-layered/build-wired.txt
- node tool/audit-apk-sources.cjs | PASS18source5assets | game/evidence-m2-layered/source-apk-audit-wired.json
- javac/d8/push HeldInspectionTouch | PASS4516bytes ban đầu, rebuilt interrupt helper | .scratch/held-touch/build.txt và build-interrupt.txt
- node tool/assert-layered-runtime.cjs | PASS mới | game/evidence-m2-layered/assert-runtime.txt và runtime-assertions.json
- Supported ComputerUse center/rotation | PASS observed413,284W1078H514 | current qemuPID21248/main1640374; oldPID/window không dùng

AVD lần mở lại QuickBoot có AndroidHome đen dù awake; một coldboot -no-snapshot-load sau explicit userapproval đã khôi phục, khôngwipe/GPUconfig. Không sửa model để che lỗi hệđiềuhành. Initialblack capture không dùng nghiệm thu; rawdevice logs có VMservice/private install path giữ .scratch. Public installed identity log đã bỏ private path.

Oracle mới ban đầu dùng nhầm arc5 không cộng footprint. Bị FAIL2!=3 cho feetdistance5.018; đọc production pointsAt/config rồi sửa expected threshold5+.22 với tolerance1e-9. Gameplay không đổi. Finalassert PASS không được dùng oldoracle sai. Một lần gửi nhóm inspection kế tiếp trước lệnh cũ kết thúc bị filelock nên ba command KHÔNG chạy; sau xác minh session hoàn tất, nhóm còn lại chạy riêng inspection-negative-rest.txt, không đồng thời inject. PowerShell NativeCommandError wrappers quanh adb progressstderr không là input failure; helper exit/ranges được xác minh riêng.

## Giới hạn và review tiếp

Actual body/arm proxy import và public TRS merge đã chạy trên một AVD; synthetic3tests trước không dùng thay bằng chứng này. Không independent everyGPUframe/full65binding, không realphoneFPS/network/fullgame. BaseIdle/Jog/Jump/landing chưa fullbodyblend; chỉ bốn armrotation có transition enter/exit/interruption. Zero-authored taps freeze mixedpose, logical release ngay. Grip/followthrough còn prototype; chưa ball spin/dribble/twohandIK. Cần QA đọc mới rawdata/ảnh và source current, Lead giải findings rồi Cindy review trước chốt M2; không mở network.
