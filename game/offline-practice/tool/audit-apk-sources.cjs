// Current layout only. Uses the same local ZIP reader as publication tools.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const Zip=require('../../../.local-tools/node_modules/jszip');
const app=path.resolve(__dirname,'..'),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const sources=['lib/main.dart','lib/src/simulation/config.dart','lib/src/simulation/practice.dart','lib/src/input/joystick.dart','lib/src/input/jump_button.dart','lib/src/input/dash_button.dart','lib/src/presentation/practice_page.dart','lib/src/presentation/offline_app.dart','lib/src/presentation/menu_pages.dart','lib/src/presentation/practice_navigation.dart'];
(async()=>{
 if(process.argv.length>2)throw Error('No arguments supported; audits current debug APK');
 const apk=fs.readFileSync(path.join(app,'build/app/outputs/flutter-apk/app-debug.apk')),zip=await Zip.loadAsync(apk);
 const key='assets/flutter_assets/kernel_blob.bin';if(!zip.file(key))throw Error('Debug kernel missing');
 const kernel=await zip.file(key).async('nodebuffer'),result={};
 for(const file of sources){const bytes=fs.readFileSync(path.join(app,file));if(!bytes.length)throw Error('Empty source');result[file]={sha256:hash(bytes),bytes:bytes.length,embeddedInAPKKernel:kernel.includes(bytes)};}
 const stale=['lib/config.dart','lib/practice.dart','lib/joystick.dart','lib/jump_button.dart'].filter(f=>fs.existsSync(path.join(app,f)));
 const architectures=Object.keys(zip.files).filter(f=>/^lib\/[^/]+\/libflutter.so$/.test(f));
 const pass=Object.values(result).every(x=>x.embeddedInAPKKernel)&&!stale.length&&architectures.includes('lib/x86_64/libflutter.so');
 console.log(JSON.stringify({schema:1,scope:'Current refactored source versus current debug APK; not installed identity/runtime',pass,apkSHA256:hash(apk),apkBytes:apk.length,kernelSHA256:hash(kernel),localKernelMatchesAPK:null,sources:result,staleFlatSources:stale,apkArchitectures:architectures,notProven:['Installed device APK identity','Runtime after refactor','Performance']},null,2));
 if(!pass)process.exitCode=1;
})().catch(e=>{console.error('FAIL source/APK audit: '+e.message);process.exitCode=1;});
