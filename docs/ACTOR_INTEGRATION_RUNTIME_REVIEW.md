# Offline human actor — runtime Lead review, 16/11/2026

Lead ACCEPT milestone để QA độc lập; chưa fullgame/network hoặc animation ném/nhảy hoàn chỉnh. Base69a1305; source module actor_motion/human_actor + practicepage, asset3file verifiedcopy. Simulation/input/HUD/deps không đổi. Actor wrapperposition/yaw/jump do simulation; clips paused/weightselected1/seekacceptedtime, khôngcộngrootmotion. Ball giữorigin/release cũ, khônghandattach; nhìn còn ởtrênđầu/táchkhỏitay trongảnh. Giới hạn này phải được xửlý trongmốc animation/ballpresentation sau, khôngtựđổi logicalrelease đểche.

## Gate và provenance

- dart analyze trước/sauvisualyawfix | PASS No issues | game/evidence-actor-integration/analyze.txt và analyze-final.txt.
- flutter test --no-pub | PASS55(52cũ+3mới) trướcfixyaw; tests.txt. Saufixyaw chỉconstantvisual, actor_motion_test3PASS actor-tests-final.txt. Không nhận55test chạy mới saumọichỉnhvisual.
- build debugx64 lib/main.dart | PASS | build-final.txt. Initial build.txt làyaw0calibration, khôngbảncuối.
- node tool/audit-apk-sources.cjs | PASS13sources +3assetlocal/bundled/expectedhash/x86_64 | source-apk-audit-final.json. localKernelMatchesAPK=null chưaso. Pythonmanifest13source chỉsource, chưachạyPython/assetgate.
- install | PASS | install-final.txt; launch-final cóthểPackageUpdateActivity, khôngdùngcoldclaim. Helperforegroundcheck + ảnhappthực xácnhận chạy.
- node tool/assert-hud-runtime.cjs actor | PASS gameplay/touchoracle | verified/assert-runtime.txt/runtime-assertions.json.
- node tool/assert-actor-runtime.cjs | PASS asset/state-transition/direction | verified/assert-actor.txt/actor-assertions.json.
- pm path/pull/hash | PASS local=installed=snapshot18dbb700a5f96ef8039d24d65a63e7f13507ace638ccda498242dbc328bdda6b | verified/installed-apk.json. Local ignored demos/releases/actor-integration/offline-human-actor-x64.apk giữHUD/Fox/humanold.

## Runtime đã quan sát

MộtPixel_9a emulator-5554. Initialyaw0 thấy nhânvậtquayngược rổ; sửa chỉvisualoffsetpi, giữsimulationfacing/mapping. Ảnhfinalneutral quayvềrổ; directions worldleft/right/toward/away cóstatefacing(-1,0)/(1,0)/(0,-1)/(0,1), ảnhjogphảnánhđổi hướng. ImportedmodelPBR vàng/tím thấyđược vớiPointLight40, khôngthấymesh nổ trongkhungđãxem. Camera/AA/courtgiữ, nhânvậttronggamelayoutnhỏ; closeupskin bằngchứng từhumanprobe trước, khôngnhậncloseupgame mới.

Gameplayoracle: hai chuỗihai pointer move+shoot/jump+shoot ghi3+3=6; airborneorigin=playerY+1,8/feet0. Dash0,2s/1,6, giữquácooldownkhôngrepeat; boundsclipfrominside3,78. Cancelkhôngném; reset giữ6vềđất; backgroundpause/resumecùngy/simtime, khôngoldshot; chargeexitreturn_menu vàAndroidBackpause, reentryfresh. Chi tiết số thực trongverified/runtime-assertions.json, khônglấygateHUDcũthay bảnactor.

Actorlog3assetloads (entry/reentries), skin65/null0/warnings[]/target65unique, yawpi. State transitionsheldIdle0 hoặcIdle/Jog time=acceptedDeltaởlầnchuyển; allfourfacinglogged. Actorassert khôngoracleperframe cliptime/matrices: tickmanualseek reviewedsource+purepolicytests, khôngclaim mọi advance/GPUskin. Renderclipalwayspaused khôngwallclockadvance theoAPI; skipdelta vàaccepted0khôngresetpose.

GUIreceipt fresh trước/sauruntime xácnhận emulator19376/window722426 x418y283 W1083H515 trênmàn1920x1080. Khôngresize/move/offscreen, chỉADBinput vàoexistingAVD sauCindyhandoff. HUDinputslots/ownership khôngđổi; background/exitgiữcounterepoch. Runtime/ làinitialyaw0calibration, verified/ + *final làbảncuối. verified/hud-resume.png làAndroidtransition, khôngdùngstableapp; hud-background-finished.png làảnhổnđịnh. Directions chạy saufullsequence vàfreshreentry, khôngtrộn vàooracle2shotsrangenumbers.

## Chưa nghiệm thu / next

Không jump/shoot/Dashclips riêng, handattach/ballcontact, modelartpolish/fullFigma3Dscene, fullbinding, pendinginitexit race injection, máy thật/Internet/multiplayer/performance. Unit vàruntime2pointer không3pointer. Chưafullgamecomplete. QAexistingreadonlyreview source/hash/ảnh/events rồiCindyreview; saugate mới mởnetworkminimal hoặcmốcballpresentation theoCindy, khôngtựmởfeature/thesis. Cầnhostrefreshquota trướctaskdài mới; ownaccounts.settingsnot_exposed, inheritedCindy16/11primary0weekly0/reserve5%cảhai. BaWordmodifiedngoàiscopekhôngstage.

## QA terminal

OrcaQA PASSkhôngP1/P2, LeadACCEPTmilestone sauđọcreport source/hash/rawJSON/10ảnh; qa/actor-integration.md. Transitionoracle35states/3loads, khôngperframeGPUclaim. Bàn giaoCindyreview trướcnexttask.
