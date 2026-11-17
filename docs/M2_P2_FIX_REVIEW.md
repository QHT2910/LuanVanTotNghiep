# M2 source QA findings — Lead fixes 17/11/2026

Lead accepted both P2 findings in qa/m2-source.md. No M2 runtime or visual acceptance yet.

P2-01: ShotPoseClock now latches the last sample returned while charging. Release starts at that value and interpolates to recovery key2 using accepted simulation time, instead of seeking straight to1. New q0/.6/1 tests assert sample equality atrelease/zeroDelta and continuity for tinyDelta. Logicalrelease remains immediately onpointerup withlatchedorigin; notdelayeduntilclipmarker. This proves clockcontinuity, not everyjoint/framevisualcontinuity, especially ifrelease precedes firstauthoredposeframe.

P2-02: HeldBallLatch stores round/inputepoch/generation and invalidates byindependentgeneration. AcceptedDash invalidates beforea freshchargecanreuseoldorigin, withoutresettingjoystickowner. Cancel/reset/background/exit alsoinvalidate; pointerup requiresmatchinground+epoch+generation. Newpolicytests cover Dashinvalidation/newchargebeforefreshsample andlate round/epoch. These arepurecontracttests, notruntimeownerfixture.

Addedinstrumentation: sampletime/round/epoch/generation/frame/acceptedDelta/camera/lastRenderBall; firstflightelapsed permitsanalytic(t) comparison. Frame is CPUScene/Flutter submittedpose sample, notGPU-present acknowledgement. release_pose_clock logs before/after time, subjecttoauthoredposeactive caveat above. No assertionfirstflight==origin whent>0.

GatesLead: analyze-p2.txt Noissues; tests-p2.txt64PASS (61prior+3new); build-p2.txt debugx64M2_INSPECT=truePASS; source-apk-audit-p2.json15source/4assetsPASS; install-p2.txtPASS. Folder game/evidence-m2-hand-action. No installedpullidentity/runtimeM2/snapshotM2 yet. Source/asset pre-P2audit/build arehistorical, notfinalcurrentidentity. ExistingM1/HUD/Fox/humanAPKs preserved.

GUI: exactemu20192/window918838 stilloffprimary(435,-931), supportedGUIshortcuts hadunverifiable effect, freshboundsunchanged. Askedusercentering once andhandoffexistingCindysession (send_to_session already-active receipt); LeadwillnotoperateGUIconcurrentlywithCindy. Needfreshcenterwindow andgame-onlyVSCode beforeAVDinput. OriginalusergoalM2implementation+runtime remainspending, notcompleteatthisreview.
