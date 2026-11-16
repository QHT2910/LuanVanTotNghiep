# Human model diagnostic — 16/11/2026

Asset original được user tải: Universal Animation Library[Standard].zip, 15.904.933 bytes. Script import-human-asset.cjs kiểm cả unsafeOriginalName để từ chối traversal/absolute/backslash, chỉ lấy GLB non-RM và License/README; không chạy nội dung ZIP, không ghi đè file khácbyte. ZIPoriginal giữ ở Downloads.

GLB7.618.436bytes SHA25669591853d817488edaa8fd9bf8fc1d821eaeaf789f8627b3cd23b41c4ed67997; licenseCC0included. Mộtmesh/65joints/hai materials. Exact Idle_Loop/Jog_Fwd_Loop được rawinspect; tất cả targetnames tronghai clip duy nhất ở rawnodes. Runtime binding/skin phải kiểm riêng. README gọi non-RM disabled, chưa thay phép đo drift. Jump_Start/Loop/Land có trongrawpack nhưng chưa chọn/thử; không có clip ném bóng rổ xác nhận. Không dùng Pistol_Shoot/Spell_Simple_Shoot như ném bóng.

Probe tái dùng tutorial-r3/lib/model_diagnostic.dart: build --dart-define=HUMAN=true, mặc định khôngdefine vẫnFox. Human scale1/camera(2.5,1.8,-3.5)target(0,.9,0), cần xem ảnh trướcaccept. Chỉ mộtselectedclipweight1, clipkhácpause/weight0. Sharedfloor/light/updateonce/lifecycle nhưFox. Khônggameplay/codegame thay đổi.

Status: asset preflight/analyze PASS, build/runtime xem logs thực; không coi README này là verdictPASSmodel. Audit là sourceasset trongAPK, runtime metadata mới kiểm đúngHUMANdefine. GiữFox/HUDsnapshot, không benchmark/claimmáythật.
