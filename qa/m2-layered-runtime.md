# QA M2 layered runtime — 18/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, session2e4ee883-bf67-44e2-bcd7-5f0463da63c5; actual send_to_lead terminal. Context Sol6.1medium theo assignment; không đổi model/provider/account. Lead đã rà terminal: chấp nhận PASS baseline có giới hạn, chưa fullgame hoặc animation thể thao hoàn thiện. Không P1/P2 chặn Cindy review trong phạm vi này.

## QA tự kiểm mới

- Hash18source/5asset current so source-apk-audit-wired.json: sourceBad0/assetBad0. APKlocal/snapshot cùng dc2a2e8182dd9a4adc8c3236b444298da69aeb469315c7d2fe1d7bc041f13c48. Installedmatching là Lead pm-path/pull kế thừa; localKernelMatchesAPK=null chưa so riêng.
- Đọc harness/oracle/source: shootowner0 giữ, pointer1 freeze/camera; timeout45s/finallyCANCEL, không lifecyclepause. Rawmarker/phasecharging xác nhận held, không dựa tên ảnh.
- Tự tính held-low/full-charge/air/interrupt: mỗi3marker frozen/charging; simTime/q/bodyTime/armTime/alpha/handworld giữ qua hai góc; hand==ball, maxcombinederror0. q=.111111/1/.152778/.111111. AirbodyJump_Loop cùng armsAuthored. held-full calibration~.83 không được gọi fullcharge.
- Interrupt range có2charge_start, pointer_cancel giữa, transitionstartalpha0 ở hủy/recharge. armStartError~4.83e-8/1.07e-7/7.49e-8/1.66e-7. Không suy60/20ms harness là exactsimulationdelay.
- Tự tính5release/5score3+3+3+2+2=13, đủ ground/air2/3; latchedhand/display/render/origin maxerror0; firstflightanalytic(t) maxerror1.67e-16; preparedclockerror0. Threshold5.22+tolerance1e-9 đúng production arcRadius+footRadius, pointsBad0. Sửa oracle cũ thiếu footprint là đúng, không đổi luật để fakePASS.
- Sáu normalnegative range0release; backgroundsimTime/playerY giữ. CPU maxBodyCopyError1.48746228667562e-7/maxArmStartError2.33459259924018e-7;18startalpha0/17endalpha1. Đây là proxycopy invariant, không independentGPU/fullbindingoracle.
- Bốn earlycases chỉ last range:65release+65firstflight matrices, maxdelta0, authoredRecoveryfalse. Idle2/Jogsideq0, Jogfrontq.0138889 nhưng alpha0 chưa có authored contribution. Không nhận mọi0ms trướcframe, không dùng singleclip/time thay mixedpose.
- Sáu held-stoprange inspectionClearedtrue/0release cho jump/Dash/reset/cancel/background/exit. final-reentry: systemBack1pause,2enter mỗi1actor_asset; ảnh cuối0điểm/lượt1. Không trộn shotIDs xuyênsession.

## Ảnh QA đã xem mới

16PNG: held-low/full-charge/air mỗi front-held+side-held(6); early-idle-sideprepare/after và early-jog-frontprepare/after(4); regressionjump-shot-release/move-shot-prepare/ground-shot-release/cancel-settled/background-settled(5); final-reentrycapture(1).

Bóng trước/ngay tay, full nâng trên đầu; heldair giữ chân/thân nhảy cùng tay canh, không còn shooting thay fullbodyIdle. Không thấy mesh nổ hoặc mirroraxis đảo toànthân rõ trong khung. Grip/ngón đơn giản/xuyên nhẹ/không twohandIK, phù hợp prototype; không nhận mocap. Frozenmarker+ảnh tốt hơn ảnh release latency nhưng không GPUACK/everyframe proof. Baseclipchange/landing chưa fullbodyblend, zeroauthoredtap không shootanimation phải công bố.

## Gates và quyền

Get-Content docs/checkpoint/tools/harness/oracle/productionpointsAt | PASS runtime-delta/threshold5+.22 | logpath=none

Get-FileHash18source/5asset/APKlocal/snapshot | PASS bad0/hashmatching | logpath=none

ConvertFrom-Json held/early/regression/stop/reentry + in-memory vector/matrix/analytic | PASS các số liệu trên | logpath=none

view_image16PNG layered | PASS khung quan sát/contact/jumpbody | logpath=none

74finaltests/analyze/build/audit/install/pm-pull/assert-layered-runtime là Lead gates kế thừa, worker không chạy lại; chỉ đọc oracle vì ghiJSON. Lượt đầu trước18/11 khôngexecute do usageapprovalfailure; sau resume cùngsession đọc thành công, không bypass/providerchange. Không write/Git/GUI/ADB/build/test/dispatch/thesis/network.

## Giới hạn và bước tiếp

PASS baseline layered một AVDdebug, submittedCPU pose/contact và gameplayregression. Chưa everyGPUframe/full65binding, grip/followthrough/baseblend hoàn thiện, physicalphone/FPS/network/fullgame. Lead bàn giao Cindy review trước task phụ thuộc; worker không tự mở task tiếp.
