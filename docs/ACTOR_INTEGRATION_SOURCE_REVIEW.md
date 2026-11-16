# Actor integration source — 16/11/2026

Lead ACCEPT kiến trúc proposal Orca developer o7v9oxz0vq8wm7n5527dnta1 readonly, Sol6.1medium; tích hợp trên69a1305. Chưa runtime/build acceptance.

HumanActor nạp asset65joints/Idle/Jog, guard sauawait trướcScenecreate; prepare khôngtạoScene/ticker lúcimport. Thayprimitivebody/head bằngwrappermodelscale1, thêmPointLight thửnghiệm40/range25/khôngshadow, giữcamera/AA/court/HUD/input/simulation. Ballkhôngboneattach, origin/release/scoring giữ. Asset/license/README copynguyênbyte, Nodeaudit chuẩn bị13sources+3assetexpectedhash; Pythonmanifest13sources chỉsource, khôngnhậnPython đãauditasset.

Manualvisualplayback: mọi clip luônpaused, selectedweight1/other0, seek theoaccepted simtime difference. Scene.update0 sau sync mộtlần mỗi onTick; repaintimplicitkhôngadvancepausedclips. Zeroaccepted/skipframe khôngresetpose, tránhflicker khiaccumulatorchưacóstep. Actorwrapperposition/yaw/jump do simulation; Jog theoactualdx/dz khi grounded+ready, DashreuseJog; boundskhôngdịch→Idle. Air/charge/flying/waiting holdIdlepose0, chưajump/shootclips. Reset không tínhteleport thànhlocomotion. Defaultyawoffset0 giảđịnhGLB+Z, cầnAVDcalibrate; khôngđổiinputmapping đểsửaảnh.

Gate Lead dartformat | PASS | game/evidence-actor-integration/format.txt.

Gate Lead dart analyze | PASS No issues | game/evidence-actor-integration/analyze.txt.

Gate Lead flutter test --no-pub | PASS55 (52cũ+3policy) | game/evidence-actor-integration/tests.txt.

Build/APKaudit/install/runtime NOTRUN. GUIđangCindycentering, LeadkhôngGUI/ADBinput. Khôngclaim yaw/material/ballvisual/animationruntime đạt. Scene API ownership khônginventNode.dispose; catchdọnScene, disposeactorpauseall/clearrefs. UnattachedimportFuture uncancellable, khôngclaimGPUcleanup hoànthành.

Next cầnhandoffGUI/emulatorvisiblecenter vàfreshquota trướcbuild; buildx64/newaudit13source+asset/installhash/snapshotriêng. Runtime di chuyển4hướng/idlejog/Dash/jump+shoot/cancel/reset/lifecycle/exit/reentry, ảnhgamefull+closeup và logacceptedtime/pose sauSceneupdate; ballrelease phảigiữoracle cũ. Cácclips thiếu chỉghiđúnglimit. SauQA/Cindyreview mớinetworkminimal, chưafullgamecomplete. Word/demos/Fox/human/HUDcũgiữ.
