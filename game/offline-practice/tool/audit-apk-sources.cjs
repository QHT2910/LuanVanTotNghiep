// Current layout only. Uses the same local ZIP reader as publication tools.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const Zip=require('../../../.local-tools/node_modules/jszip');
const app=path.resolve(__dirname,'..'),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const sources=['lib/main.dart','lib/src/simulation/config.dart','lib/src/simulation/practice.dart','lib/src/input/joystick.dart','lib/src/input/jump_button.dart','lib/src/input/dash_button.dart','lib/src/presentation/practice_page.dart','lib/src/presentation/offline_app.dart','lib/src/presentation/menu_pages.dart','lib/src/presentation/practice_navigation.dart','lib/src/presentation/practice_hud.dart'];
(async()=>{
 sources.push('lib/src/presentation/actor_motion.dart','lib/src/presentation/human_actor.dart');
 sources.push('lib/src/presentation/shot_pose_clock.dart');
 sources.push('lib/src/presentation/held_ball_latch.dart');
 sources.push('lib/src/presentation/charge_pose_gate.dart');
 if(process.argv.length>2)throw Error('No arguments supported; audits current debug APK');
 const apk=fs.readFileSync(path.join(app,'build/app/outputs/flutter-apk/app-debug.apk')),zip=await Zip.loadAsync(apk);
 const key='assets/flutter_assets/kernel_blob.bin';if(!zip.file(key))throw Error('Debug kernel missing');
 const kernel=await zip.file(key).async('nodebuffer'),result={};
 for(const file of sources){const bytes=fs.readFileSync(path.join(app,file));if(!bytes.length)throw Error('Empty source');result[file]={sha256:hash(bytes),bytes:bytes.length,embeddedInAPKKernel:kernel.includes(bytes)};}
 const stale=['lib/config.dart','lib/practice.dart','lib/joystick.dart','lib/jump_button.dart'].filter(f=>fs.existsSync(path.join(app,f)));
 const architectures=Object.keys(zip.files).filter(f=>/^lib\/[^/]+\/libflutter.so$/.test(f));
 const expectedAssets={
  'assets/human-ual-standard/HumanBasketball.glb':'80fdf68bcd037734e035675bb959f9e67db0e073d18a53f398c739298f025f8d',
  'assets/human-ual-standard/HumanDiagnostic.glb':'69591853d817488edaa8fd9bf8fc1d821eaeaf789f8627b3cd23b41c4ed67997',
  'assets/human-ual-standard/License.txt':'6d01f55c6e4c49a2c9963e147e561945ae2c83958c8ca667d90a6bffdbfac061',
  'assets/human-ual-standard/README.txt':'ccd02718886b5a57f10f0a8911a38cfe10c36880e1d6dfa3445923fba32d2a72'};
 const assetAudit={};
 for(const [file,expected] of Object.entries(expectedAssets)){
  const local=fs.readFileSync(path.join(app,file)),entry=zip.file('assets/flutter_assets/'+file);
  if(!entry)throw Error('Missing actor asset: '+file);
  const bundled=await entry.async('nodebuffer');
  assetAudit[file]={bytes:local.length,localSHA256:hash(local),bundledSHA256:hash(bundled),expectedSHA256:expected,pass:hash(local)===expected&&hash(bundled)===expected};
 }
 const pass=Object.values(result).every(x=>x.embeddedInAPKKernel)&&!stale.length&&architectures.includes('lib/x86_64/libflutter.so')&&Object.values(assetAudit).every(x=>x.pass);
 console.log(JSON.stringify({schema:1,scope:'Current source/actor assets versus debug APK; not installed identity/runtime',pass,apkSHA256:hash(apk),apkBytes:apk.length,kernelSHA256:hash(kernel),localKernelMatchesAPK:null,sources:result,assetAudit,staleFlatSources:stale,apkArchitectures:architectures,notProven:['Installed device APK identity','Actor runtime','Performance']},null,2));
 if(!pass)process.exitCode=1;
})().catch(e=>{console.error('FAIL source/APK audit: '+e.message);process.exitCode=1;});
