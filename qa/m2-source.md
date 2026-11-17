# QA M2 source/asset trung gian — 17/11/2026

Orca tester bkm37d3uiwhgp757im7y9hov, contextSol6.1medium, readonly. Chưa chốtM2/runtime/installedpull/snapshot. Sourcebuild đủtiếpcalibration nhưng2P2; Lead đãđọc vàchấpnhận findings, sửa source như ghi cuối, chưaQAworkerre-reviewfix.

P2-01: recoverytime nhảy từchargeq sang1, testcũassert1 chưacontinuity; cầnlatchlastvisualsample, nội suyacceptedtime màkhôngdelaylogicalrelease. P2-02: Dashaccepted xóashotPointer/actionclock nhưngkhôngdisplayedHeld, cầninvalidate samplegeneration/epoch riêng khôngresetjoystickowner, testnewchargebeforefreshsample khôngreleaseoldorigin.

QA đọcsource xácnhận seek→Sceneupdate0→finishPose→handglobalclone+offset→simulationheldworld→identityparentball→originlatched làthứtựđúng; finite/phase/round/reset/pointcacheauthority giữ. Authoredonairreplacebody làlimitchưalayered. Asyncguards vàallpaused/manualacceptedtime giữ. ChưaảnhM2/visualacceptance.

QA tựhash14source/4asset/APK45a4672583c992e29c4c173f080ebccf572d5ef715da3f4085aa04bd283aeed8 khớpaudittrướcP2fix. GeneratedGLBee7ff76af795af92c0a133f4e5b61820b5c1ff44f8eeac1aa66fccd2705f5f71; original69591853…ed67997 giữCC0. GLBmemoryinspect authoredclipduynhất195channels/bốnarmkeys0/1/1,15/2/quaternionnormerror~1,20e-7/bufferviewbounds/skinmeshmaterial giữ. JSONnumericnotation đổi khôngrigchange. CCDextensiontarget1,98 nhưngkếtquảtay~1,891, khôngclaimtargetexact hoặcScenerender từofflinepositions.

QA yêu cầu instrumentation: sampleepoch/time/round/frame/acceptedDelta/camera, last-renderballworld, firstflight elapsedđểsoanalytic(t), khôngépfirstflight==origin nếut>0. Runtimehai góc/cận tay/body/clipphases, 2/3groundair/once/cancelDashreset/lifecycleexit/reentry; installedidentity/snapshot saufinalcalibration. KhôngM1runtime thayM2.

Gatesworker: Get-Content/rg source/docs/tools/evidence | PASSreadonlyreview2P2 | logpath=none; Get-FileHash14source/4asset/APK | PASSpre-fix | logpath=none; GLBJSON/Float32memoryinspect | PASSassetbounds/norm, khôngrender | logpath=none. Analyze61tests/build/install kếthừaLead, khôngworkerchạy.

## Lead sửa sau report

ShotPoseClock latch_lastSample, release bắtđầutừsampleđó tiếnđếnkey2 bằngacceptedtime; testq0/.6/1 vớizero/tinydelta. HeldBallLatch riênggeneration, recordround/inputepoch/frame/time/camera/renderworld; acceptedDashinvalidate khôngresetjoystickowner; pointerupđòicurrentround+epoch+generation. Cancel/reset/background/exitinvalidate. Addedfirstflightelapsed vàreleaseframe logs đểtínhballistic(t). GateLead analyze-p2 Noissues/full64testsPASS. Đây làgatemớiLead, khôngworkerre-reviewvàruntimenotrun. APKpre-fix/audit14sourceởtrênkhôngápdụngsourcefixed; cầnbuild/audit15sourcep2mới.
