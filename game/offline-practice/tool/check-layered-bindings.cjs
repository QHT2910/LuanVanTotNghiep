// Offline channel/name validation only. This does not import or render a model.
const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const app=path.resolve(__dirname,'..');
function read(file){const b=fs.readFileSync(path.join(app,'assets/human-ual-standard',file));
 assert.equal(b.readUInt32LE(0),0x46546c67);assert.equal(b.readUInt32LE(4),2);
 assert.equal(b.readUInt32LE(8),b.length);assert.equal(b.readUInt32LE(16),0x4e4f534a);
 return JSON.parse(b.subarray(20,20+b.readUInt32LE(12)));}
const original=read('HumanBasketball.glb'),j=read('HumanBasketballLayered.glb');
const joints=j.skins[0].joints,names=joints.map(i=>j.nodes[i].name);
assert.equal(j.skins.length,1);assert.equal(joints.length,65);assert.equal(new Set(names).size,65);
const index=new Set(joints),four=new Set(['upperarm_l','upperarm_r','lowerarm_l','lowerarm_r']);
const arm=c=>four.has(j.nodes[c.target.node].name)&&c.target.path==='rotation';
const keys=channels=>channels.map(c=>j.nodes[c.target.node].name+':'+c.target.path);
function uniqueClip(name){const a=j.animations.filter(a=>a.name===name);assert.equal(a.length,1,name);return a[0];}
const rows=[];
for(const name of ['Idle_Loop','Jog_Fwd_Loop','Jump_Start','Jump_Loop','Jump_Land','Authored_Basketball_v1']){
 const base=original.animations.find(a=>a.name===name),arms=uniqueClip('Arms_'+name);
 assert.equal(new Set(keys(base.channels)).size,195,name+' duplicate original property');
 assert.equal(new Set(base.channels.map(c=>c.target.node)).size,65);
 assert(base.channels.every(c=>index.has(c.target.node)),name+' target outside skin');
 assert.deepEqual(arms.channels,base.channels.filter(arm));assert.equal(arms.channels.length,4);
 assert.equal(new Set(keys(arms.channels)).size,4);
 for(const a of [arms,...(name==='Authored_Basketball_v1'?[]:[uniqueClip('Body_'+name)])]){
  for(const c of a.channels){
   assert(c.sampler>=0&&c.sampler<a.samplers.length);
   const s=a.samplers[c.sampler],input=j.accessors[s.input],output=j.accessors[s.output];
   assert(input&&output);assert.equal(input.type,'SCALAR');
   assert.equal(output.type,c.target.path==='rotation'?'VEC4':'VEC3');
  }
 }
 if(name!=='Authored_Basketball_v1'){
  const body=uniqueClip('Body_'+name);assert.equal(body.channels.length,191);
  assert.deepEqual(body.channels,base.channels.filter(c=>!arm(c)));
  assert.deepEqual(new Set([...keys(body.channels),...keys(arms.channels)]),new Set(keys(base.channels)));
  assert(!body.channels.some(arm));
 }
 rows.push({name,skinTargets:65,uniqueOriginalProperties:195,arms:4,
  body:name==='Authored_Basketball_v1'?null:191,complementExact:true});
}
console.log(JSON.stringify({pass:true,scope:'Offline raw GLB name/channel/sampler validation, not imported Scene binding',
 skinJoints:65,uniqueNames:65,rows},null,2));
