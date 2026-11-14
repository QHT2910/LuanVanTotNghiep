# QA Fox diagnostic — 14/11/2026

Verdict Orca QA PASS trong phạm vi diagnostic trên một AVD; không P1/P2 chặn Cindy review. Lead đọc terminal report và ACCEPT baseline, chưa nghiệm thu human/gameplay model hoặc full skin/channel binding. Worker bkm37d3uiwhgp757im7y9hov/session hiện có, metadata Sol6.1 medium; chỉ đọc, không chạy lại build/analyze/ADB/assert hoặc đổi model/provider.

## Kiểm mới bởi QA

Đọc entrypoint và ba tools audit/run/assert cùng review nguồn/runtime. Tick chỉ explicit Scene.update một chỗ, không advance clip riêng; skipDelta sau play/resume, dt hữu hạn/clamp0,05; paused update0 áp seek. Lifecycle giữ wantsPlay. Guard sau async init/import, đoạn dựng Scene đồng bộ, catch/dispose dọn Scene/observer. Không suy GPU cleanup từ lời gọi. Chunk500 theo runId/seq/index/total, parser đòi đủ trước JSONparse; text/content-desc tìm được trước input. Không dùng lỗi helper ban đầu làm sequence PASS.

Tự hash source af4c504e12d71de7aa76d26578912e59e44118c3843a34a8881d92c55610f3fe và Fox d97044e701822bac5a62696459b27d7b375aada5de8574ed4362edbba94771f7 khớp audit-final. APK local/snapshot cùng d6b66c04fa11334b7df6304701afe7c42c124956c6d8e2265ffe4c4fce96270f. Installed identity kế thừa Lead pm-path/pull, không worker kiểm thiết bị mới.

QA tự so matrices trong events: pose0repeat local3joints bằng; pose50 khác; pause2samples bằng matrices/time0,7311799999999999; replay0. Root giữ localjoints và đổi actorLocal. Hai lifecycle ranges beforebackground=beforeresume=resumesample, paused intentfalse/playing intenttrue. Loop qua0 trước background không phải reset lifecycle. Metadata Run duration1,1583333015441895/21channels, một skinnednode fox/24joints/null0/warnings[]. Reopen có2runIds/2firsttick.

QA tự xem7PNG pose0/pose50/paused/root-shifted/resume-paused/resume-playing/reopened: Fox cam-trắng, pose và roottransform phản ánh, không thấy mesh nổ/kéo dài/missingmaterial rõ trong các khung. Model nhỏ nên không đủ rà mọi joint/frame. resume-playing chụp sau Pause theo helper; không mâu thuẫn playing resume trong events. Không dùng captureloading sớm.

Giấy phép giữ đúng: modelCC0, rig/animation/conversionCCBY4, aggregate attributionCCBY4. Fox baseline, không cầu thủ; không asset download mới.

## Gates

Get-Content source/tools/review/final logs/events/metadata/license | PASS readonly | logpath=none.

Get-FileHash source/asset/APK/snapshot | PASS khớp audit | logpath=none.

ConvertFrom-Json + matrix/time/range/runId comparisons in memory | PASS | logpath=none.

view_image7PNG | PASS baseline theo giới hạn | logpath=none.

Gates Lead kế thừa: analyze Noissues, build/install/launchCOLD Statusok, audit sourceEmbedded/assetMatches/x86_64, assertion/sequence PASS. Worker chỉ đọc script assertion vì ghiJSON, không thực thi.

## Giới hạn và bước tiếp

Chưa fullbinding/mọi material-light/backend, oracle perframe doubleadvance, GPUready/disposeGPU, FPS/Redmi/network/gameplaymodel. FirstFluttercallback gpuReady=null đúng. Sau Lead review bàn giao Cindy trước quyết định human; không worker mở task phụ thuộc.
