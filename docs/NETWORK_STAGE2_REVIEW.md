# Network stage2 candidate — 18/11/2026

Base91e6622 đã Cindy ACCEPT server/transport loopback. Lead đã đọc developer proposal và nối chế độ NETWORK_STAGE2 trong cùng offline-practice. Default main vẫn OfflineApp/PracticePage M2; không đổi Scene0.24.3/deps/simulation/input/modelassets. Chưa QA/Cindy stage2 acceptance, chưa commit. Đây là một AVD Scene + nativeDartpeer/server process riêng, không Internet/haiAndroid/humanM2online/full1v1.

18/11 QA terminal PASS/noP1P2 scopedstage2, Lead reviewed và lưu qa/network-stage2.md. QA tự17hash/5assets/twoAPK, raw306/297/0mismatch/FX[1,2]/lifecycle/reentry/fault và5ảnh; installed/kernel/cleanup/gates83 làLeadkếthừa rõ. Không phát sinhsourcefix/rebuild sauQA. Cindy stagegate còn chờreview, chuẩn bịcommitreviewedchanges.

## Protocol và Scene

Transport envelope thêm recipientSession. Pure network_snapshot.dart validate toàn schema/finite/vectors/2uniqueslots/phase-owner/shotKey/eventtail32/scores/ack-range trước immutable DTO. Consumer kiểm epoch/session, tăng tick và không regressionACK/eventId/scores. Wrongcontext bỏ cả packet; malformedcurrentpacket đóng connection. Foreign/missingcontext không được apply vào Scene. ACK processed, result accepted/policy_rejected/waiting khác nhau.

Scores được gán tuyệt đối. O(1) effectWatermark thay seenSet vô hạn. Snapshot đầu đặt baseline, không replay effect quá khứ; eventgap do tail32 mất lịch sử thì suppress burst và nhận absolute scores, watermark nhảy tới latest; event mới tiếp theo emit một lần. Tests repeated/new/newepoch/gap/lateinvalidfield/immutability và writerfixture không partialcommit. Page cộng số effect đã emit vào counter FX, không cộng điểm từ event.

Stage2Client giữ sequence/heartbeat/movelease, sockettimeout5s có latecleanup, đóng khi lifecyclebackground; Connect lại là explicit, không replayinput. Page có một tickwriter set playerposition/yaw/ball từ DTO, renderfoot+.9 offset; không Practice.advance/ballistic/prediction ở client. scene_applied ghi snapshotcore và actualpublicNodeposition getters trước mainScene.update0. Tolerance1e-6 vì GPU/NodevectorFloat32, không phải GPU presentation ACK. Khi disconnected giữ lastvalidgeometry với statusdisconnected rõ, ngừng nhận input/pendingapply; không trình bày đó là liveplayer.

QA lưu ý timeout5s chỉ thời gian WebSocket.connect, chưa deadline nhận welcome/snapshot hoặc end-to-endfreshness. Chưa productionavailability/stress/backpressure; cần gate riêng trước fullmatch. Stage2 không đo one-waylatency, không reuse Stage1ACKnumbers làm device latency.

Primitive coloredboxes, canonicalreleaseplayerY+1.8. Không silently đổi human M2handorigin hoặc nhận clienthandworld. Humanonline cần deterministicserverpose/hand hoặc validatedreleasecontract riêng. Fixedsimstep chưa làm deadline3phút; không fullmatch/Block/roomUI/auth/TLS/cloud.

## Gates thực chạy

- flutter test --no-pub test/network_snapshot_test.dart | PASS5 | game/evidence-network-stage2/tests-consumer-final.txt
- flutter analyze --no-pub | PASSNoissues | analyze-prebuild.txt
- flutter test --no-pub | PASS83(78+5) | tests-prebuild.txt
- dart run tool/stage2_smoke.dart | PASS typed2socket/50matched/[3,0]/1effectmỗi peer/closeboth | smoke-adapter.txt +adapter-observations.json
- dart run --define=SMOKE_TRACE=../../evidence-network-stage2/transport-observations.json tool/stage1_smoke.dart | PASS newenvelope regression73matches | smoke-envelope.txt; không đè stage1 evidence
- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=NETWORK_STAGE2=true --dart-define=NETWORK_URL=ws://10.0.2.2:8091/room/stage1 | PASS | build.txt
- node tool/audit-network-apk.cjs | PASS4clientsources/5preservedassets/x64 | source-apk-audit.json
- install/launch/installedpm-path-pull | PASS | install.txt/launch.txt/installed-apk.json
- dart analyze tool/stage1_server.dart tool/stage2_peer.dart sau processcontrol/faultinjection helpers | PASS | analyze-process-tools.txt
- node tool/stage2-verified-run.cjs | PASS boundedactual3processroles/continuouslogs/cleanup | verified-run.txt/verified-process-output.txt
- node tool/assert-stage2-runtime.cjs | PASS | assert-runtime.txt/runtime-assertions.json

Source/client Dart không đổi sau build. Source-manifest.json có17client/server/helper/test files; APKaudit chỉ4client compiledsources, không suy servercompiledAPK. localKernelMatchesAPK=null vẫn chưa so riêngkernelartifact. NetworkAPK local/installed/snapshot hash 7da23a38b33567f74c0196eb9fc008a61ce58fbbc560d1567e6782cfc54af53b, snapshot demos/releases/network-stage2/network-stage2-x64.apk. M2dc2a snapshot hash đã verify trước build, không đè; bundle5assetsunchanged không chứng minh humanonline đãrender.

## Runtime cuối có log liên tục

OneexistingPixel_9a mở bằng supportedComputerUse, freshqemuPID2952/main67106; portrait→landscape, exactcenter413,284W1078H514 verifySATISFIED. Không2AVD/RAM/GPU/mainmanifestchange. Actual10.0.2.2→hostloopback đã kết nối; INTERNETdebugmanifest sẵn, không cần sửa cleartextpolicy.

Normal accepted trace duy nhất dùng verified-live.jsonl +verified-processes/peer-7944.jsonl/manifest. ServeractualPID17840, nativepeeractualPID14772, wrapperPIDs2928/7944, AndroidappPID4390. Controller và logger là ownedtesthelpers, không thay hai client bằng hai objects. Server/nativepeer đều dart run riêngprocess, AVD là Androidprocess riêng. 306received +297scene-applied match nativepeer cùng epoch/tick/core; maxrenderFloat32error2.3563929119063687e-7. Cảhai releases, cuối absolute[3,3], app/native effects[1,2] mỗiid một lần. DeviceMoved quan sát actualslot1position; verified/shoot-release.png thấy bóng đangbay, verified/capture.png score3:3/FX2. TraceScene là CPUsubmittedtransform, khôngeveryGPUframe/FPS.

Lifecycle dùng lifecycle-live.jsonl +peer-lifecycle-preserved.jsonl: sau nativeowner0score3, AVDowner1holdcharge rồi HOME qua shell2pointerharness. Native thấy owner1charging nhưng không owner1flying, peerdisconnected, cuối[3,0]. Resume không autoConnect/release; screenshot lifecycle/background-held.png ghi background:disconnected. AndroidBack rồi amstart có mode marker NETWORK_STAGE2_CANONICAL_1_8, epoch mới, absolute[0,0]/FX0: lifecycle-live +peer-reentry-preserved +reentry/capture.png. Không mixshotIDs/epochs làm một phiên.

Faultinjection là explicit stdin invalid-snapshot trên localservertool (không normalbroadcast), gửi ball invalidstring trong envelopethật. accepted-processes/server.jsonl ghi fault_injected; peerstatusinvalidsnapshot và invalid-packet/capture.png cùng báo invalidsnapshot. Atomicunit tests/sourceguard xác minh không partialpublish; không invent GPU proof hoặc fakepublicpacket. No malformed payload được onCommit/onLog thành DTO hợp lệ.

Cuối runtime controller/logger quit/finally, server/peeractualPIDs và wrapper đã không còn trong Get-Process, port8091 khônglistener. SDKadbdaemon và emulator vẫn được giữ; không gameservice/cloudendpoint nền. Không để auto-reconnect tự chạy khi appdisconnected.

## Exploratory errors và provenance limits

Firstconsumer2fails do fixture inferredMap<String,int>/List<double> không nhận loại mutationtest, xảy ra trước decoder; sửa fixturetype/value, productionlogic không đổi. Initialanalyze rawMap/List và missingfoundationimport đã sửa, không ignore/internalAPI. Auditcommand logpath sai chưa execute; sau sửa audit cần đọc legacyPowerShellUTF16BOM, đã supportBOM. Build không lỗi.

Processcontroller nonTTY đầu nhận stdinEOF đóng trướcAVD; không tính là runtime. Earlyprocesses-runtime/accepted là calibration. Capturehelper ENOBUFS logbuffer và semanticslabel &#10; suffix đã sửa trước inputthànhcông; không claim failedinput đã chạy. Boundedlogcat/epoch-tick ranges không dựa index khi Androidringwrap. Continuouslogger180s giải quyết mấtfirsteffecttrace. Một tên peer-reconnected.jsonl cũ bị overwrite khi helperrestart, nên không dùng nativeD2epoch cũ làm matchedoracle; đã preserve riêng lifecycle/reentry trước restart và sửa helpernewlognames gắnPID/flagswx. Finalverified run mới có log đầy đủ hai phía, không trộn calibration để bù rawthiếu. Publiclogs đã scan khôngsession/recipienttokens/VMURI; rawdebugdevice .scratch only.

## Handoff

Cần QA readonly độc lập currentcode/17hash/4clientAPKhash/raw306-297/consumerFX/lifecycle/fault/images. Sau Lead xử lý findings mới Cindy review/commit. Không tiếp humanonline/fullmatch/Internet trước gate này. Quota latest77/57 reset1794974756/1795394548; reserve5%both, không task/build dài mới trước refresh.
