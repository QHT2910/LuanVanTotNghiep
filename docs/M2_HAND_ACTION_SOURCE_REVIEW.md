# M2 — inventory và contract source, 16/11/2026

Task implementation+AVD chưa hoàn tất. Lead review Orca developer o7v9oxz0vq8wm7n5527dnta1 readonly, metadataSol6.1medium: ACCEPT inventory/cache/API và interface design; authored arm pose chỉcandidate cần hai góc/cận tay, chưaacceptvisual. Không gán Pistol_Shoot/Spell_Simple_Shoot thành basketball.

## Bằng chứng worker / quyết định

GLBverifiedCC0 có43clips, Jump_Start1,3333333731/Jump_Loop2,5/Jump_Land1,2666666508, mỗi195channels, roottranslation0. Exact hand_l22/hand_r46 và arm/spine/pelvis/root hierarchy được worker đọcGLBtrongmemory. OfflineTRS/SLERP Idle0handR(-.292654,.922527,-.188834), handL(.348851,.899067,.009158) sooldheldY1,8 tạo chênhlệch~.94–.97m trướcpalmoffset; không phải runtimeScene sample. Modelyawpi khôngđổinorm/Ydifference. Không thểholdtay rồireleaseoldheadpoint màkhônggiật.

Scene0.24.3 globalTransform lazyparent*local, cầnclone snapshot; seek chưaáp pose chođếnSceneupdate0. Khônginversebind handattachment; inversebind dànhskinvertices. Candidate authoredBasketball bằng publicAnimationChannel/PropertyResolver rotation timeline trênrig, khôngclaim downloadedclip. Cần rà mirroredlocalaxes/prepareholdreleaserecover/cancel/lifecycle khi nốiUI; mãauthored chưa được Leadapply/compile/visualreview.

## Implementation đã thực hiện Lead — M2a contract

practice.dart thêm acceptHeldWorld, lưuoffsettươngđốiplayer; samplefinite/y>ballradius/distance<=4m và phasepaused/flying/waiting rejection. release optional displayedOrigin, nhậnoriginhiểnthịđúngt=0, defaultnoarg giữoldtests; trajectorysolve/score/pointcache/gravity khôngđổi. newRound clearoffsettrướcreheld. Giới hạn4m là guard thửnghiệm, chưacân bằnggame; page phải vôhiệusample khioldround/epoch/background trước gọioptionalorigin. Hiện pagechưanối nênkhôngclaimhandhold/releaseAVD.

shot_pose_clock.dart là pureacceptedtimeclock cho charge/recoveryvàjumpvisualmapping; không tựphát gameplayrelease, chưa dùngtrongactor/UI. Tách khỏi Sceneimports đểunit khôngGPU. Cóvalidatefinite, analyticvelocity→JumpStartcompressed.18s/Loop mapping khôngdelayloadlogicaljump. Landingmapping vàauthoredshoot/handWorld wiring cònphải tíchhợp.

Lead dartformat | PASS | game/evidence-m2-hand-action/format-contract.txt.

Lead dart analyze | PASS No issues | analyze-contract.txt.

Lead flutter test --no-pub | PASS61 (55old+6new) | tests-contract.txt. Newtests exactorigin+ballistic0/once, ideal2vs3oncefeet, airborneheight/feet/resetoffset, invalid/pausedsample, recoverycancel/time, jumpvisualphase. Khôngheadlessfixture→Sceneclaim. Existingtests khôngsửa đểlàmPASS.

Build/install/M2runtime NOTRUN. APKinstalled vẫnM1624fa62/18dbb700…28bdda6b. Không dùng M1audit/runtime thayM2gate; sourcecurrentpracticeđãkhácAPK, phảibuild/auditmới sau nối xong. Cũ55beforeyaw+3after không58fullsuite.

## Pending đúng thứ tự

1. Nối HumanActor.hand_r worldtransform+palmoffset sau seek/Sceneupdate0; finishPose acceptheld/sampledisplayedround rồiballworldparentidentity, khôngreparentdoubletransform. Khi release latchlastdisplayedorigin, sauđórecover; khôngadvancepose tronginputcallback đểfakeorigin.
2. Authoredrotationclip đúngrig (thiếubasketballasset), Jump_Start/Loop/Land theoacceptedanalyticphase, ưu tiênupper/lowerbody rõ; source guard/binding vàpolicytests.
3. Invalid/cancel/reset/Dash/exit/background xóaheldsample/clock, khôngrelease/replay; inputoldowner/epoch giữ. Khôngmùdelayrelease.
4. Freshquota trướclệnhdài; analyze/fulltests/build/auditnewassets/source/installedhash/snapshotM2. AVDcenter418,283; VSCodegameonlyvisible; hai góc/cậntay, handworld/ballworld/time/shotId logs releasecontinuity và2/3airborne.
5. QAexisting/Lead/Cindyreview rồinexttask, khôngfullgame/network/thesis.

Quota lastCindyprimary76weekly12%reset1794807609/1795394548 inherited; ownaccountsusage chưaexposed. Không dùngsốold nhưrefreshmới, reserve5%cảhai. Chưaquotaerror trong sourcegates; chưacoistopthresholdđãchạm. Cầnhostrefresh đểchọn phầnbuild/runtime tiếp phùhợp; giữfileM2dở vàM1APKs, khôngépcommitpartial thànhM2đãxong.
