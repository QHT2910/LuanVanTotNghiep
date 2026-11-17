# Network minimal stage1 — 18/11/2026

Basea9fc676/M2 accepted preserved. Orca developer inventory/proposal đã được Lead rà và triển khai core/transport/tools riêng trong offline-practice. Không đổi main/Page/simulation/input/assets/pubspec/lock/M2APK; chưa nối network vào game UI. Chưa chốt mạng/1v1 hoàn chỉnh hoặc Internet. QA stage1 đã rà độc lập: server/transport đạt phạm vi, một P2 hồ sơ quá claim consumerdedupe đã được Lead sửa; xem qa/network-stage1.md. Cindy stagegate còn chờ review.

## Inventory và quyết định

sync_smoke cũ trong probe-r1/tutorial-r2/r3 chỉ đồng bộ x+=dx loopback. SnapshotReplica cũ one-node writer không phải backend/phòng/sharedgame. Stage1 dùng dart:io HttpServer/WebSocket public của Dart3.13.7, không dependency/framework/cloudbill. Backend chỉ bind loopback, fixedroom /room/stage1,2slot, ephemeralepoch/session; không authentication/TLS/persistence/reconnectresume.

Stage1Room dùng hai Practice giữ hai vị trí, duy nhất ownerPractice cung cấp bóng chung. Owner charge/release, lượt đổi khi roundauto kết thúc; policy lượt là testpolicy, không phải possession/Block/vòng trận11điểm/3phút cuối. Client không gửi điểm/handorigin/dt; server release canonicalplayerY+1.8. Đây là seam có chủ đích khác offlineM2handorigin: M2 giữ nguyên, networkrenderer sau phải ghi rõ canonicalorigin, không bí mật chuyển humanhand sang điểm khác. Humanattachment trên mạng cần contract serverowned/deterministicsampler riêng.

Seq contiguous theo peer; duplicate không replay, gap/foreignsession/unknownfield/NaN/outofrange bị từ chối. ACK là processed, result có waiting/policy_rejected. Movelease.25s; quiet>1s hủy charge/Dash và dừngmove, không tựrelease. Client heartbeat100ms, move phải gia hạn. Score chỉ từ descendingcrossing Practice. Server phát scores tuyệt đối và bounded32scoreEvents/eventId; client stage1 hiện chỉ ghi snapshot, chưa áp tác dụng sự kiện. Client renderer tiếp theo phải gán scores tuyệt đối và dedupe hiệu ứng theo (epoch,eventId), không cộng lại scoreEvents lặp. Any disconnect/invalidpacket kết thúc toàn ephemeralroom, epoch mới, peer còn lại đóng. Không nhận đây là productionconnectionpolicy.

Transport50ms broadcast/3steps1/60, serverfixedsimtime có thể chậm hơn walltime khi hoststall; log serverMonoUs/maxTimerGapUs, chưa dùng làm clocktrận3phút. Msg100/1s fixedwindow/4096bytes là applicationcheck sau SDK reassemble, khôngpreallocationDoS guarantee. Seenlag120ticks giới hạn peer chậm nhưng không chứng minh boundedmemory/APIwritebuffersecurity. Localonly không publichost.

## Thử thực đã chạy

stage1_smoke khởi động HttpServer loopback ephemeral và hai WebSocket clients thật trong một processdiagnostic. Không phải hai Android/two-processrenderer. Compare73same-tick snapshots field-for-field core(epoch/tick/players/ball/scores/eventId…), ACK mỗipeer cố ý khác. Owner di chuyển, charge/release; duplicate release cùngseq gửi hai lần chỉ1scoreevent, scores[3,0], chuyểnowner1. Thirdpeer handshake bị từ chối. Leave đóng cả phòng, reconnectepochmới; oldsessionpacket, malformedJSON, binary,oversize,gapseq đều đóng hai peer.

Rawtwo-client snapshots/commandseq/clientmonotimestamps tại game/evidence-network-stage1/transport-observations.json; không ghi sessiontokens. Summary smoke-final.txt:73comparisons,1event,[3,0], ACKobservedupperbound110076us, maxservertimergap93938us. ACK quan sát chứa100mspolling/broadcast/queue, khôngonewaylatency, không trừ đồng hồserver-client hoặc suyFPSphone. Smokeđầu73comparisons/109278us/85010us cũng giữ trong smoke.txt, không coi số đo hai lần là benchmark.

Lead bổ sung waitingpeer chỉ nhận một snapshot trong trạng thái chờ, tránh stream vô hạn khi tick chưa chạy; khi roomready mới broadcast. Không có waitingconnectionexpiry/authentication, không nhận securityproduction. Sau thay đổi transport cuối đã rerun analyzeNoissues/full78PASS/smoke73comparisonsPASS và refreshsourcehashmanifest.

Gates Lead actual:

- flutter analyze --no-pub | PASSNoissues | game/evidence-network-stage1/analyze-final.txt
- flutter test --no-pub test/stage1_room_test.dart | PASS4 | tests-core-final.txt cùng thư mục
- flutter test --no-pub | PASS78(74cũ+4core) | tests-final.txt
- dart analyze tool/stage1_smoke.dart sau rawtrace edits | PASS | analyze-smoke-final.txt
- dart run tool/stage1_smoke.dart | PASS real2socket/server score-once/duplicate-sequence rejection/cleanup | smoke-final.txt +transport-observations.json
- git diff scope main/simulation/input/presentation/pubspec/lock so a9fc676 | PASSkhôngdiff | đọc console; diffcheck .scratch/network-diff-check.txt

Coretest đầu scoređạt nhưng owner chưa đổi sau2.6s; sửa boundedtest chờ actualroundend tới5s, không chỉnh simulation reset/flight. Gate banđầu fail giữ tests-core.txt. Thử format/analyze đầu dùng cwdpath sai khôngexecuteanalyze; logformatpatherror giữ .scratch/network-initial-format-path-error.txt, sau sửa absolute/cwd đúng. Chỉ task-created empty evidencefolder đã bỏ; parent game/offline-practice/game có oldevidence nên nonrecursiveRemoveItem từ chối, không xóa dữ liệu cũ. NativeCommandError quanh dart buildhooks là progressstderr, finalprocess exit0/JSONPASS đã kiểm, không che assertionfailure.

## Repro và pending

Tại game/offline-practice: dart run tool/stage1_smoke.dart. Foreground manual tools: dart run tool/stage1_server.dart (loopback8091), hai terminal dart run tool/stage1_client.dart. Client nhận move x z/stop/charge/release/cancel/jump/dash/quit. Manualserver/client tools compile/analyze nhưng chưa chạy riêng processes; actualtransport gate là smoke hai sockets trong một process. Không có service nền hoặc endpoint cloud đang để chạy sau smoke.

Sourcehash manifest source-manifest.json, không gọi là APKprovenance. M2dc2aAPK không rebuild/install. QA đã kiểm6hash/73same-tickstates/0mismatch, rawevent lặp27snapshot là broadcast hợp lệ, không phải consumer đã dedupe. Lead đóng P2 ở hồ sơ bằng sửa claim, không triển khai renderer lấn scope. Gate renderer phải thử consumer nhận cùng event nhiều lần, event mới và epoch mới: scores gán từ snapshot, hiệu ứng mỗi (epoch,eventId) chạy một lần. Sau Cindy stagegate mới tiếp oneAVDprimitive snapshotrenderer+nativeDartpeer, validate wholepacket atomic/finite/session/tick và oneScene writer. Chưa twoAndroid/Internet/roomUI/11points/3minutes/Block/finalasset-networkattachment. Không tự mở2AVD/RAM/GPUchange/thesis/Figma.
