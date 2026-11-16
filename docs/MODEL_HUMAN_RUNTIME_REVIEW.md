# Human Idle/Jog diagnostic — 16/11/2026

Lead verdict: asset/preflight và runtime baseline đạt để QA độc lập. Chưa tích hợp game hoặc nghiệm thu fullskinbinding. Orca developer task1 readonly proposal đã được Lead review ACCEPT WITH CONDITIONS; asset do user tải, Lead inspect và tích hợp. Basef227f0a/Scene0.24.3, không dependencies/HUD/simulation change.

## Asset và source

OriginalZIP15.904.933bytes SHA256cc73fc4e495b82958207316596317a3f40b9fa38065bde1027937452da537724 giữ ởDownloads. Script import-human-asset kiểm traversal cả unsafeOriginalName/đíchproject, chọn non-RM GLB + CC0License/README, không thực thiZIP/overwriteasset khácbyte. GLB7.618.436bytes SHA25669591853d817488edaa8fd9bf8fc1d821eaeaf789f8627b3cd23b41c4ed67997. Exact selected Idle_Loop/Jog_Fwd_Loop, mộtmesh/65joints/hai materials. Jumpclips có trongpack chưathử; basketballshoot thiếu, không gán Pistol/Spellshoot thànhném.

Entrypoint tái dùng model_diagnostic.dart với HUMAN=true; defaultFox giữ lựa chọnasset/scale/camera, chưa rebuildFox bằngcode mới để nhận runtime regression. Human scale1/camera(2.5,1.8,-3.5)target(0,.9,0), ảnh đủtoànthân rõhơnFox. Clipselectedweight1, clipcũ pause/weight0; cậpnhậtScene mộtchỗ/capdt0,05/skipdelta nhưFox.

Initial preflight đếm importroot tổnghợp tênroot cùngjointroot nên từchối. Đã đối chiếu cache0.24.3 runtime_importer tạo Node.importRoot(name:root), resolverAnimationTarget ưu tiênchild khiimportrootengineassigned. Sửa count riêngdescendants, khôngloạijointroot/đổiasset/renamerig. Bảnthử dùng hasEngineAssignedName bịanalyzer internalmemberwarning, đãbỏ; finalkhôngdùnginternalAPI. Mỗi target65tên match1 sauexcludeimportwrapper, skinMannequin65/null0/warnings[]. Đây là preflight namebinding, khôngchứngminh mọi channel/GPUskin.

## Kết quả thực chạy

Pose0 lặp matrices3joints bằng nhau; JogPose50 khácPose0. Play tiến, pause2samples giữtime/matrices, Replay0; rootwrappertransform đổi, localjoints giữ. Idle↔Jog switches chỉ1weight1 và inactiveclip khôngplaying; IdlePlay tiến; switchbackJogPose50 khớp mẫu trước. Lifecyclepaused/playing giữcliptime trongbackground vàfirstresume sample; restoreintent đúng. Xem runtime-events/ranges/assertions.

Lead đã xem pose0/pose50/idle0: mannequin vàng/tím hiểnthị đủđầu/tay/chân, pose thayđổi khôngthấymeshnổ trongkhung. Chưa mọiframe/mọijoint/material/light/backend. initial.png làguardfailure cũ, ready.png làAndroidtransition, không dùng nhưfinalmodelpass. Finalảnh namedpose0/50/idle0/run-switch-back v.v. helpertrạngtháiresume-playing chụpsauPause nhưFox.

RawGLB roottranslationsampler tấtcảmẫu bằng0 choIdle76samples/Jog29samples. Pelvis cóbob/localoffset (Jog localrange~0,0359/0,000076/0,24482), không được zero pelvis đểđẹp. root-motion.json chỉlocaltranslationbounds, không everyworldtrajectory. Lần tíchhợpgame phải giữsimulationownsactorposition, khôngcộng rootmotion và phảikiểm input/ballrelease mới.

## Gate thực chạy Lead

- safe selected ZIP extraction/rawGLB/CC0 | PASS | asset-manifest.json/README.md.
- dart analyze lib/model_diagnostic.dart | PASS No issues | analyze-final.txt.
- flutter build apk --debug --target-platform android-x64 --target lib/model_diagnostic.dart --dart-define=HUMAN=true --no-pub | PASS | build-final.txt.
- node tool/audit-model-apk.cjs human | PASS | source-apk-audit-final.json.
- install | PASS | install-final.txt; launch-final cóthểlàPackageUpdateActivity nênkhôngdùngclaimcoldlaunch. Foreground/runtimeảnh xácnhậnprobe thực.
- node tool/run-model-diagnostic.cjs human | PASS sequence | runtime-sequence.txt/events/ranges/PNG.
- node tool/assert-model-runtime.cjs human | PASS | assert-runtime.txt; scriptghiJSON, QA chỉđọc.
- node tool/inspect-human-motion.cjs | PASS rootstable rawsamplers | root-motion.json.
- pm path/pull/hash | PASS local=installed=snapshot52f45d5eb20c592ff72024f416a9557861227a98728bedd22d5adc2c8b103b14 | installed-apk.json. Snapshot ignored demos/releases/model-human/human-idle-jog-x64.apk, Fox/HUDcũgiữ.

Evidence ởgame/evidence-model-human. Source cuối là bảnđãbuild saufixrootwrapper; logs không-final gồmthửđầuguardfail hoặcinternalmemberwarning, khôngnhậnPASS. Chưa reopen human riêng, noGPUready/FPS/Redmi/fullgameclaim. Quota ownhostnot_exposed; inheritedCindy16/11primary0weekly0/reset1794807609/1795394454, reserve5%cảhai. SauQA/Cindyreview mới mởgameintegration; khôngnetwork/thesis/human2.

## QA terminal

OrcaQA PASSbaselinekhôngP1, LeadACCEPTsauP2labelFoxlimits đãsửaconditionalhuman và regenerateassertJSONPASS. SourceDart/APKkhôngđổi sauQA; khôngrerunAVD. qa/model-human.md. Chưaactorintegration, bàn giaoCindyreview.
