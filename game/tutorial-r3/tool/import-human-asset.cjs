const fs=require('fs'),path=require('path'),crypto=require('crypto');
const Zip=require('../../../.local-tools/node_modules/jszip');
const root=path.resolve(__dirname,'../../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
(async()=>{
 const original='C:/Users/quang/Downloads/Universal Animation Library[Standard].zip';
 const bytes=fs.readFileSync(original),zip=await Zip.loadAsync(bytes);
 for(const e of Object.values(zip.files)){
  const name=e.unsafeOriginalName||e.name;
  if(name.includes('\\')||name.startsWith('/')||/^[A-Za-z]:/.test(name)||name.split('/').includes('..'))throw Error('Unsafe ZIP path');
 }
 const prefix='Universal Animation Library[Standard]/';
 const selected={ 'Unreal-Godot/UAL1_Standard.glb':'HumanDiagnostic.glb','License.txt':'License.txt','README.txt':'README.txt'};
 const dest=path.resolve(root,'game/tutorial-r3/assets/human-ual-standard');
 fs.mkdirSync(dest,{recursive:true});const files={};
 for(const [from,to]of Object.entries(selected)){
  const data=await zip.file(prefix+from).async('nodebuffer'),target=path.resolve(dest,to);
  if(!target.startsWith(dest+path.sep))throw Error('Invalid destination');
  if(fs.existsSync(target)){if(!fs.readFileSync(target).equals(data))throw Error('Refusing overwrite');}
  else fs.writeFileSync(target,data,{flag:'wx'});
  files[to]={bytes:data.length,sha256:sha(data)};
 }
 const glb=fs.readFileSync(path.join(dest,'HumanDiagnostic.glb'));
 if(glb.readUInt32LE(0)!==0x46546c67||glb.readUInt32LE(4)!==2||glb.readUInt32LE(8)!==glb.length)throw Error('Invalid GLB');
 const j=JSON.parse(glb.subarray(20,20+glb.readUInt32LE(12)));
 const names=j.nodes.map(n=>n.name),counts={};for(const n of names)counts[n]=(counts[n]||0)+1;
 const clips=j.animations.map(a=>({name:a.name,channels:a.channels.length,targetsUnique:a.channels.every(c=>counts[names[c.target.node]]===1),translationTargets:[...new Set(a.channels.filter(c=>c.target.path==='translation').map(c=>names[c.target.node]))]}));
 for(const name of ['Idle_Loop','Jog_Fwd_Loop'])if(!clips.some(c=>c.name===name&&c.targetsUnique))throw Error('Selected clip missing/ambiguous');
 const result={sourceURL:'https://quaternius.itch.io/universal-animation-library',license:'CC0 1.0, included License.txt',zip:{bytes:bytes.length,sha256:sha(bytes),originalPreserved:true},files,selectedClips:['Idle_Loop','Jog_Fwd_Loop'],rootMotion:'README says non-RM disabled; runtime drift not yet tested',skins:j.skins.map(s=>({jointCount:s.joints.length,jointNames:s.joints.map(i=>names[i])})),materials:j.materials,meshCount:j.meshes.length,images:j.images||[],clips,runtimeValidated:false,limitations:['Basketball shoot clip not present/verified','No Scene binding/render claim until runtime']};
 const out=path.resolve(root,'game/evidence-model-human');fs.mkdirSync(out,{recursive:true});fs.writeFileSync(path.join(out,'asset-manifest.json'),JSON.stringify(result,null,2)+'\n');
 console.log('PASS safe selected extraction/license/GLB clip-name preflight; asset-manifest.json');
})().catch(e=>{console.error(e.message);process.exitCode=1;});
