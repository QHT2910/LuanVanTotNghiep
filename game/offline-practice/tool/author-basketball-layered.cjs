// Mask the verified local CC0 derivative. No changes to the original files/BIN.
const fs=require('fs'),path=require('path'),crypto=require('crypto'),assert=require('assert/strict');
const app=path.resolve(__dirname,'..'),dir=path.resolve(app,'../evidence-m2-layered');
const input=path.join(app,'assets/human-ual-standard/HumanBasketball.glb');
const output=path.join(app,'assets/human-ual-standard/HumanBasketballLayered.glb');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const source=fs.readFileSync(input);
assert.equal(hash(source),'80fdf68bcd037734e035675bb959f9e67db0e073d18a53f398c739298f025f8d');
assert.equal(source.readUInt32LE(0),0x46546c67);assert.equal(source.readUInt32LE(4),2);
assert.equal(source.readUInt32LE(8),source.length);assert.equal(source.readUInt32LE(16),0x4e4f534a);
const oldLength=source.readUInt32LE(12),j=JSON.parse(source.subarray(20,20+oldLength));
const four=['upperarm_l','upperarm_r','lowerarm_l','lowerarm_r'];
const names=['Idle_Loop','Jog_Fwd_Loop','Jump_Start','Jump_Loop','Jump_Land'];
const arm=c=>four.includes(j.nodes[c.target.node].name)&&c.target.path==='rotation';
const report=[];
for(const name of [...names,'Authored_Basketball_v1']){
 const all=j.animations.filter(a=>a.name===name);assert.equal(all.length,1);
 const a=all[0],arms=a.channels.filter(arm),body=a.channels.filter(c=>!arm(c));
 assert.equal(a.channels.length,195);assert.equal(arms.length,4);assert.equal(body.length,191);
 assert.equal(new Set(arms.map(c=>c.target.node)).size,4);
 j.animations.push({name:'Arms_'+name,channels:arms,samplers:a.samplers});
 if(names.includes(name))j.animations.push({name:'Body_'+name,channels:body,samplers:a.samplers});
 report.push({source:name,bodyChannels:names.includes(name)?191:null,armChannels:4});
}
const encoded=Buffer.from(JSON.stringify(j)),padded=Buffer.alloc(Math.ceil(encoded.length/4)*4,32);
encoded.copy(padded);const tail=source.subarray(20+oldLength),header=Buffer.alloc(20);
header.writeUInt32LE(0x46546c67,0);header.writeUInt32LE(2,4);
header.writeUInt32LE(20+padded.length+tail.length,8);header.writeUInt32LE(padded.length,12);
header.writeUInt32LE(0x4e4f534a,16);const result=Buffer.concat([header,padded,tail]);
if(fs.existsSync(output))assert(fs.readFileSync(output).equals(result),'Refusing different existing output');
else fs.writeFileSync(output,result,{flag:'wx'});
const original=JSON.parse(source.subarray(20,20+oldLength));
for(const key of ['nodes','skins','meshes','materials','accessors','bufferViews','buffers'])
 assert.deepEqual(j[key],original[key],key+' changed');
assert(result.subarray(20+padded.length).equals(tail));
assert.equal(hash(fs.readFileSync(input)),hash(source));
fs.mkdirSync(dir,{recursive:true});
fs.writeFileSync(path.join(dir,'asset-mask-manifest.json'),JSON.stringify({schema:1,
 source:'assets/human-ual-standard/HumanBasketball.glb',sourceSHA256:hash(source),
 output:'assets/human-ual-standard/HumanBasketballLayered.glb',outputSHA256:hash(result),
 outputBytes:result.length,toolSHA256:hash(fs.readFileSync(__filename)),masks:report,
 nodesSkinsMeshesMaterialsAccessorsAndBinaryUnchanged:true,
 scope:'Offline mask validation only; not Scene runtime or layered animation acceptance'},null,2)+'\n');
console.log('PASS 5 body masks/6 arm masks, unchanged rig/material/BIN | manifest=game/evidence-m2-layered/asset-mask-manifest.json | runtime NOT RUN');
