# QA cuối M3b Dash — 10/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, Sol6.1/rootOLD chỉ đọc; Lead lưu terminal report. PASS source/test/hồ sơ clean AVD, không P1/P2 chặn commit. Không phải worker chạy lại47tests hoặc nghiệm thu máy thật/hiệu năng/Internet/fullgame.

Config speed8/duration0,2/cooldown0,8 finite; ready=start+duration+cooldown không rút khi bounds/background/reset. Grounded/state guard, hướng axis/facingcache, raybounds footprint, không steer hay walk cộng tốc. Jump/charge/release bị từ chối/noqueue. Dash hủycharge và presentation xóa shotPointer nhưng giữ joystickowner. Reset/background hủyDash/input, pause đóngbăngtimer. DashButton mộtowner/edge, giữqua cooldown khôngauto. 13tests mới,34tests cũ/pubspec/lock khôngdiff so1ac51f9; fixture không mainScene.

HUD xuốngdòngy/status, sáuảnh đọcđược/nút hiểnthị/khôngcherổ ởkhungđãxem, không mọiđộphângiải. Bảy sourcehash khớpauditfinal, embeddedkernel/x64/no staleflat; installedmetadata matchingtrue. SnapshotM3b hash5ea9514aaf16d060494e1f46b668c2ec4864c1f7c4e774071ba7f8172c3d0f44, M3a d4745966535ecf924d13f617dc357c3c4549a77d3140176158c29b3719413c14 giữ. LogsLead analyze/47tests/build/install/assert PASS; tests trước đổi newlineHUD, audit/analyze/build/install cuối gồm sourcehiệnthời.

Clean runtime:7start/end,4duration0,2s/1,6unit;2boundsx−3,78 cótravel0 vì bắtđầungaybiên, không phải runtimechứngminhrayclipchéotừphíatrong (source/unit). Backgroundend0,1s/0,8unit, paused/resumed simTime95,00833333335501/cooldown0,8999999999999204 giốngnhau; khôngautoDash vànhấnDashmớisauresumeđược. Rejectedalready_dashing/cooldown,chargecancelkhôngreleasecũ;score1shot/3điểm/tổng3,autoresetlượt2.

Java gửi2MotionEventpointertheoDOWN/POINTER_DOWN/UP hoặcCANCEL, HOME từshellharness,không thêmpermissionAPK. Globalcancel khôngđảongượcDashđãnhận,đúngpolicy. Workflowrangesphânđịnhtrace;exploratory khôngoracle. Worker chỉđọcassertion,khôngchạyscriptghifile.

Workspace đúng1foldergame→game/offline-practice;README/PROJECT_STRUCTURE/ROADMAPđúngđínhchính,hồsơngoàicâygiữ. QA multi-root cũ làlịchsử. Individualcancel/races/jumpshootblocking/resettrongDash chỉunit/widget; chưa3pointer/Redmi/benchmark/Internet/Block/multiplayer. Figmaappcó/chưaComputerUse/login/editable/PNG.

Wordv0.3hash7062097215C87DF6F1EB429D8DCAF3CD773D3BC4F80C33D1ED80928BB8510404 giữ. BảyJSONcấp hiện hành noBOM,TXT khônghitmẫuURI/IP/MAC, khôngcamkếtmọiPII.

```text
Get-Content source/tests/docs/evidence + view_image6PNG | PASS phạmvi | logpath=none
git diff/status test/pubspec/lock1ac51f9 | PASS34testcũ/depskhôngđổi | logpath=none
Get-FileHash7source/snapshots/Wordv0.3 | PASS | logpath=none
ConvertFrom-Json + tínhduration/distance/pause/score | PASS | logpath=none
ReadAllBytesJSON/rgmẫunhạycảm | PASSmẫu/noBOM | logpath=none
```

Lỗi đọc nhầm offline-runtime-events.json/rootPROJECT_STRUCTURE/ROADMAP đã sửa đúng runtime-events.json vàdocs/;khôngphảithiếusảnphẩm. LeadchốtGit/bàngiaoCindy,khôngmởBlock/mạng.
