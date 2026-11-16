# QA human Idle/Jog diagnostic — 16/11/2026

Orca QA bkm37d3uiwhgp757im7y9hov, metadata Sol6.1 medium, chỉ đọc. Verdict PASS baseline, không P1; P2 nhãn limits Fox trong human mode được Lead sửa sau report. Lead ACCEPT phạm vi này để Cindy review; chưa game integration/fullskinbinding.

## Kiểm mới QA

Đọc diff/source/tools/reviews: HUMAN=true dùng nonRM human/Idle_Loop/Jog_Fwd_Loop; defaultFox giữasset/scale/camera nhưng chưa rebuildFoxcode mới. Switch pause tất cả/weight0 rồi selectedseek0/weight1; updateonce/capdt/skipdelta/pausedupdate0, lifecycleintent và guards giữ. Không internalAPI trong source cuối. Preflight exclude importwrapper, khôngrename/xóa jointroot; metadata65targets mỗi clip/count1/skin65/null0/warnings[].

QA tự hash source16173d85aebc07e31e027fef0a4797ce75b67d8a9524979e3df7171aea7ce204; GLB69591853d817488edaa8fd9bf8fc1d821eaeaf789f8627b3cd23b41c4ed67997; APKlocal/snapshot52f45d5eb20c592ff72024f416a9557861227a98728bedd22d5adc2c8b103b14. Khớp audit-final; installedidentity kế thừa Lead pm-path/pull.

Tự so JSON trong memory: pose0repeat, pose50diff, pausematrices, replay0, rootlocaljoints giữ/actorchanged, switchbackJoghalf khớp mẫu trước. 26pose samples khôngvi phạm selectedweight1/otherweight0&paused; IdlePlay tiến0,745489. Hai lifecycle freeze/sampletime bằng nhau, intent restore đúng. Không chạy assert vì script ghiJSON.

Tự xem8ảnh pose0/pose50/idle0/idle-playing-paused/run-switch-back/root-shifted/resume-paused/resume-playing: toànthân vàng/tím, poseIdle/Jog khác, rootdịchxoay, không mesh nổ/kéo dài rõ trong khung. Không dùng initialguardfail/readytransition. Resume-playing chụp sauPause theohelper.

Safeimport kiểm unsafeOriginalName/traversal/destination, chỉ3selectedfiles, refuse differentbytes/flagwx, khôngexecuteZIP. QA đọc CC0/README trongproject; ZIPoriginalhash làLeadkếthừa, khôngQAđọcDownloads. Motion script đọcrawVEC3samplers, roottranslation Idle76/Jog29 bằng0; pelvisbob giữ, khôngmọiworldtrajectory. Pubspec chỉasset, khôngdependency; game/offline-practice/tutorialmain/lock khôngdiff.

## Gates và giới hạn

Get-Content/rg + git diff f227f0a | PASS phạmvi/source, P2 nhãn | logpath=none.

Get-FileHash source/GLB/APKlocal/snapshot | PASS | logpath=none.

ConvertFrom-Json + matrix/time/weights/binding comparisons | PASS | logpath=none.

view_image8PNGfinal | PASS quan sát giới hạn | logpath=none.

Analyze/build/install/audit/runtimeassert là gate Lead kế thừa. LaunchPackageUpdateActivity khôngcoldclaim. Chưa humanreopen/defaultFoxnewcode regression/fullbinding/GPUready/dispose/perframeadvance/FPSrealphone/network/basketballshoot. Jumpraw chưathử. Khôngtaskphụthuộc trướcCindyreview.

P2 correction: human limits dùng “Human mannequin Idle/Jog diagnostic; basketball shooting not verified”; Fox giữ nhãn riêng. Chỉ sửa mô tả và regenerate JSON bằng oracle cũ, không chạy lại AVD hoặc thay điều kiệnPASS.
