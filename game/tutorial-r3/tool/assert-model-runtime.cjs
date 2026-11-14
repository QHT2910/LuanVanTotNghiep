const fs=require('fs'),assert=require('assert/strict'),path=require('path');
const out=path.resolve(__dirname,'../../evidence-model-fox'),events=JSON.parse(fs.readFileSync(path.join(out,'runtime-events.json')));
const pose=events.filter(e=>e.event==='pose_sample'),zero=pose.filter(e=>e.reason==='seek_fraction_0.0'),half=pose.find(e=>e.reason==='seek_fraction_0.5');
const joints=p=>p.jointSamples.map(j=>j.local);
assert.equal(zero.length,2);assert.deepEqual(joints(zero[0]),joints(zero[1]));assert.notDeepEqual(joints(zero[0]),joints(half));
const manual=pose.filter(e=>e.reason==='manual');assert.equal(manual[0].clipTime,manual[1].clipTime);assert.deepEqual(joints(manual[0]),joints(manual[1]));
assert.equal(pose.find(e=>e.reason==='replay').clipTime,0);
const roots=pose.filter(e=>e.reason==='root_transform');assert.notDeepEqual(roots[0].actorLocal,roots[1].actorLocal);assert.deepEqual(joints(roots[0]),joints(roots[1]));
const ranges=JSON.parse(fs.readFileSync(path.join(out,'workflow-ranges.json')));
for(const name of ['lifecycle-paused','lifecycle-playing']){const r=ranges.find(r=>r.name===name),e=events.slice(r.before,r.after),background=e.find(x=>x.event==='before_lifecycle'&&x.next==='inactive'),resume=e.find(x=>x.event==='before_lifecycle'&&x.next==='resumed'),sample=e.find(x=>x.reason==='resume');assert.equal(background.clipTime,resume.clipTime);assert.equal(resume.clipTime,sample.clipTime);assert.equal(sample.playing,name==='lifecycle-playing');}
const metadata=events.find(e=>e.event==='asset_metadata');assert(metadata.clips.some(c=>c.name==='Run'));assert(metadata.runtimeSkinnedNodes.every(s=>s.nullJoints===0));
fs.writeFileSync(path.join(out,'runtime-assertions.json'),JSON.stringify({pass:true,scope:'One AVD debug Fox diagnostic, not gameplay',pose0RepeatMatricesEqual:true,pose50Differs:true,pauseSamplesEqual:true,replayTimeZero:true,rootTransformChangedWithJointLocalPreserved:true,lifecycleFreezeAndIntentResume:true,metadata,limits:['Three sampled joints do not prove every channel binding','No GPU-ready/frame-time benchmark','No per-frame oracle for double advance; source path reviewed','Fox not basketball character']},null,2)+'\n');
console.log('PASS pose/paused matrices/replay/root/lifecycle; runtime-assertions.json');
