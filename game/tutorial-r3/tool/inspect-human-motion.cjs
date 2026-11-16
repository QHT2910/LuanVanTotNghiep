const fs=require('fs'),path=require('path');
const app=path.resolve(__dirname,'..'),b=fs.readFileSync(path.join(app,'assets/human-ual-standard/HumanDiagnostic.glb'));
const len=b.readUInt32LE(12),j=JSON.parse(b.subarray(20,20+len)),binStart=20+len+8;
const results=[];
for(const a of j.animations.filter(a=>['Idle_Loop','Jog_Fwd_Loop'].includes(a.name)))for(const c of a.channels){
 const name=j.nodes[c.target.node].name;
 if(c.target.path!=='translation'||!['root','pelvis'].includes(name))continue;
 const ac=j.accessors[a.samplers[c.sampler].output],bv=j.bufferViews[ac.bufferView];
 if(ac.componentType!==5126||ac.type!=='VEC3'||ac.sparse||bv.buffer!==0)throw Error('Unsupported motion accessor');
 const start=binStart+(bv.byteOffset||0)+(ac.byteOffset||0),stride=bv.byteStride||12;
 const min=[Infinity,Infinity,Infinity],max=[-Infinity,-Infinity,-Infinity];
 for(let i=0;i<ac.count;i++)for(let k=0;k<3;k++){const n=b.readFloatLE(start+i*stride+k*4);min[k]=Math.min(min[k],n);max[k]=Math.max(max[k],n);}
 results.push({clip:a.name,node:name,samples:ac.count,min,max,range:max.map((n,k)=>n-min[k])});
}
const rootStable=results.filter(r=>r.node==='root').every(r=>r.range.every(n=>n<1e-6));
const result={scope:'Raw GLB local translation sampler bounds; not every joint/world trajectory',rootStable,results};
fs.writeFileSync(path.resolve(app,'../evidence-model-human/root-motion.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
