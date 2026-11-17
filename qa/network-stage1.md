# QA network minimal stage1 — 18/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov/session2e4ee883-bf67-44e2-bcd7-5f0463da63c5, actual terminal send_to_lead. Readonly D:/totnghiep/LuanVanTotNghiep; không server/smoke/test/build/GUI/device. Không rà lại M2.

Verdict QA: REVISE một P2 hồ sơ; server/transport đạt phạm vi đã rà, không P1. Lead review/closure bên dưới không phải worker rerun hoặc consumerdedupe implementation.

## P2-01 — claim consumer event dedupe quá mức

docs/NETWORK_STAGE1_REVIEW.md phần contract/gate, tool/stage1_client.dart và tool/stage1_smoke.dart: console chỉ kiểm epoch/tick, ghi snapshot/loại ACK đã xử lý. Chưa có consumer áp scoreEvents hoặc dedupe hiệu ứng theo (epoch,eventId). Smoke chỉ kiểm servereventId1/eventlistlength1/twosnapshots giống nhau. Raw có cùng event trong27snapshot là lặp broadcast hợp lệ, không chứng minh consumer áp một lần.

Yêu cầu sửa: server phát scores tuyệt đối và eventId; stage1 client chỉ ghi snapshot. Renderer sau gán scores tuyệt đối và dedupe hiệu ứng theo(epoch,eventId), không cộng lại repeatedscoreEvents. Gate smoke phải ghi server score-once/duplicate-sequence rejection. Gate tiếp consumer nhận event lặp/event mới/epoch mới, scores đúng snapshot và hiệu ứng một lần.

Lead đã sửa đúng các claim trong docs/NETWORK_STAGE1_REVIEW.md, lưu acceptance consumer vào pending; không đổi source/test/oracle để đóng P2 hồ sơ. Không rerun các gate cũ vì chỉ sửa tài liệu. Consumer event dedupe vẫn CHƯA triển khai/kiểm; không nhận P2 là feature đã code.

## QA tự kiểm mới

- Sáu sourcehash khớp source-manifest.json,0sai.
- 73tick chung/0coremismatch epoch/tick/ready/owner/ball/phase/shotKey/players/scores/eventId/scoreEvents; ACK/result và servermetadata riêng peer được bỏ đúng. A74snapshot/B73; cuối[3,0], một eventId duy nhất. Duplicate release seq12 tool gửi packet lại; không coi số snapshot chứa event là số lần cộng điểm.
- Raw normalcase không chứng minh attackcases. QA đọc smokeoracle thirdpeer/disconnect/newepoch/oldsession/malformedJSON/binary/oversize/gap, kiểm cả hai socket đóng. Stalepacket đồng thời oldepoch/session chưa tách nguyên nhân; coretest có session sai.
- Server không nhận clientscore/handworld/dt; canonicalorigin1.8, ownerturn/2Practice là diagnostic không final1v1/M2handrelease. Seqsession contiguous, duplicate không replay; ACK processed cả waiting/policy_rejected, không phải acceptedaction.
- Epoch/socket guard tránh callback disconnect cũ phá phòng mới. Hai slot/teardown/lease/quiet/limits có trong nguồn. Waitingpeer chỉ một snapshot; chưa waitingexpiry. Không diff main/presentation/input/simulation/pubspec/lock so a9fc676.

## Gates

Get-Content/Select-String source/docs/evidence | PASS source/oracle và đọc gate kế thừa | logpath=none

Get-FileHash6sources/manifest | PASS6/6 | logpath=none

ConvertFrom-Json rawtransport+in-memory compare | PASS73/73,0mismatch | logpath=none

git diff --numstat a9fc676 -- main/presentation/input/simulation/pubspec.yaml/pubspec.lock | PASSnochange | logpath=none

Read analyze-final/tests-final/smoke-final | PASS Noissues/+78/JSONpass kế thừa Lead, không QA chạy lại | logpath=none

## Giới hạn

Hai WebSocket loopback trong một process, console chưa separateprocess; chưa Android/Scene/Internet/haiđiệnthoại. Không auth/TLS/waitingexpiry/prereassemblymemory/backpressuresecurity; seen do client khai. Fixedsteptimer trôi walltime; ACK110076us/maxgap93938us chứa polling/broadcast/queue/drift, khôngoneway/FPS/clocktrận3phút. Không networkAVD/fullgame acceptance. Sau Lead sửa hồ sơ, Cindy quyết định gate renderer tiếp; worker không mở task khác.
