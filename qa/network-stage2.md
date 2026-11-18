# QA network stage2 — 18/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, session2e4ee883-bf67-44e2-bcd7-5f0463da63c5; actual terminal send_to_lead. PASS scoped primitive snapshot client + một AVD/nativepeer/server riêngprocess; không P1/P2 chặn trong phần đã rà. Lead reviewed/accepted scopedterminal để bàn giao Cindy, không fullgame/M2online/Internet.

## QA kiểm mới

- Đọc report/checkpoint, decoder/consumer/Stage2Client/Page,5tests, runtimeassert/nativepeer/serverfault/processcontroller.17/17source hash khớpmanifest;5/5localasset khớpaudit. APKlocal/snapshot SHA7da23a38b33567f74c0196eb9fc008a61ce58fbbc560d1567e6782cfc54af53b. Installedpull/kernel embedding là Lead/audit kế thừa; localKernelMatchesAPK=null chưa so riêng.
- Tự tính verified-live.jsonl +verified-processes/peer-7944.jsonl:306received/297scene_applied khớpcore native cùngepoch/tick,0mismatch. ActualNodepositions so playerfoot+.9/ball maxerror2.3563929119063687e-7, dưới1e-6. Cuối[3,3], FXapp/native[1,2] đúngmộtlần.
- Lifecycle nativeowner1charging,khôngowner1flying,cuối[3,0]. Reentryepochkhácnormal,481appsnapshots[0,0]/noFX, modeNETWORK_STAGE2_CANONICAL_1_8. Không mixepochs/shotIDs.
- Faultserverlog có1fault_injected; nguồn gửi ball['invalid',0,0] trongenvelope. Không dùng peer calibration bịoverwrite để suy normalmatch/faultpeerverdict.
- View5PNG: verified/shoot-release/capture, invalid-packet/capture, lifecycle/background-held,reentry/capture. Primitiveactors/ball/flying3:0FX1/final3:3FX2; invalidsnapshot giữhìnhcũ vớistatuslỗi; backgrounddisconnected giữhìnhcũ/charging; reentryconnected0:0FX0. Canonical1.8/chưatrận1v1 rõ. Không xem thêm ảnhJump/Dash riêng hoặc điều khiểnAVD.
- Diffsimulation/input/pubspec/lock so91e6622 khôngoutput; không suy toànworktree sạch.

## Source và oracle

Decoder validate toànpacket trướccommitcurrent/watermark; immutable records/lists táchraw. Lateinvalidevents/ball khôngDTO/partialcommit. Wrongcontext/tickcũ bỏ; ACK/eventId/scores regression reject. Scoresabsolute; boundedtail32/O1watermark, initial/gapsuppresshistory, eventmớiemitonce. P2stage1 nay có consumer thật và hành vi đượctest.

Stage2Client cósocket/seq/consumer, timeoutconnect5s+latesocketcleanup, closeidempotent cancelheartbeat/subscription/context. Pagecallbacks kiểmclientidentity/alive, bg/exitclearinput/pending, khôngautoreconnect/replay. Timeout5s chỉ WebSocket.connect, KHÔNGdeadlinewelcome/firstsnapshot/end-to-endfreshness. Ping/roomguard chưa productionavailability.

Page tick solewriterpositions/yaw/ball, khôngPractice/clientphysics. Networkcallback chỉvalidatedDTO/HUD; pendinglatest bỏqua ticktrunggian là snapshotrendering, khôngmấtđiểm vìabsolute và FXconsumeởcallback. Sceneupdate0 khôngsimulation. Lastvalidfreeze códisconnectedstatus. Nodegetterproof làCPUtrướcupdate0, khôngGPUACK.

Oracle so core vàFXriêng, bỏrecipientmetadata. Assertion>=10match chỉminimum; kếtluận306/297 dựaQAtựtính. Faultassert kiểmlog+ảnhtồntại; QA đã nhìnUIlỗi, atomicitydựa source/tests, khôngcoiảnhproofmọiframekhôngpartial.

Manifestserver17840/native14772/wrappers2928/7944 vàcontroller/raw xácminhprocessroles. QA khôngkiểmPID/portlive; cleanup/installedidentity là Leadkếthừa. Noissues/+83 đượcđọc, build/install/audit/typed50/envelope73/verified/assert là Leadgates, khôngQA chạy lại. Không exploratory làmnormaloracle.

## Gates QA

Get-Content source/docs/tests/oracles/processmanifest | PASSreadonly | logpath=none

node stdin crypto source17/APKhash | PASS17/17/twoAPKhashmatching | logpath=none

node stdin compareverified/native core/Nodevectors in RAM | PASS306/297,0mismatch,max2.3564e-7,FX[1,2] | logpath=none

node stdin audit initialUTF8read | FAIL BOMUTF16LEparser, assets chưa kiểm tại lần này | logpath=none

node stdin BOMaware audit+asset/lifecycle/reentry/fault | PASS5/5/lifecycle/reentry/fault | logpath=none

view_image5PNG | PASS staticstatus/score/primitivephạmvi | logpath=none

git diff --stat91e6622 -- simulation/input/pubspec/lock | PASSnodiffscope | logpath=none

Read analyze-prebuild/tests-prebuild | PASSNoissues/+83kếthừa | logpath=none

## Giới hạn

MộtAVD/nativepeer/serverloopback, khônghumanhandonline/twoAndroid/Internet/authTLS/full1v1/Block/clock3phút. Chưaonewaylatency/FPSphone/GPUframeACK; bundleasset khônghumanrenderproof. Purefixtureskhôngthayruntime; ảnhstatickhôngmọiframe. Chưawelcome-stall/freshnesstimeout/stress/backpressureproduction. Lead/Cindyreviewstagegate trước tasknext. Worker khôngghi/Git/GUI/ADB/build/test/dispatch/modelproviderchange.
