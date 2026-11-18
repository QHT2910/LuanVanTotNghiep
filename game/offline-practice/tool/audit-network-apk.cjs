const fs=require('fs'),path=require('path'),crypto=require('crypto');
const Zip=require('../../../.local-tools/node_modules/jszip');
const app=path.resolve(__dirname,'..'),root=path.resolve(app,'../..');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
(async()=>{
 const apk=fs.readFileSync(path.join(app,'build/app/outputs/flutter-apk/app-debug.apk'));
 const zip=await Zip.loadAsync(apk),kernel=await zip.file('assets/flutter_assets/kernel_blob.bin').async('nodebuffer');
 const sources={};
 for(const file of ['lib/main.dart','lib/src/network/network_snapshot.dart','lib/src/network/stage2_client.dart','lib/src/presentation/network_stage2_page.dart']){
  const b=fs.readFileSync(path.join(app,file));sources[file]={sha256:hash(b),bytes:b.length,embeddedInKernel:kernel.includes(b)};
 }
 const baseline=fs.readFileSync(path.join(root,'game/evidence-m2-layered/source-apk-audit-wired.json'));
 const expected=JSON.parse(baseline.toString(baseline[0]===255&&baseline[1]===254?'utf16le':'utf8').replace(/^\uFEFF/,'' )).assetAudit;
 const assets={};
 for(const [file,e] of Object.entries(expected)){
  const local=fs.readFileSync(path.join(app,file)),entry=zip.file('assets/flutter_assets/'+file);
  if(!entry)throw Error('Missing preserved asset '+file);
  const bundled=await entry.async('nodebuffer');
  assets[file]={localSHA256:hash(local),bundledSHA256:hash(bundled),expectedSHA256:e.expectedSHA256,
   pass:hash(local)===e.expectedSHA256&&hash(bundled)===e.expectedSHA256};
 }
 const architectures=Object.keys(zip.files).filter(x=>/^lib\/[^/]+\/libflutter.so$/.test(x));
 const pass=Object.values(sources).every(x=>x.embeddedInKernel)&&Object.values(assets).every(x=>x.pass)&&architectures.includes('lib/x86_64/libflutter.so');
 console.log(JSON.stringify({schema:1,pass,apkSHA256:hash(apk),apkBytes:apk.length,sources,assets,architectures,
  buildCommand:'flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=NETWORK_STAGE2=true --dart-define=NETWORK_URL=ws://10.0.2.2:8091/room/stage1',
  runtimeModeVerification:'Pending network_stage2 mode marker and installed pull identity',localKernelMatchesAPK:null,
  limits:['Source inclusion does not prove compile-time mode selected','Preserved assets bundled; not evidence of online human rendering','Not runtime or network/Internet proof']},null,2));
 if(!pass)process.exitCode=1;
})().catch(e=>{console.error(e.message);process.exitCode=1;});
