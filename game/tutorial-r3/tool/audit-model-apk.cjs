const fs=require('fs'),crypto=require('crypto'),path=require('path');
const Zip=require('../../../.local-tools/node_modules/jszip');
const app=path.resolve(__dirname,'..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
(async()=>{
 const apk=fs.readFileSync(path.join(app,'build/app/outputs/flutter-apk/app-debug.apk'));
 const zip=await Zip.loadAsync(apk),kernel=await zip.file('assets/flutter_assets/kernel_blob.bin').async('nodebuffer');
 const source=fs.readFileSync(path.join(app,'lib/model_diagnostic.dart'));
 const asset=fs.readFileSync(path.join(app,'assets/Fox.glb'));
 const embeddedAsset=await zip.file('assets/flutter_assets/assets/Fox.glb').async('nodebuffer');
 const abi=Object.keys(zip.files).filter(k=>/^lib\/[^/]+\/libflutter.so$/.test(k));
 const pass=kernel.includes(source)&&asset.equals(embeddedAsset)&&abi.includes('lib/x86_64/libflutter.so');
 console.log(JSON.stringify({pass,scope:'Local debug APK source/asset identity only',apkSHA256:sha(apk),sourceSHA256:sha(source),sourceEmbedded:kernel.includes(source),assetSHA256:sha(asset),assetMatches:asset.equals(embeddedAsset),abi},null,2));
 if(!pass)process.exitCode=1;
})().catch(e=>{console.error(e.message);process.exitCode=1;});
